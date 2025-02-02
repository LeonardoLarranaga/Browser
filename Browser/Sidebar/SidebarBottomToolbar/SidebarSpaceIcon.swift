//
//  SidebarSpaceIcon.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI

struct SidebarSpaceIcon: View {
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var browserWindowState: BrowserWindowState
    
    let browserSpaces: [BrowserSpace]
    @Bindable var browserSpace: BrowserSpace
    
    var body: some View {
        Button(browserSpace.name, systemImage: browserSpace.systemImage, action: setBrowserSpace)
        .buttonStyle(.sidebarHover())
        .foregroundStyle(browserWindowState.currentSpace == browserSpace ? .secondary : .tertiary)
        .sidebarSpaceContextMenu(browserSpaces: browserSpaces, browserSpace: browserSpace)
    }
    
    func setBrowserSpace() {
        withAnimation(.bouncy) {
            browserWindowState.currentSpace = browserSpace
            browserWindowState.viewScrollState = browserSpace.id
            browserWindowState.tabBarScrollState = browserSpace.id
        }
    }
}
