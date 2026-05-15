//
//  AddInstrumentSheet.swift
//  Music App
//
//  Created by Nathan Davis on 5/10/26.
//

import SwiftUI

struct AddInstrumentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var instrumentName = ""
    @State private var lowestNote = 57
    @State private var highestNote = 77
    let initialInstrument: CustomInstrumentDefinition?
    let sheetTitle: String
    let saveButtonTitle: String
    let onSave: (CustomInstrumentDefinition) -> Void

    init(
        initialInstrument: CustomInstrumentDefinition? = nil,
        sheetTitle: String = "New Instrument",
        saveButtonTitle: String = "Save",
        onSave: @escaping (CustomInstrumentDefinition) -> Void
    ) {
        self.initialInstrument = initialInstrument
        self.sheetTitle = sheetTitle
        self.saveButtonTitle = saveButtonTitle
        self.onSave = onSave

        _instrumentName = State(initialValue: initialInstrument?.name ?? "")
        _lowestNote = State(initialValue: initialInstrument?.lowestNote ?? 57)
        _highestNote = State(initialValue: initialInstrument?.highestNote ?? 77)
    }

    private var canSave: Bool {
        !instrumentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && highestNote - lowestNote >= 12
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Instrument") {
                    TextField("Name", text: $instrumentName)
                }

                Section("Range (MIDI)") {
                    Stepper(value: $lowestNote, in: 21...107) {
                        Text("Lowest: \(noteLabel(for: lowestNote))")
                    }
                    .onChange(of: lowestNote) { _, newValue in
                        syncRange(afterChanging: .lowest(newValue))
                        playPreview(note: newValue)
                    }

                    Stepper(value: $highestNote, in: 22...108) {
                        Text("Highest: \(noteLabel(for: highestNote))")
                    }
                    .onChange(of: highestNote) { _, newValue in
                        syncRange(afterChanging: .highest(newValue))
                        playPreview(note: newValue)
                    }

                    Text("Choose any range you can comfortably sing or play. The range must span at least one octave.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(sheetTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(saveButtonTitle) {
                        onSave(
                            CustomInstrumentDefinition(
                                id: initialInstrument?.id ?? UUID(),
                                name: instrumentName.trimmingCharacters(in: .whitespacesAndNewlines),
                                lowestNote: lowestNote,
                                highestNote: highestNote
                            )
                        )
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private enum RangeSide {
        case lowest(Int)
        case highest(Int)
    }

    private func syncRange(afterChanging changedSide: RangeSide) {
        switch changedSide {
        case .lowest(let newValue):
            if newValue + 12 > highestNote {
                highestNote = min(newValue + 12, 108)
            }
        case .highest(let newValue):
            if newValue - 12 < lowestNote {
                lowestNote = max(newValue - 12, 21)
            }
        }
    }

    private func playPreview(note midi: Int) {
        guard let note = UInt8(exactly: midi) else { return }
        PianoSequencePlayer.shared.play(notes: [note], tempoBPM: 300)
    }

    private func noteLabel(for midi: Int) -> String {
        let names = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
        let name = names[midi % 12]
        let octave = (midi / 12) - 1
        return "\(name)\(octave) (\(midi))"
    }
}

//#Preview {
//    AddInstrumentSheet()
//}
