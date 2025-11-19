//
//  PreferencesView.swift
//  Outlander
//
//  Created by Christopher Symonds using Codex 11/02/2025.
//

import SwiftUI

@available(macOS 11.0, *)
struct PreferencesView: View {
    @ObservedObject var viewModel: PreferencesViewModel

    var body: some View {
        VStack(spacing: 0) {
            TabView {
                Text("General settings coming soon")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tabItem { Text("General") }

                MacroPreferencesTab(viewModel: viewModel.macrosViewModel)
                    .tabItem { Text("Macros") }
            }
            .padding()

            Divider()

            HStack {
                Button("Revert") {
                    viewModel.revert()
                }
                .disabled(!viewModel.macrosViewModel.hasUnsavedChanges)

                Spacer()

                Button("Close") {
                    viewModel.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding([.horizontal, .bottom])
        }
        .frame(minWidth: 720, minHeight: 520)
    }
}

@available(macOS 11.0, *)
struct MacroPreferencesTab: View {
    @ObservedObject var viewModel: MacroPreferencesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(MacroPreferencesCategory.allCases, id: \.self) { category in
                    Text(category.title).tag(category)
                }
            }
            .pickerStyle(.segmented)

            Picker("Modifiers", selection: $viewModel.selectedGroup) {
                ForEach(viewModel.availableGroups, id: \.self) { group in
                    Text(group.title).tag(group)
                }
            }
            .pickerStyle(.segmented)

            List {
                ForEach(viewModel.keyDefinitions, id: \.key) { definition in
                    HStack {
                        Text(definition.title)
                            .frame(width: 60, alignment: .leading)
                        if let label = viewModel.reservedLabel(for: definition) {
                            Text(label)
                                .foregroundColor(.secondary)
                        } else {
                            TextField("Macro", text: viewModel.binding(for: definition))
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .frame(maxHeight: .infinity)
        }
    }
}
