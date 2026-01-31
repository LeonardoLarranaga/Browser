//
//  BrowserActiveWindowKey.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/8/25.
//

import SwiftUI

/// Key to store the active window state
struct BrowserActiveWindowKey: FocusedValueKey {
    typealias Value = BrowserWindow
}

struct SidebarModelActiveWindowKey: FocusedValueKey {
    typealias Value = SidebarModel
}

extension FocusedValues {
    var browserActiveWindowState: BrowserWindow? {
        get { self[BrowserActiveWindowKey.self] }
        set { self[BrowserActiveWindowKey.self] = newValue }
    }
    
    var sidebarModel: SidebarModel? {
        get { self[SidebarModelActiveWindowKey.self] }
        set { self[SidebarModelActiveWindowKey.self] = newValue }
    }
}
