//
//  SettingsShortcutsView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/8/25.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsShortcutsView: View {

    let allCommands: [(title: LocalizedStringKey, shortcuts: [KeyboardShortcuts.Name])] = [
        ("File", .allFileCommands),
        ("Edit", .allEditCommands),
        ("View", .allViewCommands),
        ("History", .allHistoryCommands)
    ]

    var body: some View {
        Form {
            Text("A restart may be required after changing shortcuts.")
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(allCommands, id: \.shortcuts) { title, shortcuts in
                ShorcutSection(title, shortcuts: shortcuts)
            }
        }
        .formStyle(.grouped)
    }

    @ViewBuilder
    func ShorcutSection(_ title: LocalizedStringKey, shortcuts: [KeyboardShortcuts.Name]) -> some View {
        Section(title) {
            ForEach(shortcuts, id: \.rawValue) { shortcut in
                HStack {
                    Text(shortcut.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    Spacer()
                    KeyboardShortcuts.Recorder(for: shortcut)
                }
            }
        }
    }
}

#Preview {
    SettingsShortcutsView()
}
