//
//  SidebarDragPreview.swift
//  Browser
//

import SwiftUI

struct SidebarDragPreview: View {

    @Environment(\.colorScheme) var colorScheme

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
                    if manager.draggingTab == nil {
                        manager.begin(tab, at: value.location)
                    }
                    manager.update(to: value.location)
                }
                .onEnded { _ in
                    if let result = manager.end() {
                        withAnimation(.browserDefault) {
                            browserSpace.commitDrop(result.tab, tier: result.tier, beforeID: result.beforeID)
                        }
                    }
                }
        )
    }
}

extension View {
    func reportTabFrame(id: UUID, tier: TabPinState) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: TabFramePreferenceKey.self,
                    value: [TabFrameInfo(id: id, tier: tier, frame: geo.frame(in: .named(sidebarDragSpace)))]
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
}
