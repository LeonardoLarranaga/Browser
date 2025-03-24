//
//  WebView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/20/25.
//

import SwiftUI

/// View that represents the webview of a tab, it can be a webview or a history view
struct WebView: View {
    
    @Environment(BrowserWindowState.self) var browserWindowState
    @EnvironmentObject var userPreferences: UserPreferences
    
    @Bindable var tab: BrowserTab
    @Bindable var browserSpace: BrowserSpace
    
    @State var hoverURL = ""
    @State var showHoverURL = false
    @State var hoverURLTimer: Timer?
    
    var body: some View {
        Group {
            switch tab.type {
            case .web:
                WKWebViewControllerRepresentable(tab: tab, browserSpace: browserSpace, noTrace: browserWindowState.isNoTraceWindow, hoverURL: $hoverURL)
                    .opacity(tab.webviewErrorCode != nil ? 0 : 1)
                    .overlay {
                        if tab.webviewErrorDescription != nil, let errorCode = tab.webviewErrorCode, errorCode != -999 {
                            MyWKWebViewErrorView(tab: tab)
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        if showHoverURL {
                            Text(hoverURL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(5)
                                .background(.ultraThinMaterial)
                                .clipShape(.rect(cornerRadius: 6))
                                .padding(5)
                        }
                    }
                    .onAppear {
                        if tab.favicon == nil {
                            tab.updateFavicon(with: tab.url)
                        }
                    }
                    .onChange(of: hoverURL) {
                        guard !hoverURL.isEmpty else { return }
                        hoverURLTimer?.invalidate()
                        
                        withAnimation(.browserDefault) {
                            showHoverURL = true
                        }
                        
                        hoverURLTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
                            withAnimation(.browserDefault) {
                                showHoverURL = false
                                hoverURL = ""
                            }
                        }
                    }
            case .history:
                HistoryView(browserTab: tab)
                    .opacity(browserWindowState.currentSpace?.currentTab == tab ? 1 : 0)
            }
        }
        .overlay(alignment: .top) {
            if userPreferences.loadingIndicatorPosition == .onWebView && browserWindowState.currentSpace?.currentTab == tab {
                if tab.isLoading {
                    ProgressView(value: tab.estimatedProgress)
                        .progressViewStyle(.linear)
                        .frame(height: 3)
                        .tint(tab.browserSpace?.getColors.first ?? .primary)
                }
            }
        }
    }
}
