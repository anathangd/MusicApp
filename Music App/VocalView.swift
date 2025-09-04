//
//  VocalView.swift
//  Music App
//
//  Created by Nathan Davis on 1/22/24.
//

import SwiftUI
import AudioToolbox

struct VocalView: View {
    //vocal range: 47-72
    @State var notes: [UInt8] = [71,69,62,72,71,69,67]
    @State var rootNoteLetter = "G"
    @State var rootNote: UInt8 = 72
    @State var nextNote: UInt8 = 72
    @State var counter = 0
    @State var howMany = 2  //two extra notes after the root, loop starts at 0
    @State var answer = ["Perfect fifth", "minor third"]
    @State var diatonicAnswer = ["1", "7", "5", "8"]
    @State var diatonicAnswerString = "1, 7, 5"
    @State var diatonic = false
    @State var tempo = 150.0
    @State var fourNote = false
    @State var individual = false
    @State var interval = "Major third"
    @State var prompt = "Descending Major third from:"
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Toggle("", isOn: $diatonic)
                            .padding(.horizontal)
                        Toggle("", isOn: $individual)
                            .padding()
                    }
                }
                Spacer()
            }
            VStack {
                Text("Score: " + String(counter))
                    .font(.system(size: 30))
                    .padding()
                Text("Root Note:")
                    .font(.system(size: 30))
                Text(rootNoteLetter)
                    .font(.system(size: 80))
                Button("Play Sequence") {
                    playSequence()
                }
                .foregroundStyle(.black)
                .padding()
                .background(.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                HStack {
                    Button("First") {
                        playFirst()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .foregroundStyle(.black)
                    
                    .background(.gray.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Second") {
                        playSecond()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .foregroundStyle(.black)
                    .background(.gray.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if fourNote {
                        Button("Third") {
                            playThird()
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                        .foregroundStyle(.black)
                        .background(.gray.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                Button("next") {
                    next()
                }.padding()
            }
            VStack {
                Spacer()
                Slider(value: $tempo,
                       in: 40...200,
                       step: 1)
                .padding()
                if diatonic {
                    Text(diatonicAnswerString)
                            .font(.caption)
                } else {
                    Text(String(answer[0]) + (howMany != 1 ? ", " + answer[1] : ""))
                        .font(.caption)
                }
                
            }
            if individual {
                Rectangle()
                    .foregroundStyle(Color.white)
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
                    Text(rootNoteLetter)
                        .font(.system(size: 80))
                    Button("Play Answer") {
                        playFirst()
                    }
                    .foregroundStyle(.black)
                    .padding()
                    .background(.gray.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("next") {
                        next()
                    }.padding()
                }
            }
        }
        .onAppear {
            next()
            counter = 0
        }
    }
    
    func next() {
        fourNote = false
        notes.removeAll()
        rootNote = UInt8(Int.random(in: 49...70)) //leave room for my vocal range
        notes.append(rootNote)
        var previousNote = rootNote
        for decision in 0..<howMany {
            var done = false
            while !done { //have an audible range
                nextNote = UInt8(Int.random(in: 1...12))
                let coinflip = Int.random(in: 1...2)
                if coinflip == 1 { //descending
                    nextNote = previousNote - nextNote
                    if nextNote > 47 {
                        done = true
                    }
                } else { //ascending
                    nextNote = previousNote + nextNote
                    if nextNote <= 72 {
                        done = true
                    }
                }
            }
            notes.append(nextNote)
            switch abs(Int(previousNote) - Int(nextNote)) {
            case 1: answer[decision] = "minor second"
            case 2: answer[decision] = "Major second"
            case 3: answer[decision] = "minor third"
            case 4: answer[decision] = "Major third"
            case 5: answer[decision] = "Perfect fourth"
            case 6: answer[decision] = "tritone"
            case 7: answer[decision] = "Perfect fifth"
            case 8: answer[decision] = "minor sixth"
            case 9: answer[decision] = "Major sixth"
            case 10: answer[decision] = "minor seventh"
            case 11: answer[decision] = "Major seventh"
            case 12: answer[decision] = "Perfect octave"
            default: answer[decision] = "not found"
            }
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
        counter += 1
        
        if diatonic {
            diatonicAnswerString = "1, "
            notes.removeAll()
            rootNote = UInt8(60) //UInt8(Int.random(in: 49...70))
            notes.append(rootNote)
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
            let scaleType = Int.random(in: 1...3)
            switch scaleType {
                
                //Major scale
            case 1:
                let decision = Int.random(in: 1...4) // five cases now
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
        }
        
        if individual {
            diatonic = false
            prompt = ""
            notes.removeAll()
            rootNote = UInt8(Int.random(in: 49...63)) //leave room for my vocal range
            notes.append(rootNote)
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
            var done = false
            while !done { //have an audible range
                nextNote = UInt8(Int.random(in: 1...12))
                let coinflip = Int.random(in: 1...2)
                if coinflip == 1 { //descending
                    nextNote = rootNote - nextNote
                    if nextNote > 47 {
                        prompt += "Descending "
                        done = true
                    }
                } else { //ascending
                    nextNote = rootNote + nextNote
                    if nextNote <= 65 {
                        prompt += "Ascending "
                        done = true
                    }
                }
            }
            notes.append(nextNote)
            switch abs(Int(rootNote) - Int(nextNote)) {
            case 1: interval = "minor second"
            case 2: interval = "Major second"
            case 3: interval = "minor third"
            case 4: interval = "Major third"
            case 5: interval = "Perfect fourth"
            case 6: interval = "tritone"
            case 7: interval = "Perfect fifth"
            case 8: interval = "minor sixth"
            case 9: interval = "Major sixth"
            case 10: interval = "minor seventh"
            case 11: interval = "Major seventh"
            case 12: interval = "Perfect octave"
            default: interval = "not found"
            }
            prompt += interval
        }
        if individual {
            playRoot()
        } else {
            playSequence()
        }
    }
    
    func majorScaleAscendingPicker(note: UInt8) {
        switch note {
        case 1: notes.append(rootNote)
        case 2: notes.append(rootNote + 2)
        case 3: notes.append(rootNote + 4)
        case 4: notes.append(rootNote + 5)
        case 5: notes.append(rootNote + 7)
        case 6: notes.append(rootNote + 9)
        case 7: notes.append(rootNote + 11)
        case 8: notes.append(rootNote + 12)
        default: print("something went wrong")
        }
    }
    
    func majorScaleDescendingPicker(note: UInt8) {
        switch note {
        case 1: notes.append(rootNote - 12)
        case 2: notes.append(rootNote - 10)
        case 3: notes.append(rootNote - 8)
        case 4: notes.append(rootNote - 7)
        case 5: notes.append(rootNote - 5)
        case 6: notes.append(rootNote - 3)
        case 7: notes.append(rootNote - 1)
        case 8: notes.append(rootNote)
        default: print("something went wrong")
        }
    }
    
    func minorScaleAscendingPicker(note: UInt8) {
        switch note {
        case 1: notes.append(rootNote)
        case 2: notes.append(rootNote + 2)
        case 3: notes.append(rootNote + 3)
        case 4: notes.append(rootNote + 5)
        case 5: notes.append(rootNote + 7)
        case 6: notes.append(rootNote + 8)
        case 7: notes.append(rootNote + 10)
        case 8: notes.append(rootNote + 12)
        default: print("something went wrong")
        }
    }
    
    func minorScaleDescendingPicker(note: UInt8) {
        switch note {
        case 1: notes.append(rootNote - 12)
        case 2: notes.append(rootNote - 10)
        case 3: notes.append(rootNote - 9)
        case 4: notes.append(rootNote - 7)
        case 5: notes.append(rootNote - 5)
        case 6: notes.append(rootNote - 4)
        case 7: notes.append(rootNote - 2)
        case 8: notes.append(rootNote)
        default: print("something went wrong")
        }
    }
    
    func harMinorScaleAscendingPicker(note: UInt8) {
        switch note {
        case 1: notes.append(rootNote)
        case 2: notes.append(rootNote + 2)
        case 3: notes.append(rootNote + 3)
        case 4: notes.append(rootNote + 5)
        case 5: notes.append(rootNote + 7)
        case 6: notes.append(rootNote + 8)
        case 7: notes.append(rootNote + 11)
        case 8: notes.append(rootNote + 12)
        default: print("something went wrong")
        }
    }
    
    func harMinorScaleDescendingPicker(note: UInt8) {
        switch note {
        case 1: notes.append(rootNote - 12)
        case 2: notes.append(rootNote - 10)
        case 3: notes.append(rootNote - 9)
        case 4: notes.append(rootNote - 7)
        case 5: notes.append(rootNote - 5)
        case 6: notes.append(rootNote - 4)
        case 7: notes.append(rootNote - 1)
        case 8: notes.append(rootNote)
        default: print("something went wrong")
        }
    }
    
    func playSequence() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 0..<notes.count {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
    
    func playRoot() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 0...0 {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
    
    func playFirst() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 0...1 {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
    
    func playSecond() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 1...2 {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
    
    func playThird() {
        print(notes)
        /// Create a sequence
        var sequence : MusicSequence? = nil
        var musicSequenceStatus = NewMusicSequence(&sequence)
        var track : MusicTrack? = nil
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(sequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, tempo) != noErr {
            print("could not set tempo")
        } //60 is what it was
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 5.0, 256.0) != noErr {
            print("could not set tempo") //was set to 256
        }
        
        /// Create a music track containg a sequence and a music track
        var musicTrack = MusicSequenceNewTrack(sequence!, &track)
        var time = MusicTimeStamp(1.0)

        
        
        // The notes of the song
        for index:Int in 2..<notes.count {
            var note = MIDINoteMessage(channel: 0,
                                       note: notes[index],
                                       velocity: 100,
                                       releaseVelocity: 0,
                                       duration: 1.0)
            guard let track = track else {fatalError()}
            musicTrack = MusicTrackNewMIDINoteEvent(track, time, &note)
            time += 1
        }
        // Creating a player
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, sequence)
        player = MusicPlayerStart(musicPlayer!)
    }
}

#Preview {
    VocalView()
}
