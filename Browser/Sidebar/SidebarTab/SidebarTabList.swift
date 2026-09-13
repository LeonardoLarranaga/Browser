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
    var folderID: UUID? = nil
    var usesSidebarPadding = true

    private var isReceivingCrossTierDrag: Bool {
        guard folderID == nil,
              tabs.isEmpty,
              let draggingTab = dragManager.draggingTab
        else { return false }

        return draggingTab.pinState != pinState
    }

    private var isTierTargeted: Bool {
        dragManager.isActive
            && dragManager.dropTier == pinState
            && dragManager.dropFolderID == folderID
    }

    private func showsIndicator(before tab: BrowserTab) -> Bool {
        isTierTargeted
            && dragManager.dropBeforeTabID == tab.id
            && dragManager.draggingTab?.id != tab.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isReceivingCrossTierDrag {
                SidebarEmptyDropTarget(
                    title: pinState == .pinned ? "Drop to pin" : "Drop here",
                    rowWidth: dragManager.sourceWidth
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity)
            }

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

            if isTierTargeted && dragManager.dropBeforeTabID == nil && !isReceivingCrossTierDrag {
                TabInsertionIndicator()
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
        .padding(.leading, usesSidebarPadding ? .sidebarPadding : 0)
        .padding(.trailing, usesSidebarPadding && Preferences.sidebarPosition == .leading && sidebarModel.sidebarCollapsed ? 5 : 0)
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
