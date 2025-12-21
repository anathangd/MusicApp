//
//  IndividualIntervalView.swift
//  Music App
//
//  Created by Nathan Davis on 8/21/25.
//

import SwiftUI
import AVFoundation

final class PianoSequencePlayer {
    static let shared = PianoSequencePlayer()

    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()
    private var isSetup = false

    private func setupIfNeeded() {
        guard !isSetup else { return }

        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)

        do {
            try engine.start()
        } catch {
            print("AVAudioEngine failed to start: \(error)")
        }

        // Try to load ANY .sf2 SoundFont bundled with the app.
        // Put your Korg .sf2 into the app target (Target Membership checked).
        if let sf2URL = Bundle.main.urls(forResourcesWithExtension: "sf2", subdirectory: nil)?.first {
            do {
                try sampler.loadSoundBankInstrument(
                    at: sf2URL,
                    program: 0, // Acoustic Grand Piano
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: 0
                )
                print("Loaded SoundFont: \(sf2URL.lastPathComponent)")
            } catch {
                print("Failed to load SoundFont: \(error)")
            }
        } else {
            print("No .sf2 found in app bundle. Add the SoundFont to the target.")
        }

        isSetup = true
    }

    func play(notes: [UInt8], tempoBPM: Double) {
        setupIfNeeded()
        // AVAudioUnitSampler doesn't expose stopAllVoices on all OS versions.
        // Send an "all notes off" equivalent by stopping the full MIDI note range.
        for note: UInt8 in 0...127 {
            sampler.stopNote(note, onChannel: 0)
        }

        let secondsPerBeat = max(0.05, 60.0 / max(1.0, tempoBPM))

        for (i, n) in notes.enumerated() {
            let startDelay = secondsPerBeat * Double(i)
            let stopDelay = startDelay + (secondsPerBeat * 0.9)

            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) { [weak self] in
                self?.sampler.startNote(n, withVelocity: 100, onChannel: 0)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + stopDelay) { [weak self] in
                self?.sampler.stopNote(n, onChannel: 0)
            }
        }
    }
    
    func playChordBatches(chords: [[UInt8]], tempoBPM: Double) {
        setupIfNeeded()

        // "All notes off" safety
        for note: UInt8 in 0...127 {
            sampler.stopNote(note, onChannel: 0)
        }

        let secondsPerBeat = max(0.05, 60.0 / max(1.0, tempoBPM))

        for (i, chord) in chords.enumerated() {
            let startDelay = secondsPerBeat * Double(i)
            let stopDelay = startDelay + (secondsPerBeat * 0.9)

            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) { [weak self] in
                guard let self else { return }
                for n in chord {
                    self.sampler.startNote(n, withVelocity: 90, onChannel: 0)
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + stopDelay) { [weak self] in
                guard let self else { return }
                for n in chord {
                    self.sampler.stopNote(n, onChannel: 0)
                }
            }
        }
    }
}

struct IndividualIntervalView: View {
    
    @State var notes: [UInt8] = [71,69,62,72,71,69,67]
    @State var incorrect: [[UInt8]] = [[70,71,72], [70,71,72], [70,71,72]]
    @State var incorrectAnswers = ["1, 7, 5", "1, 7, 5", "1, 7, 5"]
    @State var practice = false
    @State var practiceDone = false
    @State var rootNoteLetter = "G"
    @State var rootNote: UInt8 = 72
    @State var nextNote: UInt8 = 72
    @State var counter = 0
    @State var howMany = 1  //one extra note after the root, loop starts at 0
    @State var answer = ["Perfect fifth", "minor third", "Major second"]
    @State var atonalAnswerString = "Perfect fifth, minor third"
    @State var tempo = UserDefaults.standard.double(forKey: "tempo")//150.0
    @State var correct = 0
    @State var percentage = ""
    @State var isEditing = false
    @State private var settings = false
    @State private var lowest: Int = {
        let saved = UserDefaults.standard.integer(forKey: "lowest")
        return saved == 0 ? 46 : saved
    }()
    @State private var absoluteLowest = 40
    @State private var highest: Int = {
        let saved = UserDefaults.standard.integer(forKey: "highest")
        return saved == 0 ? 84 : saved
    }()
    @State private var absoluteHighest = 84
    @State private var showAnswer = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.white)
                .ignoresSafeArea()
                .onTapGesture {
                    showAnswer = true
                }
            // settings button
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        if !practice {
                            Button {
                                settings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                            .font(.title)
                            .foregroundStyle(.gray)
                            .padding(.trailing, 0)
                            .padding(.bottom, 2)
                        }
                        Text(practice ? "" : percentage)
                            .frame(width: 57)
                        if incorrect.count != 0 {
                            Button {
                                practice = true
                                nextPractice()
                            } label: {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 20))
                                    .padding(5)
                                    .background(.gray.opacity(0.3), in: Circle())
                                    .foregroundStyle(practice ? Color.blue : Color.black)
                            }
                            if !practice {
                                Text(String(incorrect.count))
                                    .font(.caption)
                            }
                        }
                    } // practice incorrect button
                }
                .padding(.horizontal, 10)
                Spacer()
            }
            VStack {
                if practice && incorrect.count != 0 {
                    Text("Remaining: " + String(incorrect.count))
                        .font(.system(size: 30))
                        .padding()
                } else {
                    Text("Score: " + String(counter))
                        .font(.system(size: 30))
                        .padding()
                }
                Text("Root Note:")
                    .font(.system(size: 30))
                Text(rootNoteLetter)
                    .font(.system(size: 80))
                Button("Play Interval") {
                    playSequence()
                }
                .foregroundStyle(.black)
                .padding()
                .background(.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                HStack {
                    Button { //right
                        if !practice {
                            correct += 1
                            counter += 1
                            next()
                        } else {
                            if incorrect.count == 1 {
                                practiceDone = true
                            } else {
                                incorrect.removeFirst()
                                incorrectAnswers.removeFirst()
                                nextPractice()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.green)
                            .background(.blue, in: Circle())
                            .padding(20)
                    }
                    Button { //wrong
                        if !practice {
                            counter += 1
                            incorrect.append(notes)
                            incorrectAnswers.append(atonalAnswerString)
                            next()
                        } else {
                            incorrect.append(notes)
                            incorrect.removeFirst()
                            incorrectAnswers.append(incorrectAnswers[0])
                            incorrectAnswers.removeFirst()
                            nextPractice()
                        }

                    } label: {
                        Image(systemName: "x.circle")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.orange)
                            .background(.red, in: Circle())
                            .padding(20)
                    }
                } // correct and incorrect buttons
                .padding()
            }
            // tempo slider and answer
            VStack {
                Spacer()
                Slider(value: $tempo,
                       in: 100...270,
                       step: 1,
                       onEditingChanged: { editing in
                           isEditing = editing
                    UserDefaults.standard.set(tempo, forKey: "tempo")
                       })
                .padding()
                if practice {
                    Text(incorrectAnswers[0])
                        .foregroundStyle(showAnswer ? Color.primary : Color.white)
                        .font(.caption)
                } else {
                    Text(atonalAnswerString)
                        .foregroundStyle(showAnswer ? Color.primary : Color.white)
                        .font(.caption)
                }
                
            }
            if practiceDone {
                Rectangle()
                    .foregroundStyle(Color.white)
                    .ignoresSafeArea()
                Text("You did it!🎉")
            }
            if settings {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(.white)
                VStack {
                    Text("Interval range")
                        .font(.title)
                    HStack {
                        VStack {
                            Text("Lowest")
                                .font(.title2)
                            HStack {
                                Button("-"){
                                    if lowest > absoluteLowest {
                                        lowest -= 1
                                        UserDefaults.standard.set(lowest, forKey: "lowest")
                                    }
                                }
                                .foregroundStyle(.black)
                                .padding(7)
                                .background(.gray.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                Text(String(lowest))
                                    .font(.title)
                                    .monospacedDigit()
                                Button("+") {
                                    if highest - lowest > 12 {
                                        lowest += 1
                                        UserDefaults.standard.set(lowest, forKey: "lowest")
                                    }
                                }
                                .foregroundStyle(.black)
                                .padding(7)
                                .background(.gray.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        }
                        .padding()
                        VStack {
                            Text("Highest")
                                .font(.title2)
                            HStack {
                                Button("-"){
                                    if highest - lowest > 12 {
                                        highest -= 1
                                        UserDefaults.standard.set(highest, forKey: "highest")
                                    }
                                }
                                .foregroundStyle(.black)
                                .padding(7)
                                .background(.gray.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                Text(String(highest))
                                    .font(.title)
                                    .monospacedDigit()
                                Button("+") {
                                    if highest < absoluteHighest {
                                        highest += 1
                                        UserDefaults.standard.set(highest, forKey: "highest")
                                    }
                                }
                                .foregroundStyle(.black)
                                .padding(7)
                                .background(.gray.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        }
                        .padding()
                    }
                }
                VStack {
                    Spacer()
                    Button("done") {
                        settings = false
                        next()
                    }
                }
            }
        }
        .onAppear {
            incorrect.removeAll()
            incorrectAnswers.removeAll()
            next()
            counter = 0
        }
    }
    
    func nextPractice() {
        showAnswer = false
        notes.removeAll()
        notes = incorrect[0]
        rootNote = notes[0]
        switch rootNote % 12 {
        case 0: rootNoteLetter = "C"
        case 1: rootNoteLetter = "D♭"
        case 2: rootNoteLetter = "D"
        case 3: rootNoteLetter = "E♭"
        case 4: rootNoteLetter = "E"
        case 5: rootNoteLetter = "F"
        case 6: rootNoteLetter = "G♭"
        case 7: rootNoteLetter = "G"
        case 8: rootNoteLetter = "A♭"
        case 9: rootNoteLetter = "A"
        case 10: rootNoteLetter = "B♭"
        case 11: rootNoteLetter = "B"
        default: rootNoteLetter = "Not Found"
        }
        playSequence()
    }
    
    func next() {
        showAnswer = false
        if counter > 0 { //to find percentage
            print("Correct: " + String(correct))
            print("Counter: " + String(counter))
            print(Double(correct) / Double(counter))
            percentage = String(format: "%.1f", (Double(correct) / Double(counter) * 100)) + "%"
        }
        notes.removeAll()
        atonalAnswerString = ""
        rootNote = UInt8(Int.random(in: 57...72))
        notes.append(rootNote)
        var previousNote = rootNote
        for decision in 0..<howMany {
            var done = false
            while !done { //have an audible range
                nextNote = UInt8(Int.random(in: 1...12))
                let coinflip = Int.random(in: 1...2)
                if coinflip == 1 {
                    nextNote = previousNote - nextNote
                    if nextNote > lowest {
                        done = true
                    }
                } else {
                    nextNote = previousNote + nextNote
                    if nextNote <= highest {
                        done = true
                    }
                }
            }
            notes.append(nextNote)
            atonalAnswerString = findInterval(distance: abs(Int(previousNote) - Int(nextNote)))
            answer[decision] = findInterval(distance: abs(Int(previousNote) - Int(nextNote)))
            previousNote = nextNote
        }
        switch rootNote % 12 {
        case 0: rootNoteLetter = "C"
        case 1: rootNoteLetter = "D♭"
        case 2: rootNoteLetter = "D"
        case 3: rootNoteLetter = "E♭"
        case 4: rootNoteLetter = "E"
        case 5: rootNoteLetter = "F"
        case 6: rootNoteLetter = "G♭"
        case 7: rootNoteLetter = "G"
        case 8: rootNoteLetter = "A♭"
        case 9: rootNoteLetter = "A"
        case 10: rootNoteLetter = "B♭"
        case 11: rootNoteLetter = "B"
        default: rootNoteLetter = "Not Found"
        }
        playSequence()
    }
    
    func findInterval(distance: Int) -> String {
        switch distance {
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
    
    func playSequence() {
        print(notes)
        PianoSequencePlayer.shared.play(notes: notes, tempoBPM: tempo)
    }
}

#Preview {
    IndividualIntervalView()
}
