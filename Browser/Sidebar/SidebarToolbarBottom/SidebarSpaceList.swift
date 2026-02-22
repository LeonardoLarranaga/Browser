//
//  SidebarSpaceList.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI

/// List of spaces in the sidebar
struct SidebarSpaceList: View {
    
    @Environment(BrowserWindow.self) var browserWindow
    
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
            browserWindow.viewScrollState
        }, set: { _ in }), anchor: .center)
        .scrollIndicators(.hidden)
        .frame(height: 25)
    }
}

#Preview {
    SidebarSpaceList(browserSpaces: [])
}
