//
//  SafariExtensions.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 9/27/26.
//

import WebKit

@MainActor
@Observable
final class SafariExtensions: NSObject, WKWebExtensionControllerDelegate {
    static let shared = SafariExtensions()

    let controller: WKWebExtensionController

    private(set) var entries: [SafariExtensionEntry] = []
    var errorMessage: String?

    @ObservationIgnored
    private var restorationTask: Task<Void, Never>?
    @ObservationIgnored
    private var didRestoreInstallations = false
    @ObservationIgnored
    private var scopedApplicationURLs: [String: URL] = [:]
    @ObservationIgnored
    private var tabs: [UUID: SafariExtensionTab] = [:]
    @ObservationIgnored
    private var extensionBackgroundWebViews: [String: WKWebView] = [:]
    @ObservationIgnored
    private var extensionWindows: [ObjectIdentifier: SafariExtensionWindow] = [:]
    @ObservationIgnored
    private weak var popupAnchorView: NSView?
    @ObservationIgnored
    private weak var popupAnchorWindow: NSWindow?
    @ObservationIgnored
    private var popupAnchorRectInWindow = CGRect.zero
    @ObservationIgnored
    private var websiteAccessPrompts: [String: [(SafariExtensionAccessChoice) -> Void]] = [:]
    @ObservationIgnored
    private var activePopover: NSPopover?
    @ObservationIgnored
    private weak var activePopoverContext: WKWebExtensionContext?

    private override init() {
        let controllerConfiguration = WKWebExtensionController.Configuration.default()
        let backgroundWebViewConfiguration = WKWebViewConfiguration()
        let backgroundWebViewPreferences = WKPreferences()
        backgroundWebViewPreferences._developerExtrasEnabled = true
        backgroundWebViewConfiguration.preferences = backgroundWebViewPreferences
        controllerConfiguration.webViewConfiguration = backgroundWebViewConfiguration
        controller = WKWebExtensionController(configuration: controllerConfiguration)
        super.init()
        controller.delegate = self
        Task { await restoreInstallationsIfNeeded() }
    }

    func restoreInstallationsIfNeeded() async {
        guard !didRestoreInstallations else { return }
        if let restorationTask {
            await restorationTask.value
            return
        }

        let task = Task { @MainActor [weak self] in
            guard let self else { return }
            await self.restoreSavedInstallations()
        }
        restorationTask = task
        await task.value
        restorationTask = nil
        didRestoreInstallations = true
    }

    func addExtensions(from applicationURL: URL) async {
        await restoreInstallationsIfNeeded()
        errorMessage = nil
        retainSecurityScope(for: applicationURL)

        let applicationPath = applicationURL.standardizedFileURL.path
        let bookmark = try? applicationURL.bookmarkData(options: .withSecurityScope)
        let extensionURLs = safariExtensionBundleURLs(in: applicationURL)
        guard !extensionURLs.isEmpty else {
            errorMessage = String(localized: "The selected app does not contain a Safari web extension.")
            releaseSecurityScopeIfUnused(for: applicationURL)
            return
        }

        var preparedExtensions: [PreparedSafariExtension] = []

        for extensionURL in extensionURLs {
            do {
                guard let bundle = Bundle(url: extensionURL) else {
                    throw SafariExtensionLoadError.invalidBundle
                }

                let webExtension = try await WKWebExtension(appExtensionBundle: bundle)
                let extensionIdentifier = bundle.bundleIdentifier ?? extensionURL.deletingPathExtension().lastPathComponent
                let appPrefix = applicationURL.standardizedFileURL.path + "/"
                let extensionPath = extensionURL.standardizedFileURL.path
                guard extensionPath.hasPrefix(appPrefix) else { continue }

                let name = webExtension.displayName ?? bundle.bundleIdentifier ?? extensionIdentifier
                let version = webExtension.displayVersion
                    ?? bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                let installation = SafariExtensionInstallation(
                    extensionIdentifier: extensionIdentifier,
                    applicationPath: applicationPath,
                    applicationBookmark: bookmark,
                    extensionRelativePath: String(extensionPath.dropFirst(appPrefix.count)),
                    displayName: name,
                    displayVersion: version
                )

                preparedExtensions.append(PreparedSafariExtension(
                    appExtensionBundle: bundle,
                    webExtension: webExtension,
                    installation: installation
                ))
            } catch {
                errorMessage = error.localizedDescription
                releaseSecurityScopeIfUnused(for: applicationURL)
                return
            }
        }

        let existingIdentifiers = Set(entries.map(\.id))
        var seenIdentifiers = Set<String>()
        let extensionsToInstall = preparedExtensions.filter { prepared in
            !existingIdentifiers.contains(prepared.installation.id)
                && seenIdentifiers.insert(prepared.installation.id).inserted
        }
        var installedIdentifiers: [String] = []

        for prepared in extensionsToInstall {
            do {
                try await load(
                    prepared.webExtension,
                    appExtensionBundle: prepared.appExtensionBundle,
                    installation: prepared.installation
                )
                installedIdentifiers.append(prepared.installation.id)
            } catch {
                for identifier in installedIdentifiers {
                    if let entry = entries.first(where: { $0.id == identifier }) {
                        remove(entry)
                    }
                }
                errorMessage = error.localizedDescription
                releaseSecurityScopeIfUnused(for: applicationURL)
                return
            }
        }

        if !extensionsToInstall.isEmpty {
            reloadOpenTabs()
        }

        errorMessage = nil
    }

    func remove(_ entry: SafariExtensionEntry) {
        if activePopoverContext === entry.context {
            activePopover?.close()
            activePopover = nil
            activePopoverContext = nil
        }
        try? controller.unload(entry.context)
        if let webView = extensionBackgroundWebViews[entry.id] {
            DeveloperFeatures.closeWebInspector(for: webView)
        }
        extensionBackgroundWebViews.removeValue(forKey: entry.id)
        Preferences.safariExtensionInstallations.removeAll { $0.id == entry.id }
        entries.removeAll { $0.id == entry.id }
    }

    func setEnabled(_ isEnabled: Bool, for identifier: String) async {
        guard let entry = entries.first(where: { $0.id == identifier }),
              let index = Preferences.safariExtensionInstallations.firstIndex(where: { $0.id == identifier }),
              entry.installation.isExtensionEnabled != isEnabled else { return }

        var installation = Preferences.safariExtensionInstallations[index]
        installation.isEnabled = isEnabled

        if isEnabled {
            do {
                try await load(
                    entry.webExtension,
                    appExtensionBundle: entry.appExtensionBundle,
                    installation: installation
                )
                reloadOpenTabs()
            } catch {
                if !entries.contains(where: { $0.id == entry.id }) {
                    entries.append(entry)
                    entries.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                }
                errorMessage = error.localizedDescription
            }
            return
        }

        if activePopoverContext === entry.context {
            activePopover?.close()
            activePopover = nil
            activePopoverContext = nil
        }

        do {
            try controller.unload(entry.context)
        } catch {
            errorMessage = error.localizedDescription
            return
        }

        if let webView = extensionBackgroundWebViews[entry.id] {
            DeveloperFeatures.closeWebInspector(for: webView)
        }
        extensionBackgroundWebViews.removeValue(forKey: entry.id)
        Preferences.safariExtensionInstallations[index] = installation
        updateEntry(installation, preserving: entry)
        reloadOpenTabs()
    }

    func extensionWindow(
        for browserWindow: BrowserWindow,
        browserSpace: BrowserSpace,
        nativeWindow: NSWindow?,
        isPrivate: Bool
    ) -> SafariExtensionWindow {
        let identifier = ObjectIdentifier(browserWindow)
        let activeSpace = browserWindow.currentSpace ?? browserSpace
        if let existing = extensionWindows[identifier] {
            existing.browserSpace = activeSpace
            existing.nativeWindow = nativeWindow
            existing.isPrivateWindow = isPrivate
            return existing
        }

        let window = SafariExtensionWindow(
            manager: self,
            browserWindow: browserWindow,
            browserSpace: activeSpace,
            nativeWindow: nativeWindow,
            isPrivate: isPrivate
        )
        extensionWindows[identifier] = window
        controller.didOpenWindow(window)
        return window
    }

    func extensionTab(
        for browserTab: BrowserTab,
        webView: WKWebView?,
        windowAdapter: SafariExtensionWindow? = nil
    ) -> SafariExtensionTab {
        if let tab = tabs[browserTab.id] {
            tab.webView = webView ?? browserTab.webview
            tab.browserTab = browserTab
            if let windowAdapter { tab.windowAdapter = windowAdapter }
            return tab
        }

        let tab = SafariExtensionTab(
            browserTab: browserTab,
            webView: webView ?? browserTab.webview,
            windowAdapter: windowAdapter
        )
        tabs[browserTab.id] = tab
        return tab
    }

    func opened(
        _ browserTab: BrowserTab,
        webView: WKWebView,
        selected: Bool,
        browserWindow: BrowserWindow,
        browserSpace: BrowserSpace
    ) {
        guard webView.configuration.webExtensionController === controller else { return }
        let window = extensionWindow(
            for: browserWindow,
            browserSpace: browserSpace,
            nativeWindow: webView.window,
            isPrivate: browserWindow.isNoTraceWindow
        )
        let tab = extensionTab(for: browserTab, webView: webView, windowAdapter: window)
        tab.selected = selected
        controller.didOpenTab(tab)
        if selected {
            controller.didSelectTabs([tab])
            if window.nativeWindow?.isKeyWindow == true {
                controller.didFocusWindow(window)
            }
        }
    }

    func setSelected(
        _ selected: Bool,
        for browserTab: BrowserTab,
        webView: WKWebView,
        browserWindow: BrowserWindow,
        browserSpace: BrowserSpace
    ) {
        guard webView.configuration.webExtensionController === controller else { return }
        let window = extensionWindow(
            for: browserWindow,
            browserSpace: browserSpace,
            nativeWindow: webView.window,
            isPrivate: browserWindow.isNoTraceWindow
        )
        let tab = extensionTab(for: browserTab, webView: webView, windowAdapter: window)
        if tab.selected != selected {
            tab.selected = selected
            if selected {
                controller.didSelectTabs([tab])
            } else {
                controller.didDeselectTabs([tab])
            }
        }
        if selected, window.nativeWindow?.isKeyWindow == true {
            controller.didFocusWindow(window)
        }
    }

    func closed(_ browserTab: BrowserTab) {
        guard let tab = tabs.removeValue(forKey: browserTab.id) else { return }
        controller.didCloseTab(tab)
    }

    func tab(_ browserTab: BrowserTab, changed properties: WKWebExtension.TabChangedProperties) {
        guard let tab = tabs[browserTab.id] else { return }
        controller.didChangeTabProperties(properties, for: tab)
    }

    func performAction(for entry: SafariExtensionEntry, in browserTab: BrowserTab) {
        guard entry.installation.isExtensionEnabled,
              let webView = browserTab.webview else { return }
        let tab = extensionTab(for: browserTab, webView: webView)
        if let window = tab.windowAdapter {
            controller.didFocusWindow(window)
        }
        entry.context.performAction(for: tab)
    }

    func launchExtensionConsole(for entry: SafariExtensionEntry) {
        guard entry.installation.isExtensionEnabled,
              entry.webExtension.hasBackgroundContent else { return }

        entry.context.inspectionName = String(localized: "\(entry.name) Background Page")
        entry.context.isInspectable = true

        Task {
            do {
                try await entry.context.loadBackgroundContent()
                await Task.yield()
                guard let webView = extensionBackgroundWebViews[entry.id] else {
                    errorMessage = String(localized: "WebKit did not provide the extension background page for inspection.")
                    return
                }
                guard let inspector = webView._inspector else {
                    errorMessage = String(localized: "WebKit could not create an inspector for \(entry.name)'s background page.")
                    return
                }

                inspector.connect()
                inspector.show()
                inspector.showConsole()
                NSApp.activate(ignoringOtherApps: true)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    @objc(_webExtensionController:didCreateBackgroundWebView:forExtensionContext:)
    func webExtensionController(
        _ controller: WKWebExtensionController,
        didCreateBackgroundWebView webView: WKWebView,
        forExtensionContext extensionContext: WKWebExtensionContext
    ) {
        guard let entry = entries.first(where: { $0.context === extensionContext }) else { return }
        extensionBackgroundWebViews[entry.id] = webView
    }

    func setPopupAnchorView(_ view: NSView) {
        popupAnchorView = view
        guard let window = view.window else { return }
        popupAnchorWindow = window
        popupAnchorRectInWindow = view.convert(view.bounds, to: nil)
    }

    func webExtensionController(
        _ controller: WKWebExtensionController,
        openWindowsFor extensionContext: WKWebExtensionContext
    ) -> [any WKWebExtensionWindow] {
        extensionWindows.values
            .filter { $0.browserWindow != nil && !$0.isPrivateWindow }
            .map { $0 as any WKWebExtensionWindow }
    }

    func webExtensionController(
        _ controller: WKWebExtensionController,
        focusedWindowFor extensionContext: WKWebExtensionContext
    ) -> (any WKWebExtensionWindow)? {
        guard let keyWindow = NSApp.keyWindow else {
            return extensionWindows.values.first { $0.browserWindow != nil && !$0.isPrivateWindow }
        }
        return extensionWindows.values.first { $0.nativeWindow === keyWindow && !$0.isPrivateWindow }
    }

    func accessChoice(for entry: SafariExtensionEntry) -> SafariExtensionAccessChoice {
        guard let installation = Preferences.safariExtensionInstallations.first(where: { $0.id == entry.id }) else {
            return .ask
        }
        return installation.allWebsitesChoice
    }

    func setAccessChoice(_ choice: SafariExtensionAccessChoice, for identifier: String) {
        guard let entry = entries.first(where: { $0.id == identifier }),
              let index = Preferences.safariExtensionInstallations.firstIndex(where: { $0.id == identifier }) else { return }

        var installation = Preferences.safariExtensionInstallations[index]
        let allURLs = WKWebExtension.MatchPattern.allURLs()
        let context = entry.context
        installation.hasCustomizedWebsiteAccess = true

        switch choice {
        case .ask:
            context.setPermissionStatus(.unknown, for: allURLs)
            installation.allWebsitesChoice = .ask
        case .allow:
            context.setPermissionStatus(.grantedExplicitly, for: allURLs)
            installation.allWebsitesChoice = .allow
        case .deny:
            context.setPermissionStatus(.deniedExplicitly, for: allURLs)
            installation.allWebsitesChoice = .deny
        }

        Preferences.safariExtensionInstallations[index] = installation
        updateEntry(installation, preserving: entry)
    }

    func setDefaultAccessChoice(_ choice: SafariExtensionAccessChoice, for identifier: String) {
        setAccessChoice(choice, for: identifier)
        reloadOpenTabs()
    }

    func webExtensionController(
        _ controller: WKWebExtensionController,
        promptForPermissions permissions: Set<WKWebExtension.Permission>,
        in tab: (any WKWebExtensionTab)?,
        for extensionContext: WKWebExtensionContext,
        completionHandler: @escaping (Set<WKWebExtension.Permission>, Date?) -> Void
    ) {
        saveAPIPermissions(permissions, for: extensionContext, expirationDate: .distantFuture)
        completionHandler(permissions, nil)
    }

    func webExtensionController(
        _ controller: WKWebExtensionController,
        promptForPermissionToAccess urls: Set<URL>,
        in tab: (any WKWebExtensionTab)?,
        for extensionContext: WKWebExtensionContext,
        completionHandler: @escaping (Set<URL>, Date?) -> Void
    ) {
        presentWebsiteAccessPrompt(
            for: extensionContext,
            requested: urls.map(\.absoluteString)
        ) { choice in
            switch choice {
            case .ask, .deny:
                if choice == .deny {
                    self.setAccessChoice(choice, for: self.extensionIdentifier(for: extensionContext))
                }
                completionHandler([], nil)
            case .allow:
                self.setAccessChoice(choice, for: self.extensionIdentifier(for: extensionContext))
                completionHandler(urls, nil)
            }
        }
    }

    func webExtensionController(
        _ controller: WKWebExtensionController,
        promptForPermissionMatchPatterns matchPatterns: Set<WKWebExtension.MatchPattern>,
        in tab: (any WKWebExtensionTab)?,
        for extensionContext: WKWebExtensionContext,
        completionHandler: @escaping (Set<WKWebExtension.MatchPattern>, Date?) -> Void
    ) {
        presentWebsiteAccessPrompt(
            for: extensionContext,
            requested: matchPatterns.map(\.string)
        ) { choice in
            switch choice {
            case .ask:
                completionHandler([], nil)
            case .allow:
                self.setAccessChoice(choice, for: self.extensionIdentifier(for: extensionContext))
                completionHandler([.allURLs()], nil)
            case .deny:
                self.setAccessChoice(choice, for: self.extensionIdentifier(for: extensionContext))
                completionHandler([], nil)
            }
        }
    }

    func webExtensionController(
        _ controller: WKWebExtensionController,
        presentActionPopup action: WKWebExtension.Action,
        for extensionContext: WKWebExtensionContext,
        completionHandler: @escaping (Error?) -> Void
    ) {
        guard action.presentsPopup, let popover = action.popupPopover,
              let selectedTab = (action.associatedTab as? SafariExtensionTab)
                ?? tabs.values.first(where: { $0.selected && $0.windowAdapter?.nativeWindow?.isKeyWindow == true })
                ?? tabs.values.first(where: \.selected),
              let webView = selectedTab.webView,
              webView.window != nil else {
            completionHandler(nil)
            return
        }

        if let window = selectedTab.windowAdapter {
            controller.didFocusWindow(window)
        }

        let anchorView: NSView
        let anchorRect: CGRect
        if let popupAnchorWindow,
           popupAnchorWindow === webView.window,
           let contentView = popupAnchorWindow.contentView {
            anchorView = contentView
            anchorRect = contentView.convert(popupAnchorRectInWindow, from: nil)
        } else if let popupAnchorView, popupAnchorView.window === webView.window {
            anchorView = popupAnchorView
            anchorRect = popupAnchorView.bounds
        } else {
            anchorView = webView
            anchorRect = webView.bounds
        }
        if activePopover !== popover {
            activePopover?.close()
            NotificationCenter.default.removeObserver(self, name: NSPopover.didCloseNotification, object: activePopover)
            NotificationCenter.default.addObserver(self, selector: #selector(popoverDidClose(_:)), name: NSPopover.didCloseNotification, object: popover)
        }
        activePopover = popover
        activePopoverContext = extensionContext
        popover.behavior = .transient
        popover.show(relativeTo: anchorRect, of: anchorView, preferredEdge: .maxY)
        completionHandler(nil)
    }

    @objc private func popoverDidClose(_ notification: Notification) {
        guard let popover = notification.object as? NSPopover,
              activePopover === popover else { return }
        NotificationCenter.default.removeObserver(self, name: NSPopover.didCloseNotification, object: popover)
        activePopover = nil
        activePopoverContext = nil
    }

    private func restoreSavedInstallations() async {
        for installation in Preferences.safariExtensionInstallations {
            guard let applicationURL = resolveApplicationURL(for: installation) else {
                print("Could not find the app for Safari extension \(installation.displayName)")
                continue
            }
            retainSecurityScope(for: applicationURL)
            let extensionURL = applicationURL.appendingPathComponent(installation.extensionRelativePath, isDirectory: true)
            guard let bundle = Bundle(url: extensionURL) else { continue }

            do {
                let webExtension = try await WKWebExtension(appExtensionBundle: bundle)
                try await load(webExtension, appExtensionBundle: bundle, installation: installation)
            } catch {
                print("Could not restore Safari extension \(installation.displayName): \(error.localizedDescription)")
            }
        }

        reloadOpenTabs()
    }

    private func load(
        _ webExtension: WKWebExtension,
        appExtensionBundle: Bundle,
        installation: SafariExtensionInstallation
    ) async throws {
        var installation = installation
        if let existing = entries.first(where: { $0.id == installation.id }) {
            try? controller.unload(existing.context)
            if let webView = extensionBackgroundWebViews[existing.id] {
                DeveloperFeatures.closeWebInspector(for: webView)
            }
            extensionBackgroundWebViews.removeValue(forKey: existing.id)
            entries.removeAll { $0.id == installation.id }
        }

        let previousInstallations = Preferences.safariExtensionInstallations
        let context = WKWebExtensionContext(for: webExtension)
        context.uniqueIdentifier = installation.id
        // Earlier installations defaulted to Ask before automatic grants were supported.
        if installation.hasCustomizedWebsiteAccess == nil, installation.allWebsitesChoice == .ask {
            installation.allWebsitesChoice = .allow
        }
        var permissions = installation.grantedAPIPermissions ?? [:]
        for permission in webExtension.requestedPermissions {
            permissions[permission.rawValue] = .distantFuture
        }
        installation.grantedAPIPermissions = permissions
        restoreAccess(for: installation, in: context)
        var installations = Preferences.safariExtensionInstallations
        installations.removeAll { $0.id == installation.id }
        installations.append(installation)
        Preferences.safariExtensionInstallations = installations
        let entry = SafariExtensionEntry(
            installation: installation,
            appExtensionBundle: appExtensionBundle,
            webExtension: webExtension,
            context: context
        )
        entries.append(entry)
        entries.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        guard installation.isExtensionEnabled else { return }

        do {
            try controller.load(context)
            if webExtension.manifest["background"] != nil {
                try await context.loadBackgroundContent()
            }
        } catch {
            try? controller.unload(context)
            entries.removeAll { $0.id == installation.id }
            Preferences.safariExtensionInstallations = previousInstallations
            throw error
        }
    }

    private func reloadOpenTabs() {
        for tab in tabs.values {
            guard let webView = tab.webView, webView.url != nil else { continue }
            webView.reload()
        }
    }

    private func updateEntry(_ installation: SafariExtensionInstallation, preserving entry: SafariExtensionEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index] = SafariExtensionEntry(
            installation: installation,
            appExtensionBundle: entry.appExtensionBundle,
            webExtension: entry.webExtension,
            context: entry.context
        )
    }

    private func restoreAccess(for installation: SafariExtensionInstallation, in context: WKWebExtensionContext) {
        for (name, expirationDate) in installation.grantedAPIPermissions ?? [:] where expirationDate > .now {
            context.setPermissionStatus(.grantedExplicitly, for: WKWebExtension.Permission(rawValue: name), expirationDate: expirationDate)
        }
        let allURLs = WKWebExtension.MatchPattern.allURLs()
        switch installation.allWebsitesChoice {
        case .allow:
            context.setPermissionStatus(.grantedExplicitly, for: allURLs)
        case .deny:
            context.setPermissionStatus(.deniedExplicitly, for: allURLs)
        case .ask:
            break
        }
    }

    private func saveAPIPermissions(_ permissions: Set<WKWebExtension.Permission>, for context: WKWebExtensionContext, expirationDate: Date) {
        guard let entry = entries.first(where: { $0.context === context }),
              let index = Preferences.safariExtensionInstallations.firstIndex(where: { $0.id == entry.id }) else { return }
        var installation = Preferences.safariExtensionInstallations[index]
        var saved = installation.grantedAPIPermissions ?? [:]
        for permission in permissions { saved[permission.rawValue] = expirationDate }
        installation.grantedAPIPermissions = saved
        Preferences.safariExtensionInstallations[index] = installation
        updateEntry(installation, preserving: entry)
    }

    private func safariExtensionBundleURLs(in applicationURL: URL) -> [URL] {
        let candidates = [
            applicationURL.appendingPathComponent("Contents/PlugIns", isDirectory: true),
            applicationURL.appendingPathComponent("Contents/Extensions", isDirectory: true),
            applicationURL.appendingPathComponent("PlugIns", isDirectory: true),
            applicationURL.appendingPathComponent("Extensions", isDirectory: true)
        ]

        var extensionBundles: [URL] = []
        for directory in candidates where FileManager.default.fileExists(atPath: directory.path) {
            let bundles = (try? FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )) ?? []
            extensionBundles.append(contentsOf: bundles.filter(isSafariWebExtensionBundle(_:)))
        }
        return Array(Set(extensionBundles)).sorted { $0.path.localizedCaseInsensitiveCompare($1.path) == .orderedAscending }
    }

    private func isSafariWebExtensionBundle(_ url: URL) -> Bool {
        guard url.pathExtension.caseInsensitiveCompare("appex") == .orderedSame,
              let bundle = Bundle(url: url),
              let extensionInfo = bundle.infoDictionary?["NSExtension"] as? [String: Any],
              extensionInfo["NSExtensionPointIdentifier"] as? String == "com.apple.Safari.web-extension",
              let resourcesURL = bundle.resourceURL else { return false }

        let manifestURL = resourcesURL.appendingPathComponent("manifest.json")
        return FileManager.default.fileExists(atPath: manifestURL.path)
    }

    private func resolveApplicationURL(for installation: SafariExtensionInstallation) -> URL? {
        if let bookmark = installation.applicationBookmark {
            var isStale = false
            if let url = try? URL(
                resolvingBookmarkData: bookmark,
                options: .withSecurityScope,
                bookmarkDataIsStale: &isStale
            ), !isStale {
                return url
            }
        }

        let url = URL(fileURLWithPath: installation.applicationPath, isDirectory: true)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    private func retainSecurityScope(for url: URL) {
        let key = url.standardizedFileURL.path
        guard scopedApplicationURLs[key] == nil else { return }
        if url.startAccessingSecurityScopedResource() {
            scopedApplicationURLs[key] = url
        }
    }

    private func releaseSecurityScopeIfUnused(for url: URL) {
        let path = url.standardizedFileURL.path
        guard !Preferences.safariExtensionInstallations.contains(where: { $0.applicationPath == path }),
              let scopedURL = scopedApplicationURLs.removeValue(forKey: path) else { return }
        scopedURL.stopAccessingSecurityScopedResource()
    }

    private func extensionIdentifier(for context: WKWebExtensionContext) -> String {
        entries.first(where: { $0.context == context })?.id ?? context.webExtension.displayName ?? ""
    }

    private func extensionName(for context: WKWebExtensionContext) -> String {
        context.webExtension.displayName ?? String(localized: "This extension")
    }

    private func presentPermissionAlert(
        _ alert: NSAlert,
        completionHandler: @escaping (NSApplication.ModalResponse) -> Void
    ) {
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow ?? NSWindow.mainBrowserWindows.first else {
            completionHandler(.abort)
            return
        }
        alert.beginSheetModal(for: window, completionHandler: completionHandler)
    }

    private func presentWebsiteAccessPrompt(
        for context: WKWebExtensionContext,
        requested: [String],
        completionHandler: @escaping (SafariExtensionAccessChoice) -> Void
    ) {
        let identifier = extensionIdentifier(for: context)
        let choice = Preferences.safariExtensionInstallations.first { $0.id == identifier }?.allWebsitesChoice ?? .ask
        if choice == .allow || choice == .deny {
            completionHandler(choice)
            return
        }
        // A background page can request several resources concurrently. Share one sheet.
        if websiteAccessPrompts[identifier] != nil {
            websiteAccessPrompts[identifier]?.append(completionHandler)
            return
        }
        websiteAccessPrompts[identifier] = [completionHandler]

        let alert = NSAlert()
        alert.alertStyle = .informational
        let name = extensionName(for: context)
        alert.messageText = String(localized: "\(name) Wants Website Access")
        var informativeText = String(localized: "Choose whether \(name) can access websites.")
        if !requested.isEmpty {
            informativeText += "\n\n" + String(localized: "Requested access: \(requested.sorted().joined(separator: ", "))")
        }
        alert.informativeText = informativeText
        for choice in SafariExtensionAccessChoice.allCases {
            alert.addButton(withTitle: choice.title)
        }

        presentPermissionAlert(alert) { response in
            let index = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
            let choice = index >= 0 && Int(index) < SafariExtensionAccessChoice.allCases.count
                ? SafariExtensionAccessChoice.allCases[Int(index)] : .ask
            let completions = self.websiteAccessPrompts.removeValue(forKey: identifier) ?? []
            for completion in completions { completion(choice) }
        }
    }
}

private struct PreparedSafariExtension {
    let appExtensionBundle: Bundle
    let webExtension: WKWebExtension
    let installation: SafariExtensionInstallation
}

private enum SafariExtensionLoadError: LocalizedError {
    case invalidBundle

    var errorDescription: String? {
        switch self {
        case .invalidBundle: String(localized: "The app contains an invalid Safari web extension bundle.")
        }
    }
}
