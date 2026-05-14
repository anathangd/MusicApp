import SwiftUI

struct MelodyListView: View {
    @AppStorage("customMelodyDefinitions") private var customMelodyDefinitions = "[]"
    @State private var customMelodies: [CustomMelodyDefinition] = []
    @State private var isShowingMelodyEntrySheet = false
    @State private var melodyToEdit: CustomMelodyDefinition?

    var body: some View {
        List {
            Section("Built-in") {
                ForEach(Array(MelodyCollection.phrases.indices), id: \.self) { index in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Built-in Melody \(index + 1)")
                        Text(phraseSummary(MelodyCollection.phrases[index]))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Custom") {
                if customMelodies.isEmpty {
                    Text("No custom melodies yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(customMelodies) { melody in
                        Button {
                            melodyToEdit = melody
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(melody.name)
                                    .foregroundStyle(.primary)
                                Text(customSummary(melody))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteMelody(melody)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Melody List")
        .onAppear {
            loadCustomMelodies()
        }
        .fullScreenCover(isPresented: $isShowingMelodyEntrySheet) {
            MelodyEntryView { savedMelody in
                customMelodies.append(savedMelody)
                saveCustomMelodies()
            }
        }
        .fullScreenCover(item: $melodyToEdit) { melody in
            MelodyEntryView(initialMelody: melody) { updatedMelody in
                updateMelody(updatedMelody)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingMelodyEntrySheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Melody")
            }
        }
    }

    private func phraseSummary(_ phrase: MusicalPhrase) -> String {
        let modeText = phrase.mode == .minor ? "Minor" : "Major"
        return "\(modeText) | \(Int(phrase.tempoBPM)) BPM | \(phrase.steps.count) notes"
    }

    private func customSummary(_ melody: CustomMelodyDefinition) -> String {
        let modeText = melody.isMinor ? "Minor" : "Major"
        return "\(modeText) | \(Int(melody.tempoBPM)) BPM | \(melody.steps.count) notes"
    }

    private func loadCustomMelodies() {
        guard let data = customMelodyDefinitions.data(using: .utf8) else {
            customMelodies = []
            return
        }

        do {
            customMelodies = try JSONDecoder().decode([CustomMelodyDefinition].self, from: data)
        } catch {
            customMelodies = []
        }
    }

    private func saveCustomMelodies() {
        do {
            let data = try JSONEncoder().encode(customMelodies)
            customMelodyDefinitions = String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            customMelodyDefinitions = "[]"
        }
    }

    private func updateMelody(_ updatedMelody: CustomMelodyDefinition) {
        guard let index = customMelodies.firstIndex(where: { $0.id == updatedMelody.id }) else {
            return
        }

        customMelodies[index] = updatedMelody
        saveCustomMelodies()
    }

    private func deleteMelody(_ melody: CustomMelodyDefinition) {
        customMelodies.removeAll { $0.id == melody.id }
        saveCustomMelodies()
    }
}

#Preview {
    NavigationStack {
        MelodyListView()
    }
}
