//
//  CloseTabCommand.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 14/2/26.
//

import SwiftData
import SwiftUI

struct CloseTabCommand: UndoableCommand {
    let snapshot: ClosedTabSnapshot
    weak var space: BrowserSpace?
    let modelContext: ModelContext
    var wasCurrentTab: Bool

    var description: String {
        "Close Tab \"\(snapshot.title)\""
    }

    init(tab: BrowserTab, space: BrowserSpace, modelContext: ModelContext) {
        self.snapshot = ClosedTabSnapshot(from: tab)
        self.space = space
        self.modelContext = modelContext
        self.wasCurrentTab = space.currentTab == tab
    }

    func execute() {
        print("Is there a space? \(space != nil)")
        guard let space,
              let tab = space.tabs.first(where: { $0.id == snapshot.id })
        else { return print("Tab not found in space when trying to close") }

        let index = space.loadedTabs.firstIndex(of: tab) ?? 0
        let newTab = space.loadedTabs[safe: index == 0 ? 1 : index - 1]

        space.unloadTab(tab)

        do {
            space.tabs.removeAll(where: { $0.id == tab.id })
            modelContext.delete(tab)
            try modelContext.save()
        } catch {
            print("Error deleting tab: \(error)")
        }

        withAnimation(.browserDefault) {
            space.currentTab = newTab
        }
    }

    func undo() {
        guard let space else { return }

        let restoredTab = snapshot.createTab(in: space)

        do {
            // Insert at the original index if possible, otherwise append
            let insertIndex = min(snapshot.order, space.tabs.count)
            space.tabs.insert(restoredTab, at: insertIndex)
            try modelContext.save()
            if wasCurrentTab {
                withAnimation(.browserDefault) {
                    space.currentTab = restoredTab
                }
            }
        } catch {
            print("Error restoring tab: \(error)")
        }
    }
}
