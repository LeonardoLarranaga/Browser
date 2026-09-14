//
//  SidebarTabNewButton.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI

/// Button to open the search bar for a new tab
struct SidebarTabNewButton: View {
    
    @Environment(\.modelContext) private var modelContext

    @Environment(BrowserSpace.self) private var browserSpace
    @Environment(BrowserWindow.self) private var browserWindow

    @State private var isHovering = false
    
    var body: some View {
        Label("New Tab", systemImage: "plus")
            .buttonStyle(.plain)
            .padding(.leading, .sidebarPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 34)
            .padding(3)
            .contentShape(.rect)
            .background(isHovering ? Color.primary.opacity(0.08) : Color.clear)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.leading, .sidebarPadding)
            .onHover { isHover in
                self.isHovering = isHover
            }
            .onTapGesture(perform: openNewTabSearch)
    }
    
    private func openNewTabSearch() {
        browserWindow.searchOpenLocation = .fromNewTab
    }
}
