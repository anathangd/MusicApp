//
//  CustomInstrumentTrainerView.swift
//  Music App
//
//  Created by Nathan Davis on 5/10/26.
//

import SwiftUI
import AudioToolbox

struct CustomInstrumentTrainerView: View {
    let instrument: CustomInstrumentDefinition
    @State private var notes: [UInt8] = [60, 64, 67]
    @State private var rootNoteLetter = "C"
    @State private var rootNote: UInt8 = 60
    @State private var counter = 0
    @State private var howMany = 2
    @State private var answer = ["Major third", "minor third"]
    @State private var diatonicAnswerString = "1, 3, 5"
    @State private var tempo = 150.0
    @State private var diatonic = false
    @State private var individual = false
    @State private var interval = "Major third"
    @State private var prompt = "Ascending Major third"

    private var low: UInt8 {
        UInt8(max(21, min(108, instrument.lowestNote)))
    }

    private var high: UInt8 {
        UInt8(max(21, min(108, instrument.highestNote)))
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Toggle("", isOn: $diatonic)
                        Toggle("", isOn: $individual)
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }

            VStack {
                Text(instrument.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Score: " + String(counter))
                    .font(.system(size: 30))
                    .padding(.top, 4)
                Text("Root Note:")
                    .font(.system(size: 30))
                Text(rootNoteLetter)
                    .font(.system(size: 80))

                Button("Play Sequence") {
                    playSequence()
                }
                .foregroundStyle(.black)
                .padding()
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                HStack {
                    Button("First") {
                        playFirst()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .foregroundStyle(.black)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button("Second") {
                        playSecond()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .foregroundStyle(.black)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button("next") {
                    next()
                }
                .padding()
            }

            VStack {
                Spacer()
                Slider(value: $tempo, in: 40...200, step: 1)
                    .padding()
                Text(diatonic ? diatonicAnswerString : String(answer[0]) + (howMany != 1 ? ", " + answer[1] : ""))
                    .font(.caption)
            }

            if individual && !diatonic {
                Rectangle()
                    .foregroundStyle(Color(.systemBackground))
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Spacer()
                        Toggle("", isOn: $individual)
                            .padding(.horizontal)
                    }
                    Spacer()
                }

                VStack {
                    Text("Score: " + String(counter))
                        .font(.system(size: 30))
                        .padding()
                    Text(prompt)
                        .font(.system(size: 30))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text(rootNoteLetter)
                        .font(.system(size: 80))

                    Button("Play Answer") {
                        playFirst()
                    }
                    .foregroundStyle(.black)
                    .padding()
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button("next") {
                        next()
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            next()
            counter = 0
        }
    }

    private func next() {
        notes.removeAll()
        guard high > low else {
            notes = [60, 62, 64]
            rootNote = 60
            rootNoteLetter = noteLetter(for: rootNote)
            return
        }

        rootNote = UInt8(Int.random(in: Int(low)...Int(high)))
        rootNoteLetter = noteLetter(for: rootNote)
        notes.append(rootNote)
        counter += 1

        if diatonic {
            makeDiatonicPhrase()
            return
        }

        if individual {
            if let step = pickNextStep(from: rootNote, low: low, high: high) {
                notes = [rootNote, step.note]
                interval = intervalName(semitones: step.distance)
                prompt = (step.isAscending ? "Ascending " : "Descending ") + interval
            } else {
                prompt = "No interval available in this range"
                notes = [rootNote]
            }
            playRoot()
            return
        }

        var previousNote = rootNote
        for decision in 0..<howMany {
            guard let step = pickNextStep(from: previousNote, low: low, high: high) else {
                break
            }
            notes.append(step.note)
            answer[decision] = intervalName(semitones: step.distance)
            previousNote = step.note
        }

        if notes.count < 3 {
            while notes.count < 3 {
                notes.append(notes.last ?? rootNote)
            }
        }

        playSequence()
    }

    private func makeDiatonicPhrase() {
        guard Int(high) - Int(low) >= 12 else {
            diatonicAnswerString = "Needs at least an octave range"
            prompt = diatonicAnswerString
            playRoot()
            return
        }

        let scaleType = Int.random(in: 1...3)
        let secondDegree = Int.random(in: 2...4)
        let thirdDegree = Int.random(in: secondDegree + 1...8)

        diatonicAnswerString = "1, \(secondDegree), \(thirdDegree)"
        notes = [rootNote]
        notes.append(scaleNote(for: secondDegree, scaleType: scaleType))
        notes.append(scaleNote(for: thirdDegree, scaleType: scaleType))
        playSequence()
    }

    private func scaleNote(for degree: Int, scaleType: Int) -> UInt8 {
        let offset: UInt8
        switch scaleType {
        case 1:
            switch degree {
            case 1: offset = 0
            case 2: offset = 2
            case 3: offset = 4
            case 4: offset = 5
            case 5: offset = 7
            case 6: offset = 9
            case 7: offset = 11
            case 8: offset = 12
            default: offset = 0
            }
        case 2:
            switch degree {
            case 1: offset = 0
            case 2: offset = 2
            case 3: offset = 3
            case 4: offset = 5
            case 5: offset = 7
            case 6: offset = 8
            case 7: offset = 10
            case 8: offset = 12
            default: offset = 0
            }
        default:
            switch degree {
            case 1: offset = 0
            case 2: offset = 2
            case 3: offset = 3
            case 4: offset = 5
            case 5: offset = 7
            case 6: offset = 8
            case 7: offset = 11
            case 8: offset = 12
            default: offset = 0
            }
        }

        return rootNote + offset
    }

    private func pickNextStep(from note: UInt8, low: UInt8, high: UInt8) -> (note: UInt8, isAscending: Bool, distance: Int)? {
        let descendingMax = Int(note) - Int(low)
        let ascendingMax = Int(high) - Int(note)
        var directions: [Bool] = []

        if descendingMax > 0 {
            directions.append(false)
        }
        if ascendingMax > 0 {
            directions.append(true)
        }
        guard let isAscending = directions.randomElement() else {
            return nil
        }

        let maxDistance = min(12, isAscending ? ascendingMax : descendingMax)
        guard maxDistance >= 1 else {
            return nil
        }

        let distance = Int.random(in: 1...maxDistance)
        let next = isAscending ? note + UInt8(distance) : note - UInt8(distance)
        return (next, isAscending, distance)
    }

    private func intervalName(semitones: Int) -> String {
        switch semitones {
        case 1: return "minor second"
        case 2: return "Major second"
        case 3: return "minor third"
        case 4: return "Major third"
        case 5: return "Perfect fourth"
        case 6: return "tritone"
        case 7: return "Perfect fifth"
        case 8: return "minor sixth"
        case 9: return "Major sixth"
        case 10: return "minor seventh"
        case 11: return "Major seventh"
        case 12: return "Perfect octave"
        default: return "not found"
        }
    }

    private func noteLetter(for note: UInt8) -> String {
        switch note % 12 {
        case 0: return "C"
        case 1: return "D♭"
        case 2: return "D"
        case 3: return "E♭"
        case 4: return "E"
        case 5: return "F"
        case 6: return "G♭"
        case 7: return "G"
        case 8: return "A♭"
        case 9: return "A"
        case 10: return "B♭"
        case 11: return "B"
        default: return "Not Found"
        }
    }

    private func playSequence() {
        playNotes(at: Array(notes.indices))
    }

    private func playRoot() {
        playNotes(at: [0])
    }

    private func playFirst() {
        playNotes(at: [0, 1])
    }

    private func playSecond() {
        playNotes(at: [1, 2])
    }

    private func playNotes(at indices: [Int]) {
        var sequence: MusicSequence? = nil
        _ = NewMusicSequence(&sequence)
        var track: MusicTrack? = nil

        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        }
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo")
        }

        _ = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        for index in indices where notes.indices.contains(index) {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track else {
                continue
            }
            _ = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }

        var musicPlayer: MusicPlayer? = nil
        _ = NewMusicPlayer(&musicPlayer)
        _ = MusicPlayerSetSequence(musicPlayer!, sequence)
        _ = MusicPlayerStart(musicPlayer!)
    }
}

#Preview {
    CustomInstrumentTrainerView(
        instrument: CustomInstrumentDefinition(
            name: "C4-C5 Preview",
            lowestNote: 60,
            highestNote: 72
        )
    )
}
