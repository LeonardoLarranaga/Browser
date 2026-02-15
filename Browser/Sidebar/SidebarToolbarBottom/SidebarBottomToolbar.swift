//
//  SidebarBottomToolbar.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI

/// Bottom toolbar for the sidebar
struct SidebarBottomToolbar: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(SidebarModel.self) var sidebarModel
    @Environment(BrowserWindow.self) var browserWindow
    
    let browserSpaces: [BrowserSpace]
    let createSpace: () -> Void
    
    var foregroundColor: Color {
        browserWindow.currentSpace?.textColor(in: colorScheme) ?? .primary
    }
        
    var body: some View {
        HStack {
            Button("Downloads", systemImage: "circle") {
                withAnimation(.browserDefault) {
                    sidebarModel.showDownloads.toggle()
                    if !sidebarModel.showDownloads {
                        sidebarModel.allowDownloadHover = false
                    }
                } completion: {
                    if sidebarModel.showDownloads {
                        sidebarModel.allowDownloadHover = true
                    }
                }
            }
            .buttonStyle(.sidebarHover(padding: 2, enabledColor: foregroundColor))
            .contextMenu {
                Button("Open Downloads Folder") {
                    if let downloadURL = Preferences.downloadURL {
                        guard downloadURL.startAccessingSecurityScopedResource() else { return }
                        NSWorkspace.shared.open(downloadURL)
                        downloadURL.stopAccessingSecurityScopedResource()
                    }
                }
            }
            .overlay {
                Image(systemName: "arrow.down")
                    .resizable()
                    .fontWeight(.bold)
                    .scaledToFit()
                    .foregroundStyle(foregroundColor)
                    .frame(width: sidebarModel.isAnimatingDownloads ? 125 : 7)
                    .offset(y: sidebarModel.isAnimatingDownloads ? -125 : 0)
                    .rotationEffect(.degrees(sidebarModel.isAnimatingDownloads ? 20 : 0))
                    .animation(.interpolatingSpring(stiffness: 200, damping: 6), value: sidebarModel.isAnimatingDownloads)
                    .onChange(of: sidebarModel.isAnimatingDownloads) { _, newValue in
                        // Reverse animation
                        if newValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                sidebarModel.isAnimatingDownloads.toggle()
                            }
                        }
                    }
                    .allowsHitTesting(false)
            }
            
            Spacer()
            
            if browserWindow.isMainBrowserWindow {
                SidebarSpaceList(browserSpaces: browserSpaces)
                
                Button("New Space", systemImage: "plus.circle.dashed", action: createSpace)
                    .buttonStyle(.sidebarHover(padding: 2))
            }
        }
        .padding(.leading, .sidebarPadding)
    }
}

#Preview {
    SidebarBottomToolbar(browserSpaces: [], createSpace: {})
}
