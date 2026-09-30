//
//  WebView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/20/25.
//

import SwiftUI

/// View that represents the webview of a tab, it can be a webview or a history view
struct WebView: View {
    
    @Environment(BrowserWindow.self) private var browserWindow
    @Environment(BrowserTab.self) private var tab
    @Environment(BrowserSpace.self) private var browserSpace

    @State private var hover = HoverState()
    
    var body: some View {
        Group {
            switch tab.contentType {
            case .web:
                WKWebViewControllerRepresentable(hover: hover)
                    .opacity(tab.webviewErrorCode != nil ? 0 : 1)
                    .webViewOverlays(hover: hover)
                    .onAppear {
                        if tab.favicon == nil {
                            tab.updateFavicon(with: tab.url)
                        }
                    }
            case .history:
                HistoryView()
                    .background(.background)
                    .opacity(browserWindow.currentSpace?.currentTab == tab ? 1 : 0)
            }
        }
    }
}
