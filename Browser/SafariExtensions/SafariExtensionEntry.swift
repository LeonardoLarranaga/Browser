//
//  SafariExtensionEntry.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 27/9/26.
//

import WebKit

struct SafariExtensionEntry: Identifiable {
    let installation: SafariExtensionInstallation
    let appExtensionBundle: Bundle
    let webExtension: WKWebExtension
    let context: WKWebExtensionContext

    var id: String { installation.id }
    var name: String { webExtension.displayName ?? installation.displayName }
    var version: String? { webExtension.displayVersion ?? installation.displayVersion }
    var icon: NSImage? { webExtension.icon(for: CGSize(width: 32, height: 32)) }
}
