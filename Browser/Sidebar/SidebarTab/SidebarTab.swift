//
//  SidebarTab.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/30/25.
//

import SwiftUI

/// Tab in the sidebar
struct SidebarTab: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
    @Bindable var browserSpace: BrowserSpace
    @Bindable var browserTab: BrowserTab
    
    let dragging: Bool
    
    @State var backgroundColor: Color = .clear
    @State var isHoveringTab: Bool = false
    @State var isHoveringCloseButton: Bool = false
    @State var isPressed: Bool = false
        
    var body: some View {
        HStack {
            faviconImage
            
            if browserTab.webview?.hasActiveNowPlayingSession == true {
                Button("Mute Tab", systemImage: browserTab.webview?.mediaMutedState != .audioMuted ? "speaker.wave.2" : "speaker.slash") {
                    browserTab.webview?.toggleMute()
                }
                .buttonStyle(.sidebarHover())
                .browserTransition(.move(edge: .leading))
            }
            
            Text(browserTab.title)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            if isHoveringTab {
                closeTabButton
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 30)
        .padding(3)
        .background(dragging ? .white.opacity(0.1) : browserSpace.currentTab == browserTab ? browserSpace.textColor(in: colorScheme) == .black ? .white : .white.opacity(0.2) : isHoveringTab ? .white.opacity(0.1) : .clear)
        .clipShape(.rect(cornerRadius: 10))
        .onTapGesture(perform: selectTab)
        .onHover { hover in
            self.isHoveringTab = hover
        }
        .contextMenu {
            SidebarTabContextMenu(browserTab: browserTab)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
    }
    
    var faviconImage: some View {
        Group {
            if Preferences.shared.loadingIndicatorPosition == .onTab && browserTab.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else if let favicon = browserTab.favicon, let nsImage = NSImage(data: favicon) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray))
            }
        }
        .frame(width: 16, height: 16)
        .padding(.leading, 5)
    }
    
    var closeTabButton: some View {
        Button("Close Tab", systemImage: "xmark", action: closeTab)
            .font(.title3)
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
            .padding(4)
            .background(isHoveringCloseButton ? AnyShapeStyle(.ultraThinMaterial.opacity(0.4)) : AnyShapeStyle(.clear))
            .clipShape(.rect(cornerRadius: 6))
            .onHover { hover in
                self.isHoveringCloseButton = hover
            }
            .padding(.trailing, 5)
    }
    
    func selectTab() {
        browserSpace.currentTab = browserTab
        
        if !Preferences.shared.disableAnimations {
            // Scale bounce effect
            withAnimation(.bouncy(duration: 0.15, extraBounce: 0.0)) {
                isPressed = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
    }
    
    /// Close (delete) the tab
    func closeTab() {
        browserSpace.closeTab(browserTab, using: modelContext)
    }
}
