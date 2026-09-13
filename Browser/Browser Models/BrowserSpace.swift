//
//  BrowserSpace.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/28/25.
//

import SwiftData
import SwiftUI

/// `BrowserSpace` represents a space in the browser that contains tabs.
@Model
final class BrowserSpace: Identifiable {
    
    @Attribute(.unique) var id: UUID
    var name: String
    var systemImage: String
    var order: Int
    var colors: [String]
    var grainOpacity: Double
    var colorOpacity: Double
    var colorScheme: String
    
    @Relationship(deleteRule: .cascade) private var _tabs: [BrowserTab]
    @Relationship var profile: BrowserProfile?
    
    var tabs: [BrowserTab] {
        get {
            _tabs.sorted()
        } set {
            newValue.enumerated().forEach { index, tab in
                tab.order = index
            }
            _tabs = newValue
        }
    }
    
    var normalTabs: [BrowserTab] {
        tabs.filter { $0.pinState == .normal }
    }

    var pinnedTabs: [BrowserTab] {
        tabs.filter { $0.pinState == .pinned }
    }

    var favoriteTabs: [BrowserTab] {
        tabs.filter { $0.pinState == .favorite }
    }

    func tabs(for pinState: TabPinState) -> [BrowserTab] {
        switch pinState {
        case .normal: normalTabs
        case .pinned: pinnedTabs
        case .favorite: favoriteTabs
        }
    }
    
    var pinnedTabsVisible: Bool = true
    
    @Attribute(.ephemeral) var currentTab: BrowserTab? = nil
    @Transient var loadedTabs: [BrowserTab] = []
    @Attribute(.ephemeral) var isEditing: Bool = false
    
    init(name: String, systemImage: String, order: Int, colors: [Color], grainOpacity: Double = 0.0, colorOpacity: Double = 1.0, colorScheme: String) {
        self.id = UUID()
        self.name = name
        self.systemImage = systemImage
        self.colors = colors.map { $0.hexString() }
        self.grainOpacity = grainOpacity
        self.colorOpacity = colorOpacity
        self.order = order
        self.colorScheme = colorScheme
        self.currentTab = nil
        self._tabs = []
    }
    
    /// Returns the text color of the space based on the colors of the space and the color scheme
    func textColor(in colorScheme: ColorScheme) -> Color {
        // If the space has no colors, return the primary color (black on light mode, white on dark mode)
        if colors.isEmpty { return .primary }
        
        // Return white or black depending on the luminance of the first color
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        NSColor(getColors[0]).getRed(&r, green: &g, blue: &b, alpha: &a)
        a = colorOpacity
        
        // Convert the color to sRGB
        func sRGB(_ c: CGFloat) -> CGFloat {
            c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        
        r = sRGB(r)
        g = sRGB(g)
        b = sRGB(b)
        
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        let backgroundLuminance: CGFloat = colorScheme == .light ? 1 : 0
        
        let finalLuminance = sqrt((1 - a) * backgroundLuminance + a * luminance)
        
        return finalLuminance > 0.3 ? .black : .white
    }
    
    /// This is a computed property that returns the colors of the space as `Color` objects
    @Transient var getColors: [Color] {
        colors.map { Color(hex: $0) ?? .clear }
    }
    
    /// Removes a tab from the ZStack of WebViews of the space
    func unloadTab(_ tab: BrowserTab) {
        guard let index = loadedTabs.firstIndex(of: tab) else { return }
        currentTab = loadedTabs[safe: index - 1] ?? loadedTabs[safe: index + 1]
        loadedTabs.remove(at: index)
        loadedTabs.removeAll(where: { $0.id == tab.id })
    }
    
    /// Closes (deletes) a tab from the space and selects the next tab
    func closeTab(_ tab: BrowserTab, tabUndoManager: TabUndoManager?) {
        guard let tabUndoManager else { return }
        let command = CloseTabCommand(tab: tab, space: self)
        tabUndoManager.execute(command)
    }
    
    func clear(deleteCurrent: Bool, tabUndoManager: TabUndoManager?) {
        guard let tabUndoManager, !normalTabs.isEmpty else { return }
        
        let deletedTabs = normalTabs.filter {
            deleteCurrent ? true : $0 != currentTab
        }
        
        let command = CloseMultipleTabsCommand(
            tabs: deletedTabs,
            space: self,
            commandType: .clear
        )
        tabUndoManager.execute(command)
    }
    
    /// Opens a new tab in the space
    /// - Parameters:
    ///  - browserTab: The tab to open
    func openNewTab(_ browserTab: BrowserTab, select: Bool = true) {
        guard let modelContext else { return }
        do {
            if browserTab.order > tabs.count {
                tabs.append(browserTab)
            } else {
                tabs.insert(browserTab, at: browserTab.order)
            }
            try modelContext.save()
            if select {
                currentTab = browserTab
            } else {
                loadedTabs.append(browserTab)
            }
        } catch {
            print("Error opening new tab: \(error)")
        }
    }
    
    func pinTab(_ browserTab: BrowserTab) {
        moveTab(browserTab, to: .pinned)
    }

    func unpinTab(_ browserTab: BrowserTab) {
        moveTab(browserTab, to: .normal)
    }

    func favoriteTab(_ browserTab: BrowserTab) {
        moveTab(browserTab, to: .favorite)
    }

    func unfavoriteTab(_ browserTab: BrowserTab) {
        moveTab(browserTab, to: .normal)
    }

    private func moveTab(_ browserTab: BrowserTab, to pinState: TabPinState) {
        guard browserTab.pinState != pinState else { return }

        do {
            browserTab.pinState = pinState
            updatePinnedURL(browserTab, for: pinState)

            var allTabs = tabs
            guard let sourceIndex = allTabs.firstIndex(where: { $0.id == browserTab.id }) else { return }
            allTabs.remove(at: sourceIndex)

            let insertionIndex: Int
            if let lastOfTier = allTabs.lastIndex(where: { $0.pinState == pinState }) {
                insertionIndex = lastOfTier + 1
            } else {
                insertionIndex = defaultInsertionIndex(for: pinState, in: allTabs)
            }
            allTabs.insert(browserTab, at: insertionIndex)

            tabs = allTabs
            try modelContext?.save()
        } catch {
            print("Error moving tab: \(error)")
        }
    }

    func commitDrop(_ sourceTab: BrowserTab, tier: TabPinState, beforeID: UUID?) {
        do {
            sourceTab.pinState = tier
            updatePinnedURL(sourceTab, for: tier)

            var allTabs = tabs
            guard let sourceIndex = allTabs.firstIndex(where: { $0.id == sourceTab.id }) else { return }
            allTabs.remove(at: sourceIndex)

            let insertionIndex: Int
            if let beforeID, let idx = allTabs.firstIndex(where: { $0.id == beforeID }) {
                insertionIndex = idx
            } else if let lastOfTier = allTabs.lastIndex(where: { $0.pinState == tier }) {
                insertionIndex = lastOfTier + 1
            } else {
                insertionIndex = defaultInsertionIndex(for: tier, in: allTabs)
            }

            allTabs.insert(sourceTab, at: min(max(insertionIndex, 0), allTabs.count))

            tabs = allTabs
            try modelContext?.save()
        } catch {
            print("Error committing tab drop: \(error)")
        }
    }

    private func updatePinnedURL(_ tab: BrowserTab, for pinState: TabPinState) {
        switch pinState {
        case .pinned, .favorite:
            if tab.pinnedURL == nil {
                tab.pinnedURL = tab.url
            }
        case .normal:
            tab.pinnedURL = nil
        }
    }

    private func defaultInsertionIndex(for pinState: TabPinState, in tabs: [BrowserTab]) -> Int {
        switch pinState {
        case .favorite:
            return 0
        case .pinned:
            if let lastFavorite = tabs.lastIndex(where: { $0.pinState == .favorite }) {
                return lastFavorite + 1
            }
            return 0
        case .normal:
            return tabs.count
        }
    }
}
