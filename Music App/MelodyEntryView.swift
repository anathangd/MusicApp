//
//  MelodyEntryView.swift
//  Music App
//
//  Created by Nathan Davis on 5/10/26.
//

import SwiftUI

struct CustomMelodyStep: Identifiable, Codable, Hashable {
    var id = UUID()
    var degree: Int
    var accidental: Int
    var octave: Int
    var durationBeats: Double
    var velocity: UInt8 = 100

    func toPhraseStep() -> MusicalPhrase.Step {
        let phraseAccidental: MusicalPhrase.Step.Accidental
        switch accidental {
        case ..<0:
            phraseAccidental = .flat
        case 1...:
            phraseAccidental = .sharp
        default:
            phraseAccidental = .natural
        }

        return MusicalPhrase.Step(
            degree: max(1, min(7, degree)),
            accidental: phraseAccidental,
            octave: octave,
            durationBeats: max(0.25, durationBeats),
            velocity: velocity
        )
    }
}

struct CustomMelodyDefinition: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var isMinor: Bool
    var tempoBPM: Double
    var steps: [CustomMelodyStep]

    func toMusicalPhrase() -> MusicalPhrase {
        MusicalPhrase(
            mode: isMinor ? .minor : .major,
            tempoBPM: tempoBPM,
            steps: steps.map { $0.toPhraseStep() }
        )
    }
}

struct MelodyEntryView: View {
    @Environment(\.dismiss) private var dismiss

    private let initialMelody: CustomMelodyDefinition?
    private let onSave: (CustomMelodyDefinition) -> Void

    @State private var melodyName: String
    @State private var isMinor: Bool
    @State private var currentOctave: Int
    @State private var startingNote: Int
    @State private var tempoBPM: Double
    @State private var steps: [CustomMelodyStep]
    @State private var recording: Bool = false

    init(
        initialMelody: CustomMelodyDefinition? = nil,
        onSave: @escaping (CustomMelodyDefinition) -> Void = { _ in }
    ) {
        self.initialMelody = initialMelody
        self.onSave = onSave
        _melodyName = State(initialValue: initialMelody?.name ?? "")
        _isMinor = State(initialValue: initialMelody?.isMinor ?? true)
        _currentOctave = State(initialValue: 0)
        _startingNote = State(initialValue: 60)
        _tempoBPM = State(initialValue: initialMelody?.tempoBPM ?? 120)
        _steps = State(initialValue: initialMelody?.steps ?? [])
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    HStack {
                        Button {
                            previewMelody()
                        } label: {
                            Image(systemName: "play.circle")
                                .font(.system(size: 30))
                                .padding(.leading)
                                .padding(.top, 8)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        TextField("Melody name", text: $melodyName)
                            .frame(width: 350, height: 40)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Discard")
                                .foregroundStyle(.red)
                                .frame(width: 100, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.3))
                                )
                        }
                        .buttonStyle(.plain)

                        Button {
                            saveMelody()
                        } label: {
                            Text("Save")
                                .frame(width: 100, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.3))
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(steps.isEmpty)
                    }
                    .padding(.trailing)
                    .padding(.top, 4)
                    
                    HStack {
                        
                        ZStack {
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 12) {
                                    ForEach(steps.indices, id: \.self) { index in
                                        MelodyNote(number: index + 1, step: $steps[index]) {
                                            steps.remove(at: index)
                                        }
                                    }

                                    if steps.isEmpty {
                                        Text("Tap the toggle to go into recording mode and then tap the numbered keys to add notes")
                                            .lineLimit(1)
                                            .frame(width: .infinity, height: 40)
                                            .foregroundStyle(.secondary)
                                            .padding(.vertical)
                                            .padding(.top)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    ZStack {
                        HStack {
                            Button {
                                currentOctave = max(0, currentOctave - 1)
                            } label: {
                                Image(systemName: "minus")
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.3))
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(currentOctave == 0)
                            .opacity(currentOctave == 0 ? 0.4 : 1)

                            Text("Octave: \(currentOctave)")
                                .frame(width: 100, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.3))
                                )
                            Button {
                                currentOctave = min(1, currentOctave + 1)
                            } label: {
                                Image(systemName: "plus")
                                    .frame(width: 50, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.3))
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(currentOctave == 1)
                            .opacity(currentOctave == 1 ? 0.4 : 1)
                            
                            Spacer()

                            Button {
                                isMinor.toggle()
                            } label: {
                                Text(isMinor ? "minor" : "major")
                                    .frame(width: 100, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.3))
                                    )
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()

                            StartingNoteControl(startingNote: $startingNote)

                            Spacer()
    
                            Toggle(isOn: $recording) {
                                
                            }
                            .tint(.red)
                            .frame(width: 10)
                            
                            Spacer()
                            
                            Button {
                                tempoBPM = min(240, tempoBPM + 5)
                            } label: {
                                Text("Tempo: \(Int(tempoBPM))")
                                    .frame(width: 120, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.3))
                                    )
                            }
                            .buttonStyle(.plain)
                            .onLongPressGesture {
                                tempoBPM = max(40, tempoBPM - 5)
                            }
                            
                        }
                        .padding(.leading, 8)
                        .padding(.leading)
                        .padding(.trailing, 8)
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(0..<15) { key in
                            Button {
                                handleKeyTap(key)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity((key % 7) + 1 == 1 ? 0.8 : 0.5))
                                        .frame(width: keyWidth(for: geo.size.width), height: 130)
                                    Text("\((key % 7) + 1)")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .offset(y: 20)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom, -8)
                }
            }
        }
        .onAppear {
            OrientationManager.lockToLandscape()
        }
        .onDisappear {
            OrientationManager.lockToPortrait()
        }
    }

    private func keyWidth(for availableWidth: CGFloat) -> CGFloat {
        let horizontalPadding: CGFloat = 32
        let spacing: CGFloat = 8 * 14
        let calculatedWidth = (availableWidth - horizontalPadding - spacing) / 15
        return max(1, calculatedWidth)
    }

    private func handleKeyTap(_ key: Int) {
        let step = makeStep(fromKey: key)
        playStep(step)

        if recording {
            steps.append(step)
        }
    }

    private func makeStep(fromKey key: Int) -> CustomMelodyStep {
        let degree = (key % 7) + 1
        let octaveOffsetFromGrid: Int
        if key < 7 {
            octaveOffsetFromGrid = -1
        } else if key == 14 {
            octaveOffsetFromGrid = 1
        } else {
            octaveOffsetFromGrid = 0
        }

        return CustomMelodyStep(
            degree: degree,
            accidental: 0,
            octave: currentOctave + octaveOffsetFromGrid,
            durationBeats: 0.5
        )
    }

    private func addStep(fromKey key: Int) {
        let step = makeStep(fromKey: key)
        steps.append(step)
        playStep(step)
    }

    private func playStep(_ step: CustomMelodyStep) {
        let phrase = MusicalPhrase(
            mode: isMinor ? .minor : .major,
            tempoBPM: tempoBPM,
            steps: [step.toPhraseStep()]
        )
        PianoSequencePlayer.shared.play(phrase: phrase, startingNote: UInt8(startingNote), tempoBPM: phrase.tempoBPM)
    }

    private func previewMelody() {
        guard !steps.isEmpty else { return }
        let phrase = melodyToSave().toMusicalPhrase()
        PianoSequencePlayer.shared.play(phrase: phrase, startingNote: UInt8(startingNote), tempoBPM: phrase.tempoBPM)
    }


    private func saveMelody() {
        let melody = melodyToSave()
        onSave(melody)
        dismiss()
    }

    private func melodyToSave() -> CustomMelodyDefinition {
        let fallbackName = "Custom Melody"
        let trimmed = melodyName.trimmingCharacters(in: .whitespacesAndNewlines)

        return CustomMelodyDefinition(
            id: initialMelody?.id ?? UUID(),
            name: trimmed.isEmpty ? fallbackName : trimmed,
            isMinor: isMinor,
            tempoBPM: tempoBPM,
            steps: steps
        )
    }
}

private struct StartingNoteControl: View {
    @Binding var startingNote: Int
    private let minimumNote = 48  // C3
    private let maximumNote = 72  // C5

    private var display: String {
        let pitchClass = startingNote % 12
        let octave = (startingNote / 12) - 1

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

    var body: some View {
        HStack {
            Button {
                startingNote = max(minimumNote, startingNote - 1)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                    )
            }
            .buttonStyle(.plain)
            .disabled(startingNote == minimumNote)
            .opacity(startingNote == minimumNote ? 0.4 : 1)

            Text(display)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                )

            Button {
                startingNote = min(maximumNote, startingNote + 1)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                    )
            }
            .buttonStyle(.plain)
            .disabled(startingNote == maximumNote)
            .opacity(startingNote == maximumNote ? 0.4 : 1)
        }
    }
}


struct MelodyNote: View {
    let number: Int
    @Binding var step: CustomMelodyStep
    let onDelete: () -> Void

    var body: some View {
        ZStack {
            VStack {
                Text("\(number)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top, 18)
                    
                Spacer()
            }
            VStack(spacing: 8) {
                HStack {
                    Button(step.accidental < 0 ? "♮" : "♭") {
                        step.accidental = step.accidental < 0 ? 0 : -1
                    }
                    .font(.system(size: 30))
                    .buttonStyle(.bordered)
                    
                    Text(noteLabel)
                        .font(.system(size: 34))
                        .fontWeight(.semibold)
                        .monospacedDigit()
                    
                    Button(step.accidental > 0 ? "♮" : "♯") {
                        step.accidental = step.accidental > 0 ? 0 : 1
                    }
                    .font(.system(size: 30))
                    .buttonStyle(.bordered)
                }
                
                
                HStack(spacing: 10) {
                    Button("-") {
                        step.durationBeats = max(durationStep, step.durationBeats - durationStep)
                    }
                    .buttonStyle(.bordered)
                    
                    Text(durationText)
                        .font(.headline)
                        .monospacedDigit()
                        .lineLimit(1)
                        .frame(minWidth: 44)
                        .onLongPressGesture {
                            toggleTripletDuration()
                        }
                    
                    Button("+") {
                        step.durationBeats = min(4, step.durationBeats + durationStep)
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack {
                    Text("Oct \(step.octave)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(minWidth: 130)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
            )
            .padding(.vertical, 15)
        }
    }

    private var isTripletDuration: Bool {
        let tripletUnit = 1.0 / 3.0
        let multiple = (step.durationBeats / tripletUnit).rounded()
        return abs(step.durationBeats - (multiple * tripletUnit)) < 0.001
    }

    private var durationStep: Double {
        isTripletDuration ? (1.0 / 3.0) : 0.25
    }

    private var durationText: String {
        if isTripletDuration {
            let numerator = Int((step.durationBeats / (1.0 / 3.0)).rounded())
            return "\(String(format: "%.2f", step.durationBeats))"
        }

        return String(format: "%.2f", step.durationBeats)
    }

    private func toggleTripletDuration() {
        if isTripletDuration {
            step.durationBeats = 0.5
        } else {
            step.durationBeats = 1.0 / 3.0
        }
    }

    private var noteLabel: String {
        let accidentalSymbol: String
        switch step.accidental {
        case ..<0:
            accidentalSymbol = "♭"
        case 1...:
            accidentalSymbol = "♯"
        default:
            accidentalSymbol = ""
        }

        return "\(step.degree)\(accidentalSymbol)"
    }
}

#Preview {
    MelodyEntryView()
}
