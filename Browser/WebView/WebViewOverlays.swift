//
//  WebViewOverlays.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 30/1/26.
//

import SwiftUI

struct WebViewOverlays: ViewModifier {

    @Environment(BrowserTab.self) var tab

    @Bindable var hover: HoverState

    func body(content: Content) -> some View {
        content
            .overlay {
                if tab.webviewErrorDescription != nil, let errorCode = tab.webviewErrorCode, errorCode != -999 {
                    MyWKWebViewErrorView()
                }
            }
            .overlay(alignment: .bottomLeading) {
                if hover.show {
                    Text(hover.url)
                        .lineLimit(1)
                        .font(.caption)
                        .padding(5)
                        .glassEffect()
                        .padding(5)
                }
            }
            .overlay(alignment: .topTrailing) {
                FindInPageView()
                    .padding()
                    .opacity(tab.showFindUI ? 1 : 0)
                    .offset(y: tab.showFindUI ? 0 : -50)
                    .allowsHitTesting(tab.showFindUI)
                    .animation(.snappy(duration: 0.2), value: tab.showFindUI)
            }
    }
}

extension View {
    /// Adds overlays to the web view, such as errors, find bar, etc...
    func webViewOverlays(hover: HoverState) -> some View {
        self.modifier(WebViewOverlays(hover: hover))
    }
}
