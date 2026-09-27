//
//  SafariExtensionPopoverAnchor.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 9/27/26.
//

import SwiftUI

struct SafariExtensionPopoverAnchor: NSViewRepresentable {
    @Bindable var manager: SafariExtensions

    func makeNSView(context: Context) -> NSView {
        let view = SafariExtensionPopoverAnchorView()
        view.manager = manager
        manager.setPopupAnchorView(view)
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        (view as? SafariExtensionPopoverAnchorView)?.manager = manager
        manager.setPopupAnchorView(view)
    }
}

private final class SafariExtensionPopoverAnchorView: NSView {
    weak var manager: SafariExtensions?

    override var isFlipped: Bool { true }

    override func layout() {
        super.layout()
        if window != nil { manager?.setPopupAnchorView(self) }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            manager?.setPopupAnchorView(self)
        }
    }
}
