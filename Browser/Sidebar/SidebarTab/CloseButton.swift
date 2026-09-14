//
//  CloseButton.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 26/1/26.
//

import SwiftUI

struct SidebarTabCloseButton: View {
    
    @Environment(BrowserTab.self) private var browserTab
    @Environment(BrowserSpace.self) private var browserSpace
    @Environment(BrowserWindow.self) private var browserWindow

    @State private var isHovering = false
    private var isPinnedAndLoaded: Bool {
        browserTab.pinState == .pinned && browserTab.isLoaded
    }
    
    var body: some View {
        Button {
            if isPinnedAndLoaded {
                browserSpace.unloadTab(browserTab)
            } else {
                browserSpace.closeTab(browserTab, tabUndoManager: browserWindow.tabUndoManager)
            }
        } label: {
            Image(systemName: isPinnedAndLoaded ? "minus" : "xmark")
                .contentTransition(.symbolEffect(.replace.downUp))
                .frame(width: 20, height: 20)
                .contentShape(.rect)
        }
        .font(.body)
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .foregroundStyle(.primary)
        .background(.primary.opacity(isHovering ? 0.12 : 0))
        .clipShape(.rect(cornerRadius: 6))
        .onHover { hover in
            self.isHovering = hover
        }
        .animation(.snappy(duration: 0.22), value: isPinnedAndLoaded)
    }
}
