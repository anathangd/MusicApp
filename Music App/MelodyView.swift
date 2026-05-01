//
//  MelodyView.swift
//  Music App
//
//  Created by Nathan Davis on 1/4/26.
//

import SwiftUI
import AVFoundation

struct MelodyView: View {
    @State private var testing = false
    
    @State var notes: [UInt8] = [71,69,62,72,71,69,67]
    @State var rootNoteLetter = "G"
    @State var rootNote: UInt8 = 72
    @State var nextNote: UInt8 = 72
    @State var counter = 0
    @State var howMany = 2  //two extra notes after the root, loop starts at 0
    @State var answer = ["Perfect fifth", "minor third", "Major second"]
    @State var atonalAnswerString = "Perfect fifth, minor third"
    @State var tempo = UserDefaults.standard.double(forKey: "tempo")//150.0
    @State var currentPhrase: MusicalPhrase?
    @State private var currentPhraseEvents: [PianoSequencePlayer.NoteEvent] = []
    
    let phrases: [MusicalPhrase] = MelodyCollection.phrases
    /// Indices of phrases we haven't heard yet in the current cycle (shuffled).
    @State private var remainingPhraseIndices: [Int] = []
    /// How many full cycles have been completed.
    @State private var phraseCycleCount: Int = 0
    
    private func intervalDistanceForPair(_ i: Int) -> Int {
        guard i >= 0 && i + 1 < notes.count else { return 0 }
        return abs(Int(notes[i]) - Int(notes[i + 1]))
    }
    
    private var pairButtonsArea: some View {
        let pairCount = max(0, notes.count - 1)
        let perRow = 4
        let rowCount = Int(ceil(Double(pairCount) / Double(perRow)))

        return VStack(spacing: 8) {
            ForEach(0..<rowCount, id: \.self) { row in
                let start = row * perRow
                let end = min(start + perRow, pairCount)

                HStack {
                    ForEach(start..<end, id: \.self) { i in
                        let dist = intervalDistanceForPair(i)
                        Image(systemName: "music.note")

                        Button {
                            playPair(startIndex: i)
                        } label: {
                            Text(ordinalLabel(i))
                                .foregroundStyle(dist > 2 ? .red : .black)
                        }
                        .melodyMiniButtonStyle()
                    }
                    Image(systemName: "music.note")
                }
            }
        }
        .padding(.bottom, 4)
    }

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Text("Score: " + String(counter))
                        .font(.system(size: 30))
                    Text("Remaining: \(remainingPhraseIndices.count)")
                }
                .padding()
                Text("Starting Note:")
                    .font(.system(size: 30))
                Text(rootNoteLetter)
                    .font(.system(size: 80))
                Button("Play Sequence") {
                    atonalAnswerString = ""

                    // Replay the exact events that were generated when this phrase was selected.
                    if !currentPhraseEvents.isEmpty {
                        let bpm = currentPhrase?.tempoBPM ?? 120
                        PianoSequencePlayer.shared.playMelody(events: currentPhraseEvents, tempoBPM: bpm)
                        return
                    }

                    // Fallback: if events weren't stored for some reason, regenerate from the phrase.
                    if let phrase = currentPhrase {
                        PianoSequencePlayer.shared.play(phrase: phrase, startingNote: rootNote, tempoBPM: phrase.tempoBPM)
                    }
                }
                .foregroundStyle(.black)
                .padding()
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                
                pairButtonsArea
                
                Button("Next") {
                    atonalAnswerString = ""
                    counter += 1
                    nextPhrase()
                }
                .foregroundStyle(.black)
                .padding()
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(20)
            }
            VStack {
                Spacer()
                Text(atonalAnswerString)
                    .font(.caption)
                
            }
        }
        .onAppear {
            atonalAnswerString = ""
            counter = 0
            resetPhraseCycleIfNeeded(force: true)
            nextPhrase()
        }
    }
    
    private func resetPhraseCycleIfNeeded(force: Bool = false) {
        if force || remainingPhraseIndices.isEmpty {
            remainingPhraseIndices = Array(phrases.indices).shuffled()
            if !force {
                phraseCycleCount += 1
            }
        }
    }

    func nextPhrase() {
        rootNote = UInt8(Int.random(in: 57...72))
        // Pick the next phrase from the remaining shuffled cycle.
        resetPhraseCycleIfNeeded()
        guard let nextIndex = remainingPhraseIndices.popLast() else { return }
        let selected = testing ? MelodyCollection.phrases.last! : phrases[nextIndex]
        currentPhrase = selected

        // Keep `notes` in sync with the phrase so the UI can generate the correct number of buttons.
        let events = selected.makeNoteEvents(startingNote: rootNote)
        currentPhraseEvents = events
        notes = events.map { $0.note }

        setRootNoteLetter(root: notes.first ?? 72)
        PianoSequencePlayer.shared.playMelody(events: events, tempoBPM: selected.tempoBPM)
        print("Phrase cycle #\(phraseCycleCount) — remaining in cycle: \(remainingPhraseIndices.count)")
    }

    /// Human-friendly labels for pair buttons (First, Second, Third, ...)
    private func ordinalLabel(_ index: Int) -> String {
        switch index {
        case 0: return "First"
        case 1: return "Second"
        case 2: return "Third"
        case 3: return "Fourth"
        case 4: return "Fifth"
        case 5: return "Sixth"
        case 6: return "Seventh"
        case 7: return "Eighth"
        case 8: return "Ninth"
        case 9: return "Tenth"
        default:
            return "\(index + 1)th"
        }
    }

    /// Plays the adjacent pair starting at `startIndex` (notes[startIndex], notes[startIndex+1]).
    func playPair(startIndex: Int) {
        guard notes.count >= 2 else { return }
        guard startIndex >= 0 && startIndex + 1 < notes.count else { return }
        let slice = Array(notes[startIndex...startIndex + 1])
        PianoSequencePlayer.shared.play(notes: slice, tempoBPM: tempo)
        atonalAnswerString = "\(findInterval(distance: abs(Int(slice[0]) - Int(slice[1]))))"
    }
    
    func setRootNoteLetter(root: UInt8) {
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
        print("rootNoteLetter = \(rootNoteLetter)")
    }
    
    func findInterval(distance: Int) -> String {
        switch distance {
        case 0: return "Perfect unison"
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
}

private struct MelodyMiniButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.bordered)
            .font(.caption)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    /// Small bordered button styling used throughout MelodyView.
    func melodyMiniButtonStyle() -> some View {
        modifier(MelodyMiniButtonStyle())
    }
}

#Preview {
    MelodyView()
}
