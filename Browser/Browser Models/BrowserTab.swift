//
//  BrowserTab.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/28/25.
//

import SwiftData

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

    @Relationship private var browserSpace: BrowserSpace

    init(title: String, favicon: Data? = nil, url: URL, order: Int = 0, browserSpace: BrowserSpace, contentType: TabContentType = .web) {
        self.id = UUID()
        self.title = title
        self.favicon = favicon
        self.url = url
        self.browserSpace = browserSpace
        self.order = order
        self.pinState = .normal
        self.contentType = contentType
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

    var displayTitle: String {
        customTitle ?? title
    }

    /// Updates the tab's favicon with the largest image found in the website
    /// - Parameter url: The URL of the website to find the favicon
    func updateFavicon(with url: URL) {
        Task {
            guard let host = url.host() else { return }
            let size = 256
            let url = URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=\(size)")!

            do {
                let favicon = try await URLSession.shared.data(from: url).0
                if NSImage(data: favicon) != nil {
                    self.favicon = favicon
                } else {
                    print("Invalid favicon image for: \(url.cleanHost)")
                }
            } catch {
                print("Error finding favicon: \(error.localizedDescription)")
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
