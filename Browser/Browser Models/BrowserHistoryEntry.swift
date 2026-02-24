//
//  BrowserHistoryEntry.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/15/25.
//

import SwiftData
import SwiftUI

/// An immutable model that represents a browser history entry.
@Model
final class BrowserHistoryEntry: Identifiable {
    private(set) var id: UUID
    private(set) var title: String
    private(set) var url: URL
    private(set) var favicon: Data?
    var date: Date

    @Relationship(inverse: \BrowserProfile.historyEntries) var profile: BrowserProfile?

    init(id: UUID = UUID(), title: String, url: URL, favicon: Data?, profile: BrowserProfile?) {
        self.id = id
        self.title = title
        self.url = url
        self.favicon = favicon
        self.profile = profile
        self.date = .now
    }

    static func deleteAllHistory(using modelContext: ModelContext) {
        let alert = NSAlert()
        alert.messageText = "Clear History"
        alert.informativeText = "Are you sure you want to clear your history? This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Clear").hasDestructiveAction = true

        let response = alert.runModal()

        if response == .alertSecondButtonReturn {
            do {
                try withAnimation(.browserDefault) {
                    try modelContext.delete(model: self)
                }
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }

    static var searchDescriptor: FetchDescriptor<BrowserHistoryEntry> {
        var descriptor = FetchDescriptor(sortBy: [SortDescriptor(\BrowserHistoryEntry.date, order: .reverse)])
        descriptor.fetchLimit = 100
        return descriptor
    }
}
