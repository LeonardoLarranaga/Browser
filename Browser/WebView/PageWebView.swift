//
//  PageWebView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/7/25.
//

import SwiftUI
import SwiftData

/// A view that contains all the stacks for the loaded tabs in all the spaces
struct PageWebView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(BrowserWindow.self) var browserWindow
    
    let browserSpaces: [BrowserSpace]
    
    // UUID to scroll to the current space (using browserWindow.viewScrollState doesn't work)
    @State var scrollState: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            if Preferences.shared.urlBarPosition == .onToolbar {
                SidebarURLToolbar()
            }
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: .zero) {
                    ForEach(browserSpaces) { browserSpace in
                        WebViewStack(browserSpace: browserSpace)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                    }
                }
                .scrollTargetLayout()
            }
        }
        .scrollPosition(id: $scrollState, anchor: .center)
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .onChange(of: browserWindow.currentSpace) { _, newValue in
            scrollState = newValue?.id
        }
        .transaction { $0.disablesAnimations = true }
        // Try to enter Picture in Picture of current tab when tab changes or app goes to background
        .onChange(of: browserWindow.currentSpace?.currentTab) { oldValue, newValue in
            if Preferences.shared.openPipOnTabChange {
                if let oldValue {
                    oldValue.webview?.togglePictureInPicture()
                }
                
                if let newValue {
                    newValue.webview?.togglePictureInPicture()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
            if Preferences.shared.openPipOnTabChange {
                browserWindow.currentSpace?.currentTab?.webview?.togglePictureInPicture()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)) { _ in
            if Preferences.shared.openPipOnTabChange {
                browserWindow.currentSpace?.currentTab?.webview?.togglePictureInPicture()
            }
        }
    }
}
