//
//  FolderContextMenu.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 2/3/26.
//

import SwiftUI

struct FolderContextMenu: ViewModifier {

    @Environment(BrowserSpace.self) private var browserSpace

    let folder: BrowserFolder
    @Binding var isEditingTitle: Bool

    @State private var showDeleteAlert = false

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button("New Nested Folder") {
                    withAnimation(.browserDefault) {
                        browserSpace.createFolder(named: "New Folder", in: folder)
                    }
                }

                Button("Rename Folder") {
                    isEditingTitle = true
                }

                Divider()

                Button("Delete Folder", role: .destructive) {
                    showDeleteAlert = true
                }
            }
            .alert("Delete \"\(folder.name)\"", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    withAnimation(.browserDefault) {
                        browserSpace.deleteFolder(folder)
                    }
                }
            } message: {
                Text("All tabs and nested folders inside this folder will be deleted.")
            }
    }
}

extension View {
    func folderContextMenu(folder: BrowserFolder, isEditingTitle: Binding<Bool>) -> some View {
        modifier(FolderContextMenu(folder: folder, isEditingTitle: isEditingTitle))
    }
}
