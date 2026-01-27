//
//  SidebarTabList.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/30/25.
//

import SwiftUI

/// List of tabs of a space in the sidebar
struct SidebarTabList: View {
    
    @Environment(SidebarModel.self) var sidebarModel
    
    @Bindable var browserSpace: BrowserSpace
    var tabs: [BrowserTab]
    
    @State var draggingTab: BrowserTab?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(tabs) { browserTab in
                SidebarTab(browserSpace: browserSpace, browserTab: browserTab)
                    .draggable(browserSpace.id.uuidString) {
                       SidebarTab(browserSpace: browserSpace, browserTab: browserTab)
                            .opacity(0.65)
                    }
                // Using simultaneousGesture because onAppear is causing unexpected behavior
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { _ in
                                if draggingTab == nil {
                                    draggingTab = browserTab
                                }
                            }
                    )
                    .dropDestination(for: String.self) { items, location in
                        withAnimation(.browserDefault) {
                            draggingTab = nil
                            
                        }
                        return false
                    } isTargeted: { status in
                        if status {
//                            moveTab(to: browserTab)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.leading, .sidebarPadding)
        .padding(.trailing, Preferences.shared.sidebarPosition == .leading && sidebarModel.sidebarCollapsed ? 5 : 0)
    }
    
//    func moveTab(to destination: BrowserTab) {
//        if let draggingTab, draggingTab != destination {
//            if let sourceIndex = tabs.firstIndex(of: draggingTab),
//               let destinationIndex = tabs.firstIndex(of: destination) {
//                withAnimation(.browserDefault) {
//                    let sourceItems = tabs.remove(at: sourceIndex)
//                    tabs.insert(sourceItems, at: destinationIndex)
//                }
//            }
//        }
//    }
}
