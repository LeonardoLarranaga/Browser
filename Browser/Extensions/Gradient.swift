//
//  Gradient.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/11/25.
//

import SwiftUI

extension AngularGradient {
    /// Your typical angular rainbow gradient
    static let colorfulAngularGradient = AngularGradient(colors: stride(from: 1.0, to: -0.1, by: -0.1).map {
            Color(hue: $0, saturation: 1, brightness: 0.9)
        }, center: .center)
}
