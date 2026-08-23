//
//  TabDragManager.swift
//  Browser
//

import SwiftUI

let sidebarDragSpace = "sidebarDragSpace"

struct TabFrameInfo: Equatable {
    let id: UUID
    let tier: TabPinState
    let frame: CGRect
}

struct TierZoneInfo: Equatable {
    let tier: TabPinState
    let frame: CGRect
}

struct TabFramePreferenceKey: PreferenceKey {
    static var defaultValue: [TabFrameInfo] = []
    static func reduce(value: inout [TabFrameInfo], nextValue: () -> [TabFrameInfo]) {
        value.append(contentsOf: nextValue())
    }
}

struct TierZonePreferenceKey: PreferenceKey {
    static var defaultValue: [TierZoneInfo] = []
    static func reduce(value: inout [TierZoneInfo], nextValue: () -> [TierZoneInfo]) {
        value.append(contentsOf: nextValue())
    }
}

@Observable
final class TabDragManager {

    private(set) var draggingTab: BrowserTab?
    private(set) var pointer: CGPoint = .zero
    private(set) var dropTier: TabPinState?
    private(set) var dropBeforeTabID: UUID?
    private(set) var sourceWidth: CGFloat = 200

    var essentialTileWidth: CGFloat? {
        tabFrames.first(where: { $0.tier == .favorite })?.frame.width
    }

    var tabFrames: [TabFrameInfo] = []
    var tierZones: [TierZoneInfo] = []

    func isDragging(_ tab: BrowserTab) -> Bool {
        draggingTab?.id == tab.id
    }

    var isActive: Bool { draggingTab != nil }

    var shouldRevealEmptyEssentials: Bool {
        guard isActive else { return false }
        let tops = tierZones.filter { $0.tier != .favorite }.map { $0.frame.minY }
        guard let topTierMinY = tops.min() else { return false }
        return pointer.y < topTierMinY
    }

    func begin(_ tab: BrowserTab, at pointer: CGPoint) {
        draggingTab = tab
        self.pointer = pointer
        if let frame = tabFrames.first(where: { $0.id == tab.id })?.frame {
            sourceWidth = frame.width
        }
        recompute()
    }

    func update(to pointer: CGPoint) {
        guard draggingTab != nil else { return }
        self.pointer = pointer
        recompute()
    }

    func end() -> (tab: BrowserTab, tier: TabPinState, beforeID: UUID?)? {
        defer { reset() }
        guard let tab = draggingTab, let tier = dropTier else { return nil }
        return (tab, tier, dropBeforeTabID)
    }

    func reset() {
        draggingTab = nil
        dropTier = nil
        dropBeforeTabID = nil
    }

    private func recompute() {
        guard let source = draggingTab else { return }

        let tier = tier(for: pointer) ?? source.pinState
        dropTier = tier

        let tierTabs = tabFrames
            .filter { $0.tier == tier && $0.id != source.id }

        dropBeforeTabID = tier == .favorite
            ? gridInsertionTarget(in: tierTabs)
            : listInsertionTarget(in: tierTabs)
    }

    private func tier(for point: CGPoint) -> TabPinState? {
        guard !tierZones.isEmpty else { return nil }

        if let containing = tierZones.first(where: { $0.frame.contains(point) }) {
            return containing.tier
        }

        return tierZones.min { verticalDistance(from: point, to: $0.frame) < verticalDistance(from: point, to: $1.frame) }?.tier
    }

    private func verticalDistance(from point: CGPoint, to rect: CGRect) -> CGFloat {
        if point.y < rect.minY { return rect.minY - point.y }
        if point.y > rect.maxY { return point.y - rect.maxY }
        return 0
    }

    private func listInsertionTarget(in tabs: [TabFrameInfo]) -> UUID? {
        for info in tabs where pointer.y < info.frame.midY {
            return info.id
        }
        return nil
    }

    private func gridInsertionTarget(in tabs: [TabFrameInfo]) -> UUID? {
        for info in tabs {
            if pointer.y < info.frame.minY { return info.id }
            if pointer.y <= info.frame.maxY && pointer.x < info.frame.midX { return info.id }
        }
        return nil
    }
}
