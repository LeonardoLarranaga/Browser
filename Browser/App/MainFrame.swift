//
//  MainFrame.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/23/25.
//

import SwiftUI
import SwiftData

/// Main frame of the browser.
struct MainFrame: View {
    
    @Environment(BrowserWindowState.self) var browserWindowState
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var userPreferences: UserPreferences
    
    @State var sidebarModel = SidebarModel()
    
    @Query(sort: \BrowserSpace.order) var browserSpaces: [BrowserSpace]
    
    var isImmersive: Bool {
        browserWindowState.isFullScreen && sidebarModel.sidebarCollapsed && userPreferences.immersiveViewOnFullscreen
    }
    
    var body: some View {
        @Bindable var browserWindowState = browserWindowState
        
        HStack(spacing: 0) {
            if userPreferences.sidebarPosition == .leading {
                if !sidebarModel.sidebarCollapsed {
                    sidebar
                    SidebarResizer()
                }
            }
            
            PageWebView(browserSpaces: browserSpaces)
                .clipShape(.rect(cornerRadius: isImmersive ? 0 : userPreferences.roundedCorners ? 8 : 0))
                .shadow(radius: isImmersive ? 0 : userPreferences.enableShadow ? 3 : 0)
                .padding([.top, .bottom], isImmersive ? 0 : userPreferences.enablePadding ? 10 : 0)
                .padding(
                    userPreferences.sidebarPosition == .leading ? .leading : .trailing,
                    isImmersive ? 0 : sidebarModel.sidebarCollapsed ? 10 : 5
                )
                .padding(
                    userPreferences.sidebarPosition == .leading ? .trailing : .leading,
                    isImmersive ? 0 : userPreferences.enablePadding ? 10 : 0
                )
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.willEnterFullScreenNotification)) { _ in
                    withAnimation(.browserDefault) {
                        browserWindowState.isFullScreen = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
                    withAnimation(.browserDefault) {
                        browserWindowState.isFullScreen = false
                    }
                }
                .actionAlert()
            
            if userPreferences.sidebarPosition == .trailing {
                if !sidebarModel.sidebarCollapsed {
                    SidebarResizer()
                    sidebar
                }
            }
        }
        .frame(maxWidth: .infinity)
        .toolbar { Text("") }
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .background {
            if let currentSpace = browserWindowState.currentSpace {
                SidebarSpaceBackground(browserSpace: currentSpace, isSidebarCollapsed: false)
            }
        }
        // Show the search view
        .floatingPanel(isPresented: .init(get: {
            browserWindowState.searchOpenLocation != .none
        }, set: { newValue in
            if !newValue {
                browserWindowState.searchOpenLocation = .none
            }
        }), origin: browserWindowState.searchPanelOrigin, size: browserWindowState.searchPanelSize, shouldCenter: browserWindowState.searchOpenLocation == .fromNewTab || userPreferences.urlBarPosition == .onToolbar) {
            SearchView()
                .environment(browserWindowState)
        }
        // Show the tab switcher
        .floatingPanel(isPresented: $browserWindowState.showTabSwitcher, size: CGSize(width: 700, height: 200)) {
            TabSwitcher(browserSpaces: browserSpaces)
                .environment(browserWindowState)
        }
        // Show the sidebar by hovering the mouse on the edge of the screen
        .overlay(alignment: userPreferences.sidebarPosition == .leading ? .topLeading : .topTrailing) {
            if sidebarModel.sidebarCollapsed && sidebarModel.currentSidebarWidth > 0 {
                sidebar
                    .background {
                        if let currentSpace = browserWindowState.currentSpace {
                            SidebarSpaceBackground(browserSpace: currentSpace, isSidebarCollapsed: true)
                        }
                    }
                    .background(.ultraThinMaterial)
                    .padding(userPreferences.sidebarPosition == .leading ? .trailing : .leading, .sidebarPadding)
                    .browserTransition(.move(edge: userPreferences.sidebarPosition == .leading ? .leading : .trailing))
            }
        }
        .transaction {
            if userPreferences.disableAnimations {
                $0.animation = nil
            }
        }
        .environment(sidebarModel)
        .focusedSceneValue(\.sidebarModel, sidebarModel)
        .foregroundStyle(browserWindowState.currentSpace?.textColor(in: colorScheme) ?? .primary)
    }
    
    var sidebar: some View {
        Sidebar(browserSpaces: browserSpaces)
            .frame(width: sidebarModel.currentSidebarWidth)
            .readingWidth(width: $sidebarModel.currentSidebarWidth)
    }
}
