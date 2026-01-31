//
//  SettingsAppearanceView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/7/25.
//

import SwiftUI

struct SettingsAppearanceView: View {
    
    var body: some View {
      @Bindable var preferences = Preferences.shared
        Form {
            Section("App") {
              Picker("Sidebar Position", systemImage: "sidebar.left", selection: $preferences.sidebarPosition) {
                Label("Leading", systemImage: "sidebar.left").tag(Preferences.SidebarPosition.leading)
                    Label("Trailing", systemImage: "sidebar.right").tag(Preferences.SidebarPosition.trailing)
                }
                
                Toggle("Disable Animations", systemImage: "figure.run", isOn: $preferences.disableAnimations)
                
                Toggle("Show Window Controls On Trailling Sidebar", systemImage: "macwindow", isOn: $preferences.showWindowControlsOnTrailingSidebar)
                
                Toggle("Reverse Background Colors on Trailing Sidebar", systemImage: "paintpalette", isOn: $preferences.reverseColorsOnTrailingSidebar)
                
                LoadingPlacePicker()
                
                Picker("URL Bar Position", systemImage: "link", selection: $preferences.urlBarPosition) {
                    Label("On Sidebar", systemImage: "sidebar.left").tag(Preferences.URLBarPosition.onSidebar)
                    Label("On Toolbar", systemImage: "menubar.rectangle").tag(Preferences.URLBarPosition.onToolbar)
                }
                
                if Preferences.shared.urlBarPosition == .onToolbar {
                    Toggle("Show Full URL on Toolbar", systemImage: "menubar.arrow.up.rectangle", isOn: $preferences.showFullURLOnToolbar)
                }
            }
            
            Section {
                Toggle("Rounded Corners", systemImage: "button.roundedtop.horizontal", isOn: $preferences.roundedCorners)
                Toggle("Enable Padding", systemImage: "inset.filled.rectangle", isOn: $preferences.enablePadding)
                Toggle("Enable Shadow", systemImage: "shadow", isOn: $preferences.enableShadow)
                Toggle("Immersive View On Full Screen", systemImage: "rectangle.fill", isOn: $preferences.immersiveViewOnFullscreen)
            } header: {
                Text("Web View")
            } footer: {
                Text("""
                Immersive View On Full Screen: Removes padding, shadow, and rounded corners when in full screen and the sidebar is collapsed.
                """)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
