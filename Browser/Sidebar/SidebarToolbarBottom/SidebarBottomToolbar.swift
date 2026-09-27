//
//  SidebarBottomToolbar.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI

/// Bottom toolbar for the sidebar
struct SidebarBottomToolbar: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(SidebarModel.self) private var sidebarModel
    @Environment(BrowserWindow.self) private var browserWindow
    @State private var downloadAnimationResetDate: Date?
    
    let browserSpaces: [BrowserSpace]
    let createSpace: () -> Void
    
    private var foregroundColor: Color {
        browserWindow.currentSpace?.textColor(in: colorScheme) ?? .primary
    }
    
    var body: some View {
        HStack {
            Button("Downloads", systemImage: "circle") {
                if !sidebarModel.showDownloads {
                    DownloadManager.shared.refreshDownloads()
                }

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
                Button("Open Downloads Folder", action: DownloadManager.shared.openDownloadsFolder)
            }
            .overlay {
                Image(systemName: "arrow.down")
                    .resizable()
                    .fontWeight(.bold)
                    .scaledToFit()
                    .foregroundStyle(foregroundColor)
                    .frame(width: sidebarModel.isAnimatingDownloads ? 22 : 7)
                    .offset(y: sidebarModel.isAnimatingDownloads ? -40 : 0)
                    .rotationEffect(.degrees(sidebarModel.isAnimatingDownloads ? 12 : 0))
                    .animation(.interpolatingSpring(stiffness: 220, damping: 12), value: sidebarModel.isAnimatingDownloads)
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
        .onChange(of: DownloadManager.shared.lastStartedDownloadID) {
            let resetDate = Date().addingTimeInterval(0.75)
            downloadAnimationResetDate = resetDate
            sidebarModel.isAnimatingDownloads = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                if downloadAnimationResetDate == resetDate {
                    sidebarModel.isAnimatingDownloads = false
                }
            }
        }
    }
}

#Preview {
    SidebarBottomToolbar(browserSpaces: [], createSpace: {})
        .environment(BrowserWindow())
        .environment(SidebarModel())
}
