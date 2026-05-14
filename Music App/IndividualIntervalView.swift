//
//  IndividualIntervalView.swift
//  Music App
//
//  Created by Nathan Davis on 8/21/25.
//

import SwiftUI
import AVFoundation

private enum IntervalDirection: String, CaseIterable, Identifiable {
    case upOnly
    case downOnly
    case upAndDown

    var id: String { rawValue }

    var title: String {
        switch self {
        case .upOnly:
            return "Up only"
        case .downOnly:
            return "Down only"
        case .upAndDown:
            return "Up and down"
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
    @State private var selectedDirection: IntervalDirection = .upAndDown
    @State private var enabledIntervals = Set(1...12)
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color(.systemBackground))
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
                                    .background(Color(.secondarySystemBackground), in: Circle())
                                    .foregroundStyle(practice ? Color.blue : .primary)
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
                .foregroundStyle(.primary)
                .padding()
                .background(Color(.secondarySystemBackground))
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
                        .opacity(showAnswer ? 1 : 0)
                        .font(.caption)
                } else {
                    Text(atonalAnswerString)
                        .opacity(showAnswer ? 1 : 0)
                        .font(.caption)
                }
                
            }
            if practiceDone {
                Rectangle()
                    .foregroundStyle(Color(.systemBackground))
                    .ignoresSafeArea()
                Text("You did it!🎉")
            }
        }
        .onAppear {
            loadSavedIntervalSettings()
            incorrect.removeAll()
            incorrectAnswers.removeAll()
            next()
            counter = 0
        }
        .fullScreenCover(isPresented: $settings) {
            settingsView
        }
    }
    
    private var settingsView: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Interval range")
                    .font(.title)

                HStack {
                    VStack {
                        Text("Lowest")
                            .font(.title2)
                        HStack {
                            Button("-") {
                                if lowest > absoluteLowest {
                                    lowest -= 1
                                    UserDefaults.standard.set(lowest, forKey: "lowest")
                                    playSingleNote(lowest)
                                }
                            }
                            .foregroundStyle(.primary)
                            .padding(7)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .disabled(lowest == absoluteLowest)
                            .opacity(lowest == absoluteLowest ? 0.4 : 1)

                            Text(String(lowest))
                                .font(.title)
                                .monospacedDigit()

                            Button("+") {
                                if highest - lowest > 12 {
                                    lowest += 1
                                    UserDefaults.standard.set(lowest, forKey: "lowest")
                                    playSingleNote(lowest)
                                }
                            }
                            .foregroundStyle(.primary)
                            .padding(7)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .disabled(highest - lowest <= 12)
                            .opacity(highest - lowest <= 12 ? 0.4 : 1)
                        }
                        .padding()
                        
                        Text(noteName(for: lowest))
                    }
                    .padding()

                    VStack {
                        Text("Highest")
                            .font(.title2)
                        HStack {
                            Button("-") {
                                if highest - lowest > 12 {
                                    highest -= 1
                                    UserDefaults.standard.set(highest, forKey: "highest")
                                    playSingleNote(highest)
                                }
                            }
                            .foregroundStyle(.primary)
                            .padding(7)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .disabled(highest - lowest <= 12)
                            .opacity(highest - lowest <= 12 ? 0.4 : 1)

                            Text(String(highest))
                                .font(.title)
                                .monospacedDigit()

                            Button("+") {
                                if highest < absoluteHighest {
                                    highest += 1
                                    UserDefaults.standard.set(highest, forKey: "highest")
                                    playSingleNote(highest)
                                }
                            }
                            .foregroundStyle(.primary)
                            .padding(7)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .disabled(highest == absoluteHighest)
                            .opacity(highest == absoluteHighest ? 0.4 : 1)
                        }
                        .padding()
                        
                        Text(noteName(for: highest))
                    }
                    .padding()
                }
                
                Button("Full Practice") {
                    selectedDirection = .upAndDown
                    enabledIntervals = Set(1...12)
                    saveIntervalSettings()
                }
                .buttonStyle(.borderedProminent)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Picker("Direction", selection: directionBinding) {
                            ForEach(IntervalDirection.allCases) { direction in
                                Text(direction.title).tag(direction)
                            }
                        }
                        .pickerStyle(.segmented)

                        Toggle("All intervals", isOn: allIntervalsBinding)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Intervals")
                                .font(.title2)

                            ForEach(1...12, id: \.self) { semitones in
                                Toggle(intervalName(for: semitones), isOn: intervalBinding(for: semitones))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        settings = false
                        next()
                    }
                }
            }
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
        guard !enabledIntervals.isEmpty else {
            rootNote = UInt8(max(lowest, min(highest, 60)))
            notes = [rootNote]
            setRootNoteLetter(root: rootNote)
            return
        }

        let openingIntervals = availableOpeningIntervals()
        guard let openingInterval = openingIntervals.randomElement(),
              let selectedRootNote = availableRootNotes(for: openingInterval).randomElement() else {
            rootNote = UInt8(max(lowest, min(highest, 60)))
            notes = [rootNote]
            setRootNoteLetter(root: rootNote)
            return
        }

        rootNote = UInt8(selectedRootNote)
        notes.append(rootNote)
        var previousNote = rootNote
        for decision in 0..<howMany {
            let generatedNote: UInt8?
            if decision == 0 {
                generatedNote = UInt8(Int(rootNote) + openingInterval)
            } else {
                generatedNote = generateNextNote(from: previousNote)
            }

            guard let generatedNote else {
                break
            }
            nextNote = generatedNote
            notes.append(nextNote)
            atonalAnswerString = findInterval(distance: abs(Int(previousNote) - Int(nextNote)))
            answer[decision] = findInterval(distance: abs(Int(previousNote) - Int(nextNote)))
            previousNote = nextNote
        }
        setRootNoteLetter(root: rootNote)
        playSequence()
    }

    private var allIntervalsBinding: Binding<Bool> {
        Binding(
            get: { enabledIntervals.count == 12 },
            set: { isEnabled in
                enabledIntervals = isEnabled ? Set(1...12) : []
                saveIntervalSettings()
            }
        )
    }

    private var directionBinding: Binding<IntervalDirection> {
        Binding(
            get: { selectedDirection },
            set: { newValue in
                selectedDirection = newValue
                saveIntervalSettings()
            }
        )
    }

    private func intervalBinding(for semitones: Int) -> Binding<Bool> {
        Binding(
            get: { enabledIntervals.contains(semitones) },
            set: { isEnabled in
                if isEnabled {
                    enabledIntervals.insert(semitones)
                } else {
                    enabledIntervals.remove(semitones)
                }
                saveIntervalSettings()
            }
        )
    }

    private func generateNextNote(from previousNote: UInt8) -> UInt8? {
        guard let signedInterval = availableSignedIntervals(from: Int(previousNote)).randomElement() else {
            return nil
        }

        return UInt8(Int(previousNote) + signedInterval)
    }

    private func availableOpeningIntervals() -> [Int] {
        allSignedIntervals.filter { !availableRootNotes(for: $0).isEmpty }
    }

    private func availableSignedIntervals(from previousNote: Int) -> [Int] {
        allSignedIntervals.filter { signedInterval in
            let candidate = previousNote + signedInterval
            return candidate >= lowest && candidate <= highest
        }
    }

    private func availableRootNotes(for signedInterval: Int) -> [Int] {
        (lowest...highest).filter { root in
            let candidate = root + signedInterval
            return candidate >= lowest && candidate <= highest
        }
    }

    private var allSignedIntervals: [Int] {
        Array(enabledIntervals).flatMap { interval in
            switch selectedDirection {
            case .upOnly:
                return [interval]
            case .downOnly:
                return [-interval]
            case .upAndDown:
                return [interval, -interval]
            }
        }
    }

    private func intervalName(for semitones: Int) -> String {
        findInterval(distance: semitones)
    }

    private func setRootNoteLetter(root: UInt8) {
        switch root % 12 {
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
    }

    private func loadSavedIntervalSettings() {
        let storedDirection = UserDefaults.standard.string(forKey: "individualIntervalDirection")
            ?? IntervalDirection.upAndDown.rawValue
        if let savedDirection = IntervalDirection(rawValue: storedDirection) {
            selectedDirection = savedDirection
        }

        let storedEnabledIntervals = UserDefaults.standard.string(forKey: "individualIntervalEnabledIntervals")
            ?? "1,2,3,4,5,6,7,8,9,10,11,12"

        let parsedIntervals = storedEnabledIntervals
            .split(separator: ",")
            .compactMap { Int($0) }
            .filter { (1...12).contains($0) }

        enabledIntervals = parsedIntervals.isEmpty ? Set(1...12) : Set(parsedIntervals)
    }

    private func saveIntervalSettings() {
        UserDefaults.standard.set(selectedDirection.rawValue, forKey: "individualIntervalDirection")
        UserDefaults.standard.set(
            enabledIntervals.sorted().map(String.init).joined(separator: ","),
            forKey: "individualIntervalEnabledIntervals"
        )
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
    
    func noteName(for midiNote: Int) -> String {
        let pitchClass = midiNote % 12
        let octave = (midiNote / 12) - 1

        let name: String
        switch pitchClass {
        case 0: name = "C"
        case 1: name = "C#"
        case 2: name = "D"
        case 3: name = "D#"
        case 4: name = "E"
        case 5: name = "F"
        case 6: name = "F#"
        case 7: name = "G"
        case 8: name = "G#"
        case 9: name = "A"
        case 10: name = "A#"
        case 11: name = "B"
        default: name = "?"
        }

        return "\(name)\(octave)"
    }

    func playSingleNote(_ note: Int) {
        PianoSequencePlayer.shared.play(notes: [UInt8(note)], tempoBPM: tempo)
    }

    func playSequence() {
        print(notes)
        PianoSequencePlayer.shared.play(notes: notes, tempoBPM: tempo)
    }
}

#Preview {
    IndividualIntervalView()
}
