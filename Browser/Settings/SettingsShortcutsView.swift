//
//  SettingsShortcutsView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/8/25.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsShortcutsView: View {
    
    var allCommands: [[KeyboardShortcuts.Name]] {
        [.allFileCommands, .allEditCommands, .allViewCommands, .allHistoryCommands, .allViewCommands]
    }
    
    var body: some View {
        Form {
            Text("A restart may be required after changing shortcuts.")
                .font(.caption)
                .foregroundColor(.gray)
            
            ForEach(allCommands, id: \.self) { shortcuts in
                ShorcutSection(shortcuts)
            }   
        }
        .formStyle(.grouped)
    }
    
    @ViewBuilder
    func ShorcutSection(_ shortcuts: [KeyboardShortcuts.Name]) -> some View {
        Section {
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
