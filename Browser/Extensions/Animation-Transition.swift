//
//  Animation.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/11/25.
//

import SwiftUI

extension Animation {
    /// The default animation of the browser
    /// Depends of the `disable_animations` key saved in Preferences
    /// - Returns .bouncy of nil
    static var browserDefault: Animation? {
        Preferences.disableAnimations ? nil : .bouncy
    }

    static var browserSnappy: Animation? {
        Preferences.disableAnimations ? nil : .snappy(duration: 0.2, extraBounce: 0.05)
    }
}

extension View {
    /// Apply a transition to the view depending of the `disable_animations` key saved in Preferences
    func browserTransition(_ transition: AnyTransition) -> some View {
        self.transition(Preferences.disableAnimations ? .identity : transition)
    }
}
