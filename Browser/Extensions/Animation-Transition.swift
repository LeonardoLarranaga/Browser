//
//  Animation.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/11/25.
//

import SwiftUI

extension Animation {
    /// The default animation of the browser
    /// Depends of the `disable_animations` key saved in `UserDefaults`
    /// - Returns .bouncy of nil
    static var browserDefault: Animation? {
        Preferences.shared.disableAnimations ? nil : .bouncy
    }
}

extension View {
    /// Apply a transition to the view depending of the `disable_animations` key saved in `UserDefaults`
    func browserTransition(_ transition: AnyTransition) -> some View {
        self.transition(Preferences.shared.disableAnimations ? .identity : transition)
    }
}
