//
//  HighlightPreferencesViewModelTests.swift
//  OutlanderTests
//
//  Created by Christopher Symonds using Codex on 11/08/2025.
//

@testable import Outlander
import SwiftUI
import XCTest

@available(macOS 11.0, *)
final class HighlightPreferencesViewModelTests: XCTestCase {
    private var context: GameContext!
    private var fileSystem: InMemoryFileSystem!
    private var viewModel: HighlightPreferencesViewModel!

    override func setUp() {
        super.setUp()
        context = GameContext(InMemoryEvents())
        let highlights = [
            Highlight(foreColor: "#ff0000", backgroundColor: "", pattern: "dragon", className: "", soundFile: ""),
            Highlight(foreColor: "#00ff00", backgroundColor: "#000000", pattern: "orc", className: "creatures", soundFile: "")
        ]
        context.replaceHighlights(with: highlights)
        fileSystem = InMemoryFileSystem()
        viewModel = HighlightPreferencesViewModel(context: context, fileSystem: fileSystem)
    }

    func test_hasUnsavedChanges_false_on_init() {
        XCTAssertFalse(viewModel.hasUnsavedChanges)
    }

    func test_applyEdits_marks_view_model_dirty_and_save_clears() {
        guard let id = viewModel.entries.first?.id else {
            XCTFail("Expected an entry")
            return
        }

        viewModel.selectedID = id
        viewModel.pattern = "dragon lord"
        viewModel.applyEdits()

        XCTAssertTrue(viewModel.errors.isEmpty)
        XCTAssertTrue(viewModel.hasUnsavedChanges)
        XCTAssertEqual(context.highlights.all().first?.pattern, "dragon lord")
        XCTAssertEqual(context.highlights.active().first?.pattern, "dragon lord")

        viewModel.save()

        XCTAssertFalse(viewModel.hasUnsavedChanges)
        XCTAssertNotNil(fileSystem.savedContent)
    }

    func test_deleteSelected_removes_entry_from_store_and_context() {
        let originalCount = viewModel.entries.count

        viewModel.deleteSelected()

        XCTAssertEqual(viewModel.entries.count, originalCount - 1)
        XCTAssertEqual(context.highlights.all().count, originalCount - 1)
    }
}
