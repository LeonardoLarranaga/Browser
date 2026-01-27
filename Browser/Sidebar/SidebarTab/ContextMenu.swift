//
//  SidebarTabContextMenu.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/1/25.
//

import SwiftUI

/// Context menu for a tab in the sidebar
struct SidebarTabContextMenu: View {

    @Environment(\.modelContext) var modelContext
    @Environment(BrowserTab.self) var browserTab
    @Environment(BrowserSpace.self) var browserSpace

    @Binding var isEditingTitle: Bool

    var canCloseTabsAbove: Bool {
        if browserSpace.tabs.count > 1 {
            return browserTab.order > 0
        }
        return false
    }

    var canCloseTabsBelow: Bool {
        let tabCount = browserSpace.tabs.count
        if tabCount > 1 {
            return browserTab.order < tabCount - 1
        }
        return false
    }

    var body: some View {
        Group {
            Button("Copy Link", action: browserTab.copyLink)
            Button("Reload Tab", action: browserTab.reload)

            Divider()

            Button("Rename Tab", action: startEditingTitle)
            ShareLink("Share...", item: browserTab.url)
                .labelStyle(.titleOnly)

            Divider()

            if browserTab.pinState != .pinned {
                Button("Pin Tab", action: pinTab)
            } else {
                Button("Unpin Tab", action: unpinTab)
            }

            Button("Duplicate Tab", action: duplicateTab)

            Divider()

            Button("Close Tab", action: closeTab)

            if canCloseTabsBelow {
                Button("Close Tabs Below", action: closeTabsBelow)
            }

            if canCloseTabsAbove {
                Button("Close Tabs Above", action: closeTabsAbove)
            }
        }
    }

    func startEditingTitle() {
        isEditingTitle = true
    }

    func pinTab() {
        withAnimation(.browserDefault) {
            browserSpace.pinTab(browserTab, using: modelContext)
        }
    }

    func unpinTab() {
        withAnimation(.browserDefault) {
            browserSpace.unpinTab(browserTab, using: modelContext)
        }
    }

    /// Duplicate the tab and selects the new tab
    func duplicateTab() {
        let duplicateTab = BrowserTab(
            title: browserTab.title,
            favicon: browserTab.favicon,
            url: browserTab.url,
            order: browserTab.order + 1,
            browserSpace: browserSpace
        )

        browserSpace.tabs.insert(duplicateTab, at: duplicateTab.order)
        browserSpace.currentTab = duplicateTab
    }

    /// Close (delete) the tab and selects the next tab
    func closeTab() {
        browserSpace.closeTab(browserTab, using: modelContext)
    }

    /// Close (delete) the tabs below the current tab
    func closeTabsBelow() {
        guard let index = browserSpace.tabs.firstIndex(where: { $0.id == browserTab.id })
        else { return }

        withAnimation(.browserDefault) {
            for tab in browserSpace.tabs.suffix(from: index + 1) {
                browserSpace.unloadTab(tab)
                modelContext.delete(tab)
            }
            try? modelContext.save()
        }
    }

    /// Close (delete) the tabs above the current tab
    func closeTabsAbove() {
        guard let index = browserSpace.tabs.firstIndex(where: { $0.id == browserTab.id })
        else { return }

        withAnimation(.browserDefault) {
            for tab in browserSpace.tabs.prefix(upTo: index) {
                browserSpace.unloadTab(tab)
                modelContext.delete(tab)
            }
            try? modelContext.save()
        }
    }
}
