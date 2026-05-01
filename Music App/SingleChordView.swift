//
//  SingleChordView.swift
//  Music App
//
//  Created by Nathan Davis on 2025-04-22.
//

import SwiftUI
import AVFoundation

struct SingleChordView: View {
    @State var counter = 0
    @State var rootNote: UInt8 = 60
    @State var highestNote: UInt8 = 84
    @State var chordHighestNote: UInt8 = 84
    @State var rootNoteLetter = "C"
    @State var chords: [[UInt8]] = [[60, 64, 67], [62, 65, 69], [64, 67, 71]]
    @State var singles = true
    @State var singlesAnswer = "default"
    @State var settings = false
    
    @State private var showNoChordsAlert = false
    
    @State private var chordOptions: [ChordOption] = [
        // Normal
        .init(name: "Major", category: .normal, isOn: true),
        .init(name: "minor", category: .normal, isOn: true),
        .init(name: "diminished", category: .normal, isOn: true),
        .init(name: "augmented", category: .normal, isOn: true),
        .init(name: "Major 7th", category: .normal, isOn: true),
        .init(name: "minor 7th", category: .normal, isOn: true),
        .init(name: "Dominant 7th", category: .normal, isOn: true),
        .init(name: "half-diminished 7th", category: .normal, isOn: true),
        .init(name: "diminished Major 7th", category: .normal, isOn: true),
        .init(name: "fully-diminished 7th", category: .normal, isOn: true),
        .init(name: "super-diminished", category: .normal, isOn: true),
        .init(name: "minor-Major 7th", category: .normal, isOn: true),
        .init(name: "augmented 7th", category: .normal, isOn: true),

        // Major Extended
        .init(name: "Maj9", category: .majorExtended, isOn: true),
        .init(name: "Maj#11", category: .majorExtended, isOn: true),
        .init(name: "Maj13", category: .majorExtended, isOn: true),
        .init(name: "Maj6", category: .majorExtended, isOn: true),
        .init(name: "Maj6/9", category: .majorExtended, isOn: true),
        .init(name: "Maj6/9#11", category: .majorExtended, isOn: true),
        .init(name: "Maj6/9(#11,13)", category: .majorExtended, isOn: true),

        // Minor Extended
        .init(name: "min9", category: .minorExtended, isOn: true),
        .init(name: "min11", category: .minorExtended, isOn: true),
        .init(name: "min13", category: .minorExtended, isOn: true),
        .init(name: "min6", category: .minorExtended, isOn: true),
        .init(name: "min6/9", category: .minorExtended, isOn: true),
        .init(name: "min6/9(11)", category: .minorExtended, isOn: true),
        .init(name: "min6/9(11,13)", category: .minorExtended, isOn: true),

        // Dominant Extended
        .init(name: "7#5", category: .dominantExtended, isOn: true),
        .init(name: "9", category: .dominantExtended, isOn: true),
        .init(name: "9#5", category: .dominantExtended, isOn: true),
        .init(name: "7(#9b5)", category: .dominantExtended, isOn: true),
        .init(name: "7(#9#5)", category: .dominantExtended, isOn: true),
        .init(name: "7(b9#9#5)", category: .dominantExtended, isOn: true),
        .init(name: "7(#5b9#9#11)", category: .dominantExtended, isOn: true),
        .init(name: "b9", category: .dominantExtended, isOn: true),
        .init(name: "#9", category: .dominantExtended, isOn: true),
        .init(name: "9(#11)", category: .dominantExtended, isOn: true),
        .init(name: "13", category: .dominantExtended, isOn: true),
        .init(name: "13(#11)", category: .dominantExtended, isOn: true),
        .init(name: "13(b9#11)", category: .dominantExtended, isOn: true),
        .init(name: "13(#9#11)", category: .dominantExtended, isOn: true),

        // Half-Diminished Extended
        .init(name: "min9(b5)", category: .halfDiminishedExtended, isOn: true),
        .init(name: "min7b5(9,11)", category: .halfDiminishedExtended, isOn: true),
        .init(name: "min7b5(9,11,b13)", category: .halfDiminishedExtended, isOn: true),

        // Diminished Extended
        .init(name: "dim7(9)", category: .diminishedExtended, isOn: true),
        .init(name: "dim7(9,11)", category: .diminishedExtended, isOn: true),

        // Suspended Extended
        .init(name: "7sus4", category: .suspendedExtended, isOn: true),
        .init(name: "9sus4", category: .suspendedExtended, isOn: true),
        .init(name: "13sus4", category: .suspendedExtended, isOn: true),
        .init(name: "7sus4(b9)", category: .suspendedExtended, isOn: true),
        .init(name: "13sus4(b9)", category: .suspendedExtended, isOn: true),
    ]
    @State private var showAnswer = false
    
    var chosenChords: [String] {
        chordOptions.filter { $0.isOn }.map { $0.name }
    }
    
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
                    VStack(alignment: .trailing) {
                        Button {
                            settings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .font(.title)
                        .foregroundStyle(.gray)
                        .padding(.init(top: 10, leading: 0, bottom: 0, trailing: 20))
                    }
                }
                Spacer()
            }
            // main display
            VStack {
                Text("Score: " + String(counter))
                    .font(.system(size: 30))
                    .padding()
                    .allowsHitTesting(false)
                Text("Root Note:")
                    .font(.system(size: 30))
                    .allowsHitTesting(false)
                Text(rootNoteLetter)
                    .font(.system(size: 80))
                    .allowsHitTesting(false)
                Button("Play Chords") {
                    playChords(chords: chords)
                }
                .foregroundStyle(.black)
                .padding()
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("Next") {
                    next()
                }
                .foregroundStyle(.black)
                .padding()
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                
            }
            // answer
            VStack {
                Spacer()
                Text(singlesAnswer)
                    .opacity(showAnswer ? 1 : 0)
                    .font(.subheadline)
            } // answer
            
            // settings sheet handled below
        }
        .onAppear {
            next()
            counter = 0
        }
        .fullScreenCover(isPresented: $settings) {
            settingsView
        }
    }

    private var settingsView: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Toggle All", isOn: Binding(
                        get: { chordOptions.allSatisfy { $0.isOn } },
                        set: { toggleAll($0) }
                    ))

                    ForEach(ChordCategory.allCases, id: \.self) { category in
                        if category.rawValue == "Normal" {
                            HStack {
                                Text(category.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Toggle(isOn: Binding(
                                    get: { chordOptions.filter { $0.category == .normal }.allSatisfy { $0.isOn } },
                                    set: { newValue in
                                        for i in chordOptions.indices where chordOptions[i].category == .normal {
                                            chordOptions[i].isOn = newValue
                                        }
                                    }
                                )) {}
                                .scaleEffect(0.5)
                                .labelsHidden()
                            }
                            .padding(.top, 10)
                        } else {
                            Text(category.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 10)
                        }

                        Divider()

                        ForEach(chordOptions.indices.filter { chordOptions[$0].category == category }, id: \.self) { i in
                            HStack {
                                Text(chordOptions[i].name)
                                Spacer()
                                Toggle("", isOn: $chordOptions[i].isOn)
                                    .labelsHidden()
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Chord Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if chosenChords.isEmpty {
                            showNoChordsAlert = true
                        } else {
                            settings = false
                            next()
                        }
                    }
                }
            }
            .alert("No chords selected", isPresented: $showNoChordsAlert) {
                Button("My bad", role: .cancel) { }
            } message: {
                Text("Please select at least one chord before proceeding.")
            }
        }
    }
    func toggleAll(_ on: Bool) {
        for i in chordOptions.indices {
            chordOptions[i].isOn = on
        }
    }
    
    func next() {
        showAnswer = false
        counter += 1
        chords.removeAll()
        rootNote = UInt8(Int.random(in: 52...75)) // 72 is the C above middle C, was 67
        rootNoteLetter = rootNoteLetter(note: rootNote)
        let decision = chosenChords.randomElement()
        print(decision ?? "decision")
        chordHighestNote = 84
        createChord(decision: decision ?? "decision")
        if chordHighestNote > highestNote
        {
            chords.removeAll()
            print("Old root note: \(rootNote)")
            rootNote = UInt8(Int.random(in: 52...Int(rootNote - (chordHighestNote - highestNote))))
            // rootNote -= (chordHighestNote - highestNote)
            print("New root note: \(rootNote)")
            rootNoteLetter = rootNoteLetter(note: rootNote)
            createChord(decision: decision ?? "decision")
        }
        playChords(chords: chords)
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
    
    func createChord(decision: String) {
        switch decision {
        case "Major":
            major(note: rootNote)
            singlesAnswer = "Major"
        case "Major 7th":
            majorSeventh(note: rootNote)
            singlesAnswer = "Major 7th"
        case "minor":
            minor(note: rootNote)
            singlesAnswer = "minor"
        case "minor 7th":
            minorSeventh(note: rootNote)
            singlesAnswer = "minor 7th"
        case "Dominant 7th":
            domSeventh(note: rootNote)
            singlesAnswer = "Dominant 7th"
        case "diminished":
            diminished(note: rootNote)
            singlesAnswer = "diminished"
        case "half-diminished 7th":
            halfDimSeventh(note: rootNote)
            singlesAnswer = "half-diminished 7th"
        case "diminished Major 7th":
            dimMajorSeventh(note: rootNote)
            singlesAnswer = "diminished Major 7th"
        case "augmented":
            augmented(note: rootNote)
            singlesAnswer = "augmented"
        case "augmented 7th":
            augSeventh(note: rootNote)
            singlesAnswer = "Augmented 7th"
        case "minor-Major 7th":
            minorMajorSeventh(note: rootNote)
            singlesAnswer = "minor-Major 7th"
        case "fully-diminished 7th":
            fullyDimSeventh(note: rootNote)
            singlesAnswer = "fully-diminished 7th"
        case "super-diminished":
            superDiminished(note: rootNote)
            singlesAnswer = "super-diminished"
        case "Maj9":
            major9(note: rootNote)
            singlesAnswer = "Maj9"
        case "Maj#11":
            majorSharp11(note: rootNote)
            singlesAnswer = "Maj#11"
        case "Maj13":
            major13(note: rootNote)
            singlesAnswer = "Maj13"
        case "Maj6":
            major6(note: rootNote)
            singlesAnswer = "Maj6"
        case "Maj6/9":
            major69(note: rootNote)
            singlesAnswer = "Maj6/9"
        case "Maj6/9#11":
            major69Sharp11(note: rootNote)
            singlesAnswer = "Maj6/9#11"
        case "Maj6/9(#11,13)":
            major69Sharp11add13(note: rootNote)
            singlesAnswer = "Maj6/9(#11,13)"
        case "min9":
            minor9(note: rootNote)
            singlesAnswer = "min9"
        case "min11":
            minor11(note: rootNote)
            singlesAnswer = "min11"
        case "min13":
            minor13(note: rootNote)
            singlesAnswer = "min13"
        case "min6":
            minor6(note: rootNote)
            singlesAnswer = "min6"
        case "min6/9":
            minor69(note: rootNote)
            singlesAnswer = "min6/9"
        case "min6/9(11)":
            minor69nat11(note: rootNote)
            singlesAnswer = "min6/9(11)"
        case "min6/9(11,13)":
            minor691113(note: rootNote)
            singlesAnswer = "min6/9(11,13)"
        case "7#5":
            domSharp5(note: rootNote)
            singlesAnswer = "7#5"
        case "9":
            domNine(note: rootNote)
            singlesAnswer = "9"
        case "9#5":
            domNineSharp5(note: rootNote)
            singlesAnswer = "9#5"
        case "7(#9b5)":
            domSharp9Flat5(note: rootNote)
            singlesAnswer = "7(#9b5)"
        case "7(#9#5)":
            domSharp9Sharp5(note: rootNote)
            singlesAnswer = "7(#9#5)"
        case "7(b9#9#5)":
            domFlat9Sharp9Sharp5(note: rootNote)
            singlesAnswer = "7(b9#9#5)"
        case "7(#5b9#9#11)":
            domSharp5Flat9Sharp9Sharp11(note: rootNote)
            singlesAnswer = "7(#5b9#9#11)"
        case "b9":
            domFlat9(note: rootNote)
            singlesAnswer = "b9"
        case "#9":
            domSharp9(note: rootNote)
            singlesAnswer = "#9"
        case "9(#11)":
            dom9Sharp11(note: rootNote)
            singlesAnswer = "9(#11)"
        case "13":
            dom13(note: rootNote)
            singlesAnswer = "13"
        case "13(#11)":
            dom13Sharp11(note: rootNote)
            singlesAnswer = "13(#11)"
        case "13(b9#11)":
            dom13Flat9Sharp11(note: rootNote)
            singlesAnswer = "13(b9#11)"
        case "13(#9#11)":
            dom13Sharp9Sharp11(note: rootNote)
            singlesAnswer = "13(#9#11)"
        case "min9(b5)":
            minor9Flat5(note: rootNote)
            singlesAnswer = "min9(b5)"
        case "min7b5(9,11)":
            minor7Flat5911(note: rootNote)
            singlesAnswer = "min7b5(9,11)"
        case "min7b5(9,11,b13)":
            minor7Flat5911Flat13(note: rootNote)
            singlesAnswer = "min7b5(9,11,b13)"
        case "dim7(9)":
            diminished79(note: rootNote)
            singlesAnswer = "dim7(9)"
        case "dim7(9,11)":
            diminished7911(note: rootNote)
            singlesAnswer = "dim7(9,11)"
        case "7sus4":
            dom7sus4(note: rootNote)
            singlesAnswer = "7sus4"
        case "9sus4":
            dom9sus4(note: rootNote)
            singlesAnswer = "9sus4"
        case "13sus4":
            dom13sus4(note: rootNote)
            singlesAnswer = "13sus4"
        case "7sus4(b9)":
            dom7sus4Flat9(note: rootNote)
            singlesAnswer = "7sus4(b9)"
        case "13sus4(b9)":
            dom13sus4Flat9(note: rootNote)
            singlesAnswer = "13sus4(b9)"
        default: print("something went wrong")
        }
    }
    
    func major(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 12])
        chordHighestNote = note + 12
    }
    func major6(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 9])
        chordHighestNote = note + 9
    }
    func major69(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 9, note + 14])
        chordHighestNote = note + 14
    }
    func major69Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 9, note + 14, note + 18])
        chordHighestNote = note + 18
    }
    func major69Sharp11add13(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 9, note + 14, note + 18, note + 21])
        chordHighestNote = note + 21
    }
    func majorSeventh(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 11])
        chordHighestNote = note + 11
    }
    func major9(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 11, note + 14])
        chordHighestNote = note + 14
    }
    func majorSharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 11, note + 14, note + 18])
        chordHighestNote = note + 18
    }
    func major13(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 11, note + 14, note + 18, note + 21])
        chordHighestNote = note + 21
    }
    func minor(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 12])
        chordHighestNote = note + 12
    }
    func minor6(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 9])
        chordHighestNote = note + 9
    }
    func minor69(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 9, note + 14])
        chordHighestNote = note + 14
    }
    func minor69nat11(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 9, note + 14, note + 17])
        chordHighestNote = note + 17
    }
    func minor691113(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 9, note + 14, note + 17, note + 21])
        chordHighestNote = note + 21
    }
    func minorSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 10])
        chordHighestNote = note + 10
    }
    func minor9(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 10, note + 14])
        chordHighestNote = note + 14
    }
    func minor11(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 10, note + 14, note + 17])
        chordHighestNote = note + 17
    }
    func minor13(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 10, note + 14, note + 17, note + 21])
        chordHighestNote = note + 21
    }
    func domSeventh(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10])
        chordHighestNote = note + 10
    }
    func domSharp5(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10])
        chordHighestNote = note + 10
    }
    func domNine(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 14])
        chordHighestNote = note + 14
    }
    func domNineSharp5(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10, note + 14])
        chordHighestNote = note + 14
    }
    func domSharp9Flat5(note: UInt8) {
        chords.append([note, note + 4, note + 6, note + 10, note + 15])
        chordHighestNote = note + 15
    }
    func domSharp9Sharp5(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10, note + 15])
        chordHighestNote = note + 15
    }
    func domFlat9Sharp9Sharp5(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10, note + 13, note + 15])
        chordHighestNote = note + 15
    }
    func domSharp5Flat9Sharp9Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 10, note + 13, note + 15, note + 18])
        chordHighestNote = note + 18
    }
    func domFlat9(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 13])
        chordHighestNote = note + 13
    }
    func domSharp9(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 15])
        chordHighestNote = note + 15
    }
    func dom9Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 14, note + 18])
        chordHighestNote = note + 18
    }
    func dom13(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 14, note + 17, note + 21])
        chordHighestNote = note + 21
    }
    func dom13Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 14, note + 18, note + 21])
        chordHighestNote = note + 21
    }
    func dom13Flat9Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 13, note + 18, note + 21])
        chordHighestNote = note + 21
    }
    func dom13Sharp9Sharp11(note: UInt8) {
        chords.append([note, note + 4, note + 7, note + 10, note + 15, note + 18, note + 21])
        chordHighestNote = note + 21
    }
    func dom7sus4(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10])
        chordHighestNote = note + 10
    }
    func dom9sus4(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10, note + 14])
        chordHighestNote = note + 14
    }
    func dom7sus4Flat9(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10, note + 13])
        chordHighestNote = note + 13
    }
    func dom13sus4(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10, note + 14, note + 18, note + 21])
        chordHighestNote = note + 21
    }
    func dom13sus4Flat9(note: UInt8) {
        chords.append([note, note + 5, note + 7, note + 10, note + 13, note + 18, note + 21])
        chordHighestNote = note + 21
    }
    func diminished(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 12])
        chordHighestNote = note + 12
    }
    func halfDimSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 10])
        chordHighestNote = note + 10
    }
    func minor9Flat5(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 10, note + 14])
        chordHighestNote = note + 14
    }
    func minor7Flat5911(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 10, note + 14, note + 17])
        chordHighestNote = note + 17
    }
    func minor7Flat5911Flat13(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 10, note + 14, note + 17, note + 20])
        chordHighestNote = note + 20
    }
    func dimMajorSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 11])
        chordHighestNote = note + 11
    }
    func augmented(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 12])
        chordHighestNote = note + 12
    }
    func augSeventh(note: UInt8) {
        chords.append([note, note + 4, note + 8, note + 11])
        chordHighestNote = note + 11
    }
    func minorMajorSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 7, note + 11])
        chordHighestNote = note + 11
    }
    func fullyDimSeventh(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 9])
        chordHighestNote = note + 9
    }
    func diminished79(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 9, note + 14])
        chordHighestNote = note + 14
    }
    func diminished7911(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 9, note + 14, note + 17])
        chordHighestNote = note + 17
    }
    func superDiminished(note: UInt8) {
        chords.append([note, note + 3, note + 6, note + 9, note + 12])
        chordHighestNote = note + 12
    }
    
    func playChords(chords : [[UInt8]]){
        // One chord per beat, using the shared SoundFont-backed sampler.
        // (Tempo here matches the old 58.0 BPM you used in the MusicSequence.)
        PianoSequencePlayer.shared.playChordBatches(chords: chords, tempoBPM: 58.0)
    }
}

#Preview {
    SingleChordView()
}

enum ChordCategory: String, CaseIterable {
    case normal = "Normal"
    case majorExtended = "Major Extended"
    case minorExtended = "Minor Extended"
    case dominantExtended = "Dominant Extended"
    case halfDiminishedExtended = "Half-Diminished Extended"
    case diminishedExtended = "Diminished Extended"
    case suspendedExtended = "Suspended Extended"
}

struct ChordOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: ChordCategory
    var isOn: Bool
}
