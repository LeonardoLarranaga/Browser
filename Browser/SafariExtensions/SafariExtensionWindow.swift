//
//  SafariExtensionWindow.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 9/27/26.
//

import WebKit

@MainActor
final class SafariExtensionWindow: NSObject, WKWebExtensionWindow {
    weak var manager: SafariExtensions?
    weak var browserWindow: BrowserWindow?
    weak var browserSpace: BrowserSpace?
    weak var nativeWindow: NSWindow?
    var isPrivateWindow = false

    init(
        manager: SafariExtensions,
        browserWindow: BrowserWindow,
        browserSpace: BrowserSpace,
        nativeWindow: NSWindow?,
        isPrivate: Bool
    ) {
        self.manager = manager
        self.browserWindow = browserWindow
        self.browserSpace = browserSpace
        self.nativeWindow = nativeWindow
        self.isPrivateWindow = isPrivate
        super.init()
    }

    func tabs(for context: WKWebExtensionContext) -> [any WKWebExtensionTab] {
        guard let manager, let browserSpace else { return [] }
        return browserSpace.tabs
            .filter { $0.contentType == .web }
            .map { manager.extensionTab(for: $0, webView: $0.webview, windowAdapter: self) }
    }

    func activeTab(for context: WKWebExtensionContext) -> (any WKWebExtensionTab)? {
        guard let manager, let browserSpace,
              let tab = browserSpace.currentTab,
              tab.contentType == .web else { return nil }
        return manager.extensionTab(for: tab, webView: tab.webview, windowAdapter: self)
    }

    func windowType(for context: WKWebExtensionContext) -> WKWebExtension.WindowType {
        .normal
    }

    func isPrivate(for context: WKWebExtensionContext) -> Bool {
        isPrivateWindow
    }

    func screenFrame(for context: WKWebExtensionContext) -> CGRect {
        nativeWindow?.screen?.frame ?? .zero
    }

    func frame(for context: WKWebExtensionContext) -> CGRect {
        nativeWindow?.frame ?? .zero
    }

    func focus(for context: WKWebExtensionContext, completionHandler: @escaping ((any Error)?) -> Void) {
        nativeWindow?.makeKeyAndOrderFront(nil)
        completionHandler(nil)
    }

    func close(for context: WKWebExtensionContext, completionHandler: @escaping ((any Error)?) -> Void) {
        nativeWindow?.close()
        completionHandler(nil)
    }
}
