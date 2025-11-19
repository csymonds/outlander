//
//  HighlightPreferencesModel.swift
//  Outlander
//
//  Created by Christopher Symonds using Codex on 11/08/2025.
//

import AppKit

struct HighlightPreferencesEntry: Identifiable, Equatable {
    let id: UUID
    var pattern: String
    var className: String
    var soundFile: String
    var foreground: NSColor
    var background: NSColor?

    init(id: UUID = UUID(), pattern: String, className: String, soundFile: String, foreground: NSColor, background: NSColor?) {
        self.id = id
        self.pattern = pattern
        self.className = className
        self.soundFile = soundFile
        self.foreground = foreground
        self.background = background
    }

    init(highlight: Highlight) {
        let fore = NSColor(hex: highlight.foreColor) ?? NSColor.white
        let backgroundColor = highlight.backgroundColor.isEmpty ? nil : NSColor(hex: highlight.backgroundColor)

        self.init(
            pattern: highlight.pattern,
            className: highlight.className,
            soundFile: highlight.soundFile,
            foreground: fore,
            background: backgroundColor
        )
    }

    func normalizedHighlight() -> Highlight {
        let trimmedPattern = pattern.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedClass = className.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedSound = soundFile.trimmingCharacters(in: .whitespacesAndNewlines)

        return Highlight(
            foreColor: foreground.getHexString(),
            backgroundColor: background?.getHexString() ?? "",
            pattern: trimmedPattern,
            className: normalizedClass,
            soundFile: normalizedSound
        )
    }

    static func == (lhs: HighlightPreferencesEntry, rhs: HighlightPreferencesEntry) -> Bool {
        lhs.id == rhs.id
            && lhs.pattern == rhs.pattern
            && lhs.className == rhs.className
            && lhs.soundFile == rhs.soundFile
            && lhs.foreground.getHexString() == rhs.foreground.getHexString()
            && lhs.background?.getHexString() == rhs.background?.getHexString()
    }
}

final class HighlightPreferencesStore {
    private(set) var entries: [HighlightPreferencesEntry]

    init(highlights: [Highlight]) {
        entries = highlights.map { HighlightPreferencesEntry(highlight: $0) }
    }

    func allEntries() -> [HighlightPreferencesEntry] {
        entries
    }

    @discardableResult
    func addEntry(defaultForeground: NSColor = NSColor.white) -> HighlightPreferencesEntry {
        let entry = HighlightPreferencesEntry(
            pattern: "",
            className: "",
            soundFile: "",
            foreground: defaultForeground,
            background: nil
        )
        entries.append(entry)
        return entry
    }

    func updateEntry(_ entry: HighlightPreferencesEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            return
        }
        entries[index] = entry
    }

    func removeEntry(withId id: HighlightPreferencesEntry.ID) {
        entries.removeAll { $0.id == id }
    }

    func replace(with highlights: [Highlight]) {
        entries = highlights.map { HighlightPreferencesEntry(highlight: $0) }
    }

    func normalizedHighlights() -> [Highlight] {
        entries.map { $0.normalizedHighlight() }
    }
}
