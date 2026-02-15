//
//  ContextMenuInput.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 11/2/26.
//

extension MyWKWebView {
    func handleInputContextMenu(_ menu: NSMenu) {
        // Cut (0)
        // Copy (1)
        // Paste (2)
        if Preferences.injectOpenPasswordsApp {
            menu.insertItem(.separator(), at: 3)

            let passwordAppItem = NSMenuItem(title: "Open Passwords App", action: #selector(openPasswordsApp), keyEquivalent: "")
            passwordAppItem.image = NSImage(systemSymbolName: "key.fill", accessibilityDescription: nil)
            menu.insertItem(passwordAppItem, at: 4)
        }
    }

    @objc func openPasswordsApp() {
        if let passwordAppURL = Preferences.selectedPasswordApp {
            NSWorkspace.shared.open(passwordAppURL)
        }
    }
}
