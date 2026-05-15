//
//  DiatonicChordView.swift
//  Music App
//
//  Created by Nathan Davis on 1/6/24.
//

import SwiftUI
import AVFoundation

struct DiatonicChordView: View {
    @State var counter = 0
    @State var rootNote: UInt8 = 60
    @State var rootNoteLetter = "C"
    @State var answer = ["I", "ii", "iii", ""]
    @State var chords: [[UInt8]] = [[60, 64, 67], [62, 65, 69], [64, 67, 71]]
    @State var singles = false
    @State var singlesAnswer = "default"
    @State var onlyMm7 = false
    @State var settings = false
    @State var major = true
    @State var minor = true
    @State var dim = true
    @State var aug = true
    @State var maj7 = true
    @State var min7 = true
    @State var dom = true
    @State var halfDim7 = true
    @State var dimMaj7 = true
    @State var fullDim7 = true
    @State var superDim = true
    @State var minMaj7 = true
    @State var aug7 = true
    var highestNote = 84
    @State var chordHighestNote: UInt8 = 84 // 72 is the C above middle C
    @State var nextChords = [2, 3]
    @State var nextStartingNotes = [0]
    @State var chordList = ["Maj9"]
    @State var spicy = false
    @State private var showingAboutSheet = false
    var spicyMajor = ["Maj9", "Maj#11", "Maj13", "Maj6", "Maj6/9", "Maj6/9#11", "Maj6/9(#11,13)"]
    var spicyMinor = ["mM7", "min9", "min11", "min13", "min6", "min6/9", "min6/9(11)", "min6/9(11,13)"]
    var spicyDominant = ["7#5", "9", "9#5", "7(#9b5)", "7(#9#5)", "7(b9#9#5)", "7(#5b9#9#11)", "b9", "#9", "9(#11)", "13", "13(#11)", "13(b9#11)", "13(#9#11)", "7sus4", "9sus4", "13sus4", "7sus4(b9)", "13sus4(b9)"]
    var spicyDiminished = ["°M7", "°7", "super-diminished", "min9(b5)", "min7b5(9,11)", "min7b5(9,11,b13)", "dim7(9)", "dim7(9,11)"]
     // C, D, and E major chords
     // ° ∅
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()

                    VStack(alignment: .trailing) {
                        Toggle("", isOn: $spicy)
                            .tint(.purple)
                            .padding(.horizontal)
                    }
                }
                Spacer()
            } // toggle
            VStack {
                Text("Score: " + String(counter))
                    .font(.system(size: 30))
                    .padding()
                Text("Root Note:")
                    .font(.system(size: 30))
                Text(rootNoteLetter)
                    .font(.system(size: 80))
                Button("Play Chords") {
                    playChords(chords: chords)
                }
                .foregroundStyle(.primary)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("Next") {
                    next()
                }
                .foregroundStyle(.primary)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            } // main display
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Text(String(answer[0] + ", " + answer[1] + ", " + answer[2]))
                        .font(.subheadline)
                    if answer[3] != "" {
                        Text(", " + String(answer[3]))
                    }
                }
                
            } // answer
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
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
                        Text("Listen to the chord progression and identify which chords were played.")
                    }

                    Section("Normal Mode") {
                        Text("With the toggle off, the app plays three or four chords built from a major, minor, or harmonic minor scale.")
                        Text("The chords could be triads with the octave doubled on top or seventh chords, making this the practical mode for training diatonic harmony.")
                    }

                    Section("Extended Mode") {
                        Text("With the toggle on, the app draws from the full chord list, including extended and altered chords.")
                        Text("This mode was made for experimental use and might be impossible to identify by ear, but it can be useful for hearing advanced chord colors.")
                    }
                    
                    Section("Roman Numerals") {
                        Text("Uppercase Roman numerals indicate major chords.")
                        Text("Lowercase Roman numerals indicate minor chords.")
                        Text("° indicates diminished and ∅ indicates half-diminished.")
                        Text("7 indicates a seventh chord.")
                    }

                    Section("Controls") {
                        Text("Tap Play Chords to hear the current progression again.")
                        Text("Tap Next to generate a new progression.")
                        Text("Use the purple toggle to switch between normal and extended chord mode.")
                    }
                }
                .navigationTitle("About Diatonic Chords")
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
    
    func next() {
        counter += 1
        chords.removeAll()
        rootNote = UInt8(Int.random(in: 52...72)) // 72 is the C above middle C
        chordHighestNote = 84
        rootNoteLetter = rootNoteLetter(note: rootNote)
        //decide if Major, minor, or harmonic minor
        let majorMinorDecision = Int.random(in: 1...3)
        nextChords.removeAll()
        chordList.removeAll()
        if answer[3] != "" {
            answer[3] = ""
        }
        if spicy {
            for _ in 1...2 {
                nextChords.append(Int.random(in: 2...7))
            }
            print(nextChords)
            if nextChords[1] == 5 {
                nextChords.append(1)
                print("ended with a five: \(nextChords)")
            }
        }
        
        switch majorMinorDecision {
            
            //Major
        case 1:
            if spicy {
                majorNoteSequence(chordRoots: nextChords)
                let chosenChord = spicyMajor.randomElement()
                chordList.append(chosenChord ?? "No spicyMajor chords?")
                answer[0] = "I" + (chosenChord ?? "idk")
                print(answer[0])
                // ["Maj9", "Maj#11", "Maj13", "Maj6", "Maj6/9", "Maj6/9#11", "Maj6/9(#11,13)"]
                switch chosenChord {
                case "Maj9":
                    major9(note: rootNote)
                case "Maj#11":
                    majorSharp11(note: rootNote)
                case "Maj13":
                    major13(note: rootNote)
                case "Maj6":
                    major6(note: rootNote)
                case "Maj6/9":
                    major69(note: rootNote)
                case "Maj6/9#11":
                    major69Sharp11(note: rootNote)
                case "Maj6/9(#11,13)":
                    major69Sharp11add13(note: rootNote)
                default: print("something went wrong with the spice")
                }
                for chord in 0..<nextChords.count {
                    switch nextChords[chord] {
                    case 1:
                        let chosenChord = spicyMajor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMajor chords?")
                        answer[0 + chord + 1] = "I" + (chosenChord ?? "idk")
                    case 2:
                        let chosenChord = spicyMinor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "ii" + (chosenChord ?? "idk")
                    case 3:
                        let chosenChord = spicyMinor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "iii" + (chosenChord ?? "idk")
                    case 4:
                        let chosenChord = spicyMajor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMajor chords?")
                        answer[0 + chord + 1] = "IV" + (chosenChord ?? "idk")
                    case 5:
                        let chosenChord = spicyDominant.randomElement()
                        chordList.append(chosenChord ?? "No spicyMajor chords?")
                        answer[0 + chord + 1] = "V" + (chosenChord ?? "idk")
                    case 6:
                        let chosenChord = spicyMinor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "vi" + (chosenChord ?? "idk")
                    case 7:
                        let chosenChord = spicyDiminished.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "vii" + (chosenChord ?? "idk")
                    default: print("something went wrong with the spicy next chords in major")
                    }
                    print(answer[0 + chord + 1])
                }
                masterChordBuilder(note: rootNote)
                if chordHighestNote > highestNote {
                    rootNote = UInt8(Int.random(in: 52...(Int(rootNote) - (Int(chordHighestNote) - highestNote))))
                    rootNoteLetter = rootNoteLetter(note: rootNote)
                    masterChordBuilder(note: rootNote)
                }
            } else {
                //first chord, the tonic
                //decide if seventh or not
                var coinflip = Int.random(in: 1...2)
                if coinflip == 1 {
                    major(note: rootNote)
                    answer[0] = "I"
                } else {
                    majorSeventh(note: rootNote)
                    answer[0] = "I7"
                }
                //choose second and third chord
                for chord in 1...2 {
                    let nextChord = Int.random(in: 2...7)
                    switch nextChord {
                    case 2:
                        let nextChordRoot = rootNote + 2
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            minor(note: nextChordRoot)
                            answer[chord] = "ii"
                        } else {
                            minorSeventh(note: nextChordRoot)
                            answer[chord] = "ii7"
                        }
                    case 3:
                        let nextChordRoot = rootNote + 4
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            minor(note: nextChordRoot)
                            answer[chord] = "iii"
                        } else {
                            minorSeventh(note: nextChordRoot)
                            answer[chord] = "iii7"
                        }
                    case 4:
                        let nextChordRoot = rootNote + 5
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            major(note: nextChordRoot)
                            answer[chord] = "IV"
                        } else {
                            majorSeventh(note: nextChordRoot)
                            answer[chord] = "IV7"
                        }
                    case 5:
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            let nextChordRoot = rootNote + 7
                            //decide if seventh or not
                            coinflip = Int.random(in: 1...2)
                            if coinflip == 1 {
                                major(note: nextChordRoot)
                                answer[chord] = "V"
                            } else {
                                domSeventh(note: nextChordRoot)
                                answer[chord] = "V7"
                            }
                        } else {
                            let nextChordRoot = rootNote - 5
                            //decide if seventh or not
                            coinflip = Int.random(in: 1...2)
                            if coinflip == 1 {
                                major(note: nextChordRoot)
                                answer[chord] = "V"
                            } else {
                                domSeventh(note: nextChordRoot)
                                answer[chord] = "V7"
                            }
                        }
                    case 6:
                        let nextChordRoot = rootNote - 3 // +9 or -3
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            minor(note: nextChordRoot)
                            answer[chord] = "vi"
                        } else {
                            minorSeventh(note: nextChordRoot)
                            answer[chord] = "vi7"
                        }
                    case 7:
                        let nextChordRoot = rootNote - 1 // +11 or -1, took it down because it could get super high
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            diminished(note: nextChordRoot)
                            answer[chord] = "vii°"
                        } else {
                            halfDimSeventh(note: nextChordRoot)
                            answer[chord] = "vii∅7"
                        }
                    default: print("something went wrong1")
                    }
                }
                
            }
            
            //minor
        case 2:
            if spicy {
                minorNoteSequence(chordRoots: nextChords)
                let chosenChord = spicyMinor.randomElement()
                chordList.append(chosenChord ?? "No spicyMinor chords?")
                answer[0] = "i" + (chosenChord ?? "idk")
                print(answer[0])
                switch chosenChord {
                case "mM7":
                    minorMajorSeventh(note: rootNote)
                case "min9":
                    minor9(note: rootNote)
                case "min11":
                    minor11(note: rootNote)
                case "min13":
                    minor13(note: rootNote)
                case "min6":
                    minor6(note: rootNote)
                case "min6/9":
                    minor69(note: rootNote)
                case "min6/9(11)":
                    minor69nat11(note: rootNote)
                case "min6/9(11,13)":
                    minor691113(note: rootNote)
                default: print("something went wrong with the minor spicy: \(chosenChord ?? "shrugs")")
                }
                for chord in 0..<nextChords.count {
                    switch nextChords[chord] {
                    case 1:
                        let chosenChord = spicyMinor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "i" + (chosenChord ?? "idk")
                    case 2:
                        let chosenChord = spicyDiminished.randomElement()
                        chordList.append(chosenChord ?? "No spicyDiminished chords?")
                        answer[0 + chord + 1] = "ii" + (chosenChord ?? "idk")
                    case 3:
                        let chosenChord = spicyMajor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMajor chords?")
                        answer[0 + chord + 1] = "III" + (chosenChord ?? "idk")
                    case 4:
                        let chosenChord = spicyMinor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "iv" + (chosenChord ?? "idk")
                    case 5:
                        let chosenChord = spicyMinor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "v" + (chosenChord ?? "idk")
                    case 6:
                        let chosenChord = spicyMajor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMajor chords?")
                        answer[0 + chord + 1] = "VI" + (chosenChord ?? "idk")
                    case 7:
                        let chosenChord = spicyMajor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMajor chords?")
                        answer[0 + chord + 1] = "VII" + (chosenChord ?? "idk")
                    default: print("something went wrong with the spicy next chords in minor")
                    }
                    print(answer[0 + chord + 1])
                }
                masterChordBuilder(note: rootNote)
                if chordHighestNote > highestNote {
                    rootNote = UInt8(Int.random(in: 52...(Int(rootNote) - (Int(chordHighestNote) - highestNote))))
                    rootNoteLetter = rootNoteLetter(note: rootNote)
                    masterChordBuilder(note: rootNote)
                }
            } else {
                //first chord, the tonic
                //decide if seventh or not
                var coinflip = Int.random(in: 1...2)
                if coinflip == 1 {
                    minor(note: rootNote)
                    answer[0] = "i"
                    singlesAnswer = "minor"
                } else {
                    minorSeventh(note: rootNote)
                    answer[0] = "i7"
                    singlesAnswer = "minor seventh"
                }
                //choose next chords
                for chord in 1...2 {
                    let nextChord = Int.random(in: 2...7)
                    switch nextChord {
                    case 2:
                        let nextChordRoot = rootNote + 2
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            diminished(note: nextChordRoot)
                            answer[chord] = "ii°"
                        } else {
                            halfDimSeventh(note: nextChordRoot)
                            answer[chord] = "ii∅7"
                        }
                    case 3:
                        let nextChordRoot = rootNote + 3
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            major(note: nextChordRoot)
                            answer[chord] = "III"
                        } else {
                            majorSeventh(note: nextChordRoot)
                            answer[chord] = "III7"
                        }
                    case 4:
                        let nextChordRoot = rootNote + 5
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            minor(note: nextChordRoot)
                            answer[chord] = "iv"
                        } else {
                            minorSeventh(note: nextChordRoot)
                            answer[chord] = "iv7"
                        }
                    case 5:
                        let nextChordRoot = rootNote + 7
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            minor(note: nextChordRoot)
                            answer[chord] = "v"
                        } else {
                            minorSeventh(note: nextChordRoot)
                            answer[chord] = "v7"
                        }
                    case 6:
                        let nextChordRoot = rootNote - 4 // +8 or -4
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            major(note: nextChordRoot)
                            answer[chord] = "VI"
                        } else {
                            majorSeventh(note: nextChordRoot)
                            answer[chord] = "VI7"
                        }
                    case 7:
                        let nextChordRoot = rootNote - 2 // +10 or -2
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            major(note: nextChordRoot)
                            answer[chord] = "VII"
                        } else {
                            domSeventh(note: nextChordRoot)
                            answer[chord] = "VII7"
                        }
                    default: print("something went wrong2")
                    }
                }
                
            }
            
            //harmonic-minor
        case 3:
            if spicy {
                harmonicMinorNoteSequence(chordRoots: nextChords)
                let chosenChord = spicyMinor.randomElement()
                chordList.append(chosenChord ?? "No spicyMinor chords?")
                answer[0] = "i" + (chosenChord ?? "idk")
                print(answer[0])
                switch chosenChord {
                case "mM7":
                    minorMajorSeventh(note: rootNote)
                case "min9":
                    minor9(note: rootNote)
                case "min11":
                    minor11(note: rootNote)
                case "min13":
                    minor13(note: rootNote)
                case "min6":
                    minor6(note: rootNote)
                case "min6/9":
                    minor69(note: rootNote)
                case "min6/9(11)":
                    minor69nat11(note: rootNote)
                case "min6/9(11,13)":
                    minor691113(note: rootNote)
                default: print("something went wrong with the minor spicy: \(chosenChord ?? "shrugs")")
                }
                for chord in 0..<nextChords.count {
                    switch nextChords[chord] {
                    case 1:
                        let chosenChord = spicyMinor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "i" + (chosenChord ?? "idk")
                    case 2:
                        let chosenChord = spicyDiminished.randomElement()
                        chordList.append(chosenChord ?? "No spicyDiminished chords?")
                        answer[0 + chord + 1] = "ii" + (chosenChord ?? "idk")
                    case 3:
                        let chosenChord = spicyMajor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMajor chords?")
                        answer[0 + chord + 1] = "III" + (chosenChord ?? "idk")
                    case 4:
                        let chosenChord = spicyMinor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "iv" + (chosenChord ?? "idk")
                    case 5:
                        let chosenChord = spicyMinor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMinor chords?")
                        answer[0 + chord + 1] = "v" + (chosenChord ?? "idk")
                    case 6:
                        let chosenChord = spicyMajor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMajor chords?")
                        answer[0 + chord + 1] = "VI" + (chosenChord ?? "idk")
                    case 7:
                        let chosenChord = spicyMajor.randomElement()
                        chordList.append(chosenChord ?? "No spicyMajor chords?")
                        answer[0 + chord + 1] = "VII" + (chosenChord ?? "idk")
                    default: print("something went wrong with the spicy next chords in minor")
                    }
                    print(answer[0 + chord + 1])
                }
                masterChordBuilder(note: rootNote)
                if chordHighestNote > highestNote {
                    rootNote = UInt8(Int.random(in: 52...(Int(rootNote) - (Int(chordHighestNote) - highestNote))))
                    rootNoteLetter = rootNoteLetter(note: rootNote)
                    masterChordBuilder(note: rootNote)
                }
            } else {
                //first chord, the tonic
                //decide if seventh or not
                var coinflip = Int.random(in: 1...2)
                if coinflip == 1 {
                    minor(note: rootNote)
                    answer[0] = "i"
                    singlesAnswer = "minor"
                } else {
                    minorMajorSeventh(note: rootNote)
                    answer[0] = "imM7"
                    singlesAnswer = "minor-Major seventh"
                }
                //choose next chords
                for chord in 1...2 {
                    let nextChord = Int.random(in: 2...7)
                    switch nextChord {
                    case 2:
                        let nextChordRoot = rootNote + 2
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            diminished(note: nextChordRoot)
                            answer[chord] = "ii°"
                        } else {
                            halfDimSeventh(note: nextChordRoot)
                            answer[chord] = "ii∅7"
                        }
                    case 3:
                        let nextChordRoot = rootNote + 3
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            augmented(note: nextChordRoot)
                            answer[chord] = "III+"
                        } else {
                            augSeventh(note: nextChordRoot)
                            answer[chord] = "III+M7"
                        }
                    case 4:
                        let nextChordRoot = rootNote + 5
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            minor(note: nextChordRoot)
                            answer[chord] = "iv"
                        } else {
                            minorSeventh(note: nextChordRoot)
                            answer[chord] = "iv7"
                        }
                    case 5:
                        let nextChordRoot = rootNote + 7
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            major(note: nextChordRoot)
                            answer[chord] = "V"
                        } else {
                            domSeventh(note: nextChordRoot)
                            answer[chord] = "V7"
                        }
                    case 6:
                        let nextChordRoot = rootNote - 4 // +8 or -4
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            major(note: nextChordRoot)
                            answer[chord] = "VI"
                        } else {
                            majorSeventh(note: nextChordRoot)
                            answer[chord] = "VI7"
                        }
                    case 7:
                        let nextChordRoot = rootNote - 1 // +11 or -1
                        //decide if seventh or not
                        coinflip = Int.random(in: 1...2)
                        if coinflip == 1 {
                            diminished(note: nextChordRoot)
                            answer[chord] = "vii°"
                        } else {
                            fullyDimSeventh(note: nextChordRoot)
                            answer[chord] = "vii°7"
                        }
                    default: print("something went wrong3")
                    }
                }
            }
            
            
            
        default: print("something went wrong4")
        }
        playChords(chords: chords)
    }
    
    func major(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 12])
        if note + 12 > chordHighestNote {
            chordHighestNote = note + 12
        }
    }
    func major6(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 9])
        if note + 9 > chordHighestNote {
            chordHighestNote = note + 9
        }
        chordHighestNote = note + 9
    }
    func major69(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 9, note + 14])
        if note + 14 > chordHighestNote {
            chordHighestNote = note + 14
        }
    }
    func major69Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 9, note + 14, note + 18])
        if note + 18 > chordHighestNote {
            chordHighestNote = note + 18
        }
    }
    func major69Sharp11add13(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 9, note + 14, note + 18, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func majorSeventh(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 11])
        if note + 11 > chordHighestNote {
            chordHighestNote = note + 11
        }
    }
    func major9(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 11, note + 14])
        if note + 14 > chordHighestNote {
            chordHighestNote = note + 14
        }
    }
    func majorSharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 11, note + 14, note + 18])
        if note + 18 > chordHighestNote {
            chordHighestNote = note + 18
        }
    }
    func major13(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 11, note + 14, note + 18, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func minor(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 12])
        if note + 12 > chordHighestNote {
            chordHighestNote = note + 12
        }
        chordHighestNote = note + 12
    }
    func minor6(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 9])
        if note + 9 > chordHighestNote {
            chordHighestNote = note + 9
        }
    }
    func minor69(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 9, note + 14])
        if note + 14 > chordHighestNote {
            chordHighestNote = note + 14
        }
    }
    func minor69nat11(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 9, note + 14, note + 17])
        if note + 17 > chordHighestNote {
            chordHighestNote = note + 17
        }
    }
    func minor691113(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 9, note + 14, note + 17, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func minorSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 10])
        if note + 10 > chordHighestNote {
            chordHighestNote = note + 10
        }
    }
    func minor9(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 10, note + 14])
        if note + 14 > chordHighestNote {
            chordHighestNote = note + 14
        }
    }
    func minor11(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 10, note + 14, note + 17])
        if note + 17 > chordHighestNote {
            chordHighestNote = note + 17
        }
    }
    func minor13(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 10, note + 14, note + 17, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func domSeventh(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10])
        if note + 10 > chordHighestNote {
            chordHighestNote = note + 10
        }
    }
    func domSharp5(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10])
        if note + 10 > chordHighestNote {
            chordHighestNote = note + 10
        }
    }
    func domNine(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 14])
        if note + 14 > chordHighestNote {
            chordHighestNote = note + 14
        }
    }
    func domNineSharp5(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10, note + 14])
        if note + 14 > chordHighestNote {
            chordHighestNote = note + 14
        }
    }
    func domSharp9Flat5(note: UInt8) {
        chords.append([note, note + 4, note + 6, note + 10, note + 15])
        if note + 15 > chordHighestNote {
            chordHighestNote = note + 15
        }
    }
    func domSharp9Sharp5(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10, note + 15])
        if note + 15 > chordHighestNote {
            chordHighestNote = note + 15
        }
    }
    func domFlat9Sharp9Sharp5(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10, note + 13, note + 15])
        if note + 15 > chordHighestNote {
            chordHighestNote = note + 15
        }
    }
    func domSharp5Flat9Sharp9Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10, note + 13, note + 15, note + 18])
        if note + 18 > chordHighestNote {
            chordHighestNote = note + 18
        }
    }
    func domFlat9(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 13])
        if note + 13 > chordHighestNote {
            chordHighestNote = note + 13
        }
    }
    func domSharp9(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 15])
        if note + 15 > chordHighestNote {
            chordHighestNote = note + 15
        }
    }
    func dom9Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 14, note + 18])
        if note + 18 > chordHighestNote {
            chordHighestNote = note + 18
        }
    }
    func dom13(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 14, note + 17, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func dom13Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 14, note + 18, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func dom13Flat9Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 13, note + 18, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func dom13Sharp9Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 15, note + 18, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func dom7sus4(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10])
        if note + 10 > chordHighestNote {
            chordHighestNote = note + 10
        }
    }
    func dom9sus4(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10, note + 14])
        if note + 14 > chordHighestNote {
            chordHighestNote = note + 14
        }
    }
    func dom7sus4Flat9(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10, note + 13])
        if note + 13 > chordHighestNote {
            chordHighestNote = note + 13
        }
    }
    func dom13sus4(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10, note + 14, note + 18, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func dom13sus4Flat9(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10, note + 13, note + 18, note + 21])
        if note + 21 > chordHighestNote {
            chordHighestNote = note + 21
        }
    }
    func diminished(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 12])
        if note + 12 > chordHighestNote {
            chordHighestNote = note + 12
        }
    }
    func halfDimSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 10])
        if note + 10 > chordHighestNote {
            chordHighestNote = note + 10
        }
    }
    func minor9Flat5(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 10, note + 14])
        if note + 14 > chordHighestNote {
            chordHighestNote = note + 14
        }
    }
    func minor7Flat5911(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 10, note + 14, note + 17])
        if note + 17 > chordHighestNote {
            chordHighestNote = note + 17
        }
    }
    func minor7Flat5911Flat13(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 10, note + 14, note + 17, note + 20])
        if note + 20 > chordHighestNote {
            chordHighestNote = note + 20
        }
    }
    func dimMajorSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 11])
        if note + 11 > chordHighestNote {
            chordHighestNote = note + 11
        }
    }
    func augmented(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 12])
        if note + 12 > chordHighestNote {
            chordHighestNote = note + 12
        }
    }
    func augSeventh(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 11])
        if note + 11 > chordHighestNote {
            chordHighestNote = note + 11
        }
    }
    func minorMajorSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 11])
        if note + 11 > chordHighestNote {
            chordHighestNote = note + 11
        }
    }
    func fullyDimSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 9])
        if note + 9 > chordHighestNote {
            chordHighestNote = note + 9
        }
    }
    func diminished79(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 9, note + 14])
        if note + 14 > chordHighestNote {
            chordHighestNote = note + 14
        }
    }
    func diminished7911(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 9, note + 14, note + 17])
        if note + 17 > chordHighestNote {
            chordHighestNote = note + 17
        }
    }
    func superDiminished(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 9, note + 12])
        if note + 12 > chordHighestNote {
            chordHighestNote = note + 12
        }
    }
    
    func rootNoteLetter(note: UInt8) -> String {
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
    
    func majorNoteSequence(chordRoots: [Int]) {
        // take in the next chords
        nextStartingNotes = [0]
        for note in 0..<chordRoots.count {
            switch chordRoots[note] {
            case 1: nextStartingNotes.append(0)
            case 2: nextStartingNotes.append(2)
            case 3: nextStartingNotes.append(4)
            case 4: nextStartingNotes.append(5)
            case 5:
                if chordRoots[1] < 5 {
                    nextStartingNotes.append(7)
                } else {
                    nextStartingNotes.append(-5)
                }
            case 6: nextStartingNotes.append(-3)
            case 7: nextStartingNotes.append(-1)
            default: print("something went wrong in majorNoteSequence")
            }
        }
    }
    
    func minorNoteSequence(chordRoots: [Int]) {
        // take in the next chords
        nextStartingNotes = [0]
        for note in 0..<chordRoots.count {
            switch chordRoots[note] {
            case 1: nextStartingNotes.append(0)
            case 2: nextStartingNotes.append(2)
            case 3: nextStartingNotes.append(3) // minor third
            case 4: nextStartingNotes.append(5)
            case 5:
                if chordRoots[1] < 5 {
                    nextStartingNotes.append(7)
                } else {
                    nextStartingNotes.append(-5)
                }
            case 6: nextStartingNotes.append(-4) // minor sixth
            case 7: nextStartingNotes.append(-2) // minor seventh
            default: print("something went wrong in minorNoteSequence")
            }
        }
    }
    
    func harmonicMinorNoteSequence(chordRoots: [Int]) {
        // take in the next chords
        nextStartingNotes = [0]
        for note in 0..<chordRoots.count {
            switch chordRoots[note] {
            case 1: nextStartingNotes.append(0)
            case 2: nextStartingNotes.append(2)
            case 3: nextStartingNotes.append(3) // minor third
            case 4: nextStartingNotes.append(5)
            case 5:
                if chordRoots[1] < 5 {
                    nextStartingNotes.append(7)
                } else {
                    nextStartingNotes.append(-5)
                }
            case 6: nextStartingNotes.append(-4) // minor sixth
            case 7: nextStartingNotes.append(-1) // natural seventh
            default: print("something went wrong in minorNoteSequence")
            }
        }
    }
    
    func masterChordBuilder(note: UInt8) {
        chords.removeAll()
        var chordCount: Int = (answer[3] == "" ? 3 : 4)
        for chord in 0..<chordCount {
            switch chordList[chord] {
            case "Major": major(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "Major 7th": majorSeventh(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "Maj9": major9(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "Maj#11": majorSharp11(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "Maj13": major13(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "Maj6": major6(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "Maj6/9": major69(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "Maj6/9#11": major69Sharp11(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "Maj6/9(#11,13)": major69Sharp11add13(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "minor": minor(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "diminished": diminished(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "augmented": augmented(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "minor 7th": minorSeventh(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "Dominant 7th": domSeventh(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "half-diminished 7th": halfDimSeventh(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "°M7": dimMajorSeventh(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "°7": fullyDimSeventh(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "super-diminished": superDiminished(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "mM7": minorMajorSeventh(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "augmented 7th": augSeventh(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min9": minor9(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min11": minor11(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min13": minor13(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min6": minor6(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min6/9": minor69(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min6/9(11)": minor69nat11(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min6/9(11,13)": minor691113(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "7#5": domSharp5(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "9": domNine(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "9#5": domNineSharp5(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "7(#9b5)": domSharp9Flat5(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "7(#9#5)": domSharp9Sharp5(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "7(b9#9#5)": domFlat9Sharp9Sharp5(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "7(#5b9#9#11)": domSharp5Flat9Sharp9Sharp11(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "b9": domFlat9(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "#9": domSharp9(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "9(#11)": dom9Sharp11(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "13": dom13(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "13(#11)": dom13Sharp11(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "13(b9#11)": dom13Flat9Sharp11(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "13(#9#11)": dom13Sharp9Sharp11(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min9(b5)": minor9Flat5(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min7b5(9,11)": minor7Flat5911(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "min7b5(9,11,b13)": minor7Flat5911Flat13(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "dim7(9)": diminished79(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "dim7(9,11)": diminished7911(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "7sus4": dom7sus4(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "9sus4": dom9sus4(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "13sus4": dom13sus4(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "7sus4(b9)": dom7sus4Flat9(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            case "13sus4(b9)": dom13sus4Flat9(note: UInt8(Int(rootNote) + nextStartingNotes[chord]))
            default:
                print("something went wrong with the masterChordBuilder: \(chordList[chord])")
            }
        }
    }
    
    func playChords(chords: [[UInt8]]) {
        // One chord per beat (each inner array plays simultaneously)
        PianoSequencePlayer.shared.playChordBatches(chords: chords, tempoBPM: 58.0)
    }
}

#Preview {
    DiatonicChordView()
}
