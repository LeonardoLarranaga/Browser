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
    
    private var noTrace: Bool { browserWindow.isNoTraceWindow }
    
    func makeNSViewController(context: Context) -> WKWebViewController {
        let wkWebViewController = WKWebViewController(
            tab: tab,
            browserSpace: browserSpace,
            browserWindow: browserWindow,
            noTrace: noTrace
        )
        wkWebViewController.coordinator = context.coordinator
        return wkWebViewController
    }
    
    func updateNSViewController(_ nsViewController: WKWebViewController, context: Context) {
        let isSelected = tab == browserSpace.currentTab
        nsViewController.webView.isHidden = !isSelected
        || tab.webviewErrorDescription != nil
        || tab.webviewErrorCode != nil
        SafariExtensions.shared.setSelected(
            isSelected,
            for: tab,
            webView: nsViewController.webView,
            browserWindow: browserWindow,
            browserSpace: browserSpace
        )
    }
    
    static func dismantleNSViewController(_ nsViewController: WKWebViewController, coordinator: Coordinator) {
        print("Dismantling WKWebViewController for tab: \(nsViewController.tab.title)")
        nsViewController.cleanup()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
