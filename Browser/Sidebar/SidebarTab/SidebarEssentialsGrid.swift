//
//  SidebarEssentialsGrid.swift
//  Browser
//

import SwiftUI

struct SidebarEssentialsGrid: View {

    @Environment(BrowserSpace.self) var browserSpace
    @Environment(SidebarModel.self) var sidebarModel
    @Environment(TabDragManager.self) var dragManager

    var tabs: [BrowserTab]

    private let maxPerRow = 4

    private var effectiveCount: Int {
        var count = tabs.count
        if isTierTargeted && isReceivingCrossTierDrag { count += 1 }
        return count
    }

    private var columns: [GridItem] {
        let count = min(maxPerRow, max(1, effectiveCount))
        return Array(repeating: GridItem(.flexible(minimum: 40), spacing: 4), count: count)
    }

    private var isReceivingCrossTierDrag: Bool {
        guard let dragging = dragManager.draggingTab else { return false }
        return dragging.pinState != .favorite
    }

    private var isTierTargeted: Bool {
        dragManager.isActive && dragManager.dropTier == .favorite
    }

    private func showsGap(before tab: BrowserTab) -> Bool {
        isTierTargeted
            && dragManager.dropBeforeTabID == tab.id
            && dragManager.draggingTab?.id != tab.id
    }

    private var tileWidth: CGFloat {
        dragManager.essentialTileWidth ?? 54
    }

    var body: some View {
        Group {
            if !tabs.isEmpty {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(tabs) { browserTab in
                        if showsGap(before: browserTab) {
                            EssentialDropGap(width: tileWidth)
                        }

                        SidebarEssentialTile(browserSpace: browserSpace, browserTab: browserTab)
                            .reportTabFrame(id: browserTab.id, tier: .favorite)
                            .tabDragGesture(tab: browserTab, tier: .favorite, manager: dragManager, browserSpace: browserSpace)
                    }

                    if isTierTargeted && dragManager.dropBeforeTabID == nil {
                        EssentialDropGap(width: tileWidth)
                    }
                }
            } else if isReceivingCrossTierDrag {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.primary.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .frame(height: 40)
                    .overlay {
                        Text("Drop to add to Essentials")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .browserTransition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .reportTierZone(.favorite)
        .padding(.leading, .sidebarPadding)
        .padding(.trailing, Preferences.sidebarPosition == .leading && sidebarModel.sidebarCollapsed ? 5 : 0)
        .animation(.browserSnappy, value: dragManager.dropBeforeTabID)
        .animation(.browserSnappy, value: dragManager.dropTier)
        .animation(.browserSnappy, value: tabs.count)
    }
}

private struct EssentialDropGap: View {
    let width: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.primary.opacity(0.08))
            .frame(height: 40)
            .transition(.scale(scale: 0.6).combined(with: .opacity))
    }
}

private struct SidebarEssentialTile: View {

    @Environment(\.colorScheme) var colorScheme
    @Environment(BrowserWindow.self) var browserWindow
    @Environment(TabDragManager.self) var dragManager

    @Bindable var browserSpace: BrowserSpace
    @Bindable var browserTab: BrowserTab

    @State private var isEditingTitle = false

    private var isSelected: Bool { browserSpace.currentTab == browserTab }
    private var isDragging: Bool { dragManager.isDragging(browserTab) }

    var body: some View {
        faviconView
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(tileBackground)
            .clipShape(.rect(cornerRadius: 10))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(browserTab.iconColor, lineWidth: 1.5)
                }
            }
            .contentShape(.rect)
            .opacity(isDragging ? 0 : 1)
            .help(browserTab.displayTitle)
            .simultaneousGesture(TapGesture().onEnded { browserSpace.currentTab = browserTab })
            .contextMenu { SidebarTabContextMenu(isEditingTitle: $isEditingTitle) }
            .environment(browserTab)
            .environment(browserSpace)
    }

    @ViewBuilder
    private var faviconView: some View {
        Group {
            if let favicon = browserTab.favicon, let nsImage = NSImage(data: favicon) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 5))
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(.systemGray))
            }
        }
        .frame(width: 20, height: 20)
    }

    @ViewBuilder
    private var tileBackground: some View {
        if isSelected {
            browserTab.iconColor.opacity(0.15)
        } else {
            Color.primary.opacity(0.05)
        }
    }
}
