//
//  SettingsView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                GeneralSettingsView()
            }
            
            Tab("Appearance", systemImage: "paintpalette") {
                SettingsAppearanceView()
            }
            
            Tab("Keyboard Shortcuts", systemImage: "command") {
                SettingsShortcutsView()
            }

            if Preferences.shared.shouldShowFeatureFlagSettings {
                Tab("Feature Flags", systemImage: "flag.2.crossed.fill") {
                    SettingsFeatureFlagsView()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
