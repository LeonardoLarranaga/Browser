//
//  WKWebViewControllerRepresentable.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/2/25.
//

import SwiftUI

/// WKWebViewController wrapper for SwiftUI
struct WKWebViewControllerRepresentable: NSViewControllerRepresentable {
    
    @Environment(\.modelContext) var modelContext
    
    @Environment(BrowserWindow.self) var browserWindow
    @Environment(SidebarModel.self) var sidebarModel
        
    @Bindable var browserSpace: BrowserSpace
    @Bindable var tab: BrowserTab
    let noTrace: Bool
    var hoverURL: Binding<String>
    
    init(tab: BrowserTab, browserSpace: BrowserSpace, noTrace: Bool = false, hoverURL: Binding<String>) {
        self.tab = tab
        self.browserSpace = browserSpace
        self.noTrace = noTrace
        self.hoverURL = hoverURL
    }
    
    func makeNSViewController(context: Context) -> WKWebViewController {
        let wkWebViewController = WKWebViewController(tab: tab, browserSpace: browserSpace, noTrace: noTrace, using: modelContext)
        wkWebViewController.coordinator = context.coordinator
        return wkWebViewController
    }
    
    func updateNSViewController(_ nsViewController: WKWebViewController, context: Context) {
        nsViewController.webView.isHidden = tab != browserSpace.currentTab
                                            || tab.webviewErrorDescription != nil
                                            || tab.webviewErrorCode != nil
        nsViewController.webView.findBarView?.isHidden = nsViewController.webView.isHidden
    }

    static func dismantleNSViewController(_ nsViewController: WKWebViewController, coordinator: Coordinator) {
        print("🟡 Dismantling WKWebViewController for tab: \(nsViewController.tab.title)")
        nsViewController.cleanup()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
