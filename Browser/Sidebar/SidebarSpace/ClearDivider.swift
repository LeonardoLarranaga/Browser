//
//  SidebarSpaceClearDivider.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/1/25.
//

import SwiftUI

/// Divider with a clear button to remove all tabs from a space
struct SidebarSpaceClearDivider: View {

    @Environment(\.modelContext) var modelContext

    @Environment(BrowserSpace.self) var browserSpace
    @Environment(BrowserWindow.self) var browserWindow

    let isHovering: Bool

    @State var isHoveringClearButton = false
    @State var lastTapTime: Date?

    var body: some View {
        HStack {
            VStack {
                Divider()
            }

            if !browserSpace.tabs.isEmpty && isHovering {
                Button("Clear") {
                    let now = Date()

                    var deleteCurrent = false
                    if let lastTap = lastTapTime, now.timeIntervalSince(lastTap) < 3 {
                        deleteCurrent = true
                    }

                    lastTapTime = now
                    browserSpace.clear(using: modelContext, deleteCurrent: deleteCurrent, tabUndoManager: browserWindow.tabUndoManager)
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.plain)
                .foregroundStyle(isHoveringClearButton ? .primary : .secondary)
                .onHover {
                    isHoveringClearButton = $0
                }
            }
        }
        .padding(.leading, .sidebarPadding * 2)
        .padding(.trailing, .sidebarPadding)
        .frame(height: 20)
    }
}
