//
//  SidebarSpaceContextMenu.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/1/25.
//

import SwiftUI

/// Context menu for the sidebar space and space icon
struct SidebarSpaceContextMenu: ViewModifier {
    
    @Environment(BrowserWindow.self) var browserWindow
    @Environment(\.modelContext) var modelContext
    
    let browserSpaces: [BrowserSpace]
    @Bindable var browserSpace: BrowserSpace
    
    @State var showDeleteAlert = false
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                if browserWindow.isMainBrowserWindow {
                    Button("Edit Space") {
                        withAnimation(.browserDefault) {
                            browserSpace.isEditing = true
                        }
                    }
                    
                    Divider()
                    
                    Button("Delete Space") {
                        showDeleteAlert.toggle()
                    }
                }
            }
            .alert("Delete \"\(browserSpace.name)\"", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel, action: {})
                Button("Delete", role: .destructive, action: deleteSpace)
            } message: {
                Text("This action cannot be undone. All tabs in this space will be lost.")
            }
    }
    
    /// Deletes the current space, selects a new space and scrolls to it
    func deleteSpace() {
        if browserWindow.currentSpace == browserSpace {
            guard let index = browserSpaces.firstIndex(where: { $0.id == browserSpace.id }) else { return }
            let newSpace = browserSpaces[safe: index == 0 ? 1 : index - 1]
            browserWindow.goToSpace(newSpace)
        }
        
        withAnimation(.browserDefault) {
            modelContext.delete(browserSpace)
            try? modelContext.save()
        }
    }
}

extension View {
    /// Adds a context menu to the sidebar space and space icon
    func sidebarSpaceContextMenu(browserSpaces: [BrowserSpace], browserSpace: BrowserSpace) -> some View {
        modifier(SidebarSpaceContextMenu(browserSpaces: browserSpaces, browserSpace: browserSpace))
    }
}
