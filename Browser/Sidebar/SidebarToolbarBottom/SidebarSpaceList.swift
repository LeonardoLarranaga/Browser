//
//  SidebarSpaceList.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI
import SwiftData

/// List of spaces in the sidebar
struct SidebarSpaceList: View {
    
    @Environment(BrowserWindowState.self) var browserWindowState
    
    let browserSpaces: [BrowserSpace]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(browserSpaces) { browserSpace in
                    SidebarSpaceIcon(browserSpaces: browserSpaces, browserSpace: browserSpace)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: .init(get: {
            browserWindowState.viewScrollState
        }, set: { _ in }), anchor: .center)
        .scrollIndicators(.hidden)
        .frame(height: 25)
    }
}

#Preview {
    SidebarSpaceList(browserSpaces: [])
}
