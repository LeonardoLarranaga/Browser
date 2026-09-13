//
//  SidebarFolder.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 1/3/26.
//

import SwiftUI

/// A collapsible folder row in the sidebar that contains tabs and sub-folders.
struct SidebarFolder: View {

    @Environment(BrowserSpace.self) var space
    @Environment(TabDragManager.self) var dragManager

    @Bindable var folder: BrowserFolder

    @State var isEditingTitle = false
    @State var isHovering = false

    private var isDropTarget: Bool {
        dragManager.dropFolderID == folder.id && !dragManager.isDragging(folder)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .rotationEffect(.degrees(folder.isExpanded ? 90 : 0))
                    .animation(.browserDefault, value: folder.isExpanded)
                    .frame(width: 12)

                Image(systemName: folder.isEmpty ? "folder" : "folder.fill")
                    .font(.caption)

                SidebarTabTitle(
                    title: .init(get: { folder.name }, set: { folder.name = $0 ?? "" }),
                    displayTitle: folder.name,
                    isEditingTitle: $isEditingTitle
                )
            }
            .tabCellConfiguration(
                onTap: folder.toggleExpansion,
                onDoubleTap: { isEditingTitle = true },
                background: isDropTarget ? .white.opacity(0.35) :
                    isHovering ? .white.opacity(0.15) : Color.clear
            )
            .onHover { isHovering = $0 }
            .folderDragGesture(
                folder: folder,
                manager: dragManager,
                browserSpace: space
            )
            .folderContextMenu(folder: folder, isEditingTitle: $isEditingTitle)

            if folder.isExpanded {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(folder.subfolders) { subfolder in
                        SidebarFolder(folder: subfolder)
                    }

                    SidebarTabList(
                        tabs: folder.tabs,
                        pinState: .pinned,
                        folderID: folder.id,
                        usesSidebarPadding: false
                    )
                }
                .padding(.leading, 16)
                .browserTransition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .opacity(dragManager.isDragging(folder) ? 0 : 1)
        .reportFolderFrame(id: folder.id, depth: folder.depth)
    }
}
