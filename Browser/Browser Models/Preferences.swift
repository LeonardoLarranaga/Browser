//
//  Preferences.shared.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import ObservableDefaults
import SwiftUI

/// Singleton instance of user preferences
let Preferences = AppPreferences.shared

typealias TranslatedLanguage = AppPreferences.TranslatedLanguage

/// User preferences consistent throughout app sessions
@ObservableDefaults
class AppPreferences {
    fileprivate static let shared = AppPreferences()

    enum SidebarPosition: String {
        case leading, trailing
    }

    var currentBrowserSpace: UUID? = nil

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

    // Web appearance preferences
    var roundedCorners = true
    var enablePadding = true
    var enableShadow = true
    var immersiveViewOnFullscreen = true

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
    var askForDownloadLocation = false
    private var rememberedDownloadFolderBookmarks: [Data] = []
    var downloadURL: URL? {
        get { getDownloadsFolder() }
        set {
            downloadLocationBookmark = try? newValue?.bookmarkData(options: .withSecurityScope)
            askForDownloadLocation = false
        }
    }

    @Ignore
    var isUsingDefaultDownloadLocation: Bool {
        !askForDownloadLocation && downloadLocationBookmark == nil
    }

    @Ignore
    var downloadLocationRequiresSecurityScope: Bool {
        guard !askForDownloadLocation, downloadLocationBookmark != nil else { return false }
        guard let downloadLocation = getDownloadsFolder() else { return false }
        return downloadLocationNeedsSecurityScope(downloadLocation)
    }

    @Ignore
    var defaultDownloadURL: URL? {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads", isDirectory: true)
    }

    @Ignore
    var downloadHistoryFolders: [URL] {
        var folders = [downloadURL, defaultDownloadURL].compactMap { $0 }
        folders.append(contentsOf: resolveRememberedDownloadFolders())

        var seenPaths = Set<String>()
        return folders.filter { seenPaths.insert($0.standardizedFileURL.path).inserted }
    }

    func downloadLocationNeedsSecurityScope(_ location: URL) -> Bool {
        guard let defaultDownloadURL else { return true }
        let defaultPath = defaultDownloadURL.standardizedFileURL.path
        let locationPath = location.standardizedFileURL.path
        return locationPath != defaultPath && !locationPath.hasPrefix(defaultPath + "/")
    }

    private func changeTrafficLightsTrailingAppearance() {
        if sidebarPosition == .trailing {
            NSApp.setBrowserWindowControls(hidden: !showWindowControlsOnTrailingSidebar)
        }
    }

    private func getDownloadsFolder() -> URL? {
        guard !askForDownloadLocation else { return nil }
        guard let downloadLocationBookmark else { return defaultDownloadURL }
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: downloadLocationBookmark,
            options: .withSecurityScope,
            bookmarkDataIsStale: &isStale) else {
            self.downloadLocationBookmark = nil
            return defaultDownloadURL
        }

        if isLegacySandboxDownloadsURL(url) {
            self.downloadLocationBookmark = nil
            return defaultDownloadURL
        }

        if isStale {
            self.downloadLocationBookmark = nil
            return defaultDownloadURL
        }

        return url
    }

    func removeDownloadLocation() {
        askForDownloadLocation = true
    }

    func useDefaultDownloadLocation() {
        downloadLocationBookmark = nil
        askForDownloadLocation = false
    }

    func rememberDownloadFolder(_ folderURL: URL) {
        let folderPath = folderURL.standardizedFileURL.path
        if folderPath == defaultDownloadURL?.standardizedFileURL.path { return }

        guard !resolveRememberedDownloadFolders().contains(where: {
            $0.standardizedFileURL.path == folderPath
        }),
        let bookmark = try? folderURL.bookmarkData(options: .withSecurityScope) else { return }

        rememberedDownloadFolderBookmarks.append(bookmark)
    }

    private func resolveRememberedDownloadFolders() -> [URL] {
        rememberedDownloadFolderBookmarks.compactMap { bookmark in
            var isStale = false
            guard let url = try? URL(
                resolvingBookmarkData: bookmark,
                options: .withSecurityScope,
                bookmarkDataIsStale: &isStale
            ), !isStale else { return nil }

            if isLegacySandboxDownloadsURL(url) {
                return defaultDownloadURL
            }
            return url
        }
    }

    private func isLegacySandboxDownloadsURL(_ url: URL) -> Bool {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "swift.eva.browser"
        let containerDownloadsSuffix = "/Library/Containers/\(bundleIdentifier)/Data/Downloads"
        let path = url.standardizedFileURL.path
        return path.hasSuffix(containerDownloadsSuffix)
            && path != defaultDownloadURL?.standardizedFileURL.path
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
    private func ensureValidDefaultWebsiteSearcherIdentifier() {
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

    // MARK: Window size and position
    struct WindowFrame: Codable {
        let originX: Double
        let originY: Double
        let width: Double
        let height: Double
    }
    var windowFrame = WindowFrame(originX: 0, originY: 0, width: 600, height: 800)

    // MARK: Recently translated languages
    struct TranslatedLanguage: Codable {
        let code: String
        let name: String
    }
    var recentlyTranslatedLanguages: [TranslatedLanguage] = []
}
