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
    @Environment(BrowserWindow.self) var browserWindow

    let browserSpace: BrowserSpace
    let isHovering: Bool
    
    @State var isHoveringClearButton = false
    
    var body: some View {
        HStack {
            VStack {
                Divider()
            }
            
            if !browserSpace.tabs.isEmpty && isHovering {
                Button("Clear") {
                    browserSpace.clear(using: modelContext, tabUndoManager: browserWindow.tabUndoManager)
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
