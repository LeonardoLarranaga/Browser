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
    let folderID: UUID?
}

struct TierZoneInfo: Equatable {
    let tier: TabPinState
    let frame: CGRect
}

struct FolderFrameInfo: Equatable {
    let id: UUID
    let depth: Int
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

struct FolderFramePreferenceKey: PreferenceKey {
    static var defaultValue: [FolderFrameInfo] = []
    static func reduce(value: inout [FolderFrameInfo], nextValue: () -> [FolderFrameInfo]) {
        value.append(contentsOf: nextValue())
    }
}

enum SidebarDragResult {
    case tab(BrowserTab, tier: TabPinState, beforeID: UUID?, folderID: UUID?)
    case folder(BrowserFolder, destinationFolderID: UUID?)
}

@Observable
final class TabDragManager {

    private(set) var draggingTab: BrowserTab?
    private(set) var draggingFolder: BrowserFolder?
    private(set) var pointer: CGPoint = .zero
    private(set) var dropTier: TabPinState?
    private(set) var dropBeforeTabID: UUID?
    private(set) var dropFolderID: UUID?
    private(set) var sourceWidth: CGFloat = 200

    var essentialTileWidth: CGFloat? {
        tabFrames.first(where: { $0.tier == .favorite })?.frame.width
    }

    var tabFrames: [TabFrameInfo] = []
    var tierZones: [TierZoneInfo] = []
    var folderFrames: [FolderFrameInfo] = []

    func isDragging(_ tab: BrowserTab) -> Bool {
        draggingTab?.id == tab.id
    }

    func isDragging(_ folder: BrowserFolder) -> Bool {
        draggingFolder?.id == folder.id
    }

    var isActive: Bool { draggingTab != nil || draggingFolder != nil }

    var shouldRevealEmptyEssentials: Bool {
        guard draggingTab != nil else { return false }
        let tops = tierZones.filter { $0.tier != .favorite }.map { $0.frame.minY }
        guard let topTierMinY = tops.min() else { return false }
        return pointer.y < topTierMinY
    }

    func begin(_ tab: BrowserTab, at pointer: CGPoint) {
        draggingTab = tab
        draggingFolder = nil
        self.pointer = pointer
        if let frame = tabFrames.first(where: { $0.id == tab.id })?.frame {
            sourceWidth = frame.width
        }
        recompute()
    }

    func begin(_ folder: BrowserFolder, at pointer: CGPoint) {
        draggingTab = nil
        draggingFolder = folder
        self.pointer = pointer
        if let frame = folderFrames.first(where: { $0.id == folder.id })?.frame {
            sourceWidth = frame.width
        }
        recompute()
    }

    func update(to pointer: CGPoint) {
        guard isActive else { return }
        self.pointer = pointer
        recompute()
    }

    func end() -> SidebarDragResult? {
        defer { reset() }

        if let tab = draggingTab, let tier = dropTier {
            return .tab(tab, tier: tier, beforeID: dropBeforeTabID, folderID: dropFolderID)
        }

        if let folder = draggingFolder {
            return .folder(folder, destinationFolderID: dropFolderID)
        }

        return nil
    }

    func reset() {
        draggingTab = nil
        draggingFolder = nil
        dropTier = nil
        dropBeforeTabID = nil
        dropFolderID = nil
    }

    private func recompute() {
        dropFolderID = folderTargetID()

        guard let source = draggingTab else {
            dropTier = nil
            dropBeforeTabID = nil
            return
        }

        let tier = dropFolderID == nil ? (tier(for: pointer) ?? source.pinState) : .pinned
        dropTier = tier

        let tierTabs = tabFrames
            .filter {
                $0.tier == tier
                    && $0.folderID == dropFolderID
                    && $0.id != source.id
            }

        dropBeforeTabID = tier == .favorite
            ? gridInsertionTarget(in: tierTabs)
            : listInsertionTarget(in: tierTabs)
    }

    private func folderTargetID() -> UUID? {
        let sourceFolderID = draggingFolder?.id

        return folderFrames
            .filter { info in
                info.frame.contains(pointer) && info.id != sourceFolderID
            }
            .max { lhs, rhs in
                lhs.depth < rhs.depth
            }?.id
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
