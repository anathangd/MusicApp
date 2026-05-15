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
    var isTriplet: Bool = false
    var velocity: UInt8 = 100

    private enum CodingKeys: String, CodingKey {
        case id
        case degree
        case accidental
        case octave
        case durationBeats
        case isTriplet
        case velocity
    }

    init(
        id: UUID = UUID(),
        degree: Int,
        accidental: Int,
        octave: Int,
        durationBeats: Double,
        isTriplet: Bool = false,
        velocity: UInt8 = 100
    ) {
        self.id = id
        self.degree = degree
        self.accidental = accidental
        self.octave = octave
        self.durationBeats = durationBeats
        self.isTriplet = isTriplet
        self.velocity = velocity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        degree = try container.decodeIfPresent(Int.self, forKey: .degree) ?? 1
        accidental = try container.decodeIfPresent(Int.self, forKey: .accidental) ?? 0
        octave = try container.decodeIfPresent(Int.self, forKey: .octave) ?? 0
        durationBeats = try container.decodeIfPresent(Double.self, forKey: .durationBeats) ?? 0.5
        isTriplet = try container.decodeIfPresent(Bool.self, forKey: .isTriplet) ?? false
        velocity = try container.decodeIfPresent(UInt8.self, forKey: .velocity) ?? 100
    }

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

        let playbackDuration: Double
        let useTripletGrid = isTriplet || Self.isTripletLikeDuration(durationBeats)
        if useTripletGrid {
            // Snap triplets to a 1/3-beat grid for consistent triplet feel.
            playbackDuration = max(1.0 / 3.0, (durationBeats * 3.0).rounded() / 3.0)
        } else {
            // Keep regular notes aligned to 1/4-beat increments.
            playbackDuration = max(0.25, (durationBeats * 4.0).rounded() / 4.0)
        }

        return MusicalPhrase.Step(
            degree: max(1, min(7, degree)),
            accidental: phraseAccidental,
            octave: octave,
            durationBeats: playbackDuration,
            velocity: velocity
        )
    }

    private static func isTripletLikeDuration(_ value: Double) -> Bool {
        guard value > 0 else { return false }

        let nearestTriplet = (value * 3.0).rounded() / 3.0
        let nearestStraight = (value * 4.0).rounded() / 4.0
        let tripletDelta = abs(value - nearestTriplet)
        let straightDelta = abs(value - nearestStraight)

        return tripletDelta < 0.02 && tripletDelta + 0.0001 < straightDelta
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
    private let maximumRecordedNotes = 30

    private let initialMelody: CustomMelodyDefinition?
    private let onSave: (CustomMelodyDefinition) -> Void

    @State private var melodyName: String
    @State private var isMinor: Bool
    @State private var currentOctave: Int
    @State private var startingNote: Int
    @State private var tempoBPM: Double
    @State private var steps: [CustomMelodyStep]
    @State private var recording: Bool = false
    @State private var showingAboutSheet = false
    @State private var showingNoteLimitAlert = false
    @FocusState private var isMelodyNameFocused: Bool

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

                        Button {
                            showingAboutSheet = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 28))
                                .padding(.top, 8)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        TextField("Melody name", text: $melodyName)
                            .frame(width: 350, height: 40)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 8)
                            .focused($isMelodyNameFocused)
                        
                        Spacer()
                        
                        Button {
                            isMelodyNameFocused = false
                            dismissKeyboard()
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
                            isMelodyNameFocused = false
                            dismissKeyboard()
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            OrientationManager.lockToLandscape()
        }
        .onDisappear {
            isMelodyNameFocused = false
            dismissKeyboard()
            OrientationManager.lockToPortrait()
        }
        .sheet(isPresented: $showingAboutSheet) {
            NavigationStack {
                List {
                    Section("About") {
                        Text("Create melodies that will play in different keys for great ear training practice!")
                        Text("The goal is to be able to hear a melody and play it back by ear.")
                    }
                    
                    Section("Recording") {
                        Text("Tap the red recording toggle, then tap the numbered keys to add notes to the melody.")
                        Text("When recording is off, tapping a key previews the note without adding it.")
                    }

                    Section("Keys") {
                        Text("The numbered keys represent scale degrees 1 through 7.")
                        Text("The middle 1 starts at the selected octave.")
                    }

                    Section("Root and Mode") {
                        Text("Use the root note control to transpose the melody by half step, such as C4, D♭4, or D4 in case you're trying to figure out notes played in a specific key.")
                        Text("Tap the major/minor button to switch the scale mode.")
                    }

                    Section("Editing Notes") {
                        Text("Use ♭ and ♯ to add accidentals. If a note already has that accidental, the button changes to ♮ so you can return it to normal.")
                        Text("Use + and - around the duration value to change how long the note lasts.")
                        Text("Long-press the duration value to switch between normal values and triplet values such as 0.33 and 0.67.")
                    }

                    Section("Playback") {
                        Text("Tap the play button to hear the full melody.")
                        Text("Tap Tempo to increase the tempo. Long-press Tempo to decrease it.")
                    }
                }
                .navigationTitle("About Melody Entry")
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
        .onChange(of: recording) { newValue in
            if newValue && steps.count >= maximumRecordedNotes {
                recording = false
                showingNoteLimitAlert = true
            }
        }
        .alert("Note limit reached", isPresented: $showingNoteLimitAlert) {
            Button("My bad", role: .cancel) { }
        } message: {
            Text("The limit is 30 notes.")
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
            guard steps.count < maximumRecordedNotes else {
                recording = false
                return
            }

            steps.append(step)

            if steps.count == maximumRecordedNotes {
                recording = false
            }
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

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                        step.durationBeats = max(durationStep, roundedDuration(step.durationBeats - durationStep))
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
                        step.durationBeats = min(4, roundedDuration(step.durationBeats + durationStep))
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
        step.isTriplet
    }

    private var durationStep: Double {
        isTripletDuration ? (1.0 / 3.0) : 0.25
    }
    
    private func roundedDuration(_ value: Double) -> Double {
        let unit = durationStep
        return (value / unit).rounded() * unit
    }

    private var durationText: String {return String(format: "%.2f", step.durationBeats)
    }

    private func toggleTripletDuration() {
        step.isTriplet.toggle()

        if step.isTriplet {
            step.durationBeats = 1.0 / 3.0
        } else {
            step.durationBeats = 0.5
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
