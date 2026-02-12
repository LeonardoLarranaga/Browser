//
//  ContextMenuType.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/12/25.
//

import Foundation

/// Possible context menu types inside a WKWebView
enum ContextMenuType: String {
    case frame = "WKMenuItemIdentifierReload"
    case text = "WKMenuItemIdentifierTranslate"
    case link = "WKMenuItemIdentifierOpenLink"
    case image = "WKMenuItemIdentifierCopyImage"
    case media = "WKMenuItemIdentifierShowHideMediaControls"
    case input = "WKMenuItemIdentifierSpellingMenu"
    case unknown = "unknown"
}
