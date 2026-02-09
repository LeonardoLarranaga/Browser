//
//  Preferences.shared.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import SwiftUI
import ObservableDefaults

/// User preferences consistent throughout app sessions
@ObservableDefaults
class Preferences {
    static let shared = Preferences()

    enum SidebarPosition: String {
        case leading, trailing
    }

    var disableAnimations = false
    var sidebarPosition = SidebarPosition.leading {
        didSet { changeTrafficLightsTrailingAppearance() }
    }
    var showWindowControlsOnTrailingSidebar = true {
        didSet { changeTrafficLightsTrailingAppearance() }
    }
    var reverseColorsOnTrailingSidebar = true {
        didSet { changeTrafficLightsTrailingAppearance() }
    }

    enum LoadingIndicatorPosition: Int, CaseIterable {
        case onURL, onTab, onWebView

        var localizedStringKey: LocalizedStringKey {
            switch self {
            case .onURL: "URL Bar"
            case .onTab: "Sidebar Tab"
            case .onWebView: "Above Web Content"
            }
        }

        var systemImage: String {
            switch self {
            case .onURL: "link"
            case .onTab: "sidebar.squares.left"
            case .onWebView: "arrow.trianglehead.rectanglepath"
            }
        }
    }

    var loadingIndicatorPosition = LoadingIndicatorPosition.onURL

    enum URLBarPosition: Int {
        case onSidebar
        case onToolbar
    }
    var urlBarPosition = URLBarPosition.onSidebar
    var showFullURLOnToolbar = false

    // Web appearance preferences
    var roundedCorners = true
    var enablePadding = true
    var enableShadow = true
    var immersiveViewOnFullscreen = true

    // General preferences
    var clearSelectedTab = false
    var openPipOnTabChange = true
    var warnBeforeQuitting = true

    var automaticPageSuspension = true

    var customWebsiteSearchers = [
        BrowserCustomSearcher(website: "ChatGPT", queryURL: "https://chatgpt.com/?q=%s", hexColor: "#74AA9C"),
        BrowserCustomSearcher(website: "Claude AI", queryURL: "https://claude.ai/new?q=%s", hexColor: "#C7785A")
    ] {
        didSet { ensureValidDefaultWebsiteSearcherIdentifier() }
    }

    var showHoverURL = true

    private var downloadLocationBookmark: Data? = nil
    var downloadURL: URL? {
        get { getDownloadsFolder() }
        set {
            downloadLocationBookmark = try? newValue?.bookmarkData(options: .withSecurityScope)
        }
    }

    @Ignore
    var hasDownloadLocationSet: Bool {
        downloadLocationBookmark != nil
    }

    func changeTrafficLightsTrailingAppearance() {
        if sidebarPosition == .trailing {
            NSApp.setBrowserWindowControls(hidden: !showWindowControlsOnTrailingSidebar)
        }
    }

    private func getDownloadsFolder() -> URL? {
        guard let downloadLocationBookmark else { return nil }
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: downloadLocationBookmark,
            options: .withSecurityScope,
            bookmarkDataIsStale: &isStale) else {
            self.downloadLocationBookmark = nil
            return nil
        }

        if isStale {
            self.downloadLocationBookmark = nil
            return nil
        }

        return url
    }

    func removeDownloadLocation() {
        downloadLocationBookmark = nil
    }

    private var defaultSearchEngine = SearchEngine.google
    private var defaultCustomSearcherId: String? = nil

    /// The default website searcher, either a built-in search engine or a custom one
    @Ignore
    var defaultWebsiteSearcher: any WebsiteSearcher {
        get {
            if let customId = defaultCustomSearcherId,
               let customSearcher = customWebsiteSearchers.first(where: { $0.id == customId }) {
                return customSearcher
            }
            return defaultSearchEngine.searcher
        }
        set {
            if let customSearcher = newValue as? BrowserCustomSearcher {
                defaultCustomSearcherId = customSearcher.id
            } else if let engine = SearchEngine.allCases.first(where: { $0.searcher.equals(newValue) }) {
                defaultSearchEngine = engine
                defaultCustomSearcherId = nil
            }
        }
    }

    /// Ensures the default website searcher identifier is valid after custom searchers are modified
    func ensureValidDefaultWebsiteSearcherIdentifier() {
        if let customId = defaultCustomSearcherId,
           !customWebsiteSearchers.contains(where: { $0.id == customId }) {
            defaultCustomSearcherId = nil
        }
    }

    var shouldShowFeatureFlagSettings = false
    var configuredFeatureFlags: [String: Bool] = [:]

    var injectOpenPasswordsApp = true
    private var passwordAppBundleIdentifier = "com.apple.Passwords"
    @Ignore
    var selectedPasswordApp: URL? {
        get {
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: passwordAppBundleIdentifier)
        } set {
            if let newValue,
               let bundle = Bundle(url: newValue),
               let identifier = bundle.bundleIdentifier {
                passwordAppBundleIdentifier = identifier
            }
        }
    }
}
