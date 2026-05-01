//
//  PianoPieceView.swift
//  Music App
//
//  Created by Nathan Davis on 4/30/26.
//

import SwiftUI
import SwiftData
import UIKit

struct PianoPieceView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var piece: PianoPiece
    @State private var showingCustomSectionSheet = false
    @State private var customSectionName = ""
    @State private var showingRenameSectionAlert = false
    @State private var renameSectionName = ""
    @State private var renameEntryID: UUID?
    @State private var renameSectionIndex: Int?
    @State private var entryPendingDeletion: TallyMethodEntry?
    @FocusState private var focusedEntryID: UUID?
    private let calendar = Calendar.current

    private func playLightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func playMediumHaptic() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func playSuccessHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func playWarningHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    private var sortedEntries: [TallyMethodEntry] {
        piece.entries.sorted {
            if calendar.isDate($0.dateCreated, inSameDayAs: $1.dateCreated) {
                if $0.session == $1.session {
                    return $0.day > $1.day
                }
                return $0.session > $1.session
            }
            return $0.dateCreated > $1.dateCreated
        }
    }

    private var sectionOptions: [String] {
        let existingSections = Array(Set(piece.entries.flatMap { $0.sections })).sorted()
        let letterSections = existingSections.filter { section in
            section.count == 1 && section.first?.isLetter == true
        }

        let highestLetter = letterSections
            .compactMap { $0.uppercased().unicodeScalars.first?.value }
            .max()

        let nextLetter: String? = highestLetter.flatMap { value in
            let zValue = UnicodeScalar("Z").value
            guard value < zValue,
                  let scalar = UnicodeScalar(value + 1) else { return nil }
            return String(scalar)
        }

        var options = ["A", "B", "C"]

        for section in existingSections where !options.contains(section) {
            options.append(section)
        }

        if let nextLetter, !options.contains(nextLetter) {
            options.append(nextLetter)
        }

        return options
    }

    var body: some View {
        List {
            ForEach(sortedEntries) { entry in
                Section {
                    ForEach(sectionRows(for: entry)) { row in
                        let i = row.index
                        HStack {
                            Text("\(entry.sections[i]):    \(entry.reps[i])")
                                .font(.system(size: 30))
                                .onLongPressGesture {
                                    beginRenameSection(entry: entry, index: i)
                                }
                            Spacer()
                            if isSectionMemorized(entry: entry, index: i) {
                                Image(systemName: "brain.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.blue)
                            }
                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .foregroundStyle(.blue)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                                .contentShape(Rectangle())
                                .gesture(
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            decrementSection(entry: entry, index: i)
                                        }
                                        .exclusively(before: TapGesture().onEnded {
                                            incrementSection(entry: entry, index: i)
                                        })
                                )
                                .accessibilityLabel("Increment section")
                                .accessibilityHint("Tap to increase. Long press to decrease.")
                        }
                        .padding(.vertical, 2)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                deleteSection(entry: entry, index: i)
                            }

                            if isSectionMemorized(entry: entry, index: i) {
                                Button("Unmemorize") {
                                    setSectionMemorized(false, entry: entry, index: i)
                                }
                                .tint(.gray)
                            } else {
                                Button("Memorized") {
                                    setSectionMemorized(true, entry: entry, index: i)
                                }
                                .tint(.blue)
                            }
                        }
                    }

                    let available = sectionOptions.filter { !entry.sections.contains($0) }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add:")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        WrappingHStack(spacing: 8, lineSpacing: 8) {
                            ForEach(available, id: \.self) { name in
                                Button(name) {
                                    entry.sections = entry.sections + [name]
                                    entry.reps = entry.reps + [0]
                                    entry.memorized = entry.memorized + [false]
                                    save()
                                }
                                .buttonStyle(.bordered)
                            }

                            Button("Custom") {
                                customSectionName = ""
                                showingCustomSectionSheet = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 2)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Note")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField(
                            "Write a quick note",
                            text: Binding(
                                get: { entry.notes },
                                set: { newValue in
                                    entry.notes = newValue
                                    save()
                                }
                            ),
                            axis: .vertical
                        )
                        .lineLimit(1...)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedEntryID, equals: entry.id)
                    }
                    .padding(.top, 4)
                } header: {
                    HStack {
                        Text(dayHeader(for: entry))
                        Spacer()
                        Menu {
                            Button("Delete Session", role: .destructive) {
                                entryPendingDeletion = entry
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .navigationTitle(piece.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addDay()
                } label: {
                    Label("Add Entry", systemImage: "plus")
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedEntryID = nil
                }
            }
        }
        .sheet(isPresented: $showingCustomSectionSheet) {
            NavigationStack {
                Form {
                    TextField("Section name", text: $customSectionName)
                }
                .navigationTitle("Custom Section")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingCustomSectionSheet = false
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addCustomSection()
                        }
                        .disabled(customSectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        .alert("Rename Section", isPresented: $showingRenameSectionAlert) {
            TextField("Section name", text: $renameSectionName)
            Button("Cancel", role: .cancel) {
                clearRenameState()
            }
            Button("Rename") {
                applySectionRename()
            }
        } message: {
            Text("Long-press a section to edit its name.")
        }
        .confirmationDialog(
            "Delete this session?",
            isPresented: Binding(
                get: { entryPendingDeletion != nil },
                set: { if !$0 { entryPendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete Session", role: .destructive) {
                if let entry = entryPendingDeletion {
                    deleteEntry(entry)
                }
                entryPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) {
                entryPendingDeletion = nil
            }
        } message: {
            Text("This will delete the entire session, including all section counts and notes.")
        }
    }

    private func addDay() {
        playSuccessHaptic()
        let now = Date()
        let todayEntries = piece.entries.filter { calendar.isDate($0.dateCreated, inSameDayAs: now) }

        let nextDay: Int
        let nextSession: Int

        if let latestTodaySession = todayEntries.map(\ .session).max() {
            nextDay = todayEntries.first?.day ?? ((piece.entries.map(\ .day).max() ?? 0) + 1)
            nextSession = latestTodaySession + 1
        } else {
            nextDay = (piece.entries.map(\ .day).max() ?? 0) + 1
            nextSession = 1
        }

        let entry = TallyMethodEntry(day: nextDay, session: nextSession, dateCreated: now, piece: piece)
        modelContext.insert(entry)
        save()
    }

    private func addCustomSection() {
        let trimmedName = customSectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        playSuccessHaptic()

        if let latestEntry = sortedEntries.first, !latestEntry.sections.contains(trimmedName) {
            latestEntry.sections.append(trimmedName)
            latestEntry.reps.append(0)
            latestEntry.memorized.append(false)
        }

        customSectionName = ""
        showingCustomSectionSheet = false
        save()
    }

    private func beginRenameSection(entry: TallyMethodEntry, index: Int) {
        guard entry.sections.indices.contains(index) else { return }
        playMediumHaptic()
        renameEntryID = entry.id
        renameSectionIndex = index
        renameSectionName = entry.sections[index]
        showingRenameSectionAlert = true
    }

    private func applySectionRename() {
        let trimmed = renameSectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let entryID = renameEntryID,
              let sectionIndex = renameSectionIndex,
              let entry = piece.entries.first(where: { $0.id == entryID }),
              entry.sections.indices.contains(sectionIndex)
        else {
            clearRenameState()
            return
        }

        let alreadyExists = entry.sections.enumerated().contains {
            $0.offset != sectionIndex && $0.element.caseInsensitiveCompare(trimmed) == .orderedSame
        }
        guard !alreadyExists else {
            clearRenameState()
            return
        }

        entry.sections[sectionIndex] = trimmed
        clearRenameState()
        playSuccessHaptic()
        save()
    }

    private func clearRenameState() {
        renameEntryID = nil
        renameSectionIndex = nil
        renameSectionName = ""
    }

    private func sectionRows(for entry: TallyMethodEntry) -> [SectionRow] {
        entry.sections.indices.map { index in
            SectionRow(id: "\(entry.id.uuidString)-\(index)", index: index)
        }
    }

    private func isSectionMemorized(entry: TallyMethodEntry, index: Int) -> Bool {
        guard entry.memorized.indices.contains(index) else { return false }
        return entry.memorized[index]
    }

    private func setSectionMemorized(_ isMemorized: Bool, entry: TallyMethodEntry, index: Int) {
        guard entry.sections.indices.contains(index) else { return }
        var updated = entry.memorized
        if updated.count < entry.sections.count {
            updated.append(contentsOf: Array(repeating: false, count: entry.sections.count - updated.count))
        }
        updated[index] = isMemorized
        entry.memorized = updated
        playMediumHaptic()
        save()
    }

    private func incrementSection(entry: TallyMethodEntry, index: Int) {
        guard entry.sections.indices.contains(index) else { return }
        var updated = entry.reps
        if updated.count < entry.sections.count {
            updated.append(contentsOf: Array(repeating: 0, count: entry.sections.count - updated.count))
        }
        updated[index] += 1
        entry.reps = updated
        playLightHaptic()
        save()
    }

    private func decrementSection(entry: TallyMethodEntry, index: Int) {
        guard entry.sections.indices.contains(index) else { return }
        var updated = entry.reps
        if updated.count < entry.sections.count {
            updated.append(contentsOf: Array(repeating: 0, count: entry.sections.count - updated.count))
        }
        updated[index] = max(0, updated[index] - 1)
        entry.reps = updated
        playWarningHaptic()
        save()
    }

    private func deleteSection(entry: TallyMethodEntry, index: Int) {
        guard entry.sections.indices.contains(index) else { return }

        var updatedSections = entry.sections
        updatedSections.remove(at: index)
        entry.sections = updatedSections

        if entry.reps.indices.contains(index) {
            var updatedReps = entry.reps
            updatedReps.remove(at: index)
            entry.reps = updatedReps
        }

        if entry.memorized.indices.contains(index) {
            var updatedMemorized = entry.memorized
            updatedMemorized.remove(at: index)
            entry.memorized = updatedMemorized
        }

        playWarningHaptic()
        save()
    }

    private func deleteEntry(_ entry: TallyMethodEntry) {
        playWarningHaptic()
        modelContext.delete(entry)
        save()
    }

    private func save() {
        try? modelContext.save()
    }

    private func dayHeader(for entry: TallyMethodEntry) -> String {
        let dateText = entry.dateCreated.formatted(date: .abbreviated, time: .omitted)
        let hasMultipleSessions = piece.entries.filter { $0.day == entry.day }.count > 1
        if hasMultipleSessions {
            return "Day \(entry.day) - \(dateText) - Session \(entry.session)"
        }
        return "Day \(entry.day) - \(dateText)"
    }

}

private struct SectionRow: Identifiable {
    let id: String
    let index: Int
}

private struct WrappingHStack: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentLineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var maxLineWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX > 0 && currentX + size.width > maxWidth {
                totalHeight += currentLineHeight + lineSpacing
                maxLineWidth = max(maxLineWidth, currentX - spacing)
                currentX = 0
                currentLineHeight = 0
            }

            currentX += size.width + spacing
            currentLineHeight = max(currentLineHeight, size.height)
        }

        if !subviews.isEmpty {
            totalHeight += currentLineHeight
            maxLineWidth = max(maxLineWidth, max(0, currentX - spacing))
        }

        return CGSize(width: maxLineWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var currentLineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX > bounds.minX && currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += currentLineHeight + lineSpacing
                currentLineHeight = 0
            }

            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            currentX += size.width + spacing
            currentLineHeight = max(currentLineHeight, size.height)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: PianoPiece.self, TallyMethodEntry.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let piece = PianoPiece(name: "Moonlight Sonata")
    container.mainContext.insert(piece)
    let day1 = TallyMethodEntry(day: 1, session: 1, dateCreated: Date().addingTimeInterval(-86400), piece: piece)
    day1.sections = ["A", "B"]
    day1.reps = [4, 2]
    container.mainContext.insert(day1)
    let day2 = TallyMethodEntry(day: 2, session: 1, dateCreated: Date(), piece: piece)
    day2.sections = ["A"]
    day2.reps = [1]
    container.mainContext.insert(day2)
    let day2Session2 = TallyMethodEntry(day: 2, session: 2, dateCreated: Date(), piece: piece)
    day2Session2.sections = ["B"]
    day2Session2.reps = [3]
    container.mainContext.insert(day2Session2)
    return NavigationStack {
        PianoPieceView(piece: piece)
    }
    .modelContainer(container)
}
