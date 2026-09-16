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
            let passwordAppItem = NSMenuItem(title: "Open Passwords App", action: #selector(openPasswordsApp), keyEquivalent: "")
            passwordAppItem.image = NSImage(systemSymbolName: "key.fill", accessibilityDescription: nil)
            passwordAppItem.target = self
            menu.addItem(passwordAppItem)
        }

        menu.addItem(.separator())
        menu.addItem(makeAutoFillMenuItem())
    }

    private func makeAutoFillMenuItem() -> NSMenuItem {
        let autoFillMenu = NSMenu(title: "AutoFill")
        autoFillMenu.autoenablesItems = false
        autoFillMenu.addItem(makeAutoFillItem(
            title: "Contact…",
            systemImage: "person.crop.circle",
            action: WebPageAutoFillAction.contacts
        ))
        autoFillMenu.addItem(makeAutoFillItem(
            title: "Passwords…",
            systemImage: "key.dots",
            action: WebPageAutoFillAction.passwords
        ))
        autoFillMenu.addItem(makeAutoFillItem(
            title: "Credit Card…",
            systemImage: "creditcard",
            action: WebPageAutoFillAction.creditCards
        ))

        let autoFillItem = NSMenuItem(title: "AutoFill", action: nil, keyEquivalent: "")
        autoFillItem.image = NSImage(
            systemSymbolName: "rectangle.and.pencil.and.ellipsis",
            accessibilityDescription: nil
        )
        autoFillItem.submenu = autoFillMenu
        return autoFillItem
    }

    private func makeAutoFillItem(title: String, systemImage: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.image = NSImage(systemSymbolName: systemImage, accessibilityDescription: nil)
        item.target = self
        item.isEnabled = true
        return item
    }
    
    @objc private func openPasswordsApp() {
        if let passwordAppURL = Preferences.selectedPasswordApp {
            NSWorkspace.shared.open(passwordAppURL)
        }
    }
}
