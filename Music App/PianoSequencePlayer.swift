//
//  PianoSequencePlayer.swift
//  Music App
//
//  Created by Nathan Davis on 1/4/26.
//

import Foundation
import AVFoundation
import AudioToolbox

final class PianoSequencePlayer {
    static let shared = PianoSequencePlayer()

    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()
    private var isSetup = false

    private lazy var sequencer: AVAudioSequencer = AVAudioSequencer(audioEngine: engine)

    // Dedicated queue for scheduling note on/off. Helps prevent very short notes from being delayed
    // or coalesced on the main thread.
    private let schedulingQueue = DispatchQueue(label: "PianoSequencePlayer.scheduling", qos: .userInitiated)

    // Token used to invalidate any pending scheduled callbacks from a previous playback.
    private var playbackToken = UUID()

    private func setupIfNeeded() {
        guard !isSetup else { return }

        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)

        do {
            try engine.start()
        } catch {
            print("AVAudioEngine failed to start: \(error)")
        }

        // Load the default SoundFont: prefer user-imported default, fall back to bundle.
        if let sf2URL = SoundFontStore.shared.defaultSoundFontURL {
            do {
                try sampler.loadSoundBankInstrument(
                    at: sf2URL,
                    program: 0, // Acoustic Grand Piano
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: 0
                )
            } catch {
                print("Failed to load SoundFont: \(error)")
            }
        } else {
            print("No .sf2 found. Add a SoundFont to the app or import one.")
        }

        isSetup = true
        // Prime sequencer
        _ = sequencer
    }

    /// Load (or swap) the SoundFont used by the sampler. Safe to call at any time after setup.
    func loadSoundFont(url: URL) {
        setupIfNeeded()
        do {
            try sampler.loadSoundBankInstrument(
                at: url,
                program: 0,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: 0
            )
        } catch {
            print("Failed to load SoundFont \(url.lastPathComponent): \(error)")
        }
    }

    func play(notes: [UInt8], tempoBPM: Double) {
        setupIfNeeded()
        let token = UUID()
        schedulingQueue.sync { self.playbackToken = token }
        // AVAudioUnitSampler doesn't expose stopAllVoices on all OS versions.
        // Send an "all notes off" equivalent by stopping the full MIDI note range.
        for note: UInt8 in 0...127 {
            sampler.stopNote(note, onChannel: 0)
        }

        let secondsPerBeat = max(0.05, 60.0 / max(1.0, tempoBPM))

        for (i, n) in notes.enumerated() {
            let startDelay = secondsPerBeat * Double(i)
            let stopDelay = startDelay + (secondsPerBeat * 0.9)

            schedulingQueue.asyncAfter(deadline: .now() + startDelay) { [weak self] in
                guard let self else { return }
                guard self.playbackToken == token else { return }
                // Retrigger-safe: prevent a pending stop for the same MIDI note from killing the new note.
                self.sampler.stopNote(n, onChannel: 0)
                self.sampler.startNote(n, withVelocity: 100, onChannel: 0)
            }

            schedulingQueue.asyncAfter(deadline: .now() + stopDelay) { [weak self] in
                guard let self else { return }
                guard self.playbackToken == token else { return }
                self.sampler.stopNote(n, onChannel: 0)
            }
        }
    }
    
    func playChordBatches(chords: [[UInt8]], tempoBPM: Double) {
        setupIfNeeded()
        let token = UUID()
        schedulingQueue.sync { self.playbackToken = token }

        // "All notes off" safety
        for note: UInt8 in 0...127 {
            sampler.stopNote(note, onChannel: 0)
        }

        let secondsPerBeat = max(0.05, 60.0 / max(1.0, tempoBPM))

        for (i, chord) in chords.enumerated() {
            let startDelay = secondsPerBeat * Double(i)
            let stopDelay = startDelay + (secondsPerBeat * 0.9)

            schedulingQueue.asyncAfter(deadline: .now() + startDelay) { [weak self] in
                guard let self else { return }
                guard self.playbackToken == token else { return }
                for n in chord {
                    // Retrigger-safe for repeated chord tones.
                    self.sampler.stopNote(n, onChannel: 0)
                    self.sampler.startNote(n, withVelocity: 90, onChannel: 0)
                }
            }

            schedulingQueue.asyncAfter(deadline: .now() + stopDelay) { [weak self] in
                guard let self else { return }
                guard self.playbackToken == token else { return }
                for n in chord {
                    self.sampler.stopNote(n, onChannel: 0)
                }
            }
        }
    }
}

extension PianoSequencePlayer {
    struct NoteEvent {
        let note: UInt8
        let startBeat: Double        // when to start, in beats from phrase start
        let durationBeats: Double    // how long to hold, in beats
        let velocity: UInt8

        init(note: UInt8, startBeat: Double, durationBeats: Double, velocity: UInt8 = 100) {
            self.note = note
            self.startBeat = startBeat
            self.durationBeats = durationBeats
            self.velocity = velocity
        }
    }

    /// Play a phrase with independent timing and durations per note.
    /// Uses AVAudioSequencer/MusicSequence for precise scheduling.
    func playMelody(events: [NoteEvent], tempoBPM: Double) {
        setupIfNeeded()

        // Invalidate any pending scheduled callbacks from older playbacks.
        let token = UUID()
        schedulingQueue.sync { self.playbackToken = token }

        // Stop anything currently sounding.
        sequencer.stop()
        for note: UInt8 in 0...127 {
            sampler.stopNote(note, onChannel: 0)
        }

        // Build a fresh MusicSequence each time.
        var sequence: MusicSequence?
        NewMusicSequence(&sequence)
        guard let seq = sequence else { return }

        // Tempo track
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(seq, &tempoTrack)
        if let tempoTrack {
            // Clear existing events, then set tempo at time 0.
            MusicTrackClear(tempoTrack, 0, MusicTimeStamp.greatestFiniteMagnitude)
            MusicTrackNewExtendedTempoEvent(tempoTrack, 0, tempoBPM)
        }

        // Note track
        var noteTrack: MusicTrack?
        MusicSequenceNewTrack(seq, &noteTrack)
        guard let track = noteTrack else { return }
        MusicTrackClear(track, 0, MusicTimeStamp.greatestFiniteMagnitude)

        // Sort by startBeat to ensure deterministic order.
        let sorted = events.sorted { $0.startBeat < $1.startBeat }

        // Add notes. MusicTimeStamp uses beats when the sequencer is running.
        for e in sorted {
            let start = MusicTimeStamp(max(0.0, e.startBeat))
            let durBeats = max(0.01, e.durationBeats)

            var msg = MIDINoteMessage(
                channel: 0,
                note: e.note,
                velocity: e.velocity,
                releaseVelocity: 0,
                duration: Float32(durBeats)
            )

            MusicTrackNewMIDINoteEvent(track, start, &msg)
        }

        // Load into AVAudioSequencer by writing a temporary Standard MIDI File.
        // AVAudioSequencer does not expose a public `musicSequence` setter on all platforms.
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("phrase.mid")

        // Remove old file if it exists
        try? FileManager.default.removeItem(at: tmpURL)

        let status = MusicSequenceFileCreate(
            seq,
            tmpURL as CFURL,
            .midiType,
            MusicSequenceFileFlags.eraseFile,
            480
        )

        if status != noErr {
            print("Failed to write MIDI file: \(status)")
            return
        }

        do {
            // Stop any existing playback and load the new MIDI file
            sequencer.stop()
            try sequencer.load(from: tmpURL, options: [])
        } catch {
            print("Failed to load MIDI into sequencer: \(error)")
            return
        }

        do {
            sequencer.currentPositionInBeats = 0
            try sequencer.start()
        } catch {
            print("Sequencer failed to start: \(error)")
        }
    }

    /// Play using the phrase's own tempo.
    func play(phrase: MusicalPhrase, startingNote: UInt8) {
        let events = phrase.makeNoteEvents(startingNote: startingNote)
        playMelody(events: events, tempoBPM: phrase.tempoBPM)
    }

    /// Play using an explicit tempo override.
    func play(phrase: MusicalPhrase, startingNote: UInt8, tempoBPM: Double) {
        let events = phrase.makeNoteEvents(startingNote: startingNote)
        playMelody(events: events, tempoBPM: tempoBPM)
    }
}

struct MusicalPhrase {
    enum Mode {
        case major
        case minor
    }

    /// Major by default.
    /// Tempo for the phrase in BPM (default = 120).
    let tempoBPM: Double
    /// One step in a phrase expressed as scale degree numbers (1...7) plus optional octave shift.
    struct Step {
        enum Accidental {
            case flat
            case natural
            case sharp
        }

        /// Scale degree: 1 = tonic, 2 = supertonic, ... 7 = leading tone.
        let degree: Int
        /// Optional accidental applied to the scale degree.
        let accidental: Accidental
        /// Octave offset relative to the starting note's octave (0 = same octave).
        let octave: Int
        /// Duration in beats (default quarter note = 1.0 beat).
        let durationBeats: Double
        /// MIDI velocity (0...127).
        let velocity: UInt8

        init(
            degree: Int,
            accidental: Accidental = .natural,
            octave: Int = 0,
            durationBeats: Double = 0.5,
            velocity: UInt8 = 100
        ) {
            self.degree = degree
            self.accidental = accidental
            self.octave = octave
            self.durationBeats = durationBeats
            self.velocity = velocity
        }
    }

    /// Steps of the phrase in order.
    let mode: Mode
    let steps: [Step]

    init(mode: Mode = .major, tempoBPM: Double = 120, steps: [Step]) {
        self.mode = mode
        self.tempoBPM = tempoBPM
        self.steps = steps
    }

    /// Convert scale-degree phrase steps into NoteEvents using a given starting note (tonic).
    /// - Parameter startingNote: MIDI note number for scale degree 1 (tonic).
    /// - Returns: An array of NoteEvents with automatically computed startBeat based on durations.
    func makeNoteEvents(startingNote: UInt8) -> [PianoSequencePlayer.NoteEvent] {
        // Semitone offsets for degrees 1...7.
        let majorOffsets = [0, 2, 4, 5, 7, 9, 11]
        let minorOffsets = [0, 2, 3, 5, 7, 8, 10] // natural minor
        let offsets = (mode == .major) ? majorOffsets : minorOffsets

        var events: [PianoSequencePlayer.NoteEvent] = []
        var currentBeat: Double = 0.0

        for s in steps {
            // Clamp degree into 1...7 to avoid crashes; you can tighten this later if you prefer.
            let d = min(7, max(1, s.degree))

            let accidentalOffset: Int
            switch s.accidental {
            case .flat: accidentalOffset = -1
            case .natural: accidentalOffset = 0
            case .sharp: accidentalOffset = 1
            }

            let semitoneOffset = offsets[d - 1] + accidentalOffset + (12 * s.octave)

            // Safely add without under/overflowing UInt8.
            let midiValue = Int(startingNote) + semitoneOffset
            let clampedMidi = UInt8(min(127, max(0, midiValue)))

            let duration = max(0.01, s.durationBeats)
            // Use a slight gate so repeated notes at exact boundaries (same pitch)
            // retrigger reliably instead of being canceled by coincident note-off events.
            let gatedDuration = min(duration, max(0.01, duration * 0.9))
            events.append(
                .init(note: clampedMidi, startBeat: currentBeat, durationBeats: gatedDuration, velocity: s.velocity)
            )

            currentBeat += duration
        }

        return events
    }
}

struct MelodyCollection {
    static let phrases: [MusicalPhrase] = [
        // Musical phrase has mode, tempoBPM, steps
        // Steps have degree, accidental, octave, durationBeats
        // Valse Op 69 No 2
        MusicalPhrase(
            mode: .minor,
            tempoBPM: 152,
            steps: [
                .init(degree: 5, durationBeats: 1.5),
                .init(degree: 6),
                .init(degree: 5),
                .init(degree: 2),
                .init(degree: 3),
                .init(degree: 1),
                .init(degree: 7, accidental: .sharp, octave: -1, durationBeats: 2),
                .init(degree: 5, durationBeats: 1.5)
            ]
        ),
        
        // Arabesque
        MusicalPhrase(tempoBPM: 80, steps: [
            .init(degree: 6, octave: -1, durationBeats: 1.0/3.0),
            .init(degree: 1, durationBeats: 1.0/3.0),
            .init(degree: 4, durationBeats: 1.0/3.0),
            .init(degree: 6, durationBeats: 1.0/3.0),
            .init(degree: 1, octave: 1, durationBeats: 1.0/3.0),
            .init(degree: 2, octave: 1, durationBeats: 1.0/3.0),
            .init(degree: 3, octave: 1, durationBeats: 1.0/3.0),
            .init(degree: 7, durationBeats: 1.0/3.0),
            .init(degree: 5, durationBeats: 1.0/3.0),
            .init(degree: 3, durationBeats: 1.0/3.0),
            .init(degree: 7, octave: -1, durationBeats: 1.0/3.0),
            .init(degree: 5, octave: -1, durationBeats: 1.0/3.0)
        ]),
        MusicalPhrase(tempoBPM: 80, steps: [
            .init(degree: 4, octave: -1, durationBeats: 1.0/3.0),
            .init(degree: 6, octave: -1, durationBeats: 1.0/3.0),
            .init(degree: 2, durationBeats: 1.0/3.0),
            .init(degree: 4, durationBeats: 1.0/3.0),
            .init(degree: 6, durationBeats: 1.0/3.0),
            .init(degree: 7, durationBeats: 1.0/3.0),
            .init(degree: 1, octave: 1, durationBeats: 1.0/3.0),
            .init(degree: 5, durationBeats: 1.0/3.0),
            .init(degree: 3, durationBeats: 1.0/3.0),
            .init(degree: 1, durationBeats: 1.0/3.0),
            .init(degree: 5, octave: -1, durationBeats: 1.0/3.0),
            .init(degree: 3, octave: -1, durationBeats: 1.0/3.0)
        ]),
        MusicalPhrase(tempoBPM: 80, steps: [
            .init(degree: 1, octave: 1, durationBeats: 1.0/3.0),
            .init(degree: 2, octave: 1, durationBeats: 1.0/3.0),
            .init(degree: 6, durationBeats: 1.0/3.0),
            .init(degree: 1, octave: 1, durationBeats: 1.0/3.0),
            .init(degree: 5, durationBeats: 1.0/3.0),
            .init(degree: 6, durationBeats: 1.0/3.0),
            .init(degree: 3, durationBeats: 1.0/3.0),
            .init(degree: 5, durationBeats: 1.0/3.0),
            .init(degree: 2, durationBeats: 1.0/3.0),
            .init(degree: 3, durationBeats: 1.0/3.0),
            .init(degree: 1, durationBeats: 1.0/3.0),
            .init(degree: 3, durationBeats: 1.0/3.0),
            .init(degree: 7, octave: -1, durationBeats: 2),
            .init(degree: 6, octave: -1, durationBeats: 1)
        ]),

        // Greensleeves 5
        MusicalPhrase(mode: .minor, tempoBPM: 92, steps: [
            .init(degree: 1),
            .init(degree: 3),
            .init(degree: 4),
            .init(degree: 5),
            .init(degree: 6, durationBeats: 1.5),
            .init(degree: 5),
            .init(degree: 4),
            .init(degree: 2, durationBeats: 2)
        ]),

        // Scarborough Fair 6
        MusicalPhrase(mode: .minor, tempoBPM: 88, steps: [
            .init(degree: 5),
            .init(degree: 1, octave: 1),
            .init(degree: 1, octave: 1),
            .init(degree: 7),
            .init(degree: 6),
            .init(degree: 5, durationBeats: 2)
        ]),

        // Frère Jacques 7
        MusicalPhrase(tempoBPM: 108, steps: [
            .init(degree: 1),
            .init(degree: 2),
            .init(degree: 3),
            .init(degree: 1),
            .init(degree: 1),
            .init(degree: 2),
            .init(degree: 3),
            .init(degree: 1)
        ]),

        // Ode to Joy 8
        MusicalPhrase(tempoBPM: 110, steps: [
            .init(degree: 3),
            .init(degree: 3),
            .init(degree: 4),
            .init(degree: 5),
            .init(degree: 5),
            .init(degree: 4),
            .init(degree: 3),
            .init(degree: 2)
        ]),

        // Aura Lee 9
        MusicalPhrase(tempoBPM: 82, steps: [
            .init(degree: 1),
            .init(degree: 3),
            .init(degree: 5),
            .init(degree: 6, durationBeats: 2),
            .init(degree: 5),
            .init(degree: 3),
            .init(degree: 1, durationBeats: 2)
        ]),
    ]
}
