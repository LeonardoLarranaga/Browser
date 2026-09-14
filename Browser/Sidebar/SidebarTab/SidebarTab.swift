//
//  SidebarTab.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/30/25.
//

import SwiftUI

struct SidebarTab: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(BrowserWindow.self) private var browserWindow
    @Environment(TabDragManager.self) private var dragManager

    @Bindable var browserSpace: BrowserSpace
    @Bindable var browserTab: BrowserTab

    var pinState: TabPinState

    @State private var isEditingTitle = false
    @State private var isHovering = false
    @State private var isPressed = false

    private var isSelected: Bool {
        browserSpace.currentTab == browserTab
    }

    private var isDragging: Bool {
        dragManager.isDragging(browserTab)
    }

    var body: some View {
        HStack(spacing: 0) {
            SidebarTabFaviconImage()

            if browserTab.webview?.hasActiveNowPlayingSession == true {
                Button("Mute Tab", systemImage: browserTab.webview?.isAudioMuted == true ? "speaker.slash" : "speaker.wave.2") {
                    self.browserTab.webview?.toggleMute()
                }
                .buttonStyle(.sidebarHover(enabledColor: .primary, hoverColor: .primary))
                .browserTransition(.move(edge: .leading))
                .padding(.leading, 4)
            }

            SidebarTabTitle(
                title: $browserTab.customTitle,
                displayTitle: browserTab.displayTitle,
                isEditingTitle: $isEditingTitle
            )
                .foregroundStyle(colorScheme == .dark && browserSpace.currentTab == browserTab ? .black : .primary)
                .padding(.leading, 6)

            Spacer(minLength: 0)

            ZStack {
                if isHovering {
                    SidebarTabCloseButton()
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
            }
            .frame(width: 24)
            .animation(.snappy(duration: 0.18), value: isHovering)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 34)
        .padding(.horizontal, 4)
        .background(tabBackground)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(colorScheme == .dark ? 0.08 : 0.5), lineWidth: 0.5)
            }
        }
        .shadow(color: .black.opacity(isSelected ? 0.12 : 0), radius: 3, y: 1)
        .contentShape(.rect)
        .opacity(isDragging ? 0 : 1)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .reportTabFrame(id: browserTab.id, tier: pinState, folderID: browserTab.folder?.id)
        .simultaneousGesture(TapGesture().onEnded(selectTab))
        .simultaneousGesture(TapGesture(count: 2).onEnded { isEditingTitle = true })
        .tabDragGesture(tab: browserTab, tier: pinState, manager: dragManager, browserSpace: browserSpace)
        .onHover {
            if !dragManager.isActive {
                isHovering = $0
            }
        }
        .contextMenu { SidebarTabContextMenu(isEditingTitle: $isEditingTitle) }
        .animation(.bouncy(duration: 0.15), value: isPressed)
        .environment(browserTab)
        .environment(browserSpace)
    }

    @ViewBuilder
    private var tabBackground: some View {
        if isSelected {
            Color.white.opacity(colorScheme == .dark ? 0.22 : 0.9)
        } else if isHovering {
            Color.primary.opacity(0.08)
        } else {
            Color.clear
        }
    }

    private func selectTab() {
        browserSpace.currentTab = browserTab
        if Preferences.disableAnimations { return }
        Task {
            isPressed = true
            try? await Task.sleep(for: .milliseconds(100))
            isPressed = false
        }
    }
}
