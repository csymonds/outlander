//
//  HighlightPreferencesModelTests.swift
//  OutlanderTests
//
//  Created by Christopher Symonds using Codex on 11/08/2025.
//

@testable import Outlander
import AppKit
import XCTest

final class HighlightPreferencesModelTests: XCTestCase {
    func test_init_copies_existing_highlights() {
        let highlights = [
            Highlight(foreColor: "#ff0000", backgroundColor: "", pattern: "dragon", className: "", soundFile: ""),
            Highlight(foreColor: "#00ff00", backgroundColor: "#000000", pattern: "orc", className: "creatures", soundFile: "growl.wav"),
        ]

        let store = HighlightPreferencesStore(highlights: highlights)

        XCTAssertEqual(store.allEntries().count, 2)
        let second = store.allEntries()[1]
        XCTAssertEqual(second.pattern, "orc")
        XCTAssertEqual(second.className, "creatures")
        XCTAssertEqual(second.soundFile, "growl.wav")
        XCTAssertEqual(second.foreground.getHexString(), "#00ff00")
        XCTAssertEqual(second.background?.getHexString(), "#000000")
    }

    func test_add_creates_entry_with_defaults() {
        let store = HighlightPreferencesStore(highlights: [])

        let entry = store.addEntry()

        XCTAssertTrue(store.allEntries().contains(where: { $0.id == entry.id }))
        XCTAssertEqual(entry.pattern, "")
        XCTAssertEqual(entry.className, "")
        XCTAssertEqual(entry.soundFile, "")
        XCTAssertEqual(entry.foreground.getHexString(), "#ffffff")
        XCTAssertNil(entry.background)
    }

    func test_normalized_highlight_applies_trimming_and_lowercasing() {
        let store = HighlightPreferencesStore(highlights: [
            Highlight(foreColor: "#ffffff", backgroundColor: "", pattern: "test", className: "", soundFile: "")
        ])

        var entry = store.allEntries()[0]
        entry.pattern = "  Dragon  "
        entry.className = "Creatures"
        entry.soundFile = " roar.wav "
        entry.foreground = NSColor(hex: "#FF00FF") ?? NSColor.magenta
        entry.background = NSColor(hex: "#00FF00")
        store.updateEntry(entry)

        let normalized = store.normalizedHighlights()[0]

        XCTAssertEqual(normalized.pattern, "Dragon")
        XCTAssertEqual(normalized.className, "creatures")
        XCTAssertEqual(normalized.soundFile, "roar.wav")
        XCTAssertEqual(normalized.foreColor, entry.foreground.getHexString())
        XCTAssertEqual(normalized.backgroundColor, entry.background?.getHexString())
    }
}
