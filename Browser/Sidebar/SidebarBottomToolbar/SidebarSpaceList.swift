//
//  SidebarSpaceList.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI
import SwiftData

struct SidebarSpaceList: View {
    
    @EnvironmentObject var browserWindowState: BrowserWindowState
    
    let browserSpaces: [BrowserSpace]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(browserSpaces) { browserSpace in
                    SidebarSpaceIcon(browserSpace: browserSpace)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: .init(get: {
            browserWindowState.tabBarScrollState
        }, set: { _ in
        }), anchor: .center)
        .scrollIndicators(.hidden)
        .frame(height: 25)
    }
}

#Preview {
    SidebarSpaceList(browserSpaces: [])
}
