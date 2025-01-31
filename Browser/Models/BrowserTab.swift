//
//  BrowserTab.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/28/25.
//

import SwiftData
import WebKit

@Model
final class BrowserTab: Identifiable {
    
    @Attribute(.unique) var id: UUID
    var title: String
    var favicon: Data?
    var url: URL
    
    @Transient var webview: WKWebView? = nil
    
    init(title: String, favicon: Data?, url: URL) {
        self.id = UUID()
        self.title = title
        self.favicon = favicon
        self.url = url
    }
}
