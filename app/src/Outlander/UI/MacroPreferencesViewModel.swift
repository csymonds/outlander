//
//  MacroPreferencesViewModel.swift
//  Outlander
//
//  Created by Christopher Symonds using Codex 11/02/2025.
//

import SwiftUI
import Combine

@available(macOS 11.0, *)
final class MacroPreferencesViewModel: ObservableObject {
    @Published var selectedCategory: MacroPreferencesCategory {
        didSet {
            if let store = stores[selectedCategory] {
                if !store.modifierGroups.contains(selectedGroup) {
                    selectedGroup = store.modifierGroups.first ?? .none
                }
            }
        }
    }

    @Published var selectedGroup: MacroModifierGroup

    private var stores: [MacroPreferencesCategory: MacroPreferencesStore]
    private let context: GameContext
    private let loader: MacroLoader
    private var originalEntries: [MacroDefaultEntry]

    init(context: GameContext) {
        self.context = context
        let fileSystem = LocalFileSystem(context.applicationSettings)
        loader = MacroLoader(fileSystem)

        var map: [MacroPreferencesCategory: MacroPreferencesStore] = [:]
        for category in MacroPreferencesCategory.allCases {
            map[category] = MacroPreferencesStore(category: category, context: context)
        }
        stores = map

        let initialCategory: MacroPreferencesCategory = .keypad
        selectedCategory = initialCategory
        selectedGroup = stores[initialCategory]?.modifierGroups.first ?? .none

        originalEntries = MacroPreferencesViewModel.entries(from: context.macros)
    }

    var availableGroups: [MacroModifierGroup] {
        stores[selectedCategory]?.modifierGroups ?? []
    }

    var keyDefinitions: [MacroKeyDefinition] {
        stores[selectedCategory]?.keyDefinitions ?? []
    }

    func reservedLabel(for definition: MacroKeyDefinition) -> String? {
        stores[selectedCategory]?.reservedLabel(group: selectedGroup, key: definition.key)
    }

    func isReserved(_ definition: MacroKeyDefinition) -> Bool {
        stores[selectedCategory]?.isReserved(group: selectedGroup, key: definition.key) ?? false
    }

    func binding(for definition: MacroKeyDefinition) -> Binding<String> {
        Binding(
            get: {
                self.stores[self.selectedCategory]?.value(for: self.selectedGroup, key: definition.key) ?? ""
            },
            set: { newValue in
                guard let store = self.stores[self.selectedCategory], !self.isReserved(definition) else {
                    return
                }
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                store.setValue(trimmed, for: self.selectedGroup, key: definition.key)
                let action = trimmed.isEmpty ? nil : trimmed
                self.context.setMacro(action: action, for: definition.key, modifiers: self.selectedGroup.flags)
#if DEBUG
                let label = action ?? "<cleared>"
                print("[Preferences] \(definition.title) (\(self.selectedGroup.title)) → \(label)")
#endif
                self.objectWillChange.send()
            }
        )
    }

    var hasUnsavedChanges: Bool {
        snapshot(context.macros) != snapshot(from: originalEntries)
    }

    func save() {
        loader.save(context.applicationSettings, macros: context.macros)
        context.events2.echoText("Macros saved")
        originalEntries = MacroPreferencesViewModel.entries(from: context.macros)
    }

    func restore() {
        context.macros.removeAll()
        for entry in originalEntries {
            context.setMacro(action: entry.action, for: entry.key, modifiers: entry.modifiers)
        }
        rebuildStores()
    }

    private func rebuildStores() {
        for category in MacroPreferencesCategory.allCases {
            stores[category] = MacroPreferencesStore(category: category, context: context)
        }
        if !(stores[selectedCategory]?.modifierGroups.contains(selectedGroup) ?? false) {
            selectedGroup = stores[selectedCategory]?.modifierGroups.first ?? .none
        }
        objectWillChange.send()
    }

    private func snapshot(_ macros: [String: Macro]) -> [MacroSnapshot] {
        macros.values.compactMap { macro in
            guard let key = macro.key else { return nil }
            let modifiers = NSEvent.ModifierFlags(carbon: macro.carbonModifiers)
            return MacroSnapshot(key: key, modifiers: modifiers, action: macro.action)
        }
        .sorted(by: MacroSnapshot.sorter)
    }

    private func snapshot(from entries: [MacroDefaultEntry]) -> [MacroSnapshot] {
        entries.map { MacroSnapshot(key: $0.key, modifiers: $0.modifiers, action: $0.action) }
            .sorted(by: MacroSnapshot.sorter)
    }

    private static func entries(from macros: [String: Macro]) -> [MacroDefaultEntry] {
        macros.values.compactMap { macro in
            guard let key = macro.key else { return nil }
            let modifiers = NSEvent.ModifierFlags(carbon: macro.carbonModifiers)
            return MacroDefaultEntry(key: key, modifiers: modifiers, action: macro.action)
        }
    }

    private struct MacroSnapshot: Equatable {
        let key: Key
        let modifiers: NSEvent.ModifierFlags
        let action: String

        static func == (lhs: MacroSnapshot, rhs: MacroSnapshot) -> Bool {
            lhs.key == rhs.key && lhs.modifiers.rawValue == rhs.modifiers.rawValue && lhs.action == rhs.action
        }

        static func sorter(lhs: MacroSnapshot, rhs: MacroSnapshot) -> Bool {
            if lhs.key.rawValue == rhs.key.rawValue {
                return lhs.modifiers.rawValue < rhs.modifiers.rawValue
            }
            return lhs.key.rawValue < rhs.key.rawValue
        }
    }
}
