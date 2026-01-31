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

    private var sidebarPosition: Preferences.SidebarPosition {
        Preferences.shared.sidebarPosition
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
                        SidebarButton()
                        BackButton()
                        ForwardButton()
                    }
                }
            }
            .toolbar {
                if sidebarPosition == .trailing {
                    Spacer()
                    SidebarButton()
                    BackButton()
                    ForwardButton()
                }
            }
    }

    func SidebarButton() -> some View {
        Button("Toggle Sidebar", systemImage: sidebarIcon, action: sidebarModel.toggleSidebar)
            .labelStyle(.iconOnly)
    }

    func BackButton() -> some View {
        Button("Go Back", systemImage: "chevron.left", action: browserWindow.backButtonAction)
            .labelStyle(.iconOnly)
            .disabled(currentTab == nil || currentTab?.canGoBack == false)
    }

    func ForwardButton() -> some View {
        Button("Go Forward", systemImage: "chevron.right", action: browserWindow.forwardButtonAction)
            .labelStyle(.iconOnly)
            .disabled(currentTab == nil || currentTab?.canGoForward == false)
    }
}

extension View {
    func sidebarToolbar(browserSpaces: [BrowserSpace]) -> some View {
        modifier(SidebarToolbar(browserSpaces: browserSpaces))
    }
}
