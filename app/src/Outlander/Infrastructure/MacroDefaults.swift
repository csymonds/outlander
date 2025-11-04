//
//  MacroDefaults.swift
//  Outlander
//
//  Created by Christopher Symonds using Codex 11/02/2025.
//

import Cocoa

struct MacroDefaultEntry {
    let key: Key
    let modifiers: NSEvent.ModifierFlags
    let action: String
}

enum MacroDefaults {
    static let entries: [MacroDefaultEntry] = buildEntries()

    static func defaultMacros() -> [Macro] {
        entries.map { Macro(key: $0.key, modifiers: $0.modifiers, action: $0.action) }
    }

    private static func add(to list: inout [MacroDefaultEntry], _ key: Key, _ modifiers: NSEvent.ModifierFlags = [], _ action: String) {
        list.append(MacroDefaultEntry(key: key, modifiers: modifiers, action: action))
    }

    private static func buildEntries() -> [MacroDefaultEntry] {
        var list: [MacroDefaultEntry] = []

        // Base keypad navigation (no modifier)
        add(to: &list, .keypadMultiply, [], "exp")
        add(to: &list, .keypadPlus, [], "look")
        add(to: &list, .keypadDecimal, [], "up")
        add(to: &list, .keypadDivide, [], "health")
        add(to: &list, .keypad0, [], "down")
        add(to: &list, .keypad1, [], "southwest")
        add(to: &list, .keypad2, [], "south")
        add(to: &list, .keypad3, [], "southeast")
        add(to: &list, .keypad4, [], "west")
        add(to: &list, .keypad5, [], "out")
        add(to: &list, .keypad6, [], "east")
        add(to: &list, .keypad7, [], "northwest")
        add(to: &list, .keypad8, [], "north")
        add(to: &list, .keypad9, [], "northeast")

        // Command keypad (sneak)
        add(to: &list, .keypadDecimal, [.command], "sneak up")
        add(to: &list, .keypad0, [.command], "sneak down")
        add(to: &list, .keypad1, [.command], "sneak southwest")
        add(to: &list, .keypad2, [.command], "sneak south")
        add(to: &list, .keypad3, [.command], "sneak southeast")
        add(to: &list, .keypad4, [.command], "sneak west")
        add(to: &list, .keypad5, [.command], "sneak out")
        add(to: &list, .keypad6, [.command], "sneak east")
        add(to: &list, .keypad7, [.command], "sneak northwest")
        add(to: &list, .keypad8, [.command], "sneak north")
        add(to: &list, .keypad9, [.command], "sneak northeast")

        // Control keypad (familiar)
        add(to: &list, .keypadPlus, [.control], "tell familiar to look")
        add(to: &list, .keypadDecimal, [.control], "tell familiar to go up")
        add(to: &list, .keypad0, [.control], "tell familiar to go down")
        add(to: &list, .keypad1, [.control], "tell familiar to go southwest")
        add(to: &list, .keypad2, [.control], "tell familiar to go south")
        add(to: &list, .keypad3, [.control], "tell familiar to go southeast")
        add(to: &list, .keypad4, [.control], "tell familiar to go west")
        add(to: &list, .keypad5, [.control], "tell familiar to go out")
        add(to: &list, .keypad6, [.control], "tell familiar to go east")
        add(to: &list, .keypad7, [.control], "tell familiar to go northwest")
        add(to: &list, .keypad8, [.control], "tell familiar to go north")
        add(to: &list, .keypad9, [.control], "tell familiar to go northeast")

        return list
    }
}
