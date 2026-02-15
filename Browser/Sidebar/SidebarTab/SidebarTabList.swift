//
//  SidebarTabList.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/30/25.
//

import SwiftUI

/// List of tabs of a space in the sidebar
struct SidebarTabList: View {

    @Environment(BrowserSpace.self) var browserSpace
    @Environment(\.modelContext) var modelContext
    @Environment(SidebarModel.self) var sidebarModel

    var tabs: [BrowserTab]
    var pinState: TabPinState
    @Binding var draggingTab: BrowserTab?

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 5) {
            ForEach(tabs) { browserTab in
                SidebarTab(
                    browserSpace: browserSpace,
                    browserTab: browserTab,
                    pinState: pinState,
                    draggingTab: $draggingTab
                )
                .onDrag {
                    draggingTab = browserTab
                    let tabDropProvider = TabDropProvider(object: browserTab.id.uuidString as NSString)
                    tabDropProvider.onEnd = {
                        Task { @MainActor in
                            draggingTab = nil
                        }
                    }
                    return tabDropProvider
                }
            }
        }
        .padding(.leading, .sidebarPadding)
        .padding(.trailing, Preferences.sidebarPosition == .leading && sidebarModel.sidebarCollapsed ? 5 : 0)
    }
}

class TabDropProvider: NSItemProvider {
    var onEnd: (() -> Void)?

    deinit {
        onEnd?()
    }
}
