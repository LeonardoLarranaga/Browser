//
//  WebView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/23/25.
//

import SwiftUI

/// View that contains a stack for the loaded tabs in the current space
struct WebViewStack: View {
    @Bindable var browserSpace: BrowserSpace
    var body: some View {
        ZStack {
            if let currentTab = browserSpace.currentTab {
                ForEach(browserSpace.tabs.filter { browserSpace.loadedTabs.contains($0) || $0 == currentTab }) { tab in
                    WebView(tab: tab, browserSpace: browserSpace)
                    .zIndex(tab == currentTab ? 1 : 0)
                    .onAppear {
                        if !browserSpace.loadedTabs.contains(tab) {
                            browserSpace.loadedTabs.append(tab)
                        }
                    }
                }
            } else {
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
        }
        .transaction { $0.animation = nil }
    }
}
