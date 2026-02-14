//
//  HistoryEntryRowContextMenu.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/1/25.
//

import SwiftUI

/// Context menu for a history entry row. Contains actions to open the history entry in a new tab, in a new window, or to delete it.
fileprivate struct HistoryEntryRowContextMenu: ViewModifier {

    @Environment(\.modelContext) var modelContext
    @Environment(BrowserWindow.self) var browserWindow

    let entry: BrowserHistoryEntry
    let selectedEntries: Set<BrowserHistoryEntry>
    let browserTab: BrowserTab

    func body(content: Content) -> some View {
        content.contextMenu {
            if selectedEntries.count < 2 {
                Button("Open") {
                    browserTab.title = entry.title
                    browserTab.url = entry.url
                    browserTab.favicon = entry.favicon
                    browserTab.contentType = .web
                }

                Button("Open in New Tab") {
                    openEntryInNewTab(entry)
                }

                Divider()

                Button("Delete Entry") {
                    deleteEntry(entry)
                }
            } else {
                Button("Open \(selectedEntries.count) Entries") {
                    selectedEntries.forEach(openEntryInNewTab(_:))
                }

                Divider()

                Button("Delete \(selectedEntries.count) Entries") {
                    selectedEntries.forEach(deleteEntry(_:))
                }
            }
        }
        .simultaneousGesture(
            TapGesture(count: 2).onEnded {
                if selectedEntries.count < 2 {
                    openEntryInNewTab(entry)
                } else {
                    selectedEntries.forEach(openEntryInNewTab(_:))
                }
            }
        )
    }

    func openEntryInNewTab(_ entry: BrowserHistoryEntry) {
        if let currentSpace = browserWindow.currentSpace {
            let browserTab = BrowserTab(
                title: entry.title,
                favicon: entry.favicon,
                url: entry.url,
                order: currentSpace.tabs.count,
                browserSpace: currentSpace,
                contentType: .web
            )
            currentSpace.openNewTab(browserTab, using: modelContext)
        }
    }

    func deleteEntry(_ entry: BrowserHistoryEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }
}

extension View {
    func historyEntryRowContextMenu(
        entry: BrowserHistoryEntry,
        selectedEntries: Set<BrowserHistoryEntry>,
        browserTab: BrowserTab
    ) -> some View {
        self.modifier(HistoryEntryRowContextMenu(entry: entry, selectedEntries: selectedEntries, browserTab: browserTab))
    }
}
