//
//  HighlightPreferencesViewModel.swift
//  Outlander
//
//  Created by Christopher Symonds using Codex on 11/08/2025.
//

import Combine
import SwiftUI

@available(macOS 11.0, *)
final class HighlightPreferencesViewModel: ObservableObject {
    @Published private(set) var entries: [HighlightPreferencesEntry]
    @Published var selectedID: HighlightPreferencesEntry.ID? {
        didSet {
            guard selectedID != oldValue else {
                return
            }
            loadSelection()
        }
    }

    @Published var pattern: String = ""
    @Published var className: String = ""
    @Published var soundFile: String = ""
    @Published var foregroundColor: Color = Color.white
    @Published var backgroundColor: Color = Color.white
    @Published var usesBackgroundColor: Bool = false
    @Published var errors: [String] = []

    var hasSelection: Bool {
        selectedEntry != nil
    }

    var hasUnsavedChanges: Bool {
        store.normalizedHighlights() != originalHighlights
    }

    private var selectedEntry: HighlightPreferencesEntry? {
        guard let id = selectedID else {
            return nil
        }
        return entries.first(where: { $0.id == id })
    }

    private let context: GameContext
    private let loader: HighlightLoader
    private let store: HighlightPreferencesStore
    private var originalHighlights: [Highlight]

    init(context: GameContext, fileSystem: FileSystem? = nil) {
        self.context = context
        let fs = fileSystem ?? LocalFileSystem(context.applicationSettings)
        loader = HighlightLoader(fs)

        let currentHighlights = context.highlights.all()
        store = HighlightPreferencesStore(highlights: currentHighlights)
        entries = store.allEntries()
        originalHighlights = store.normalizedHighlights()

        selectedID = entries.first?.id
        loadSelection()
    }

    func refreshFromContext() {
        store.replace(with: context.highlights.all())
        entries = store.allEntries()
        if !entries.contains(where: { $0.id == selectedID }) {
            selectedID = entries.first?.id
        } else {
            loadSelection()
        }
    }

    func addNew() {
        errors = []
        let entry = store.addEntry()
        entries = store.allEntries()
        selectedID = entry.id
        applySelection(entry)
        pushToContext()
    }

    func deleteSelected() {
        guard let id = selectedID else {
            return
        }
        errors = []
        store.removeEntry(withId: id)
        entries = store.allEntries()
        selectedID = entries.first?.id
        loadSelection()
        pushToContext()
    }

    func applyEdits() {
        guard let id = selectedID else {
            return
        }

        let trimmedPattern = pattern.trimmingCharacters(in: .whitespacesAndNewlines)
        var validationErrors: [String] = []

        if trimmedPattern.isEmpty {
            validationErrors.append("Pattern cannot be blank.")
        }

        guard validationErrors.isEmpty else {
            errors = validationErrors
            return
        }

        errors = []

        let entry = HighlightPreferencesEntry(
            id: id,
            pattern: trimmedPattern,
            className: className,
            soundFile: soundFile,
            foreground: nsColor(from: foregroundColor),
            background: usesBackgroundColor ? nsColor(from: backgroundColor) : nil
        )

        store.updateEntry(entry)
        entries = store.allEntries()
        applySelection(entry)
        selectedID = id
        pushToContext()
    }

    func save() {
        let highlights = store.normalizedHighlights()
        context.replaceHighlights(with: highlights)
        loader.save(context.applicationSettings, highlights: highlights)
        context.events2.echoText("Highlights saved")
        originalHighlights = highlights
    }

    func restore() {
        store.replace(with: originalHighlights)
        entries = store.allEntries()
        selectedID = entries.first?.id
        loadSelection()
        context.replaceHighlights(with: originalHighlights)
    }

    private func loadSelection() {
        guard let entry = selectedEntry else {
            clearSelection()
            return
        }
        applySelection(entry)
    }

    private func applySelection(_ entry: HighlightPreferencesEntry) {
        pattern = entry.pattern
        className = entry.className
        soundFile = entry.soundFile
        foregroundColor = Color(nsColor: entry.foreground)

        if let background = entry.background {
            backgroundColor = Color(nsColor: background)
            usesBackgroundColor = true
        } else {
            backgroundColor = Color.white
            usesBackgroundColor = false
        }
    }

    private func clearSelection() {
        pattern = ""
        className = ""
        soundFile = ""
        foregroundColor = Color.white
        backgroundColor = Color.white
        usesBackgroundColor = false
    }

    private func pushToContext() {
        context.replaceHighlights(with: store.normalizedHighlights())
    }

    private func nsColor(from color: Color) -> NSColor {
        #if os(macOS)
        if let cgColor = color.cgColor, let converted = NSColor(cgColor: cgColor) {
            return converted
        }
        #endif
        return NSColor.white
    }
}
