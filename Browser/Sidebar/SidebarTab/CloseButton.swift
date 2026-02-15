//
//  CloseButton.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 26/1/26.
//

import SwiftUI

struct SidebarTabCloseButton: View {

    @Environment(\.modelContext) var modelContext
    @Environment(BrowserTab.self) var browserTab
    @Environment(BrowserSpace.self) var browserSpace
    @Environment(BrowserWindow.self) var browserWindow

    @State var isHovering = false

    var body: some View {
        Button("Close Tab", systemImage: "xmark") {
            browserSpace.closeTab(browserTab, using: modelContext, tabUndoManager: browserWindow.tabUndoManager)
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
