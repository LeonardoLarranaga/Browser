//
//  SidebarSpacesTabView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI
import SwiftData

/// Horizontal scrollable collection of spaces in the sidebar
struct SidebarSpacesTabView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(BrowserWindow.self) var browserWindow
    
    let browserSpaces: [BrowserSpace]
    
    @State var appeared = false
    @State var lastWidth = CGFloat.zero
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(browserSpaces) { browserSpace in
                    if browserSpace.name.isEmpty || browserSpace.isEditing {
                        SidebarSpaceCreateView(browserSpaces: browserSpaces, browserSpace: browserSpace)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                    } else {
                        SidebarSpaceView(browserSpaces: browserSpaces, browserSpace: browserSpace)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: .init(get: {
            browserWindow.viewScrollState
        }, set: { position in
            if browserWindow.viewScrollState != position {   
                browserWindow.goToSpace(browserSpaces.first { $0.id == position })
            }
        }), anchor: .center)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollDisabled(browserSpaces.count < 2)
        // Scroll to the selected space when the viewScrollState changes
        .onChange(of: browserWindow.viewScrollState) { oldValue, newValue in
            if let newValue {
                withAnimation(appeared ? .browserDefault : nil) {
                    browserWindow.viewScrollState = newValue
                    browserWindow.currentSpace = browserSpaces.first { $0.id == newValue }
                }
            }
            
            // Delete browserSpaces with empty names if they are not the one selected
            if let currentSpace = browserWindow.currentSpace, !currentSpace.name.isEmpty {
                for space in browserSpaces where space.name.isEmpty {
                    modelContext.delete(space)
                }
                
                // Update order of spaces
                for (index, space) in browserSpaces.enumerated() {
                    space.order = index
                }
                try? modelContext.save()
            }
        }
        // This is a workaround to prevent the animation when the view first appears
        .transaction { $0.disablesAnimations = !appeared }
        .task {
            if browserWindow.currentSpace == nil && browserWindow.isMainBrowserWindow {
                browserWindow.loadCurrentSpace(browserSpaces: browserSpaces)
            }
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.appeared = true
            }
        }
    }
}
