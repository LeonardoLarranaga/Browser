//
//  SidebarToolbar.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/23/25.
//

import SwiftUI

struct SidebarToolbar: View {
    @Environment(\.colorScheme) private var colorScheme

    @Environment(SidebarModel.self) private var sidebarModel
    @Environment(BrowserWindow.self) private var browserWindow

    let browserSpaces: [BrowserSpace]

    private var toolbarColorScheme: ColorScheme {
        browserWindow.currentSpace?.textColor(in: colorScheme) == .black ? .light : .dark
    }

    private var currentTab: BrowserTab? {
        browserWindow.currentSpace?.currentTab
    }

    private var sidebarPosition: AppPreferences.SidebarPosition {
        Preferences.sidebarPosition
    }

    private var sidebarIcon: String {
        switch sidebarPosition {
        case .leading: "sidebar.left"
        case .trailing: "sidebar.right"
        }
    }

    private var usesCompactToolbar: Bool {
        sidebarModel.currentSidebarWidth < 205
    }

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 4) {
                if usesCompactToolbar {
                    SmallToolbar()
                } else {
                    SidebarButton()
                    BackButton()
                    ForwardButton()
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(GlassToolbarButtonStyle())
            .menuIndicator(.hidden)
            .padding(.leading, usesCompactToolbar ? 2 : 4)
            .padding(.trailing, 2)
            .padding(.vertical, 4)
            .glassEffect(in: .capsule)
        }
        .preferredColorScheme(toolbarColorScheme)
        .padding(.top, 8)
        .padding(.trailing, 12)
        .toolbar {
            // Reserve the native header without overlapping the sidebar controls.
            ToolbarItem(placement: .principal) {
                Text(" ")
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }

    private func SidebarButton() -> some View {
        Button("Toggle Sidebar", systemImage: sidebarIcon, action: sidebarModel.toggleSidebar)
    }

    private func BackButton() -> some View {
        Button("Go Back", systemImage: "chevron.left", action: browserWindow.backButtonAction)
            .disabled(currentTab == nil || currentTab?.canGoBack == false)
    }

    private func ForwardButton() -> some View {
        Button("Go Forward", systemImage: "chevron.right", action: browserWindow.forwardButtonAction)
            .disabled(currentTab == nil || currentTab?.canGoForward == false)
    }

    private func SmallToolbar() -> some View {
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

}

private struct GlassToolbarButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    private var highlightColor: Color {
        // An explicit color keeps glass vibrancy from lightening the hover fill.
        colorScheme == .dark ? .white : .black
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17))
            .frame(width: 32, height: 28)
            .foregroundStyle(.primary)
            .opacity(isEnabled ? 1 : 0.21)
            .background {
                Capsule()
                    .fill(highlightColor.opacity(isEnabled && (isHovered || configuration.isPressed) ? 0.18 : 0))
            }
            .contentShape(.capsule)
            .onHover { isHovered = $0 }
            .animation(.easeOut(duration: 0.12), value: isHovered)
    }
}
