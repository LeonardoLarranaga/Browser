//
//  SidebarTab.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/30/25.
//

import SwiftUI

/// Tab in the sidebar
struct SidebarTab: View {
    
    @Environment(\.colorScheme) var colorScheme

    @Environment(BrowserWindow.self) var browserWindow

    @Bindable var browserSpace: BrowserSpace
    @Bindable var browserTab: BrowserTab

    @State var isEditingTitle = false
    @State var isHovering = false
    @State var isPressed = false

    var body: some View {
        HStack {
            SidebarTabFaviconImage()

            if browserTab.webview?.hasActiveNowPlayingSession == true {
                Button("Mute Tab", systemImage: browserTab.webview?.isAudioMuted == true ? "speaker.slash" : "speaker.wave.2") {
                    self.browserTab.webview?.toggleMute()
                }
                .buttonStyle(.sidebarHover(
                    enabledColor: colorScheme == .dark && browserSpace.currentTab == browserTab ? .black : .primary,
                    hoverColor: colorScheme == .dark && browserSpace.currentTab == browserTab ? .black : .primary
                ))
                .browserTransition(.move(edge: .leading))
            }

            SidebarTabTitle(isEditingTitle: $isEditingTitle)

            Spacer()

            if isHovering {
                SidebarTabCloseButton()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 30)
        .padding(3)
        .background(browserSpace.currentTab == browserTab ? .white : isHovering ? .white.opacity(0.5) : .clear)
        .clipShape(.rect(cornerRadius: 10))
        .contentShape(.rect)
        .onTapGesture(perform: selectTab)
        .onHover { isHovering = $0 }
        .contextMenu { SidebarTabContextMenu(isEditingTitle: $isEditingTitle) }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.bouncy(duration: 0.15), value: isPressed)
        .environment(browserTab)
        .environment(browserSpace)
    }

    func selectTab() {
        browserSpace.currentTab = browserTab
        if Preferences.disableAnimations { return }
        // Scale bounce effect
        Task {
            isPressed = true
            try? await Task.sleep(for: .milliseconds(100))
            isPressed = false
        }
    }
}
