//
//  HistoryEntryRowContextMenu.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/1/25.
//

import SwiftUI

/// Context menu for a history entry row. Contains actions to open the history entry in a new tab, in a new window, or to delete it.

struct HistoryEntryRowContextMenu: ViewModifier {
    
    @Environment(\.modelContext) var modelContext
    @Environment(BrowserWindow.self) var browserWindow

    let entry: BrowserHistoryEntry
    let browserTab: BrowserTab

    func body(content: Content) -> some View {
        content.contextMenu {
            Button("Open") {
                browserTab.title = entry.title
                browserTab.url = entry.url
                browserTab.favicon = entry.favicon
                browserTab.contentType = .web
            }
            
            Button("Open in New Tab") {
                if let currentSpace = browserWindow.currentSpace {
                    currentSpace.openNewTab(BrowserTab(title: entry.title, favicon: entry.favicon, url: entry.url, order: browserTab.order + 1, browserSpace: currentSpace, contentType: .web), using: modelContext)
                }
            }

            Divider()
            
            Button("Delete Entry") {
                modelContext.delete(entry)
                try? modelContext.save()
            }
        }
    }
}
