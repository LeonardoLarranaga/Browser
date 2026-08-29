//
//  SidebarSpaceIcon.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI

/// Icon for a browser space in the sidebar space list
struct SidebarSpaceIcon: View {

    @Environment(\.modelContext) var modelContext
    @Environment(BrowserWindow.self) var browserWindow

    let browserSpaces: [BrowserSpace]
    @Bindable var browserSpace: BrowserSpace

    @State private var isHovering = false

    private var isActive: Bool { browserWindow.currentSpace == browserSpace }
    private var tint: Color { browserSpace.getColors.first ?? .primary }

    var body: some View {
        Image(systemName: browserSpace.systemImage)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(isActive ? AnyShapeStyle(tint) : AnyShapeStyle(.primary))
            .frame(width: 26, height: 24)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(.primary.opacity(isActive ? 0.12 : (isHovering ? 0.06 : 0)))
            }
            .opacity(isActive ? 1 : (isHovering ? 0.8 : 0.45))
            .contentShape(.rect)
            .onTapGesture {
                withAnimation(.browserDefault) {
                    browserWindow.goToSpace(browserSpace)
                }
            }
            .onHover { hovering in
                withAnimation(.snappy(duration: 0.15)) { isHovering = hovering }
            }
            .sidebarSpaceContextMenu(browserSpaces: browserSpaces, browserSpace: browserSpace)
    }
}
