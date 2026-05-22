//
//  SoundFontStore.swift
//  Music App
//

import Foundation

struct SoundFontDefinition: Identifiable, Codable, Hashable {
    var id = UUID()
    var displayName: String
    var filename: String
    var isDefault: Bool
}

struct SoundFontAssetArchive: Codable, Hashable {
    var id: UUID
    var data: Data
}

final class SoundFontStore: ObservableObject {
    static let shared = SoundFontStore()

    @Published private(set) var soundFonts: [SoundFontDefinition] = []

    private let storageKey = "soundFontDefinitions"
    let soundFontsDirectory: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        soundFontsDirectory = docs.appendingPathComponent("soundfonts")
        try? FileManager.default.createDirectory(at: soundFontsDirectory, withIntermediateDirectories: true)
        load()
    }

    // URL for the active default: the user-set default if any, otherwise first bundled .sf2.
    var defaultSoundFontURL: URL? {
        if let def = soundFonts.first(where: { $0.isDefault }) {
            let url = soundFontsDirectory.appendingPathComponent(def.filename)
            if FileManager.default.fileExists(atPath: url.path) { return url }
        }
        return Bundle.main.urls(forResourcesWithExtension: "sf2", subdirectory: nil)?.first
    }

    func fileURL(for id: UUID) -> URL? {
        guard let def = soundFonts.first(where: { $0.id == id }) else { return nil }
        let url = soundFontsDirectory.appendingPathComponent(def.filename)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func importSoundFont(from sourceURL: URL) throws {
        let originalFilename = sourceURL.lastPathComponent
        let storedFilename = "\(UUID().uuidString)_\(originalFilename)"
        let destination = soundFontsDirectory.appendingPathComponent(storedFilename)
        try FileManager.default.copyItem(at: sourceURL, to: destination)

        let isFirstImport = soundFonts.isEmpty
        let displayName = sourceURL.deletingPathExtension().lastPathComponent
        let def = SoundFontDefinition(displayName: displayName, filename: storedFilename, isDefault: isFirstImport)
        soundFonts.append(def)
        save()

        // If first import, also make it active immediately.
        if isFirstImport {
            PianoSequencePlayer.shared.loadSoundFont(url: destination)
        }
    }

    func deleteSoundFont(id: UUID) {
        guard let index = soundFonts.firstIndex(where: { $0.id == id }) else { return }
        let def = soundFonts[index]
        let wasDefault = def.isDefault
        try? FileManager.default.removeItem(at: soundFontsDirectory.appendingPathComponent(def.filename))
        soundFonts.remove(at: index)
        if wasDefault, !soundFonts.isEmpty {
            soundFonts[0].isDefault = true
        }
        save()

        // Reload appropriate soundfont into player.
        if let url = defaultSoundFontURL {
            PianoSequencePlayer.shared.loadSoundFont(url: url)
        }
    }

    func renameSoundFont(id: UUID, to newName: String) {
        guard let index = soundFonts.firstIndex(where: { $0.id == id }) else { return }
        soundFonts[index].displayName = newName
        save()
    }

    func setDefault(id: UUID) {
        for i in soundFonts.indices {
            soundFonts[i].isDefault = (soundFonts[i].id == id)
        }
        save()
        if let url = defaultSoundFontURL {
            PianoSequencePlayer.shared.loadSoundFont(url: url)
        }
    }

    func backupAssets() -> [SoundFontAssetArchive] {
        soundFonts.compactMap { def in
            let url = soundFontsDirectory.appendingPathComponent(def.filename)
            guard let data = try? Data(contentsOf: url) else { return nil }
            return SoundFontAssetArchive(id: def.id, data: data)
        }
    }

    func applyBackup(
        definitions importedDefinitions: [SoundFontDefinition],
        assets importedAssets: [SoundFontAssetArchive],
        replaceExisting: Bool
    ) {
        let fm = FileManager.default

        if replaceExisting {
            if let existingFiles = try? fm.contentsOfDirectory(at: soundFontsDirectory, includingPropertiesForKeys: nil) {
                for url in existingFiles {
                    try? fm.removeItem(at: url)
                }
            }
            soundFonts.removeAll()
        }

        let assetsByID = Dictionary(uniqueKeysWithValues: importedAssets.map { ($0.id, $0.data) })
        var merged = soundFonts

        for imported in importedDefinitions {
            guard let data = assetsByID[imported.id] else { continue }

            var finalDefinition = imported
            let preferredFilename = imported.filename.isEmpty ? "\(imported.id.uuidString).sf2" : imported.filename
            let resolvedFilename = uniqueFilename(
                preferred: preferredFilename,
                excludingID: imported.id,
                existing: merged
            )
            finalDefinition.filename = resolvedFilename

            let destination = soundFontsDirectory.appendingPathComponent(resolvedFilename)
            do {
                try data.write(to: destination, options: .atomic)
            } catch {
                continue
            }

            if let existingIndex = merged.firstIndex(where: { $0.id == imported.id }) {
                let oldFilename = merged[existingIndex].filename
                if oldFilename != resolvedFilename {
                    try? fm.removeItem(at: soundFontsDirectory.appendingPathComponent(oldFilename))
                }
                merged[existingIndex] = finalDefinition
            } else {
                merged.append(finalDefinition)
            }
        }

        soundFonts = merged
        normalizeDefaults()
        save()

        if let url = defaultSoundFontURL {
            PianoSequencePlayer.shared.loadSoundFont(url: url)
        }
    }

    private func uniqueFilename(preferred: String, excludingID: UUID, existing: [SoundFontDefinition]) -> String {
        let existingNames = Set(
            existing
                .filter { $0.id != excludingID }
                .map { $0.filename }
        )
        if !existingNames.contains(preferred) {
            return preferred
        }

        let base = URL(fileURLWithPath: preferred).deletingPathExtension().lastPathComponent
        let ext = URL(fileURLWithPath: preferred).pathExtension
        var candidate = preferred
        var index = 2
        while existingNames.contains(candidate) {
            let suffix = "_\(index)"
            candidate = ext.isEmpty ? "\(base)\(suffix)" : "\(base)\(suffix).\(ext)"
            index += 1
        }
        return candidate
    }

    private func normalizeDefaults() {
        guard !soundFonts.isEmpty else { return }

        let firstDefaultIndex = soundFonts.firstIndex(where: { $0.isDefault })
        for i in soundFonts.indices {
            soundFonts[i].isDefault = (i == firstDefaultIndex)
        }

        if firstDefaultIndex == nil {
            soundFonts[0].isDefault = true
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let defs = try? JSONDecoder().decode([SoundFontDefinition].self, from: data) else { return }
        soundFonts = defs
        normalizeDefaults()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(soundFonts) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
