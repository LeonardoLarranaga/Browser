//
//  SidebarDragPreview.swift
//  Browser
//

import SwiftUI

struct SidebarDragPreview: View {

    @Environment(\.colorScheme) private var colorScheme

    let tab: BrowserTab
    let tier: TabPinState
    let rowWidth: CGFloat
    let tileWidth: CGFloat

    private var isTile: Bool { tier == .favorite }

    var body: some View {
        HStack(spacing: isTile ? 0 : 6) {
            favicon(size: isTile ? 22 : 16)
                .frame(maxWidth: isTile ? .infinity : nil)

            Text(tab.displayTitle)
                .lineLimit(1)
                .truncationMode(.tail)
                .opacity(isTile ? 0 : 1)
                .frame(maxWidth: isTile ? 0 : nil)

            if !isTile { Spacer(minLength: 0) }
        }
        .padding(.horizontal, isTile ? 0 : 8)
        .frame(width: isTile ? max(tileWidth, 44) : max(rowWidth, 80), height: isTile ? 40 : 34)
        .background(cardFill)
        .clipShape(.rect(cornerRadius: isTile ? 10 : 12))
        .overlay {
            RoundedRectangle(cornerRadius: isTile ? 10 : 12)
                .strokeBorder(isTile ? tab.iconColor : .white.opacity(colorScheme == .dark ? 0.12 : 0.6),
                              lineWidth: isTile ? 1.5 : 0.5)
        }
        .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
        .scaleEffect(1.03)
        .animation(.snappy(duration: 0.2, extraBounce: 0.05), value: isTile)
        .animation(.snappy(duration: 0.2), value: tileWidth)
    }

    private var cardFill: Color {
        .white.opacity(colorScheme == .dark ? 0.28 : 0.95)
    }

    @ViewBuilder
    private func favicon(size: CGFloat) -> some View {
        Group {
            if let data = tab.favicon, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray))
            }
        }
        .frame(width: size, height: size)
    }
}

struct SidebarFolderDragPreview: View {

    @Environment(\.colorScheme) private var colorScheme

    let folder: BrowserFolder
    let rowWidth: CGFloat

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: folder.isEmpty ? "folder" : "folder.fill")
                .font(.caption)

            Text(folder.name)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(width: max(rowWidth, 80), height: 30)
        .background(.white.opacity(colorScheme == .dark ? 0.28 : 0.95))
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.white.opacity(colorScheme == .dark ? 0.12 : 0.6), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
        .scaleEffect(1.03)
    }
}

struct SidebarEmptyDropTarget: View {

    let title: String
    let rowWidth: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(.primary.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4]))
            .frame(width: max(rowWidth, 80), height: 40)
            .overlay {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
    }
}

extension View {
    func tabDragGesture(
        tab: BrowserTab,
        tier: TabPinState,
        manager: TabDragManager,
        browserSpace: BrowserSpace
    ) -> some View {
        simultaneousGesture(
            DragGesture(minimumDistance: 6, coordinateSpace: .named(sidebarDragSpace))
                .onChanged { value in
                    if manager.draggingTab == nil && manager.draggingFolder == nil {
                        manager.begin(tab, at: value.location)
                    }
                    manager.update(to: value.location)
                }
                .onEnded { _ in
                    if let result = manager.end() {
                        withAnimation(.browserDefault) {
                            applySidebarDragResult(result, in: browserSpace)
                        }
                    }
                }
        )
    }

    func folderDragGesture(
        folder: BrowserFolder,
        manager: TabDragManager,
        browserSpace: BrowserSpace
    ) -> some View {
        simultaneousGesture(
            DragGesture(minimumDistance: 6, coordinateSpace: .named(sidebarDragSpace))
                .onChanged { value in
                    if manager.draggingFolder == nil && manager.draggingTab == nil {
                        manager.begin(folder, at: value.location)
                    }
                    manager.update(to: value.location)
                }
                .onEnded { _ in
                    if let result = manager.end() {
                        withAnimation(.browserDefault) {
                            applySidebarDragResult(result, in: browserSpace)
                        }
                    }
                }
        )
    }
}

private func applySidebarDragResult(_ result: SidebarDragResult, in browserSpace: BrowserSpace) {
    switch result {
    case let .tab(tab, tier, beforeID, folderID):
        if let folderID,
           let folder = browserSpace.allFolders.first(where: { $0.id == folderID }) {
            browserSpace.moveTab(tab, to: folder, beforeID: beforeID)
        } else {
            browserSpace.commitDrop(tab, tier: tier, beforeID: beforeID)
        }

    case let .folder(folder, destinationFolderID):
        let destination = destinationFolderID.flatMap { id in
            browserSpace.allFolders.first(where: { $0.id == id })
        }
        browserSpace.moveFolder(folder, to: destination)
    }
}

extension View {
    func reportTabFrame(id: UUID, tier: TabPinState, folderID: UUID? = nil) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: TabFramePreferenceKey.self,
                    value: [TabFrameInfo(
                        id: id,
                        tier: tier,
                        frame: geo.frame(in: .named(sidebarDragSpace)),
                        folderID: folderID
                    )]
                )
            }
        )
    }

    func reportTierZone(_ tier: TabPinState) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: TierZonePreferenceKey.self,
                    value: [TierZoneInfo(tier: tier, frame: geo.frame(in: .named(sidebarDragSpace)))]
                )
            }
        )
    }

    func reportFolderFrame(id: UUID, depth: Int) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: FolderFramePreferenceKey.self,
                    value: [FolderFrameInfo(
                        id: id,
                        depth: depth,
                        frame: geo.frame(in: .named(sidebarDragSpace))
                    )]
                )
            }
        )
    }
}
