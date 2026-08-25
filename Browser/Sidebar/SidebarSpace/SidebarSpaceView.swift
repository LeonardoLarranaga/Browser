//
//  SidebarSpaceView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI

// View that represents a space in the sidebar
struct SidebarSpaceView: View {

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext

    let browserSpaces: [BrowserSpace]

    @Bindable var browserSpace: BrowserSpace

    @Environment(SidebarModel.self) var sidebarModel

    @State private var dragManager = TabDragManager()

    @State var isHovering = false
    @State var isHoveringClearButton = false
    @State private var headerHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !browserSpace.favoriteTabs.isEmpty || dragManager.shouldRevealEmptyEssentials {
                SidebarEssentialsGrid(tabs: browserSpace.favoriteTabs)
                    .padding(.top, 5)
                    .padding(.bottom, 8)
                    .browserTransition(.move(edge: .top).combined(with: .opacity))
            }

            spaceHeader
                .padding(.leading, .sidebarPadding)
                .padding(.trailing, Preferences.sidebarPosition == .leading && sidebarModel.sidebarCollapsed ? 5 : 0)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if browserSpace.pinnedTabsVisible && (!browserSpace.pinnedTabs.isEmpty || dragManager.isActive) {
                        SidebarTabList(tabs: browserSpace.pinnedTabs, pinState: .pinned)
                            .browserTransition(.move(edge: .top).combined(with: .opacity))
                    }

                    SidebarSpaceClearDivider(isHovering: isHovering)
                        .padding(.top, 2)

                    SidebarTabNewButton()

                    SidebarTabList(tabs: browserSpace.normalTabs, pinState: .normal)
                }
            }
            .scrollDisabled(dragManager.isActive)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .coordinateSpace(.named(sidebarDragSpace))
        .onPreferenceChange(TabFramePreferenceKey.self) { frames in
            dragManager.tabFrames = frames
        }
        .onPreferenceChange(TierZonePreferenceKey.self) { zones in
            dragManager.tierZones = zones
        }
        .overlay(alignment: .topLeading) {
            if let tab = dragManager.draggingTab {
                SidebarDragPreview(
                    tab: tab,
                    tier: dragManager.dropTier ?? tab.pinState,
                    rowWidth: dragManager.sourceWidth,
                    tileWidth: projectedEssentialTileWidth(for: tab)
                )
                .position(dragManager.pointer)
                .allowsHitTesting(false)
                .transition(.opacity)
            }
        }
        .sidebarSpaceContextMenu(browserSpaces: browserSpaces, browserSpace: browserSpace)
        .onHover { isHover in
            withAnimation(.browserDefault) {
                self.isHovering = isHover
            }
        }
        .environment(browserSpace)
        .environment(dragManager)
    }

    private var spaceHeader: some View {
        HStack(spacing: 6) {
            if headerHovering && !browserSpace.pinnedTabs.isEmpty {
                Button {
                    withAnimation(.browserSnappy) {
                        browserSpace.pinnedTabsVisible.toggle()
                    }
                } label: {
                    Image(systemName: browserSpace.pinnedTabsVisible ? "chevron.down" : "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 16, height: 16)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            Text(browserSpace.name)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .foregroundStyle(.secondary)
        .fontWeight(.bold)
        .padding(.horizontal, 9)
        .frame(height: 34)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(headerHovering ? Color.primary.opacity(0.08) : Color.clear)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            if headerHovering {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
            }
        }
        .contentShape(.rect)
        .onHover { hovering in
            withAnimation(.browserSnappy) { headerHovering = hovering }
        }
    }

    private func projectedEssentialTileWidth(for tab: BrowserTab) -> CGFloat {
        let maxPerRow = 4
        let gap: CGFloat = 4
        var count = browserSpace.favoriteTabs.count
        if tab.pinState != .favorite { count += 1 }
        let cols = min(maxPerRow, max(1, count))
        let content = dragManager.sourceWidth
        return (content - gap * CGFloat(cols - 1)) / CGFloat(cols)
    }
}
