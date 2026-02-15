//
//  SidebarURLToolbar.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/24/25.
//

import SwiftUI

struct SidebarURLToolbar: View {
    
    @Environment(BrowserWindow.self) var browserWindow
    @Environment(\.colorScheme) var colorScheme
    
    var currentTab: BrowserTab? {
        browserWindow.currentSpace?.currentTab
    }
    
    var foregroundColor: Color {
        browserWindow.currentSpace?.textColor(in: colorScheme) ?? .primary
    }
    
    @State var hoveringURL = false
    
    var body: some View {
        HStack {
            SidebarToolbarButton("arrow.left", disabled: currentTab == nil || currentTab?.canGoBack == false, action: browserWindow.backButtonAction)
            
            SidebarToolbarButton("arrow.right", disabled: currentTab == nil || currentTab?.canGoForward == false, action: browserWindow.forwardButtonAction)
            
            SidebarToolbarButton("arrow.trianglehead.clockwise", disabled: currentTab == nil, action: browserWindow.refreshButtonAction)
            
            Spacer()
            
            if let url = currentTab?.url {
                Text("\(url.cleanHost)\(Preferences.showFullURLOnToolbar ? Text("/" + url.route).foregroundStyle(foregroundColor.opacity(0.6)) : Text(""))")
                    .lineLimit(1)
                    .foregroundStyle(foregroundColor.opacity(0.8))
                    .padding(3)
                    .background(.white.opacity(hoveringURL ? 0.3 : 0))
                    .clipShape(.rect(cornerRadius: 6))
                    .onHover { hoveringURL = $0 }
                    .onTapGesture {
                        browserWindow.searchOpenLocation = .fromURLBar
                    }
            }

            Spacer()
            
            SidebarToolbarButton("link", disabled: currentTab == nil, action: browserWindow.copyURLToClipboard)
                .padding(.trailing)
        }
        .background(.ultraThinMaterial)
    }
}
