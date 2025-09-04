//
//  SingleChordView.swift
//  Music App
//
//  Created by Nathan Davis on 2025-04-22.
//

import SwiftUI
import AudioToolbox

struct SingleChordView: View {
    @State var counter = 0
    @State var rootNote: UInt8 = 60
    @State var highestNote: UInt8 = 84
    @State var chordHighestNote: UInt8 = 84
    @State var rootNoteLetter = "C"
    @State var answer = ["I", "ii", "iii"]
    @State var chords: [[UInt8]] = [[60, 64, 67], [62, 65, 69], [64, 67, 71]]
    @State var singles = true
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
    
    @State var maj9 = true
    @State var majSharp11 = true
    @State var maj13 = true
    @State var maj6 = true
    @State var maj69 = true
    @State var maj69Sharp11 = true
    @State var maj69Sharp11Add13 = true
    
    @State var min9 = true
    @State var min11 = true
    @State var min13 = true
    @State var min6 = true
    @State var min69 = true
    @State var min69nat11 = true
    @State var min691113 = true
    
    @State var domSharp5 = true
    @State var domNine = true
    @State var domNineSharp5 = true
    @State var domSharp9Flat5 = true
    @State var domSharp9Sharp5 = true
    @State var domFlat9Sharp9Sharp5 = true
    @State var domSharp5Flat9Sharp9Sharp11 = true
    @State var domFlat9 = true
    @State var domSharp9 = true
    @State var dom9Sharp11 = true
    @State var dom13 = true
    @State var dom13Sharp11 = true
    @State var dom13Flat9Sharp11 = true
    @State var dom13Sharp9Sharp11 = true
    
    @State var min9Flat5 = true
    @State var min7Flat5911 = true
    @State var min7Flat5911Flat13 = true
    
    @State var dim79 = true
    @State var dim7911 = true
    @State var dom7sus4 = true
    @State var dom9sus4 = true
    @State var dom13sus4 = true
    @State var dom7sus4Flat9 = true
    @State var dom13sus4Flat9 = true
    
    @State var allOn = true
    @State var normalOn = true
    
    @State private var showNoChordsAlert = false
    
    @State var chosenChords : Set = ["Major", "minor", "diminished", "augmented", "Major 7th", "minor 7th", "Dominant 7th", "half-diminished 7th", "diminished Major 7th", "fully-diminished 7th", "super-diminished", "minor-Major 7th", "augmented 7th", "Maj9", "Maj#11", "Maj13", "Maj6", "Maj6/9", "Maj6/9#11", "Maj6/9(#11,13)", "min9", "min11", "min13", "min6", "min6/9", "min6/9(11)", "min6/9(11,13)", "7#5", "9", "9#5", "7(#9b5)", "7(#9#5)", "7(b9#9#5)", "7(#5b9#9#11)", "b9", "#9", "9(#11)", "13", "13(#11)", "13(b9#11)", "13(#9#11)", "min9(b5)", "min7b5(9,11)", "min7b5(9,11,b13)", "dim7(9)", "dim7(9,11)", "7sus4", "9sus4", "13sus4", "7sus4(b9)", "13sus4(b9)"]
     // C, D, and E major chords
    
    var body: some View {
        ZStack {
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
            } // settings button
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
                .foregroundStyle(.black)
                .padding()
                .background(.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("Next") {
                    next()
                }
                .foregroundStyle(.black)
                .padding()
                .background(.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                
            } // main display
            VStack {
                Spacer()
                Text(singlesAnswer)
                    .font(.subheadline)
            } // answer
            if settings {
                ZStack {
                    Rectangle()
                        .foregroundStyle(Color.white)
                        .ignoresSafeArea()
                    ScrollView(showsIndicators: false) {
                        VStack {
                            HStack {
                                Text("Toggle All")
                                Toggle(isOn: $allOn){}
                                    .onChange(of: allOn) { _, newValue in
                                        if allOn {
                                            normalOn = true
                                            major = true
                                            minor = true
                                            dim = true
                                            aug = true
                                            maj7 = true
                                            min7 = true
                                            dom = true
                                            halfDim7 = true
                                            dimMaj7 = true
                                            fullDim7 = true
                                            superDim = true
                                            minMaj7 = true
                                            aug7 = true
                                            
                                            maj9 = true
                                            majSharp11 = true
                                            maj13 = true
                                            maj6 = true
                                            maj69 = true
                                            maj69Sharp11 = true
                                            maj69Sharp11Add13 = true

                                            min9 = true
                                            min11 = true
                                            min13 = true
                                            min6 = true
                                            min69 = true
                                            min69nat11 = true
                                            min691113 = true

                                            domSharp5 = true
                                            domNine = true
                                            domNineSharp5 = true
                                            domSharp9Flat5 = true
                                            domSharp9Sharp5 = true
                                            domFlat9Sharp9Sharp5 = true
                                            domSharp5Flat9Sharp9Sharp11 = true
                                            domFlat9 = true
                                            domSharp9 = true
                                            dom9Sharp11 = true
                                            dom13 = true
                                            dom13Sharp11 = true
                                            dom13Flat9Sharp11 = true
                                            dom13Sharp9Sharp11 = true

                                            min9Flat5 = true
                                            min7Flat5911 = true
                                            min7Flat5911Flat13 = true

                                            dim79 = true
                                            dim7911 = true
                                            dom7sus4 = true
                                            dom9sus4 = true
                                            dom13sus4 = true
                                            dom7sus4Flat9 = true
                                            dom13sus4Flat9 = true
                                        } else {
                                            normalOn = false
                                            major = false
                                            minor = false
                                            dim = false
                                            aug = false
                                            maj7 = false
                                            min7 = false
                                            dom = false
                                            halfDim7 = false
                                            dimMaj7 = false
                                            fullDim7 = false
                                            superDim = false
                                            minMaj7 = false
                                            aug7 = false

                                            maj9 = false
                                            majSharp11 = false
                                            maj13 = false
                                            maj6 = false
                                            maj69 = false
                                            maj69Sharp11 = false
                                            maj69Sharp11Add13 = false

                                            min9 = false
                                            min11 = false
                                            min13 = false
                                            min6 = false
                                            min69 = false
                                            min69nat11 = false
                                            min691113 = false

                                            domSharp5 = false
                                            domNine = false
                                            domNineSharp5 = false
                                            domSharp9Flat5 = false
                                            domSharp9Sharp5 = false
                                            domFlat9Sharp9Sharp5 = false
                                            domSharp5Flat9Sharp9Sharp11 = false
                                            domFlat9 = false
                                            domSharp9 = false
                                            dom9Sharp11 = false
                                            dom13 = false
                                            dom13Sharp11 = false
                                            dom13Flat9Sharp11 = false
                                            dom13Sharp9Sharp11 = false

                                            min9Flat5 = false
                                            min7Flat5911 = false
                                            min7Flat5911Flat13 = false

                                            dim79 = false
                                            dim7911 = false
                                            dom7sus4 = false
                                            dom9sus4 = false
                                            dom13sus4 = false
                                            dom7sus4Flat9 = false
                                            dom13sus4Flat9 = false
                                        }
                                    }
                            }
                            
                            Text("")
                            HStack {
                                Text("Normal")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Toggle(isOn: $normalOn) {}
                                    .scaleEffect(0.5)
                                    .padding(.trailing, -100)
                                    .onChange(of: normalOn) { _, newValue in
                                        if normalOn {
                                            major = true
                                            minor = true
                                            dim = true
                                            aug = true
                                            maj7 = true
                                            min7 = true
                                            dom = true
                                            halfDim7 = true
                                            dimMaj7 = true
                                            fullDim7 = true
                                            superDim = true
                                            minMaj7 = true
                                            aug7 = true
                                        } else {
                                            major = false
                                            minor = false
                                            dim = false
                                            aug = false
                                            maj7 = false
                                            min7 = false
                                            dom = false
                                            halfDim7 = false
                                            dimMaj7 = false
                                            fullDim7 = false
                                            superDim = false
                                            minMaj7 = false
                                            aug7 = false
                                        }
                                    }
                            }
                            Divider()
                            
                            // Normal
                            HStack {
                                Text("Major")
                                Toggle(isOn: $major){}
                            } // Major
                            HStack {
                                Text("minor")
                                Toggle(isOn: $minor){}
                            } // minor
                            HStack {
                                Text("diminished")
                                Toggle(isOn: $dim){}
                            } // diminished
                            HStack {
                                Text("augmented")
                                Toggle(isOn: $aug){}
                            } // augmented
                            HStack {
                                Text("Major 7th")
                                Toggle(isOn: $maj7){}
                            } // Major 7th
                            HStack {
                                Text("minor 7th")
                                Toggle(isOn: $min7){}
                            } // minor 7th
                            HStack {
                                Text("Dominant 7th")
                                Toggle(isOn: $dom){}
                            } // Dominant 7th
                            HStack {
                                Text("half-diminished 7th")
                                Toggle(isOn: $halfDim7){}
                            } // half-diminished 7th
                            HStack {
                                Text("diminished Major 7th")
                                Toggle(isOn: $dimMaj7){}
                            } // diminished Major 7th
                            HStack {
                                Text("fully-diminished 7th")
                                Toggle(isOn: $fullDim7){}
                            } // fully diminished 7th
                            HStack {
                                Text("super-diminished")
                                Toggle(isOn: $superDim){}
                            } // super-diminished
                            HStack {
                                Text("minor-Major 7th")
                                Toggle(isOn: $minMaj7){}
                            } // minor-Major 7th
                            HStack {
                                Text("augmented 7th")
                                Toggle(isOn: $aug7){}
                            } // augmented 7th
                            
                            Text("")
                            HStack {
                                Text("Major extended")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            Divider()
                            
                            // Major extended
                            HStack {
                                Text("Maj9")
                                Toggle(isOn: $maj9){}
                            } // Maj9
                            HStack {
                                Text("Maj#11")
                                Toggle(isOn: $majSharp11){}
                            }
                            HStack {
                                Text("Maj13")
                                Toggle(isOn: $maj13){}
                            }
                            HStack {
                                Text("Maj6")
                                Toggle(isOn: $maj6){}
                            }
                            HStack {
                                Text("Maj6/9")
                                Toggle(isOn: $maj69){}
                            }
                            HStack {
                                Text("Maj6/9#11")
                                Toggle(isOn: $maj69Sharp11){}
                            }
                            HStack {
                                Text("Maj6/9(#11,13)")
                                Toggle(isOn: $maj69Sharp11Add13){}
                            }
                            
                            Text("")
                            HStack {
                                Text("minor extended")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            Divider()
                            
                            // minor extended
                            HStack {
                                Text("min9")
                                Toggle(isOn: $min9){}
                            }
                            HStack {
                                Text("min11")
                                Toggle(isOn: $min11){}
                            }
                            HStack {
                                Text("min13")
                                Toggle(isOn: $min13){}
                            }
                            HStack {
                                Text("min6")
                                Toggle(isOn: $min6){}
                            }
                            HStack {
                                Text("min6/9")
                                Toggle(isOn: $min69){}
                            }
                            HStack {
                                Text("min6/9(11)")
                                Toggle(isOn: $min69nat11){}
                            }
                            HStack {
                                Text("min6/9(11,13)")
                                Toggle(isOn: $min691113){}
                            }
                            
                            Text("")
                            HStack {
                                Text("Dominant Extended")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            Divider()
                            
                            // Dominant
                            HStack {
                                Text("7#5")
                                Toggle(isOn: $domSharp5){}
                            }
                            HStack {
                                Text("9")
                                Toggle(isOn: $domNine){}
                            }
                            HStack {
                                Text("9#5")
                                Toggle(isOn: $domNineSharp5){}
                            }
                            HStack {
                                Text("7(#9b5)")
                                Toggle(isOn: $domSharp9Flat5) {}
                            }
                            HStack {
                                Text("7(#9#5)")
                                Toggle(isOn: $domSharp9Sharp5) {}
                            }
                            HStack {
                                Text("7(b9#9#5)")
                                Toggle(isOn: $domFlat9Sharp9Sharp5) {}
                            }
                            HStack {
                                Text("7(#5b9#9#11)")
                                Toggle(isOn: $domSharp5Flat9Sharp9Sharp11) {}
                            }
                            HStack {
                                Text("b9")
                                Toggle(isOn: $domFlat9) {}
                            }
                            HStack {
                                Text("#9")
                                Toggle(isOn: $domSharp9) {}
                            }
                            HStack {
                                Text("9(#11)")
                                Toggle(isOn: $dom9Sharp11) {}
                            }
                            HStack {
                                Text("13")
                                Toggle(isOn: $dom13) {}
                            }
                            HStack {
                                Text("13(#11)")
                                Toggle(isOn: $dom13Sharp11) {}
                            }
                            HStack {
                                Text("13(b9#11)")
                                Toggle(isOn: $dom13Flat9Sharp11) {}
                            }
                            HStack {
                                Text("13(#9#11)")
                                Toggle(isOn: $dom13Sharp9Sharp11) {}
                            }
                            
                            Text("")
                            HStack {
                                Text("half-diminished extended")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            Divider()
                            
                            // half-diminished
                            HStack {
                                Text("min9(b5)")
                                Toggle(isOn: $min9Flat5) {}
                            }
                            HStack {
                                Text("min7b5(9,11)")
                                Toggle(isOn: $min7Flat5911) {}
                            }
                            HStack {
                                Text("min7b5(9,11,b13)")
                                Toggle(isOn: $min7Flat5911Flat13) {}
                            }
                            
                            Text("")
                            HStack {
                                Text("diminished extended")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            Divider()
                            
                            // diminished
                            HStack {
                                Text("dim7(9)")
                                Toggle(isOn: $dim79) {}
                            }
                            HStack {
                                Text("dim7(9,11)")
                                Toggle(isOn: $dim7911) {}
                            }
                            
                            Text("")
                            HStack {
                                Text("Suspended Extended")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            Divider()
                            
                            // suspended
                            HStack {
                                Text("7sus4")
                                Toggle(isOn: $dom7sus4) {}
                            }
                            HStack {
                                Text("9sus4")
                                Toggle(isOn: $dom9sus4) {}
                            }
                            HStack {
                                Text("13sus4")
                                Toggle(isOn: $dom13sus4) {}
                            }
                            HStack {
                                Text("7sus4(b9)")
                                Toggle(isOn: $dom7sus4Flat9) {}
                            }
                            HStack {
                                Text("13sus4(b9)")
                                Toggle(isOn: $dom13sus4Flat9) {}
                            }
                        }
                        .padding()
                    }// buttons
                    .padding()
                    VStack {
                        Spacer()
                        Button("done") {
                            chooseChords()
                            if chosenChords.isEmpty {
                                showNoChordsAlert = true
                            } else {
                                settings = false
                                next()
                            }
                        }
                        .alert("No chords selected", isPresented: $showNoChordsAlert) {
                            Button("My bad", role: .cancel) { }
                        } message: {
                            Text("Please select at least one chord before proceeding.")
                        }
                        .padding()
                    } // done button
                }
            }
        }
        .onAppear {
            next()
            counter = 0
        }
    }
    func chooseChords() {
        if major == true {
            chosenChords.insert("Major")
        } else {
            chosenChords.remove("Major")
        }
        if minor == true {
            chosenChords.insert("minor")
        } else {
            chosenChords.remove("minor")
        }
        if dim == true {
            chosenChords.insert("diminished")
        } else {
            chosenChords.remove("diminished")
        }
        if aug == true {
            chosenChords.insert("augmented")
        } else {
            chosenChords.remove("augmented")
        }
        if maj7 == true {
            chosenChords.insert("Major 7th")
        } else {
            chosenChords.remove("Major 7th")
        }
        if min7 == true {
            chosenChords.insert("minor 7th")
        } else {
            chosenChords.remove("minor 7th")
        }
        if dom == true {
            chosenChords.insert("Dominant 7th")
        } else {
            chosenChords.remove("Dominant 7th")
        }
        if halfDim7 == true {
            chosenChords.insert("half-diminished 7th")
        } else {
            chosenChords.remove("half-diminished 7th")
        }
        if dimMaj7 == true {
            chosenChords.insert("diminished Major 7th")
        } else {
            chosenChords.remove("diminished Major 7th")
        }
        if fullDim7 == true {
            chosenChords.insert("fully-diminished 7th")
        } else {
            chosenChords.remove("fully-diminished 7th")
        }
        if superDim == true {
            chosenChords.insert("super-diminished")
        } else {
            chosenChords.remove("super-diminished")
        }
        if minMaj7 == true {
            chosenChords.insert("minor-Major 7th")
        } else {
            chosenChords.remove("minor-Major 7th")
        }
        if aug7 == true {
            chosenChords.insert("augmented 7th")
        } else {
            chosenChords.remove("augmented 7th")
        }
        
        if maj9 {
            chosenChords.insert("Maj9")
        } else {
            chosenChords.remove("Maj9")
        }
        if majSharp11 {
            chosenChords.insert("Maj#11")
        } else {
            chosenChords.remove("Maj#11")
        }
        if maj13 {
            chosenChords.insert("Maj13")
        } else {
            chosenChords.remove("Maj13")
        }
        if maj6 {
            chosenChords.insert("Maj6")
        } else {
            chosenChords.remove("Maj6")
        }
        if maj69 {
            chosenChords.insert("Maj6/9")
        } else {
            chosenChords.remove("Maj6/9")
        }
        if maj69Sharp11 {
            chosenChords.insert("Maj6/9#11")
        } else {
            chosenChords.remove("Maj6/9#11")
        }
        if maj69Sharp11Add13 {
            chosenChords.insert("Maj6/9(#11,13)")
        } else {
            chosenChords.remove("Maj6/9(#11,13)")
        }
        if min9 {
            chosenChords.insert("min9")
        } else {
            chosenChords.remove("min9")
        }
        if min11 {
            chosenChords.insert("min11")
        } else {
            chosenChords.remove("min11")
        }
        if min13 {
            chosenChords.insert("min13")
        } else {
            chosenChords.remove("min13")
        }
        if min6 {
            chosenChords.insert("min6")
        } else {
            chosenChords.remove("min6")
        }
        if min69 {
            chosenChords.insert("min6/9")
        } else {
            chosenChords.remove("min6/9")
        }
        if min69nat11 {
            chosenChords.insert("min6/9(11)")
        } else {
            chosenChords.remove("min6/9(11)")
        }
        if min691113 {
            chosenChords.insert("min6/9(11,13)")
        } else {
            chosenChords.remove("min6/9(11,13)")
        }
        
        if domSharp5 {
            chosenChords.insert("7#5")
        } else {
            chosenChords.remove("7#5")
        }
        if domNine {
            chosenChords.insert("9")
        } else {
            chosenChords.remove("9")
        }
        if domNineSharp5 {
            chosenChords.insert("9#5")
        } else {
            chosenChords.remove("9#5")
        }
        if domSharp9Flat5 {
            chosenChords.insert("7(#9b5)")
        } else {
            chosenChords.remove("7(#9b5)")
        }
        if domSharp9Sharp5 {
            chosenChords.insert("7(#9#5)")
        } else {
            chosenChords.remove("7(#9#5)")
        }
        if domFlat9Sharp9Sharp5 {
            chosenChords.insert("7(b9#9#5)")
        } else {
            chosenChords.remove("7(b9#9#5)")
        }
        if domSharp5Flat9Sharp9Sharp11 {
            chosenChords.insert("7(#5b9#9#11)")
        } else {
            chosenChords.remove("7(#5b9#9#11)")
        }
        if domFlat9 {
            chosenChords.insert("b9")
        } else {
            chosenChords.remove("b9")
        }
        if domSharp9 {
            chosenChords.insert("#9")
        } else {
            chosenChords.remove("#9")
        }
        if dom9Sharp11 {
            chosenChords.insert("9(#11)")
        } else {
            chosenChords.remove("9(#11)")
        }
        if dom13 {
            chosenChords.insert("13")
        } else {
            chosenChords.remove("13")
        }
        if dom13Sharp11 {
            chosenChords.insert("13(#11)")
        } else {
            chosenChords.remove("13(#11)")
        }
        if dom13Flat9Sharp11 {
            chosenChords.insert("13(b9#11)")
        } else {
            chosenChords.remove("13(b9#11)")
        }
        if dom13Sharp9Sharp11 {
            chosenChords.insert("13(#9#11)")
        } else {
            chosenChords.remove("13(#9#11)")
        }
        
        if min9Flat5 {
            chosenChords.insert("min9(b5)")
        } else {
            chosenChords.remove("min9(b5)")
        }
        if min7Flat5911 {
            chosenChords.insert("min7b5(9,11)")
        } else {
            chosenChords.remove("min7b5(9,11)")
        }
        if min7Flat5911Flat13 {
            chosenChords.insert("min7b5(9,11,b13)")
        } else {
            chosenChords.remove("min7b5(9,11,b13)")
        }
        
        if dim79 {
            chosenChords.insert("dim7(9)")
        } else {
            chosenChords.remove("dim7(9)")
        }
        if dim7911 {
            chosenChords.insert("dim7(9,11)")
        } else {
            chosenChords.remove("dim7(9,11)")
        }
        
        if dom7sus4 {
            chosenChords.insert("7sus4")
        } else {
            chosenChords.remove("7sus4")
        }
        if dom9sus4 {
            chosenChords.insert("9sus4")
        } else {
            chosenChords.remove("9sus4")
        }
        if dom13sus4 {
            chosenChords.insert("13sus4")
        } else {
            chosenChords.remove("13sus4")
        }
        if dom7sus4Flat9 {
            chosenChords.insert("7sus4(b9)")
        } else {
            chosenChords.remove("7sus4(b9)")
        }
        if dom13sus4Flat9 {
            chosenChords.insert("13sus4(b9)")
        } else {
            chosenChords.remove("13sus4(b9)")
        }
    } // for the settings
    
    func next() {
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
    
    func createMusicSequence(chords: [[UInt8]] ) -> MusicSequence {

        var musicSequence: MusicSequence?
        var status = NewMusicSequence(&musicSequence)
        if status != noErr {
            print(" bad status \(status) creating sequence")
        }
        
        var tempoTrack: MusicTrack?
        if MusicSequenceGetTempoTrack(musicSequence!, &tempoTrack) != noErr {
            assert(tempoTrack != nil, "Cannot get tempo track")
        }

        //MusicTrackClear(tempoTrack, 0, 1)
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 0.0, 58.0) != noErr {
            print("could not set tempo")
        } //128.0 was the default
        if MusicTrackNewExtendedTempoEvent(tempoTrack!, 4.0, 256.0) != noErr {
            print("could not set tempo")
        }
        
        
        // add a track
        var track: MusicTrack?
        status = MusicSequenceNewTrack(musicSequence!, &track)
        if status != noErr {
            print("error creating track \(status)")
        }
        
      
        
        // make some notes and put them on the track
        var beat: MusicTimeStamp = 0.0
       
        for batch in 0..<chords.count {
            for note: UInt8 in chords[batch] {
                var mess = MIDINoteMessage(channel: 0,
                                           note: note,
                                           velocity: 64,
                                           releaseVelocity: 0,
                                           duration: 1.0 )
                status = MusicTrackNewMIDINoteEvent(track!, beat, &mess)
                if status != noErr {    print("creating new midi note event \(status)") }
                
            }// beat changes after this
            beat += 1
        }
        
        CAShow(UnsafeMutablePointer<MusicSequence>(musicSequence!))
        
        return musicSequence!
    }
    
    func playChords(chords : [[UInt8]]){
        var musicPlayer : MusicPlayer? = nil
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, createMusicSequence(chords: chords))
        player = MusicPlayerStart(musicPlayer!)
    }
}

#Preview {
    SingleChordView()
}
