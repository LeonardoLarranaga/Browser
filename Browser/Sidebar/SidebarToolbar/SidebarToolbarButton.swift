//
//  SidebarToolbarButton.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/23/25.
//

import SwiftUI

/// A button that is used in the sidebar toolbar
struct SidebarToolbarButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(BrowserWindow.self) var browserWindow
    
    let systemImage: String
    let action: () -> Void
    let disabled: Bool
    
    init(_ systemImage: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.action = action
        self.disabled = disabled
    }
    
    var color: Color {
        browserWindow.currentSpace?.textColor(in: colorScheme) ?? .primary
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
        }
        .buttonStyle(.sidebarHover(enabledColor: color, disabled: disabled, disabledColor: color))
    }
}
