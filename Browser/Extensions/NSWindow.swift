//
//  NSWindow.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/5/25.
//

import Foundation

extension NSWindow {
    static func hasPrefix(_ prefix: String, in window: NSWindow?) -> Bool {
        guard let window,
              let windowId = window.identifier?.rawValue,
              windowId.hasPrefix(prefix) else {
            return false
        }
        return true
    }

    static var mainBrowserWindows: [NSWindow] {
        NSApp.windows.filter { $0.identifier?.rawValue.hasPrefix("BrowserWindow") == true }
    }
}
