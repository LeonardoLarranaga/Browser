//
//  DeveloperFeatures.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 8/2/26.
//

import WebKit

enum DeveloperFeatures {

    static func showWebInspector(for webView: WKWebView) {
        guard let inspector = webView._inspector else { return }
        inspector.show()
    }

    static func toggleWebInspector(for webView: WKWebView) {
        guard let inspector = webView._inspector else { return }
        if inspector.isVisible {
            inspector.hide()
        } else {
            inspector.show()
        }
    }

    static func showJavaScriptConsole(for webView: WKWebView) {
        guard let inspector = webView._inspector else { return }
        if !inspector.isVisible {
            inspector.show()
        }
        inspector.showConsole()
    }

    static func showPageResources(for webView: WKWebView) {
        guard let inspector = webView._inspector else { return }
        if !inspector.isVisible {
            inspector.show()
        }
        inspector.showResources()
    }

    static func isWebInspectorVisible(for webView: WKWebView) -> Bool {
        return webView._inspector.isVisible
    }

    /// Check if the Web Inspector is connected
    static func isWebInspectorConnected(for webView: WKWebView) -> Bool {
        return webView._inspector.isConnected
    }

    static func hideWebInspector(for webView: WKWebView) {
        guard let inspector = webView._inspector else { return }
        inspector.hide()
    }

    static func closeWebInspector(for webView: WKWebView) {
        guard let inspector = webView._inspector else { return }
        inspector.close()
    }

    static func attachWebInspector(for webView: WKWebView) {
        guard let inspector = webView._inspector else { return }
        inspector.attach()
    }

    static func detachWebInspector(for webView: WKWebView) {
        guard let inspector = webView._inspector else { return }
        inspector.detach()
    }
}
