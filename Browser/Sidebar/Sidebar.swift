//
//  Sidebar.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import SwiftUI

/// The main sidebar view
struct Sidebar: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Environment(SidebarModel.self) var sidebarModel
    
    @Environment(BrowserWindowState.self) var browserWindowState
    
    let browserSpaces: [BrowserSpace]
    
    var body: some View {
        VStack {
            SidebarToolbar(browserSpaces: browserSpaces)
            if Preferences.shared.urlBarPosition == .onSidebar {
                SidebarURL()
            }
            SidebarSpacesTabView(browserSpaces: browserSpaces)
            SidebarBottomToolbar(browserSpaces: browserSpaces, createSpace: createSpace)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.bottom, 10)
        .opacity(sidebarModel.currentSidebarWidth == 0 ? 0 : 1)
        .padding(.trailing, Preferences.shared.sidebarPosition == .trailing ? .sidebarPadding * 2 : 0)
        .gesture(WindowDragGesture()) // Move the browser window by dragging the sidebar
        .task {
            if browserSpaces.isEmpty {
                createSpace()
            } else if !NSApp.isKeyWindowOfTypeMain && !NSApp.isKeyWindowSettings && browserSpaces.isEmpty {
                createSpace()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
            // If the window is not the main browser window, delete the window temporary space
            if !browserWindowState.isMainBrowserWindow {
                guard NSWindow.hasPrefix("Browser", in: notification.object as? NSWindow) else { return }
                do {
                    guard let space = browserWindowState.currentSpace else { return }
                    space.tabs.forEach { modelContext.delete($0) }
                    modelContext.delete(space)
                    try modelContext.save()
                } catch {
                    print("Error deleting temporary spaces: \(error)")
                }
            }
        }
        .overlay(alignment: .bottomLeading) {
            if sidebarModel.showDownloads {
                DownloadsList()
                    .padding(.leading, .sidebarPadding)
                    .padding(.bottom, 44)
            }
        }
    }
    
    func createSpace() {
        do {
            let nextIndex = browserSpaces.firstIndex(where: { $0.id == browserWindowState.currentSpace?.id }) ?? -1 + 1
            
            var newSpace: BrowserSpace
            
            if browserWindowState.isMainBrowserWindow {
                newSpace = BrowserSpace(name: "", systemImage: "circle.fill", order: nextIndex, colors: [], colorScheme: "system")
            } else if browserWindowState.isNoTraceWindow {
                newSpace = BrowserSpace(name: "No-Trace Window", systemImage: "sunglasses.fill", order: 0, colors: [.black], colorScheme: "system")
            } else {
                newSpace = BrowserSpace(name: "Temporary Window", systemImage: "circle.fill", order: 0, colors: [], colorScheme: "system")
            }
            
            modelContext.insert(newSpace)
            try modelContext.save()
            
            // Select the new space
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                browserWindowState.goToSpace(newSpace)
            }
            
            if browserSpaces.count > 1 {
                // Update all spaces order
                for (index, space) in browserSpaces.enumerated() {
                    space.order = index
                }
                try modelContext.save()
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}
