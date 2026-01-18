//
//  SidebarTabContextMenu.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/1/25.
//

import SwiftUI

/// Context menu for a tab in the sidebar
struct SidebarTabContextMenu: View {

    @Environment(SidebarTabViewModel.self) var viewModel

    var body: some View {
        Group {
            Button("Copy Link", action: viewModel.browserTab.copyLink)
            Button("Reload Tab", action: viewModel.browserTab.reload)

            Divider()

            Button("Rename Tab", action: viewModel.startEditingTitle)
            ShareLink("Share...", item: viewModel.browserTab.url)

            Divider()

            if !viewModel.isTabPinned {
                Button("Pin Tab", action: viewModel.pinTab)
            } else {
                Button("Unpin Tab", action: viewModel.unpinTab)
            }

            Button("Duplicate Tab", action: viewModel.duplicateTab)

            Divider()

            Button("Close Tab", action: viewModel.closeTab)

            if viewModel.canCloseTabsBelow {
                Button("Close Tabs Below", action: viewModel.closeTabsBelow)
            }

            if viewModel.canCloseTabsAbove {
                Button("Close Tabs Above", action: viewModel.closeTabsAbove)
            }
        }
    }
}
