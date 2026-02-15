//
//  GlassEffectView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/25/25.
//  https://cindori.com/developer/floating-panel
//

import SwiftUI

struct GlassEffectView: NSViewRepresentable {

    let style: NSGlassEffectView.Style
    let tintColor: Color?

    init(style: NSGlassEffectView.Style = .regular, tintColor: Color? = nil) {
        self.style = style
        self.tintColor = tintColor
    }

    func makeNSView(context: Context) -> NSGlassEffectView {
        NSGlassEffectView()
    }

    func updateNSView(_ nsView: NSGlassEffectView, context: Context) {
        nsView.style = style
        nsView.cornerRadius = 0
        if let tintColor {
            nsView.tintColor = NSColor(tintColor)
        }
    }
}
