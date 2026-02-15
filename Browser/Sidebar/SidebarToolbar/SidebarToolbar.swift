//
//  SidebarToolbar.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/23/25.
//

import SwiftUI

/// Sidebar toolbar using Liquid Glass.
/// Contains the sidebar toggle button and web navigation buttons (back, forward).
///
/// ToolbarItem/ToolbarItemGroup doesn't conform to View,
/// so the current implementation is very repetitive.
struct SidebarToolbar: ViewModifier {

    @Environment(\.modelContext) var modelContext

    @Environment(SidebarModel.self) var sidebarModel
    @Environment(BrowserWindow.self) var browserWindow

    let browserSpaces: [BrowserSpace]

    var currentTab: BrowserTab? {
        browserWindow.currentSpace?.currentTab
    }

    private var placement: ToolbarItemPlacement {
        .navigation
    }

    private var sidebarPosition: _Preferences.SidebarPosition {
        Preferences.sidebarPosition
    }

    private var sidebarIcon: String {
        switch sidebarPosition {
        case .leading: "sidebar.left"
        case .trailing: "sidebar.right"
        }
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                if sidebarPosition == .leading {
                    ToolbarItemGroup(placement: .navigation) {
                        Toolbar()
                    }
                }
            }
            .toolbar {
                if sidebarPosition == .trailing {
                    Toolbar(addSpacer: true)
                }
            }
    }

    func SidebarButton() -> some View {
        Button("Toggle Sidebar", systemImage: sidebarIcon, action: sidebarModel.toggleSidebar)
    }

    func BackButton() -> some View {
        Button("Go Back", systemImage: "chevron.left", action: browserWindow.backButtonAction)
            .disabled(currentTab == nil || currentTab?.canGoBack == false)
    }

    func ForwardButton() -> some View {
        Button("Go Forward", systemImage: "chevron.right", action: browserWindow.forwardButtonAction)
            .disabled(currentTab == nil || currentTab?.canGoForward == false)
    }

    func SmallToolbar() -> some View {
        Menu("Sidebar Options", systemImage: "ellipsis") {
            SidebarButton()
                .labelStyle(.titleAndIcon)
            BackButton()
                .labelStyle(.titleAndIcon)
            ForwardButton()
                .labelStyle(.titleAndIcon)
        }
        .labelStyle(.iconOnly)
    }

    func Toolbar(addSpacer: Bool = false) -> some View {
        Group {
            if sidebarModel.currentSidebarWidth < 205 {
                SmallToolbar()
            } else {
                if addSpacer { Spacer() }
                SidebarButton()
                BackButton()
                ForwardButton()
            }
        }
        .labelStyle(.iconOnly)
        .menuIndicator(.hidden)
    }
}

extension View {
    func sidebarToolbar(browserSpaces: [BrowserSpace]) -> some View {
        modifier(SidebarToolbar(browserSpaces: browserSpaces))
    }
}
