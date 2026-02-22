//
//  SidebarTabContextMenu.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/1/25.
//

import SwiftUI

/// Context menu for a tab in the sidebar
struct SidebarTabContextMenu: View {

    @Environment(BrowserTab.self) var browserTab
    @Environment(BrowserSpace.self) var browserSpace
    @Environment(BrowserWindow.self) var browserWindow

    @Binding var isEditingTitle: Bool

    var canCloseTabsAbove: Bool {
        guard browserTab.pinState == .normal else { return false }

        let normalTabs = browserSpace.normalTabs
        if normalTabs.count > 1,
           let index = normalTabs.firstIndex(where: { $0.id == browserTab.id }) {
            return index > 0
        }
        return false
    }

    var canCloseTabsBelow: Bool {
        guard browserTab.pinState == .normal else { return false }

        let normalTabs = browserSpace.normalTabs
        if normalTabs.count > 1,
           let index = normalTabs.firstIndex(where: { $0.id == browserTab.id }) {
            return index < normalTabs.count - 1
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
            browserSpace.pinTab(browserTab)
        }
    }

    func unpinTab() {
        withAnimation(.browserDefault) {
            browserSpace.unpinTab(browserTab)
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
        browserSpace.closeTab(browserTab, tabUndoManager: browserWindow.tabUndoManager)
    }

    /// Close (delete) the tabs below the current tab
    func closeTabsBelow() {
        let normalTabs = browserSpace.normalTabs
        guard let index = normalTabs.firstIndex(where: { $0.id == browserTab.id })
        else { return }

        // Collect tabs to delete first to avoid SwiftData invalidation issues
        let tabsToDelete = Array(normalTabs.suffix(from: index + 1))

        let command = CloseMultipleTabsCommand(
            tabs: tabsToDelete,
            space: browserSpace,
            commandType: .closeTabsBelow
        )
        browserWindow.tabUndoManager.execute(command)
    }

    /// Close (delete) the tabs above the current tab
    func closeTabsAbove() {
        let normalTabs = browserSpace.normalTabs
        guard let index = normalTabs.firstIndex(where: { $0.id == browserTab.id })
        else { return }

        // Collect tabs to delete first to avoid SwiftData invalidation issues
        let tabsToDelete = Array(normalTabs.prefix(upTo: index))

        let command = CloseMultipleTabsCommand(
            tabs: tabsToDelete,
            space: browserSpace,
            commandType: .closeTabsAbove
        )

        browserWindow.tabUndoManager.execute(command)
    }
}
