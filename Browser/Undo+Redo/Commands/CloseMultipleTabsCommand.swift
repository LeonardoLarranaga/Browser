//
//  CloseMultipleTabsCommand.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 14/2/26.
//

import SwiftUI
import SwiftData

struct CloseMultipleTabsCommand: UndoableCommand {

    enum CommandType {
        case closeTabsAbove, closeTabsBelow, clear

        func description(tabCount: Int) -> String {
            switch self {
            case .closeTabsAbove: "Close \(tabCount) Tabs Above"
            case .closeTabsBelow: "Close \(tabCount) Tabs Below"
            case .clear: "Clear Space With \(tabCount) Tabs"
            }
        }
    }

    let snapshots: [ClosedTabSnapshot]
    weak var space: BrowserSpace?
    let modelContext: ModelContext
    let currentTabId: UUID?
    let commandType: CommandType

    var description: String {
        commandType.description(tabCount: snapshots.count)
    }

    init(tabs: [BrowserTab], space: BrowserSpace, modelContext: ModelContext, commandType: CommandType) {
        self.snapshots = tabs.map { ClosedTabSnapshot(from: $0) }
        self.space = space
        self.modelContext = modelContext
        self.currentTabId = space.currentTab?.id
        self.commandType = commandType
    }

    func execute() {
        guard let space else { return }
        let tabIds = snapshots.map { $0.id }

        // Check if current tab is being deleted
        let isDeletingCurrentTab = space.currentTab.map { tabIds.contains($0.id) } ?? false

        // Select a new tab before deleting if current tab is being deleted
        if isDeletingCurrentTab {
            let newTab = space.tabs.first(where: { !tabIds.contains($0.id) })
            space.currentTab = newTab
        }

        withAnimation(.browserDefault) {
            for tabId in tabIds {
                if let tab = space.tabs.first(where: { $0.id == tabId }) {
                    space.unloadTab(tab)
                    modelContext.delete(tab)
                }
            }
            try? modelContext.save()
        }
    }

    func undo() {
        guard let space else { return }

        do {
            // Restore tabs in reverse order to maintain their original positions
            for snapshot in snapshots.reversed() {
                let restoredTab = snapshot.createTab(in: space)
                let insertIndex = space.tabs.firstIndex(where: { $0.id == currentTabId }) ?? space.tabs.count
                space.tabs.insert(restoredTab, at: insertIndex)
            }
            try modelContext.save()
            // Restore the current tab if it was one of the closed tabs
            if let currentTabId, let restoredCurrentTab = space.tabs.first(where: { $0.id == currentTabId }) {
                withAnimation(.browserDefault) {
                    space.currentTab = restoredCurrentTab
                }
            }
        } catch {
            print("Error undoing close multiple tabs command: \(error)")
        }
    }
}
