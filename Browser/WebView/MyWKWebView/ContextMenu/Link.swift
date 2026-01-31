//
//  ContextMenuLink.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/20/25.
//

import WebKit

extension MyWKWebView {
    /// Creates the custom context menu for links
    /// - Parameter menu: The context menu to modify
    func handleLinkContextMenu(_ menu: NSMenu) {
        let openInWindowItem = menu.items.first { $0.title.contains("Window") }
        if let openInWindowItem, let copy = openInWindowItem.copy() as? NSMenuItem {
            copy.title = "Open Link in New Tab"
            menu.insertItem(copy, at: 1)
            menu.removeItem(openInWindowItem)
        }
    }
}
