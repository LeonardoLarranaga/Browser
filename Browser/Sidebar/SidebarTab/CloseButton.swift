//
//  CloseButton.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 26/1/26.
//

import SwiftUI

struct SidebarTabCloseButton: View {
    
    @Environment(BrowserTab.self) var browserTab
    @Environment(BrowserSpace.self) var browserSpace
    @Environment(BrowserWindow.self) var browserWindow
    
    @State var isHovering = false
    var isPinnedAndLoaded: Bool {
        browserTab.pinState == .pinned && browserTab.isLoaded
    }
    
    var body: some View {
        Button("Close Tab", systemImage: isPinnedAndLoaded ? "minus" : "xmark") {
            if isPinnedAndLoaded {
                browserSpace.unloadTab(browserTab)
            } else {
                browserSpace.closeTab(browserTab, tabUndoManager: browserWindow.tabUndoManager)
            }
        }
        .font(.title3)
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding(4)
        .background(.ultraThinMaterial.opacity(isHovering ? 0.5 : 0))
        .clipShape(.rect(cornerRadius: 6))
        .onHover { hover in
            self.isHovering = hover
        }
        .padding(.trailing, 5)
    }
}
