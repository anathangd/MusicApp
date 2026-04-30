//
//  TallyMethodView.swift
//  Music App
//
//  Created by Nathan Davis on 4/30/26.
//

import SwiftUI
import SwiftData

struct TallyMethodView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PianoPiece.dateCreated, order: .reverse) private var pieces: [PianoPiece]

    @State private var showingAddSheet = false

    private var activePieces: [PianoPiece] {
        pieces.filter { $0.status == .active }
    }

    private var completedPieces: [PianoPiece] {
        pieces.filter { $0.status == .completed }
    }

    private var inactivePieces: [PianoPiece] {
        pieces.filter { $0.status == .inactive }
    }

    var body: some View {
        List {
            Section {
                NavigationLink {
                    PieceFolderView(title: "Completed", emptyText: "No completed pieces yet", pieces: completedPieces) { piece in
                        pieceRow(piece)
                    }
                } label: {
                    HStack {
                        Label("Completed", systemImage: "checkmark.rectangle.fill")
                        Spacer()
                        Text("\(completedPieces.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                NavigationLink {
                    PieceFolderView(title: "Inactive", emptyText: "No inactive pieces yet", pieces: inactivePieces) { piece in
                        pieceRow(piece)
                    }
                } label: {
                    HStack {
                        Label("Inactive", systemImage: "folder.fill")
                        Spacer()
                        Text("\(inactivePieces.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Active") {
                if activePieces.isEmpty {
                    Text("Add your first piece to get started")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(activePieces) { piece in
                        pieceRow(piece)
                    }
                }
            }
        }
        .navigationTitle("Tally Method")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Piece", systemImage: "doc.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddPianoPieceSheet { name in
                let piece = PianoPiece(name: name)
                modelContext.insert(piece)
                try? modelContext.save()
            }
        }
        .onAppear {
            print(pieces)
        }
    }

    @ViewBuilder
    private func pieceRow(_ piece: PianoPiece) -> some View {
        NavigationLink {
            PianoPieceView(piece: piece)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(piece.name)
                    .font(.headline)
                Text(piece.dateCreated, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if piece.status != .completed {
                Button("Complete") {
                    piece.status = .completed
                }
                .tint(.green)
            }

            if piece.status != .inactive {
                Button("Inactive") {
                    piece.status = .inactive
                }
                .tint(.orange)
            }

            if piece.status != .active {
                Button("Activate") {
                    piece.status = .active
                }
                .tint(.blue)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(role: .destructive) {
                modelContext.delete(piece)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

private struct PieceFolderView<RowContent: View>: View {
    let title: String
    let emptyText: String
    let pieces: [PianoPiece]
    @ViewBuilder let rowContent: (PianoPiece) -> RowContent

    var body: some View {
        List {
            if pieces.isEmpty {
                Text(emptyText)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(pieces) { piece in
                    rowContent(piece)
                }
            }
        }
        .navigationTitle(title)
    }
}

private struct AddPianoPieceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pieceName = ""

    let onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("New Piano Piece") {
                    TextField("Piece name", text: $pieceName)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Add Piece")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmedName = pieceName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedName.isEmpty else { return }
                        onAdd(trimmedName)
                        pieceName = ""
                        dismiss()
                    }
                    .disabled(pieceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: PianoPiece.self, TallyMethodEntry.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let samples: [(String, PianoPieceStatus)] = [
        ("Moonlight Sonata", .active),
        ("Clair de Lune", .active),
        ("Für Elise", .completed),
        ("Gymnopédie No. 1", .inactive)
    ]
    for (name, status) in samples {
        container.mainContext.insert(PianoPiece(name: name, status: status))
    }
    return NavigationStack {
        TallyMethodView()
    }
    .modelContainer(container)
}
