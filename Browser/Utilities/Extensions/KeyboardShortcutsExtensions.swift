//
//  KeyboardShortcutsExtensions.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 2/10/26.
//

import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
    init(localized: LocalizedStringResource, default defaultShortcut: Shortcut? = nil) {
        var name = localized
        name.locale = Locale(languageCode: .english)
        self.init(String(localized: name), default: defaultShortcut)
    }
}
