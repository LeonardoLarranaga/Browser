//
//  BrowserTab.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/28/25.
//

import SwiftData
import SwiftUI
import WebKit

enum TabContentType: String, Codable {
    case web
    case history
}

enum TabPinState: String, Codable {
    case normal
    case pinned
    case favorite
}

/// A model that represents a tab in the browser
@Model
final class BrowserTab: Identifiable, Comparable {
    
    @Attribute(.unique) var id: UUID
    var title: String
    var favicon: Data?
    var url: URL
    var order: Int
    var pinState: TabPinState
    var contentType: TabContentType
    
    var customTitle: String? = nil

    var pinnedURL: URL? = nil

    @Relationship private var browserSpace: BrowserSpace
    var spaceId: UUID { browserSpace.id }

    @Relationship var folder: BrowserFolder?

    init(
        title: String,
        favicon: Data? = nil,
        url: URL,
        order: Int = 0,
        browserSpace: BrowserSpace,
        contentType: TabContentType = .web,
        restoredId: UUID? = nil,
        folder: BrowserFolder? = nil
    ) {
        self.id = restoredId ?? UUID()
        self.title = title
        self.favicon = favicon
        self.url = url
        self.browserSpace = browserSpace
        self.order = order
        self.pinState = .normal
        self.contentType = contentType
        self.folder = folder
    }
    
    @Transient weak var webview: MyWKWebView? = nil
    @Attribute(.ephemeral) var webviewErrorDescription: String? = nil
    @Attribute(.ephemeral) var webviewErrorCode: Int? = nil
    
    @Transient var findInPageManager: FindInPageManager? = nil
    
    @Attribute(.ephemeral) var canGoBack: Bool = false
    @Attribute(.ephemeral) var canGoForward: Bool = false
    @Attribute(.ephemeral) var estimatedProgress: Double = 0.0
    @Attribute(.ephemeral) var isLoading: Bool = false
    
    @Attribute(.ephemeral) var showFindUI = false

    @Attribute(.ephemeral) var pageZoomLevel: CGFloat = 1.0
    
    var displayTitle: String {
        customTitle ?? title
    }

    @Transient private var iconColorCache: (data: Data, color: Color)? = nil
    var iconColor: Color {
        guard let favicon else { return .accentColor }
        if let cache = iconColorCache, cache.data == favicon { return cache.color }
        guard let nsImage = NSImage(data: favicon),
              let average = nsImage.averageColor else { return .accentColor }
        let color = Color(nsColor: average)
        iconColorCache = (favicon, color)
        return color
    }
    
    var isLoaded: Bool {
        browserSpace.loadedTabs.contains(self)
    }
    
    /// Updates the tab's favicon with the largest image found in the website
    /// - Parameter url: The URL of the website to find the favicon
    func updateFavicon(with url: URL) {
        Task {
            guard let host = url.host() else { return }
            let size = 256
            let faviconURL = URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=\(size)")!
            
            do {
                let favicon = try await URLSession.shared.data(from: faviconURL).0
                // Google's favicon service returns a 16x16 image when it can't find a favicon,
                // so we check and add a placeholder
                guard let nsImage = NSImage(data: favicon), nsImage.size != CGSize(width: 16, height: 16) else {
                    self.favicon = await FaviconPlaceholder.nsImage(url: url)?.pngData
                    return
                }
                self.favicon = favicon
            } catch {
                self.favicon = await FaviconPlaceholder.nsImage(url: url)?.pngData
            }
        }
    }
    
    /// Reloads the tab
    func reload() {
        clearError()
        webview?.reload()
    }
    
    func clearError() {
        webviewErrorDescription = nil
        webviewErrorCode = nil
    }
    
    var canResetToPinnedURL: Bool {
        guard let pinnedURL else { return false }
        return pinnedURL != url
    }

    func resetToPinnedURL() {
        guard let pinnedURL else { return }

        let wasCurrent = browserSpace.currentTab == self
        url = pinnedURL
        pageZoomLevel = 1.0

        // Recreate the web view so the reset also clears its back/forward history.
        if wasCurrent {
            browserSpace.currentTab = nil
        }
        browserSpace.loadedTabs.removeAll { $0.id == id }

        guard wasCurrent else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.browserSpace.currentTab = self
        }
    }

    func replacePinnedURLWithCurrent() {
        pinnedURL = url
    }

    /// Copies the tab's URL to the clipboard
    func copyLink() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.absoluteString, forType: .string)
    }
    
    /// Activates the space that contains this tab in the given window state
    func activateSpace(in browserWindow: BrowserWindow) {
        browserWindow.goToSpace(browserSpace)
        browserSpace.currentTab = self
    }
    
    // MARK: - Comparable
    static func < (lhs: BrowserTab, rhs: BrowserTab) -> Bool {
        lhs.order < rhs.order
    }
}
