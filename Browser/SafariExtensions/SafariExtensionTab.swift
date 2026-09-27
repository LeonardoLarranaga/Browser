//
//  SafariExtensionTab.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 9/27/26.
//

import WebKit

@MainActor
final class SafariExtensionTab: NSObject, WKWebExtensionTab {
    weak var browserTab: BrowserTab?
    weak var webView: WKWebView?
    weak var windowAdapter: SafariExtensionWindow?
    var selected = false

    init(browserTab: BrowserTab, webView: WKWebView?, windowAdapter: SafariExtensionWindow?) {
        self.browserTab = browserTab
        self.webView = webView
        self.windowAdapter = windowAdapter
        super.init()
    }

    func window(for context: WKWebExtensionContext) -> (any WKWebExtensionWindow)? {
        windowAdapter
    }

    func webView(for context: WKWebExtensionContext) -> WKWebView? {
        webView
    }

    func url(for context: WKWebExtensionContext) -> URL? {
        webView?.url ?? browserTab?.url
    }

    func title(for context: WKWebExtensionContext) -> String? {
        webView?.title ?? browserTab?.displayTitle
    }

    func isLoadingComplete(for context: WKWebExtensionContext) -> Bool {
        webView?.isLoading == false
    }

    func isSelected(for context: WKWebExtensionContext) -> Bool {
        selected
    }

    func shouldGrantPermissionsOnUserGesture(for context: WKWebExtensionContext) -> Bool {
        true
    }
}
