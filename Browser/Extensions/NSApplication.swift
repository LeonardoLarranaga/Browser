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

    func closeAllWindows() {
        windows.forEach { $0.close() }
    }

    var isKeyWindowOfTypeMain: Bool {
        keyWindow?.identifier?.rawValue.hasPrefix("BrowserWindow") == true
    }

    var isKeyWindowSettings: Bool {
        keyWindow?.identifier?.rawValue == "com_apple_SwiftUI_Settings_window"
    }

    func selectAllText() {
        DispatchQueue.main.async {
            self.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: nil)
        }
    }
}
