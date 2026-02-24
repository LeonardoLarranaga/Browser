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
    @Environment(BrowserSpace.self) var browserSpace
    @Environment(BrowserTab.self) var tab
    @Environment(SidebarModel.self) var sidebarModel

    @Bindable var hover: HoverState

    var noTrace: Bool { browserWindow.isNoTraceWindow }

    func makeNSViewController(context: Context) -> WKWebViewController {
        let wkWebViewController = WKWebViewController(
            tab: tab,
            browserSpace: browserSpace,
            noTrace: noTrace
        )
        wkWebViewController.coordinator = context.coordinator
        return wkWebViewController
    }

    func updateNSViewController(_ nsViewController: WKWebViewController, context: Context) {
        nsViewController.webView.isHidden = tab != browserSpace.currentTab
        || tab.webviewErrorDescription != nil
        || tab.webviewErrorCode != nil
    }

    static func dismantleNSViewController(_ nsViewController: WKWebViewController, coordinator: Coordinator) {
        print("Dismantling WKWebViewController for tab: \(nsViewController.tab.title)")
        nsViewController.cleanup()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
