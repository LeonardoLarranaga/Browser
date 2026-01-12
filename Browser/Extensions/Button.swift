//
//  Button.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/8/25.
//

import SwiftUI

extension Button where Label == Text {
    /// Extension to create a button with an optional action
    /// This is used for the menu bar commands
    init(_ titleKey: LocalizedStringKey, action: (@MainActor () -> Void)?) {
        self.init(titleKey) {
            action?()
        }
    }
}
