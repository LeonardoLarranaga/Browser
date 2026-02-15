//
//  BrowserSpace.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/28/25.
//

import SwiftUI
import SwiftData

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
        loadedTabs.removeAll(where: { $0.id == tab.id })
    }

    /// Closes (deletes) a tab from the space and selects the next tab
    func closeTab(_ tab: BrowserTab, using modelContext: ModelContext, tabUndoManager: TabUndoManager?) {
        guard let tabUndoManager else { return }
        let command = CloseTabCommand(tab: tab, space: self, modelContext: modelContext)
        tabUndoManager.execute(command)
    }

    func clear(using modelContext: ModelContext, deleteCurrent: Bool, tabUndoManager: TabUndoManager?) {
        guard let tabUndoManager, !normalTabs.isEmpty else { return }

        let deletedTabs = normalTabs.filter {
            deleteCurrent ? true : $0 != currentTab
        }

        let command = CloseMultipleTabsCommand(
            tabs: deletedTabs,
            space: self,
            modelContext: modelContext,
            commandType: .clear
        )
        tabUndoManager.execute(command)
    }

    /// Opens a new tab in the space
    /// - Parameters:
    ///  - browserTab: The tab to open
    ///  - modelContext: The model context to save the changes
    func openNewTab(_ browserTab: BrowserTab, using modelContext: ModelContext, select: Bool = true) {
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

    func pinTab(_ browserTab: BrowserTab, using modelContext: ModelContext) {
        do {
            browserTab.pinState = .pinned
            try modelContext.save()
        } catch {
            print("Error pinning tab: \(error)")
        }
    }

    func unpinTab(_ browserTab: BrowserTab, using modelContext: ModelContext) {
        do {
            browserTab.pinState = .normal
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
