//
//  MacroPreferencesModelTests.swift
//  OutlanderTests
//
//  Created by Christopher Symonds using Codex 11/04/2025.
//

@testable import Outlander
import XCTest

class MacroPreferencesModelTests: XCTestCase {
    func test_keypad_defaults_match_expected_groups() {
        let store = MacroPreferencesStore(category: .keypad, context: nil)

        XCTAssertEqual(store.value(for: .none, key: .keypad8), "north")
        XCTAssertEqual(store.value(for: .command, key: .keypad7), "sneak northwest")
        XCTAssertEqual(store.value(for: .control, key: .keypad8), "tell familiar to go north")
        XCTAssertEqual(store.value(for: .option, key: .keypad8), "")
    }

    func test_letter_reservations_match_expected_rules() {
        let store = MacroPreferencesStore(category: .letters, context: nil)

        XCTAssertTrue(store.isReserved(group: .command, key: .c))
        XCTAssertFalse(store.isReserved(group: .command, key: .b))
        XCTAssertFalse(store.isReserved(group: .option, key: .c))
    }
}
