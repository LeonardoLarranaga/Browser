//
//  WebView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/20/25.
//

import SwiftUI

/// View that represents the webview of a tab, it can be a webview or a history view
struct WebView: View {

    @Environment(BrowserWindow.self) var browserWindow
    @Environment(BrowserTab.self) var tab
    @Environment(BrowserSpace.self) var browserSpace

    @State var hover = HoverState()

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
        .overlay(alignment: .top) {
            if Preferences.loadingIndicatorPosition == .onWebView && browserWindow.currentSpace?.currentTab == tab {
                if tab.isLoading {
                    ProgressView(value: tab.estimatedProgress)
                        .progressViewStyle(.linear)
                        .frame(height: 3)
                        .tint(browserWindow.currentSpace?.getColors.first ?? .primary)
                }
            }
        }
    }
}
