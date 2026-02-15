//
//  SidebarTabNewButton.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI

/// Button to open the search bar for a new tab
struct SidebarTabNewButton: View {

    @Environment(\.modelContext) var modelContext

    @Environment(BrowserSpace.self) var browserSpace
    @Environment(BrowserWindow.self) var browserWindow

    @State var isHovering = false

    var body: some View {
        Label("New Tab", systemImage: "plus")
            .buttonStyle(.plain)
            .padding(.leading, .sidebarPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 30)
            .padding(3)
            .contentShape(.rect)
            .background(isHovering ? .white.opacity(0.1) : .clear)
            .clipShape(.rect(cornerRadius: 10))
            .padding(.leading, .sidebarPadding)
            .onHover { isHover in
                self.isHovering = isHover
            }
            .onTapGesture(perform: openNewTabSearch)
    }

    func openNewTabSearch() {
        browserWindow.searchOpenLocation = .fromNewTab
    }
}
