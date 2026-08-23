//
//  SidebarTabList.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/30/25.
//

import SwiftUI

struct SidebarTabList: View {

    @Environment(BrowserSpace.self) var browserSpace
    @Environment(SidebarModel.self) var sidebarModel
    @Environment(TabDragManager.self) var dragManager

    var tabs: [BrowserTab]
    var pinState: TabPinState

    private var isReceivingCrossTierDrag: Bool {
        guard let dragging = dragManager.draggingTab else { return false }
        return dragging.pinState != pinState
    }

    private var isTierTargeted: Bool {
        dragManager.isActive && dragManager.dropTier == pinState
    }

    private func showsIndicator(before tab: BrowserTab) -> Bool {
        isTierTargeted
            && dragManager.dropBeforeTabID == tab.id
            && dragManager.draggingTab?.id != tab.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(tabs) { browserTab in
                if showsIndicator(before: browserTab) {
                    TabInsertionIndicator()
                }

                SidebarTab(
                    browserSpace: browserSpace,
                    browserTab: browserTab,
                    pinState: pinState
                )
            }

            if isTierTargeted && dragManager.dropBeforeTabID == nil {
                TabInsertionIndicator()
            }

            if tabs.isEmpty && isReceivingCrossTierDrag {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.primary.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .frame(height: 40)
                    .overlay {
                        Text(pinState == .pinned ? "Drop to pin" : "Drop here")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, .sidebarPadding)
                    .browserTransition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .background {
            if isTierTargeted {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.primary.opacity(0.05))
            }
        }
        .reportTierZone(pinState)
        .padding(.leading, .sidebarPadding)
        .padding(.trailing, Preferences.sidebarPosition == .leading && sidebarModel.sidebarCollapsed ? 5 : 0)
        .animation(.browserSnappy, value: dragManager.dropBeforeTabID)
        .animation(.browserSnappy, value: dragManager.dropTier)
    }
}

struct TabInsertionIndicator: View {
    var body: some View {
        Capsule()
            .fill(Color.accentColor)
            .frame(height: 3)
            .padding(.horizontal, 4)
            .transition(.asymmetric(insertion: .scale(scale: 0.4).combined(with: .opacity), removal: .opacity))
    }
}
