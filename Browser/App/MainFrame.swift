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

    @Environment(BrowserWindow.self) var browserWindow
    @Environment(\.colorScheme) var colorScheme

    @State var sidebarModel = SidebarModel()

    @Query(sort: \BrowserSpace.order) var browserSpaces: [BrowserSpace]

    var isImmersive: Bool {
        browserWindow.isFullScreen && sidebarModel.sidebarCollapsed && Preferences.shared.immersiveViewOnFullscreen
    }

    var body: some View {
        @Bindable var browserWindow = browserWindow

        HStack(spacing: 0) {
            if Preferences.shared.sidebarPosition == .leading {
                if !sidebarModel.sidebarCollapsed {
                    sidebar
                    SidebarResizer()
                }
            }

            PageWebView(browserSpaces: browserSpaces)
                .clipShape(.rect(corners: isImmersive ? .fixed(0) : Preferences.shared.roundedCorners ? .concentric(minimum: 8) : .fixed(0)))
                .shadow(radius: isImmersive ? 0 : Preferences.shared.enableShadow ? 3 : 0)
                .padding([.top, .bottom], isImmersive ? 0 : Preferences.shared.enablePadding ? 10 : 0)
                .padding(
                    Preferences.shared.sidebarPosition == .leading ? .leading : .trailing,
                    isImmersive ? 0 : sidebarModel.sidebarCollapsed ? 10 : 5
                )
                .padding(
                    Preferences.shared.sidebarPosition == .leading ? .trailing : .leading,
                    isImmersive ? 0 : Preferences.shared.enablePadding ? 10 : 0
                )
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.willEnterFullScreenNotification)) { _ in
                    withAnimation(.browserDefault) {
                        browserWindow.isFullScreen = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
                    withAnimation(.browserDefault) {
                        browserWindow.isFullScreen = false
                    }
                }
                .actionAlert()

            if Preferences.shared.sidebarPosition == .trailing {
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
            if let currentSpace = browserWindow.currentSpace {
                SidebarSpaceBackground(browserSpace: currentSpace, isSidebarCollapsed: false)
            }
        }
        // Show the search view
        .floatingPanel(isPresented: .init(get: {
            browserWindow.searchOpenLocation != .none
        }, set: { newValue in
            if !newValue {
                browserWindow.searchOpenLocation = .none
            }
        }), origin: browserWindow.searchPanelOrigin, size: browserWindow.searchPanelSize, shouldCenter: browserWindow.searchOpenLocation == .fromNewTab || Preferences.shared.urlBarPosition == .onToolbar) {
            SearchView()
                .environment(browserWindow)
        }
        // Show the tab switcher
        .floatingPanel(isPresented: $browserWindow.showTabSwitcher, size: CGSize(width: 700, height: 200)) {
            TabSwitcher(browserSpaces: browserSpaces)
                .environment(browserWindow)
        }
        // Show the sidebar by hovering the mouse on the edge of the screen
        .overlay(alignment: Preferences.shared.sidebarPosition == .leading ? .topLeading : .topTrailing) {
            if sidebarModel.sidebarCollapsed && sidebarModel.currentSidebarWidth > 0 {
                sidebar
                    .background {
                        if let currentSpace = browserWindow.currentSpace {
                            SidebarSpaceBackground(browserSpace: currentSpace, isSidebarCollapsed: true)
                        }
                    }
                    .glassEffect(in: .rect)
                    .padding(Preferences.shared.sidebarPosition == .leading ? .trailing : .leading, .sidebarPadding)
                    .browserTransition(.move(edge: Preferences.shared.sidebarPosition == .leading ? .leading : .trailing))
            }
        }
        .transaction {
            if Preferences.shared.disableAnimations {
                $0.animation = nil
            }
        }
        .environment(sidebarModel)
        .focusedSceneValue(\.sidebarModel, sidebarModel)
        .foregroundStyle(browserWindow.currentSpace?.textColor(in: colorScheme) ?? .primary)
    }

    var sidebar: some View {
        Sidebar(browserSpaces: browserSpaces)
            .frame(width: sidebarModel.currentSidebarWidth)
            .readingWidth(width: $sidebarModel.currentSidebarWidth)
    }
}
