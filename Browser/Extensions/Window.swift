//
//  Window.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/7/25.
//

import AppKit

extension NSApplication {
    func setBrowserWindowControls(hidden: Bool) {
        for window in windows where window.identifier?.rawValue.contains("BrowserWindow") == true {
            window.standardWindowButton(.closeButton)?.isHidden = hidden
            window.standardWindowButton(.miniaturizeButton)?.isHidden = hidden
            window.standardWindowButton(.zoomButton)?.isHidden = hidden
        }
    }
}
