//
//  ContentView.swift
//  Music App
//
//  Created by Nathan Davis on 10/31/23.
//

import SwiftUI
import AudioToolbox
import SwiftData
import UniformTypeIdentifiers

private enum ImportMode {
    case merge
    case replace
}

struct CustomInstrumentDefinition: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var lowestNote: Int
    var highestNote: Int
}

private struct TallyMethodEntryBackup: Codable {
    var id: UUID?
    var day: Int
    var session: Int
    var dateCreated: Date
    var sections: [String]
    var reps: [Int]
    var memorized: [Bool]
    var notes: String
}

private struct PianoPieceBackup: Codable {
    var id: UUID?
    var name: String
    var dateCreated: Date
    var status: PianoPieceStatus
    var entries: [TallyMethodEntryBackup]
}

private struct UserSettingsBackup: Codable {
    var tempo: Double? = nil
    var lowest: Int? = nil
    var highest: Int? = nil
    var individualIntervalDirection: String? = nil
    var individualIntervalEnabledIntervals: String? = nil
    var singleChordSelectedNames: [String]? = nil
}

private struct MusicAppBackup: Codable {
    var version: Int = 2
    var exportedAt: Date = Date()
    var instruments: [CustomInstrumentDefinition]
    var melodies: [CustomMelodyDefinition]
    var tallyPieces: [PianoPieceBackup]
    var settings: UserSettingsBackup

    private enum CodingKeys: String, CodingKey {
        case version
        case exportedAt
        case instruments
        case melodies
        case tallyPieces
        case settings
    }

    init(
        version: Int = 2,
        exportedAt: Date = Date(),
        instruments: [CustomInstrumentDefinition],
        melodies: [CustomMelodyDefinition],
        tallyPieces: [PianoPieceBackup],
        settings: UserSettingsBackup
    ) {
        self.version = version
        self.exportedAt = exportedAt
        self.instruments = instruments
        self.melodies = melodies
        self.tallyPieces = tallyPieces
        self.settings = settings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
        exportedAt = try container.decodeIfPresent(Date.self, forKey: .exportedAt) ?? Date()
        instruments = try container.decodeIfPresent([CustomInstrumentDefinition].self, forKey: .instruments) ?? []
        melodies = try container.decodeIfPresent([CustomMelodyDefinition].self, forKey: .melodies) ?? []
        tallyPieces = try container.decodeIfPresent([PianoPieceBackup].self, forKey: .tallyPieces) ?? []
        settings = try container.decodeIfPresent(UserSettingsBackup.self, forKey: .settings) ?? UserSettingsBackup()
    }
}

private struct MusicAppBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var backup: MusicAppBackup

    init(backup: MusicAppBackup) {
        self.backup = backup
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        backup = try decoder.decode(MusicAppBackup.self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(backup)
        return .init(regularFileWithContents: data)
    }
}

struct ContentView: View {
    let chords: [[UInt8]] = [[60, 64, 67], [62, 65, 69], [64, 67, 71]]
     // C, D, and E major chords
    @AppStorage("customInstrumentDefinitions") private var customInstrumentDefinitions = "[]"
    @AppStorage("customMelodyDefinitions") private var customMelodyDefinitions = "[]"
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PianoPiece.dateCreated, order: .forward) private var pieces: [PianoPiece]
    @State private var customInstruments: [CustomInstrumentDefinition] = []
    @State private var isShowingAddInstrumentSheet = false
    @State private var instrumentToEdit: CustomInstrumentDefinition?
    @State private var exportDocument: MusicAppBackupDocument?
    @State private var isShowingExporter = false
    @State private var isShowingImporter = false
    @State private var backupMessage = ""
    @State private var isShowingBackupAlert = false
    @State private var pendingImportBackup: MusicAppBackup?
    @State private var isShowingImportModeAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Button {
                            startExport()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .padding(.top, 10)
                                .padding(.leading, 12)
                                .font(.system(size: 20))
                        }
                        
                        Button {
                            startImport()
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .padding(.top, 10)
                                .padding(.leading, 20)
                                .font(.system(size: 20))
                        }

                        Spacer()
                        
                        Button {
                            isShowingAddInstrumentSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .padding(.top, 10)
                                .padding(.trailing, 20)
                                .font(.system(size: 20))
                        }
                    }
                    Spacer()
                }
                VStack {
                    Text("Music Trainer!")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                    Spacer()
                    ScrollView(showsIndicators: false) {
                        NavigationLink(destination: IndividualIntervalView()) {
                            Text("Individual Intervals")
                                .capsuleButtonStyle()
                        }
                        .frame(maxWidth: .infinity)
                        
                        NavigationLink(destination: SequenceView()) {
                            Text("Intervals")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: MelodyView()) {
                            Text("Melodies")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: SingleChordView()) {
                            Text("Single Chords")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: DiatonicChordView()) {
                            Text("Diatonic Chords")
                                .capsuleButtonStyle()
                        }
                        
                        NavigationLink(destination: TallyMethodView()) {
                            Text("Tally Method")
                                .capsuleButtonStyle()
                        }

                        ForEach(customInstruments) { instrument in
                            NavigationLink(destination: SequenceView(noteRange: instrument.noteRange)) {
                                Text(instrument.name)
                                    .capsuleButtonStyle(color: .blue)
                            }
                            .contextMenu {
                                Button("Edit") {
                                    instrumentToEdit = instrument
                                }

                                Button("Delete", role: .destructive) {
                                    deleteCustomInstrument(id: instrument.id)
                                }
                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            OrientationManager.lockToPortrait()
            loadCustomInstruments()
        }
        .sheet(isPresented: $isShowingAddInstrumentSheet) {
            AddInstrumentSheet { newInstrument in
                customInstruments.append(newInstrument)
                saveCustomInstruments()
            }
        }
        .sheet(item: $instrumentToEdit) { instrument in
            AddInstrumentSheet(
                initialInstrument: instrument,
                sheetTitle: "Edit Instrument",
                saveButtonTitle: "Update"
            ) { updated in
                updateCustomInstrument(updated)
            }
        }
        .fileExporter(
            isPresented: $isShowingExporter,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "music-app-backup"
        ) { result in
            switch result {
            case .success:
                backupMessage = "Backup exported successfully."
            case .failure(let error):
                backupMessage = "Export failed: \(error.localizedDescription)"
            }
            isShowingBackupAlert = true
        }
        .fileImporter(
            isPresented: $isShowingImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else {
                    backupMessage = "No file selected."
                    isShowingBackupAlert = true
                    return
                }
                prepareImport(from: url)
            case .failure(let error):
                backupMessage = "Import failed: \(error.localizedDescription)"
                isShowingBackupAlert = true
            }
        }
        .alert("Import Backup", isPresented: $isShowingImportModeAlert) {
            Button("Merge") {
                if let backup = pendingImportBackup {
                    applyBackup(backup, mode: .merge)
                    backupMessage = "Backup imported with merge."
                    isShowingBackupAlert = true
                }
                pendingImportBackup = nil
            }
            Button("Replace") {
                if let backup = pendingImportBackup {
                    applyBackup(backup, mode: .replace)
                    backupMessage = "Backup imported and existing data replaced."
                    isShowingBackupAlert = true
                }
                pendingImportBackup = nil
            }
            Button("Cancel", role: .cancel) {
                pendingImportBackup = nil
            }
        } message: {
            Text("Choose Merge to keep existing data and add/update imported data, or Replace to overwrite existing data.")
        }
        .alert("Backup", isPresented: $isShowingBackupAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(backupMessage)
        }

    }

    private func loadCustomInstruments() {
        guard let data = customInstrumentDefinitions.data(using: .utf8) else {
            customInstruments = []
            return
        }

        do {
            customInstruments = try JSONDecoder().decode([CustomInstrumentDefinition].self, from: data)
        } catch {
            customInstruments = []
        }
    }

    private func saveCustomInstruments() {
        do {
            let data = try JSONEncoder().encode(customInstruments)
            customInstrumentDefinitions = String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            customInstrumentDefinitions = "[]"
        }
    }

    private func deleteCustomInstrument(id: UUID) {
        customInstruments.removeAll { $0.id == id }
        saveCustomInstruments()
    }

    private func updateCustomInstrument(_ updated: CustomInstrumentDefinition) {
        guard let index = customInstruments.firstIndex(where: { $0.id == updated.id }) else {
            return
        }
        customInstruments[index] = updated
        saveCustomInstruments()
    }

    private func startExport() {
        let backup = MusicAppBackup(
            instruments: customInstruments,
            melodies: loadCustomMelodies(),
            tallyPieces: pieces.map { piece in
                PianoPieceBackup(
                    id: piece.id,
                    name: piece.name,
                    dateCreated: piece.dateCreated,
                    status: piece.status,
                    entries: piece.entries.map { entry in
                        TallyMethodEntryBackup(
                            id: entry.id,
                            day: entry.day,
                            session: entry.session,
                            dateCreated: entry.dateCreated,
                            sections: entry.sections,
                            reps: entry.reps,
                            memorized: entry.memorized,
                            notes: entry.notes
                        )
                    }
                )
            },
            settings: currentSettingsBackup()
        )

        exportDocument = MusicAppBackupDocument(backup: backup)
        isShowingExporter = true
    }

    private func startImport() {
        isShowingImporter = true
    }

    private func loadCustomMelodies() -> [CustomMelodyDefinition] {
        guard let data = customMelodyDefinitions.data(using: .utf8) else {
            return []
        }

        return (try? JSONDecoder().decode([CustomMelodyDefinition].self, from: data)) ?? []
    }

    private func saveCustomMelodies(_ melodies: [CustomMelodyDefinition]) {
        do {
            let melodyData = try JSONEncoder().encode(melodies)
            customMelodyDefinitions = String(data: melodyData, encoding: .utf8) ?? "[]"
        } catch {
            customMelodyDefinitions = "[]"
        }
    }

    private func prepareImport(from url: URL) {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let backup = try decoder.decode(MusicAppBackup.self, from: data)
            pendingImportBackup = backup
            isShowingImportModeAlert = true
        } catch {
            backupMessage = "Import failed: \(error.localizedDescription)"
            pendingImportBackup = nil
            isShowingImportModeAlert = false
            isShowingBackupAlert = true
        }
    }

    private func applyBackup(_ backup: MusicAppBackup, mode: ImportMode) {
        applyCustomInstruments(backup.instruments, mode: mode)
        applyCustomMelodies(backup.melodies, mode: mode)
        applyTallyPieces(backup.tallyPieces, mode: mode)
        applySettings(backup.settings, mode: mode)
    }

    private func applyCustomInstruments(_ imported: [CustomInstrumentDefinition], mode: ImportMode) {
        switch mode {
        case .replace:
            customInstruments = imported
        case .merge:
            var mergedById = Dictionary(uniqueKeysWithValues: customInstruments.map { ($0.id, $0) })
            for instrument in imported {
                mergedById[instrument.id] = instrument
            }
            customInstruments = Array(mergedById.values).sorted { $0.name < $1.name }
        }
        saveCustomInstruments()
    }

    private func applyCustomMelodies(_ imported: [CustomMelodyDefinition], mode: ImportMode) {
        switch mode {
        case .replace:
            saveCustomMelodies(imported)
        case .merge:
            let existing = loadCustomMelodies()
            var mergedById = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
            for melody in imported {
                mergedById[melody.id] = melody
            }
            let merged = Array(mergedById.values).sorted { $0.name < $1.name }
            saveCustomMelodies(merged)
        }
    }

    private func applyTallyPieces(_ imported: [PianoPieceBackup], mode: ImportMode) {
        switch mode {
        case .replace:
            for piece in pieces {
                modelContext.delete(piece)
            }
            for pieceBackup in imported {
                let newPiece = makePiece(from: pieceBackup)
                modelContext.insert(newPiece)
            }
        case .merge:
            var existingById: [UUID: PianoPiece] = [:]
            var existingByNameDate: [String: PianoPiece] = [:]

            for piece in pieces {
                existingById[piece.id] = piece
                existingByNameDate["\(piece.name)|\(piece.dateCreated.timeIntervalSince1970)"] = piece
            }

            for pieceBackup in imported {
                if let id = pieceBackup.id, let existing = existingById[id] {
                    merge(pieceBackup, into: existing)
                    continue
                }

                let fallbackKey = "\(pieceBackup.name)|\(pieceBackup.dateCreated.timeIntervalSince1970)"
                if let existing = existingByNameDate[fallbackKey] {
                    merge(pieceBackup, into: existing)
                    continue
                }

                let newPiece = makePiece(from: pieceBackup)
                modelContext.insert(newPiece)
            }
        }

        try? modelContext.save()
    }

    private func makePiece(from backup: PianoPieceBackup) -> PianoPiece {
        let piece = PianoPiece(name: backup.name, status: backup.status)
        if let id = backup.id {
            piece.id = id
        }
        piece.dateCreated = backup.dateCreated

        for entryBackup in backup.entries {
            let newEntry = TallyMethodEntry(
                day: entryBackup.day,
                session: entryBackup.session,
                dateCreated: entryBackup.dateCreated,
                piece: piece
            )
            if let id = entryBackup.id {
                newEntry.id = id
            }
            newEntry.sections = entryBackup.sections
            newEntry.reps = entryBackup.reps
            newEntry.memorized = entryBackup.memorized
            newEntry.notes = entryBackup.notes
            piece.entries.append(newEntry)
        }

        return piece
    }

    private func merge(_ backup: PianoPieceBackup, into piece: PianoPiece) {
        piece.name = backup.name
        piece.dateCreated = backup.dateCreated
        piece.status = backup.status

        var existingEntriesById: [UUID: TallyMethodEntry] = [:]
        var existingEntriesByFallbackKey: [String: TallyMethodEntry] = [:]

        for entry in piece.entries {
            existingEntriesById[entry.id] = entry
            existingEntriesByFallbackKey["\(entry.day)|\(entry.session)|\(entry.dateCreated.timeIntervalSince1970)"] = entry
        }

        for entryBackup in backup.entries {
            if let id = entryBackup.id, let existing = existingEntriesById[id] {
                existing.day = entryBackup.day
                existing.session = entryBackup.session
                existing.dateCreated = entryBackup.dateCreated
                existing.sections = entryBackup.sections
                existing.reps = entryBackup.reps
                existing.memorized = entryBackup.memorized
                existing.notes = entryBackup.notes
                continue
            }

            let fallbackKey = "\(entryBackup.day)|\(entryBackup.session)|\(entryBackup.dateCreated.timeIntervalSince1970)"
            if let existing = existingEntriesByFallbackKey[fallbackKey] {
                existing.sections = entryBackup.sections
                existing.reps = entryBackup.reps
                existing.memorized = entryBackup.memorized
                existing.notes = entryBackup.notes
                continue
            }

            let newEntry = TallyMethodEntry(
                day: entryBackup.day,
                session: entryBackup.session,
                dateCreated: entryBackup.dateCreated,
                piece: piece
            )
            if let id = entryBackup.id {
                newEntry.id = id
            }
            newEntry.sections = entryBackup.sections
            newEntry.reps = entryBackup.reps
            newEntry.memorized = entryBackup.memorized
            newEntry.notes = entryBackup.notes
            piece.entries.append(newEntry)
        }
    }

    private func currentSettingsBackup() -> UserSettingsBackup {
        let defaults = UserDefaults.standard
        let tempo = (defaults.object(forKey: "tempo") as? NSNumber)?.doubleValue
        let lowest = (defaults.object(forKey: "lowest") as? NSNumber)?.intValue
        let highest = (defaults.object(forKey: "highest") as? NSNumber)?.intValue
        let direction = defaults.string(forKey: "individualIntervalDirection")
        let enabledIntervals = defaults.string(forKey: "individualIntervalEnabledIntervals")
        let selectedChords = defaults.array(forKey: "SingleChordView.selectedChordNames") as? [String]

        return UserSettingsBackup(
            tempo: tempo,
            lowest: lowest,
            highest: highest,
            individualIntervalDirection: direction,
            individualIntervalEnabledIntervals: enabledIntervals,
            singleChordSelectedNames: selectedChords
        )
    }

    private func applySettings(_ settings: UserSettingsBackup, mode: ImportMode) {
        let defaults = UserDefaults.standard

        if let tempo = settings.tempo {
            defaults.set(tempo, forKey: "tempo")
        } else if mode == .replace {
            defaults.removeObject(forKey: "tempo")
        }

        if let lowest = settings.lowest {
            defaults.set(lowest, forKey: "lowest")
        } else if mode == .replace {
            defaults.removeObject(forKey: "lowest")
        }

        if let highest = settings.highest {
            defaults.set(highest, forKey: "highest")
        } else if mode == .replace {
            defaults.removeObject(forKey: "highest")
        }

        if let direction = settings.individualIntervalDirection {
            defaults.set(direction, forKey: "individualIntervalDirection")
        } else if mode == .replace {
            defaults.removeObject(forKey: "individualIntervalDirection")
        }

        if let enabledIntervals = settings.individualIntervalEnabledIntervals {
            defaults.set(enabledIntervals, forKey: "individualIntervalEnabledIntervals")
        } else if mode == .replace {
            defaults.removeObject(forKey: "individualIntervalEnabledIntervals")
        }

        if let importedNames = settings.singleChordSelectedNames {
            if mode == .merge,
               let existingNames = defaults.array(forKey: "SingleChordView.selectedChordNames") as? [String] {
                let mergedNames = Array(Set(existingNames).union(importedNames)).sorted()
                defaults.set(mergedNames, forKey: "SingleChordView.selectedChordNames")
            } else {
                defaults.set(importedNames, forKey: "SingleChordView.selectedChordNames")
            }
        } else if mode == .replace {
            defaults.removeObject(forKey: "SingleChordView.selectedChordNames")
        }
    }

}

private extension CustomInstrumentDefinition {
    var noteRange: ClosedRange<UInt8> {
        let lower = UInt8(max(0, min(127, lowestNote)))
        let upper = UInt8(max(0, min(127, highestNote)))
        return lower...upper
    }
    
}

#Preview {
    ContentView()
}


