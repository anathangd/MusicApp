//
//  SoundFontManagementView.swift
//  Music App
//

import SwiftUI
import UniformTypeIdentifiers

struct SoundFontManagementView: View {
    @ObservedObject private var store = SoundFontStore.shared
    @State private var isShowingImporter = false
    @State private var importErrorMessage: String?
    @State private var isShowingImportError = false
    @State private var renameTarget: SoundFontDefinition?
    @State private var pendingRename = ""
    @State private var deleteTarget: SoundFontDefinition?
    @State private var isShowingDeleteConfirm = false

    @ViewBuilder
    private var emptyPlaceholder: some View {
        if store.soundFonts.isEmpty {
            Section {
                Text("No SoundFonts imported yet. Tap + to import an .sf2 file.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
    }

    @ViewBuilder
    private var soundFontRows: some View {
        ForEach(store.soundFonts) { sf in
            soundFontRow(sf)
        }
    }

    @ViewBuilder
    private func soundFontRow(_ sf: SoundFontDefinition) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(sf.displayName)
                if sf.isDefault {
                    Text("Default")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor, in: Capsule())
                }
            }
            Spacer()
            if sf.isDefault {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !sf.isDefault {
                store.setDefault(id: sf.id)
            }
        }
        .contextMenu {
            if !sf.isDefault {
                Button {
                    store.setDefault(id: sf.id)
                } label: {
                    Label("Set as Default", systemImage: "checkmark.circle")
                }
            }
            Button {
                renameTarget = sf
                pendingRename = sf.displayName
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive) {
                deleteTarget = sf
                isShowingDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteTarget = sf
                isShowingDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityHint("Tap to make this the default SoundFont")
    }

    var body: some View {
        List {
            emptyPlaceholder
            soundFontRows
        }
        .navigationTitle("SoundFonts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingImporter = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .fileImporter(
            isPresented: $isShowingImporter,
            allowedContentTypes: [UTType(filenameExtension: "sf2") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                let didAccess = url.startAccessingSecurityScopedResource()
                defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
                do {
                    try store.importSoundFont(from: url)
                } catch {
                    importErrorMessage = error.localizedDescription
                    isShowingImportError = true
                }
            case .failure(let error):
                importErrorMessage = error.localizedDescription
                isShowingImportError = true
            }
        }
        .alert("Rename SoundFont", isPresented: Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )) {
            TextField("Name", text: $pendingRename)
            Button("Save") {
                if let target = renameTarget {
                    let trimmed = pendingRename.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        store.renameSoundFont(id: target.id, to: trimmed)
                    }
                }
                renameTarget = nil
            }
            Button("Cancel", role: .cancel) {
                renameTarget = nil
            }
        } message: {
            Text("Enter a new name for this SoundFont.")
        }
        .alert("Delete SoundFont", isPresented: $isShowingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let target = deleteTarget {
                    store.deleteSoundFont(id: target.id)
                }
                deleteTarget = nil
            }
            Button("Cancel", role: .cancel) {
                deleteTarget = nil
            }
        } message: {
            if let target = deleteTarget {
                Text("Delete \"\(target.displayName)\"? Any instruments using this SoundFont will fall back to the default.")
            }
        }
        .alert("Import Failed", isPresented: $isShowingImportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importErrorMessage ?? "Unknown error.")
        }
    }
}
