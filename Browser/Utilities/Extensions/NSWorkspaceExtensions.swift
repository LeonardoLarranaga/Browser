//
//  NSWorkspaceExtensions.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/9/25.
//

import Foundation

extension NSWorkspace {
    var urlForDefaultBrowser: URL? {
        guard let schemeURL = URL(string: "https:"),
              let defaultBrowserURL = urlForApplication(toOpen: schemeURL) else {
            return nil
        }
        return defaultBrowserURL
    }
}
