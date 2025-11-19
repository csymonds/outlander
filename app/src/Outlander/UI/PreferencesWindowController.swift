//
//  PreferencesWindowController.swift
//  Outlander
//
//  Created by Christopher Symonds using Codex 11/02/2025.
//

import Cocoa
import Combine
import SwiftUI

@available(macOS 11.0, *)
final class PreferencesViewModel: ObservableObject {
    @ObservedObject var macrosViewModel: MacroPreferencesViewModel
    private let onDismiss: () -> Void

    init(context: GameContext, onDismiss: @escaping () -> Void) {
        macrosViewModel = MacroPreferencesViewModel(context: context)
        self.onDismiss = onDismiss
    }

    func close() {
        macrosViewModel.save()
        onDismiss()
    }

    func revert() {
        macrosViewModel.restore()
    }
}

@available(macOS 11.0, *)
final class PreferencesWindowController: NSWindowController {
    private var hostingController: NSHostingController<PreferencesView>?

    func show(with context: GameContext) {
        let viewModel = PreferencesViewModel(context: context) { [weak self] in
            self?.window?.close()
        }

        if let hosting = hostingController {
            hosting.rootView = PreferencesView(viewModel: viewModel)
            hosting.view.window?.makeKeyAndOrderFront(nil)
        } else {
            let hosting = NSHostingController(rootView: PreferencesView(viewModel: viewModel))
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 720, height: 520),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Preferences"
            window.isReleasedWhenClosed = false
            window.tabbingMode = .disallowed
            window.contentViewController = hosting
            window.center()

            self.window = window
            hostingController = hosting
        }

        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
