//
//  SequenceView.swift
//  Music App
//
//  Created by Nathan Davis on 1/5/24.
//

import SwiftUI
import AVFoundation

struct SequenceView: View {
    let noteRange: ClosedRange<UInt8>?
    
    @State var notes: [UInt8] = [71,69,62,72,71,69,67]
    @State var incorrect: [[UInt8]] = [[70,71,72], [70,71,72], [70,71,72]]
    @State var incorrectAnswers = ["1, 7, 5", "1, 7, 5", "1, 7, 5"]
    @State var practice = false
    @State var practiceDone = false
    @State var rootNoteLetter = "G"
    @State var rootNote: UInt8 = 72
    @State var nextNote: UInt8 = 72
    @State var counter = 0
    @State var howMany = 2  //two extra notes after the root, loop starts at 0
    @State var answer = ["Perfect fifth", "minor third", "Major second"]
    @State var atonalAnswerString = "Perfect fifth, minor third"
    @State var diatonicAnswer = ["1", "7", "5", "8"]
    @State var diatonicAnswerString = "1, 7, 5"
    @State var diatonic = false
    @State var diatonicFirstPress = true
    @State var atonalFirstPress = false
    @State var tempo = UserDefaults.standard.double(forKey: "tempo")//150.0
    @State var fourNote = false
    @State var correct = 0
    @State var percentage = ""
    @State var isEditing = false
    @State private var showingAboutSheet = false
    
    let phrase: [PianoSequencePlayer.NoteEvent] = [
        .init(note: 60, startBeat: 0.0, durationBeats: 1.0),  // C quarter
        .init(note: 62, startBeat: 1.0, durationBeats: 0.5),  // D eighth
        .init(note: 64, startBeat: 1.5, durationBeats: 0.5),  // E eighth
        .init(note: 67, startBeat: 2.0, durationBeats: 2.0)   // G half
    ]

    init(noteRange: ClosedRange<UInt8>? = nil) {
        self.noteRange = noteRange
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()

                    if !practice {
                        Toggle("", isOn: $diatonic)
                            .padding(.horizontal)
                    }
                }
                HStack {
                    Spacer()
                    VStack {
                        Text(practice ? "" : percentage)
                        if incorrect.count != 0 {
                            Button {
                                practice = true
                                nextPractice()
                            } label: {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 20))
                                    .padding(5)
                                    .background(Color(.secondarySystemBackground), in: Circle())
                                    .foregroundStyle(practice ? Color.blue : Color.primary)
                            }
                            if !practice {
                                Text(String(incorrect.count))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding(.horizontal)
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
                Button("Play Sequence") {
                    playSequence()
                }
                .foregroundStyle(.primary)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                HStack {
                    Button("First") {
                        playFirst()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Second") {
                        playSecond()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if fourNote {
                        Button("Third") {
                            playThird()
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
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
                            incorrectAnswers.append((diatonic && !diatonicFirstPress) || atonalFirstPress  ? diatonicAnswerString : atonalAnswerString)
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
                        .font(.caption)
                } else if (diatonic && !diatonicFirstPress) || atonalFirstPress {
                    Text(diatonicAnswerString)
                        .font(.caption)
                } else {
                    Text(atonalAnswerString)
                        .font(.caption)
                }
                
            }
            if practiceDone {
                Rectangle()
                    .foregroundStyle(Color.white)
                    .ignoresSafeArea()
                Text("You did it!🎉")
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            incorrect.removeAll()
            incorrectAnswers.removeAll()
            next()
            counter = 0
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingAboutSheet = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showingAboutSheet) {
            NavigationStack {
                List {
                    Section("Goal") {
                        Text("Listen to the sequence, then identify the intervals or scale degrees you heard.")
                        Text("Use the checkmark if you got it right, or the X if you missed it.")
                    }

                    Section("Modes") {
                        Text("With the toggle off, the app picks two or three random atonal intervals between a given range.")
                        Text("With the toggle on, the app picks diatonic intervals within a major, minor, or harmonic minor scale.")
                    }

                    Section("Replay") {
                        Text("Tap Play Sequence to hear the full sequence again.")
                        Text("Use First, Second, and Third to replay smaller parts of the sequence.")
                    }

                    Section("Practice Mode") {
                        Text("Review sequences marked as incorrect in Practice Mode.")
                        Text("Tap the practice button to review missed sequences until they are cleared.")
                    }

                    Section("Tempo") {
                        Text("Use the slider at the bottom to adjust the playback speed.")
                    }
                }
                .navigationTitle("About Sequences")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showingAboutSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    func nextPractice() {
        fourNote = false
        notes.removeAll()
        notes = incorrect[0]
        if notes.count == 4 {
            fourNote = true
        }
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
        if counter > 0 { //to find percentage
            print("Correct: " + String(correct))
            print("Counter: " + String(counter))
            print(Double(correct) / Double(counter))
            percentage = String(format: "%.1f", (Double(correct) / Double(counter) * 100)) + "%"
        }
        fourNote = false
        notes.removeAll()
        atonalAnswerString = ""
        if let noteRange {
            print("SequenceView range: \(noteRange.lowerBound)...\(noteRange.upperBound)")
        } else {
            print("SequenceView range: default 57...72")
        }
        rootNote = randomRootNote()
        print("SequenceView root note: \(rootNote)")
        appendNote(rootNote)
        if atonalFirstPress == true {
            atonalFirstPress = false
        }
        if diatonic {
            if diatonicFirstPress == true {
                diatonicFirstPress = false
            }
            if !atonalFirstPress {
                atonalFirstPress = true
            }
            diatonicAnswerString = "1, "
            let scaleType = Int.random(in: 1...3)
            switch scaleType {
                
                //Major scale
            case 1:
                let decision = Int.random(in: 1...5) // five cases now
                switch decision { //two same direction
                case 1:
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //going up
                        let secondNote = Int.random(in: 2...4)
                        diatonicAnswer[1] = String(secondNote)
                        majorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote + 1...8)
                        diatonicAnswer[2] = String(thirdNote)
                        majorScaleAscendingPicker(note: UInt8(thirdNote))
                    } else { //going down
                        let secondNote = Int.random(in: 5...7)
                        diatonicAnswer[1] = String(secondNote)
                        majorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 1..<secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        majorScaleDescendingPicker(note: UInt8(thirdNote))
                    }
                case 2: //large first then small the other way
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //ascending first
                        let secondNote = Int.random(in: 5...8)
                        diatonicAnswer[1] = String(secondNote)
                        majorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 2..<secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        majorScaleAscendingPicker(note: UInt8(thirdNote))
                    } else {    //descending first
                        let secondNote = Int.random(in: 1...4)
                        diatonicAnswer[1] = String(secondNote)
                        majorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote + 1...7)
                        diatonicAnswer[2] = String(thirdNote)
                        majorScaleDescendingPicker(note: UInt8(thirdNote))
                    }
                case 3: //jump the tonic
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //ascending first
                        let secondNote = Int.random(in: 2...7)
                        diatonicAnswer[1] = String(secondNote)
                        majorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote...7)
                        diatonicAnswer[2] = String(thirdNote)
                        majorScaleDescendingPicker(note: UInt8(thirdNote))
                    } else { //descending first
                        let secondNote = Int.random(in: 2...7)
                        diatonicAnswer[1] = String(secondNote)
                        majorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 2...secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        majorScaleAscendingPicker(note: UInt8(thirdNote))
                    }
                case 4: //four notes straight up or down!
                    fourNote = true
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //ascending first
                        let secondNote = Int.random(in: 2...3)
                        diatonicAnswer[1] = String(secondNote)
                        majorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote + 1...5)
                        diatonicAnswer[2] = String(thirdNote)
                        majorScaleAscendingPicker(note: UInt8(thirdNote))
                        let fourthNote = Int.random(in: thirdNote + 1...8)
                        diatonicAnswer[3] = String(fourthNote)
                        majorScaleAscendingPicker(note: UInt8(fourthNote))
                    } else { //descending first
                        let secondNote = Int.random(in: 5...7)
                        diatonicAnswer[1] = String(secondNote)
                        majorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 4..<secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        majorScaleDescendingPicker(note: UInt8(thirdNote))
                        let fourthNote = Int.random(in: 1..<thirdNote)
                        diatonicAnswer[3] = String(fourthNote)
                        majorScaleDescendingPicker(note: UInt8(fourthNote))
                    }
                case 5: //any four notes
                    fourNote = true
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //above the tonic
                        var alreadySelected = [9]
                        alreadySelected.removeAll()
                        var note = Int.random(in: 2...8)
                        alreadySelected.append(note)
                        diatonicAnswer[1] = String(note)
                        majorScaleAscendingPicker(note: UInt8(note))
                        for iteration in 2...3 {
                            note = Int.random(in: 2...8)
                            while alreadySelected.contains(note) {
                                note = Int.random(in: 2...8)
                            }
                            alreadySelected.append(note)
                            diatonicAnswer[iteration] = String(note)
                            majorScaleAscendingPicker(note: UInt8(note))
                        }
                    } else { //below the tonic
                        var alreadySelected = [9]
                        alreadySelected.removeAll()
                        var note = Int.random(in: 1...7)
                        alreadySelected.append(note)
                        diatonicAnswer[1] = String(note)
                        majorScaleDescendingPicker(note: UInt8(note))
                        for iteration in 2...3 {
                            note = Int.random(in: 1...7)
                            while alreadySelected.contains(note) {
                                note = Int.random(in: 1...7)
                            }
                            alreadySelected.append(note)
                            diatonicAnswer[iteration] = String(note)
                            majorScaleDescendingPicker(note: UInt8(note))
                        }
                    }
                    
                default: print("something went wrong")
                }
                
                //minor Scale
            case 2:
                let decision = Int.random(in: 1...5) //five cases now
                switch decision {
                case 1: //two same direction
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //going up
                        let secondNote = Int.random(in: 2...4)
                        diatonicAnswer[1] = String(secondNote)
                        minorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote + 1...8)
                        diatonicAnswer[2] = String(thirdNote)
                        minorScaleAscendingPicker(note: UInt8(thirdNote))
                    } else { //going down
                        let secondNote = Int.random(in: 5...7)
                        diatonicAnswer[1] = String(secondNote)
                        minorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 1..<secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        minorScaleDescendingPicker(note: UInt8(thirdNote))
                    }
                case 2: //large first then small the other way
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //ascending first
                        let secondNote = Int.random(in: 5...8)
                        diatonicAnswer[1] = String(secondNote)
                        minorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 2..<secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        minorScaleAscendingPicker(note: UInt8(thirdNote))
                    } else {    //descending first
                        let secondNote = Int.random(in: 1...4)
                        diatonicAnswer[1] = String(secondNote)
                        minorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote + 1...7)
                        diatonicAnswer[2] = String(thirdNote)
                        minorScaleDescendingPicker(note: UInt8(thirdNote))
                    }
                case 3: //jump the tonic
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //ascending first
                        let secondNote = Int.random(in: 2...7)
                        diatonicAnswer[1] = String(secondNote)
                        minorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote...7)
                        diatonicAnswer[2] = String(thirdNote)
                        minorScaleDescendingPicker(note: UInt8(thirdNote))
                    } else { //descending first
                        let secondNote = Int.random(in: 2...7)
                        diatonicAnswer[1] = String(secondNote)
                        minorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 2...secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        minorScaleAscendingPicker(note: UInt8(thirdNote))
                    }
                case 4:
                    fourNote = true
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //ascending first
                        let secondNote = Int.random(in: 2...3)
                        diatonicAnswer[1] = String(secondNote)
                        minorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote + 1...5)
                        diatonicAnswer[2] = String(thirdNote)
                        minorScaleAscendingPicker(note: UInt8(thirdNote))
                        let fourthNote = Int.random(in: thirdNote + 1...8)
                        diatonicAnswer[3] = String(fourthNote)
                        minorScaleAscendingPicker(note: UInt8(fourthNote))
                    } else { //descending first
                        let secondNote = Int.random(in: 5...7)
                        diatonicAnswer[1] = String(secondNote)
                        minorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 4..<secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        minorScaleDescendingPicker(note: UInt8(thirdNote))
                        let fourthNote = Int.random(in: 1..<thirdNote)
                        diatonicAnswer[3] = String(fourthNote)
                        minorScaleDescendingPicker(note: UInt8(fourthNote))
                    }
                case 5: //any four notes
                    fourNote = true
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //above the tonic
                        var alreadySelected = [9]
                        alreadySelected.removeAll()
                        var note = Int.random(in: 2...8)
                        alreadySelected.append(note)
                        diatonicAnswer[1] = String(note)
                        minorScaleAscendingPicker(note: UInt8(note))
                        for iteration in 2...3 {
                            note = Int.random(in: 2...8)
                            while alreadySelected.contains(note) {
                                note = Int.random(in: 2...8)
                            }
                            alreadySelected.append(note)
                            diatonicAnswer[iteration] = String(note)
                            minorScaleAscendingPicker(note: UInt8(note))
                        }
                    } else { //below the tonic
                        var alreadySelected = [9]
                        alreadySelected.removeAll()
                        var note = Int.random(in: 1...7)
                        alreadySelected.append(note)
                        diatonicAnswer[1] = String(note)
                        minorScaleDescendingPicker(note: UInt8(note))
                        for iteration in 2...3 {
                            note = Int.random(in: 1...7)
                            while alreadySelected.contains(note) {
                                note = Int.random(in: 1...7)
                            }
                            alreadySelected.append(note)
                            diatonicAnswer[iteration] = String(note)
                            minorScaleDescendingPicker(note: UInt8(note))
                        }
                    }
                default: print("something went wrong")
                }
                
                //harmonic-minor scale
            case 3:
                let decision = Int.random(in: 1...5) //five cases now
                switch decision { //two same direction
                case 1:
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //going up
                        let secondNote = Int.random(in: 2...4)
                        diatonicAnswer[1] = String(secondNote)
                        harMinorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote + 1...8)
                        diatonicAnswer[2] = String(thirdNote)
                        harMinorScaleAscendingPicker(note: UInt8(thirdNote))
                    } else { //going down
                        let secondNote = Int.random(in: 5...7)
                        diatonicAnswer[1] = String(secondNote)
                        harMinorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 1..<secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        harMinorScaleDescendingPicker(note: UInt8(thirdNote))
                    }
                case 2: //large first then small the other way
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //ascending first
                        let secondNote = Int.random(in: 5...8)
                        diatonicAnswer[1] = String(secondNote)
                        harMinorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 2..<secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        harMinorScaleAscendingPicker(note: UInt8(thirdNote))
                    } else {    //descending first
                        let secondNote = Int.random(in: 1...4)
                        diatonicAnswer[1] = String(secondNote)
                        harMinorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote + 1...7)
                        diatonicAnswer[2] = String(thirdNote)
                        harMinorScaleDescendingPicker(note: UInt8(thirdNote))
                    }
                case 3: //jump the tonic
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //ascending first
                        let secondNote = Int.random(in: 2...7)
                        diatonicAnswer[1] = String(secondNote)
                        harMinorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote...7)
                        diatonicAnswer[2] = String(thirdNote)
                        harMinorScaleDescendingPicker(note: UInt8(thirdNote))
                    } else { //descending first
                        let secondNote = Int.random(in: 2...7)
                        diatonicAnswer[1] = String(secondNote)
                        harMinorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 2...secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        harMinorScaleAscendingPicker(note: UInt8(thirdNote))
                    }
                case 4:
                    fourNote = true
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //ascending first
                        let secondNote = Int.random(in: 2...3)
                        diatonicAnswer[1] = String(secondNote)
                        harMinorScaleAscendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: secondNote + 1...5)
                        diatonicAnswer[2] = String(thirdNote)
                        harMinorScaleAscendingPicker(note: UInt8(thirdNote))
                        let fourthNote = Int.random(in: thirdNote + 1...8)
                        diatonicAnswer[3] = String(fourthNote)
                        harMinorScaleAscendingPicker(note: UInt8(fourthNote))
                    } else { //descending first
                        let secondNote = Int.random(in: 5...7)
                        diatonicAnswer[1] = String(secondNote)
                        harMinorScaleDescendingPicker(note: UInt8(secondNote))
                        let thirdNote = Int.random(in: 4..<secondNote)
                        diatonicAnswer[2] = String(thirdNote)
                        harMinorScaleDescendingPicker(note: UInt8(thirdNote))
                        let fourthNote = Int.random(in: 1..<thirdNote)
                        diatonicAnswer[3] = String(fourthNote)
                        harMinorScaleDescendingPicker(note: UInt8(fourthNote))
                    }
                case 5: //any four notes
                    fourNote = true
                    let coinflip = Int.random(in: 1...2)
                    if coinflip == 1 { //above the tonic
                        var alreadySelected = [9]
                        alreadySelected.removeAll()
                        var note = Int.random(in: 2...8)
                        alreadySelected.append(note)
                        diatonicAnswer[1] = String(note)
                        harMinorScaleAscendingPicker(note: UInt8(note))
                        for iteration in 2...3 {
                            note = Int.random(in: 2...8)
                            while alreadySelected.contains(note) {
                                note = Int.random(in: 2...8)
                            }
                            alreadySelected.append(note)
                            diatonicAnswer[iteration] = String(note)
                            harMinorScaleAscendingPicker(note: UInt8(note))
                        }
                    } else { //below the tonic
                        var alreadySelected = [9]
                        alreadySelected.removeAll()
                        var note = Int.random(in: 1...7)
                        alreadySelected.append(note)
                        diatonicAnswer[1] = String(note)
                        harMinorScaleDescendingPicker(note: UInt8(note))
                        for iteration in 2...3 {
                            note = Int.random(in: 1...7)
                            while alreadySelected.contains(note) {
                                note = Int.random(in: 1...7)
                            }
                            alreadySelected.append(note)
                            diatonicAnswer[iteration] = String(note)
                            harMinorScaleDescendingPicker(note: UInt8(note))
                        }
                    }
                default: print("something went wrong")
                }
                
                
            default: print("something went wrong")
            }
            diatonicAnswerString += diatonicAnswer[1]
            diatonicAnswerString += ", " + diatonicAnswer[2]
            if fourNote {
                diatonicAnswerString += ", " + diatonicAnswer[3]
            }
        } else {
            let lowerBound = noteRange?.lowerBound ?? 45
            let upperBound = noteRange?.upperBound ?? 84
            let exerciseType = Int.random(in: 1...4)
            switch exerciseType {
            //regular pick anything
            case 1:
                var previousNote = rootNote
                for decision in 0..<howMany {
                    var done = false
                    while !done { //have an audible range
                        nextNote = UInt8(Int.random(in: 1...12))
                        let coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            nextNote = previousNote - nextNote
                            if nextNote >= lowerBound {
                                done = true
                            }
                        } else {
                            nextNote = previousNote + nextNote
                            if nextNote <= upperBound {
                                done = true
                            }
                        }
                    }
                    appendNote(nextNote)
                    answer[decision] = findInterval(distance: abs(Int(previousNote) - Int(nextNote)))
                    previousNote = nextNote
                }
            //any three in the octave
            case 2:
                var previousNote = rootNote
                var picked: [UInt8] = []
                let coinflip = Int.random(in: 1...2)
                for decision in 0..<2 {
                    nextNote = UInt8(Int.random(in: 1...12))
                    while picked.contains(nextNote) {
                        nextNote = UInt8(Int.random(in: 1...12))
                    }
                    picked.append(nextNote)
                    if coinflip == 1 { //above the root
                        nextNote = rootNote + nextNote
                        while nextNote > upperBound {
                            nextNote -= 12
                        }
                    } else { //below the root
                        nextNote = rootNote - nextNote
                        while nextNote < lowerBound {
                            nextNote += 12
                        }
                    }
                    answer[decision] = findInterval(distance: abs(Int(previousNote) - Int(nextNote)))
                    appendNote(nextNote)
                    previousNote = nextNote
                }
            //any four in the octave
            case 3:
                fourNote = true
                var previousNote = rootNote
                var picked: [UInt8] = []
                let coinflip = Int.random(in: 1...2)
                for decision in 0..<3 {
                    nextNote = UInt8(Int.random(in: 1...12))
                    while picked.contains(nextNote) {
                        nextNote = UInt8(Int.random(in: 1...12))
                    }
                    picked.append(nextNote)
                    if coinflip == 1 {
                        nextNote = rootNote + nextNote
                        while nextNote > upperBound {
                            nextNote -= 12
                        }
                    } else {
                        nextNote = rootNote - nextNote
                        while nextNote < lowerBound {
                            nextNote += 12
                        }
                    }
                    answer[decision] = findInterval(distance: abs(Int(previousNote) - Int(nextNote)))
                    appendNote(nextNote)
                    previousNote = nextNote
                }
            //walking up by half or whole
            case 4:
                fourNote = true
                var previousNote = rootNote
                let coinflip = Int.random(in: 1...2)
                for decision in 0..<3 {
                    nextNote = UInt8(Int.random(in: 1...2)) //half or whole only
                    if coinflip == 1 {
                        nextNote = previousNote + nextNote
                        if nextNote > upperBound {
                            nextNote = previousNote - (nextNote - previousNote)
                        }
                    } else {
                        nextNote = previousNote - nextNote
                        if nextNote < lowerBound {
                            nextNote = previousNote + (previousNote - nextNote)
                        }
                    }
                    answer[decision] = findInterval(distance: abs(Int(previousNote) - Int(nextNote)))
                    appendNote(nextNote)
                    previousNote = nextNote
                }
            default: print("something went wrong")
            }
            atonalAnswerString = answer[0] + ", " + answer[1]
            if fourNote {
                atonalAnswerString += ", " + answer[2]
            }
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
    
    func majorScaleAscendingPicker(note: UInt8) {
        switch note {
        case 1: appendNote(rootNote)
        case 2: appendNote(rootNote + 2)
        case 3: appendNote(rootNote + 4)
        case 4: appendNote(rootNote + 5)
        case 5: appendNote(rootNote + 7)
        case 6: appendNote(rootNote + 9)
        case 7: appendNote(rootNote + 11)
        case 8: appendNote(rootNote + 12)
        default: print("something went wrong")
        }
    }
    
    func majorScaleDescendingPicker(note: UInt8) {
        switch note {
        case 1: appendNote(rootNote - 12)
        case 2: appendNote(rootNote - 10)
        case 3: appendNote(rootNote - 8)
        case 4: appendNote(rootNote - 7)
        case 5: appendNote(rootNote - 5)
        case 6: appendNote(rootNote - 3)
        case 7: appendNote(rootNote - 1)
        case 8: appendNote(rootNote)
        default: print("something went wrong")
        }
    }
    
    func minorScaleAscendingPicker(note: UInt8) {
        switch note {
        case 1: appendNote(rootNote)
        case 2: appendNote(rootNote + 2)
        case 3: appendNote(rootNote + 3)
        case 4: appendNote(rootNote + 5)
        case 5: appendNote(rootNote + 7)
        case 6: appendNote(rootNote + 8)
        case 7: appendNote(rootNote + 10)
        case 8: appendNote(rootNote + 12)
        default: print("something went wrong")
        }
    }
    
    func minorScaleDescendingPicker(note: UInt8) {
        switch note {
        case 1: appendNote(rootNote - 12)
        case 2: appendNote(rootNote - 10)
        case 3: appendNote(rootNote - 9)
        case 4: appendNote(rootNote - 7)
        case 5: appendNote(rootNote - 5)
        case 6: appendNote(rootNote - 4)
        case 7: appendNote(rootNote - 2)
        case 8: appendNote(rootNote)
        default: print("something went wrong")
        }
    }
    
    func harMinorScaleAscendingPicker(note: UInt8) {
        switch note {
        case 1: appendNote(rootNote)
        case 2: appendNote(rootNote + 2)
        case 3: appendNote(rootNote + 3)
        case 4: appendNote(rootNote + 5)
        case 5: appendNote(rootNote + 7)
        case 6: appendNote(rootNote + 8)
        case 7: appendNote(rootNote + 11)
        case 8: appendNote(rootNote + 12)
        default: print("something went wrong")
        }
    }
    
    func harMinorScaleDescendingPicker(note: UInt8) {
        switch note {
        case 1: appendNote(rootNote - 12)
        case 2: appendNote(rootNote - 10)
        case 3: appendNote(rootNote - 9)
        case 4: appendNote(rootNote - 7)
        case 5: appendNote(rootNote - 5)
        case 6: appendNote(rootNote - 4)
        case 7: appendNote(rootNote - 1)
        case 8: appendNote(rootNote)
        default: print("something went wrong")
        }
    }

    private func appendNote(_ note: UInt8) {
        if let noteRange {
            let bounded = boundedNote(note, within: noteRange)
            print("SequenceView note: \(note) -> \(bounded)")
            notes.append(bounded)
        } else {
            print("SequenceView note: \(note)")
            notes.append(note)
        }
    }

    private func boundedNote(_ note: UInt8, within range: ClosedRange<UInt8>) -> UInt8 {
        var result = note
        while result > range.upperBound {
            result -= 12
        }
        while result < range.lowerBound {
            result += 12
        }
        return result
    }
    
    func playSequence() {
        print("SequenceView playback notes: \(notes)")
        // Uses PianoSequencePlayer (defined elsewhere in the project) to play via SoundFont.
        PianoSequencePlayer.shared.play(notes: notes, tempoBPM: tempo)
    }
    
    func playFirst() {
        print(notes)
        guard notes.count >= 2 else { return }
        let slice = Array(notes[0...1])
        PianoSequencePlayer.shared.play(notes: slice, tempoBPM: tempo)
    }
    
    func playSecond() {
        print(notes)
        guard notes.count >= 3 else { return }
        let slice = Array(notes[1...2])
        PianoSequencePlayer.shared.play(notes: slice, tempoBPM: tempo)
    }
    
    func playThird() {
        print(notes)
        guard notes.count >= 3 else { return }
        let slice = Array(notes[2..<notes.count])
        PianoSequencePlayer.shared.play(notes: slice, tempoBPM: tempo)
    }

    private func randomRootNote() -> UInt8 {
        if let noteRange {
            return UInt8(Int.random(in: Int(noteRange.lowerBound)...Int(noteRange.upperBound)))
        }

        return UInt8(Int.random(in: 57...72))
    }
}

#Preview {
    SequenceView()
}
