//
//  SidebarTabViewModel.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 18/1/26.
//

import SwiftData
import SwiftUI

/// ViewModel for a sidebar tab, managing its state and behavior.
/// Suck as duplicating, closing, and reordering tabs.
@Observable final class SidebarTabViewModel {

    var browserTab: BrowserTab
    var modelContext: ModelContext!

    var isButtonPressed = false
    var isHovering = false
    var isHoveringCloseButton = false
    var isEditingTitle = false
    var customTitle = ""

    init(browserTab: BrowserTab) {
        self.browserTab = browserTab
        self.modelContext = modelContext
    }

    var browserSpace: BrowserSpace? {
        browserTab.browserSpace
    }

    // MARK: Computed properties for views
    var isTabPinned: Bool {
        browserSpace?.pinnedTabs.contains(browserTab) == true
    }

    var canCloseTabsAbove: Bool {
        if let tabCount = browserSpace?.tabs.count, tabCount > 1 {
            return browserTab.order > 0
        }
        return false
    }

    var canCloseTabsBelow: Bool {
        if let tabCount = browserSpace?.tabs.count, tabCount > 1 {
            return browserTab.order < tabCount - 1
        }
        return false
    }

    var hasActiveNowPlayingSession: Bool {
        browserTab.webview?.hasActiveNowPlayingSession == true
    }

    // MARK: SidebarTab views
    var faviconImage: some View {
        Group {
            if Preferences.shared.loadingIndicatorPosition == .onTab && browserTab.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else if let favicon = browserTab.favicon, let nsImage = NSImage(data: favicon) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray))
            }
        }
        .frame(width: 16, height: 16)
        .padding(.leading, 5)
    }

    var muteButton: some View {
        Button("Mute Tab", systemImage: browserTab.webview?.mediaMutedState != .audioMuted ? "speaker.wave.2" : "speaker.slash") {
            self.browserTab.webview?.toggleMute()
        }
        .buttonStyle(.sidebarHover())
        .browserTransition(.move(edge: .leading))
    }

    var closeTabButton: some View {
        Button("Close Tab", systemImage: "xmark", action: closeTab)
            .font(.title3)
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
            .padding(4)
            .background(isHoveringCloseButton ? AnyShapeStyle(.ultraThinMaterial.opacity(0.4)) : AnyShapeStyle(.clear))
            .clipShape(.rect(cornerRadius: 6))
            .onHover { hover in
                self.isHoveringCloseButton = hover
            }
            .padding(.trailing, 5)
    }

    func selectTab() {
        browserSpace?.currentTab = browserTab
        if Preferences.shared.disableAnimations { return }
        // Scale bounce effect
        withAnimation(.bouncy(duration: 0.15, extraBounce: 0.0)) {
            isButtonPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isButtonPressed = false
            }
        }
    }

    // MARK: Context menu actions
    func startEditingTitle() {
        isEditingTitle = true
    }

    func pinTab() {
        withAnimation(.browserDefault) {
            browserSpace?.pinTab(browserTab, using: modelContext)
        }
    }

    func unpinTab() {
        withAnimation(.browserDefault) {
            browserSpace?.unpinTab(browserTab, using: modelContext)
        }
    }

    /// Duplicate the tab and selects the new tab
    func duplicateTab() {
        let duplicateTab = BrowserTab(
            title: browserTab.title,
            favicon: browserTab.favicon,
            url: browserTab.url,
            order: browserTab.order + 1,
            browserSpace: browserTab.browserSpace
        )

        if browserSpace?.pinnedTabs.contains(browserTab) == false {
            browserSpace?.tabs.insert(duplicateTab, at: browserTab.order + 1)
            browserSpace?.currentTab = duplicateTab
        } else {
            browserSpace?.pinnedTabs.insert(duplicateTab, at: browserTab.order + 1)
            browserSpace?.currentTab = duplicateTab
        }
    }

    /// Close (delete) the tab and selects the next tab
    func closeTab() {
        browserSpace?.closeTab(browserTab, using: modelContext)
    }

    /// Close (delete) the tabs below the current tab
    func closeTabsBelow() {
        guard let browserSpace,
              let index = browserSpace.tabs.firstIndex(where: { $0.id == browserTab.id })
        else { return }

        withAnimation(.browserDefault) {
            for tab in browserSpace.tabs.suffix(from: index + 1) {
                browserSpace.unloadTab(tab)
                modelContext.delete(tab)
            }
            try? modelContext.save()
        }
    }

    /// Close (delete) the tabs above the current tab
    func closeTabsAbove() {
        guard let browserSpace,
              let index = browserSpace.tabs.firstIndex(where: { $0.id == browserTab.id })
        else { return }

        withAnimation(.browserDefault) {
            for tab in browserSpace.tabs.prefix(upTo: index) {
                browserSpace.unloadTab(tab)
                modelContext.delete(tab)
            }
            try? modelContext.save()
        }
    }
}
