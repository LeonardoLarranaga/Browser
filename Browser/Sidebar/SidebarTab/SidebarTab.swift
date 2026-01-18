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
    @Environment(\.modelContext) var modelContext

    @Environment(BrowserWindowState.self) var browserWindowState

    @Bindable var browserSpace: BrowserSpace
    @Bindable var browserTab: BrowserTab
    
    let dragging: Bool

    @State var viewModel: SidebarTabViewModel
    init(browserSpace: BrowserSpace, browserTab: BrowserTab, dragging: Bool = false) {
        self.browserSpace = browserSpace
        self.browserTab = browserTab
        self.dragging = dragging
        self.viewModel = SidebarTabViewModel(browserTab: browserTab)
    }

    @FocusState var isTextFieldFocused: Bool

    var body: some View {
        HStack {
            viewModel.faviconImage

            if viewModel.hasActiveNowPlayingSession {
                viewModel.muteButton
            }

            if viewModel.isEditingTitle {
                TextField("", text: $viewModel.customTitle, onCommit: {
                    viewModel.isEditingTitle = false
                    if viewModel.customTitle.isReallyEmpty {
                        browserTab.customTitle = nil
                    } else {
                        browserTab.customTitle = viewModel.customTitle
                    }
                })
                .focused($isTextFieldFocused)
                .onAppear {
                    viewModel.customTitle = browserTab.displayTitle
                    isTextFieldFocused = true
                    DispatchQueue.main.async {
                        NSApplication.shared.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: nil)
                    }
                }
            } else {
                Text(browserTab.displayTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer()

            if viewModel.isHovering {
                viewModel.closeTabButton
            }
        }
        .onAppear { viewModel.modelContext = modelContext }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 30)
        .padding(3)
        .background(dragging ? .white.opacity(0.1) : browserSpace.currentTab == browserTab ? browserSpace.textColor(in: colorScheme) == .black ? .white : .white.opacity(0.2) : viewModel.isHovering ? .white.opacity(0.1) : .clear)
        .clipShape(.rect(cornerRadius: 10))
        .onTapGesture(perform: viewModel.selectTab)
        .onTapGesture(count: 2, perform: viewModel.startEditingTitle)
        .onHover { hover in
            viewModel.isHovering = hover
        }
        .contextMenu {
            SidebarTabContextMenu()
        }
        .scaleEffect(viewModel.isButtonPressed ? 0.98 : 1.0)
        .environment(viewModel)
    }
    
    /// Close (delete) the tab
    func closeTab() {
        browserSpace.closeTab(browserTab, using: modelContext)
    }
}
