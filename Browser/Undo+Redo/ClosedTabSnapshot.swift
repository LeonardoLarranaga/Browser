//
//  ClosedTabSnapshot.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 14/2/26.
//

import Foundation

/// A snapshot of a closed tab, used for undo/redo operations
struct ClosedTabSnapshot {
    let id: UUID
    let title: String
    let favicon: Data?
    let url: URL
    let order: Int
    let pinState: TabPinState
    let contentType: TabContentType
    let customTitle: String?
    let spaceId: UUID

    init(from tab: BrowserTab) {
        self.id = tab.id
        self.title = tab.title
        self.favicon = tab.favicon
        self.url = tab.url
        self.order = tab.order
        self.pinState = tab.pinState
        self.contentType = tab.contentType
        self.customTitle = tab.customTitle
        self.spaceId = tab.spaceId
    }

    func createTab(in space: BrowserSpace) -> BrowserTab {
        assert(spaceId == space.id, "The space ID of the snapshot does not match the provided space")
        let tab = BrowserTab(
            title: title,
            favicon: favicon,
            url: url,
            order: order,
            browserSpace: space,
            contentType: contentType,
            restoredId: id
        )
        tab.pinState = pinState
        tab.customTitle = customTitle
        return tab
    }
}
