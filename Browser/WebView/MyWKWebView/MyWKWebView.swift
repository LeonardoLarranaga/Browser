//
//  MyWKWebView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/2/25.
//

import WebKit

/// Custom WKWebView subclass to handle context menus
class MyWKWebView: WKWebView {
    
    private let zoomFactors: [CGFloat] = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 4, 5, 6]
    
    /// The "Search With Google" action (passed from the WKWebViewController)
    var searchWebAction: ((String) -> Void)? = nil
    /// The "Open Link In New Tab" action (passed from the WKWebViewController)
    var openLinkInNewTabAction: ((URL) -> Void)? = nil
    /// Present an action alert from the WKWebView (passed from the WKWebViewController)
    var presentActionAlert: ((String, String) -> Void)? = nil
    /// Toggle the Find UI action (passed from the WKWebViewController)
    var toggleFindUI: (() -> Void)? = nil
    var onZoomChanged: ((CGFloat) -> Void)? = nil
    
    override var isEditable: Bool {
        get {
            return _isEditable
        }
        set {
            _isEditable = newValue
        }
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func zoomActualSize() {
        setZoomFactor(1.0)
    }
    
    /// Handle Zoom In
    func zoomIn() {
        let nextIndex = currentZoomIndex + 1
        guard zoomFactors.indices.contains(nextIndex) else { return }
        setZoomFactor(zoomFactors[nextIndex])
    }
    
    /// Handle Zoom Out
    func zoomOut() {
        let previousIndex = currentZoomIndex - 1
        guard zoomFactors.indices.contains(previousIndex) else { return }
        setZoomFactor(zoomFactors[previousIndex])
    }

    private var currentZoomIndex: Int {
        zoomFactors.enumerated().min {
            abs($0.element - pageZoom) < abs($1.element - pageZoom)
        }?.offset ?? zoomFactors.firstIndex(of: 1.0) ?? 0
    }
    
    /// Sets the zoom factor
    /// - Parameter zoomFactor: The zoom factor to set
    func setZoomFactor(_ zoomFactor: CGFloat) {
        let clamped = max(zoomFactors.first!, min(zoomFactor, zoomFactors.last!))
        pageZoom = clamped
        onZoomChanged?(clamped)
    }
    
    /// Toggles the page editable
    func toggleEditable() {
        isEditable.toggle()
    }
    
    /// Clears the cookies of the specific host and reloads
    func clearCookiesAndReload() {
        let cookieStore = configuration.websiteDataStore.httpCookieStore
        let host = url?.host()

        cookieStore.getAllCookies { [weak self] cookies in
            let matchingCookies = cookies.filter { cookie in
                guard let host else { return false }
                return host.matchesWebsiteDomain(cookie.domain)
            }

            guard !matchingCookies.isEmpty else {
                DispatchQueue.main.async { self?.reload() }
                return
            }

            let group = DispatchGroup()
            for cookie in matchingCookies {
                group.enter()
                cookieStore.delete(cookie) {
                    group.leave()
                }
            }

            group.notify(queue: .main) { [weak self] in
                self?.reload()
            }
        }
    }
    
    /// Clears the cache of the specific host and reloads
    func clearCacheAndReload() {
        let dataStore = configuration.websiteDataStore
        let host = url?.host()

        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { [weak self] records in
            guard let host else {
                DispatchQueue.main.async { self?.reload() }
                return
            }

            let matchingRecords = records.filter { host.matchesWebsiteDomain($0.displayName) }
            let cacheTypes = Set(matchingRecords.flatMap { record in
                record.dataTypes.filter { $0.contains("Cache") }
            })

            guard !matchingRecords.isEmpty, !cacheTypes.isEmpty else {
                DispatchQueue.main.async { self?.reload() }
                return
            }

            dataStore.removeData(ofTypes: cacheTypes, for: matchingRecords) {
                DispatchQueue.main.async { self?.reload() }
            }
        }
    }
    
    /// Toggles the developer tools
    func toggleDeveloperTools() {
        DeveloperFeatures.toggleWebInspector(for: self)
    }
    
    func showJavaScriptConsole() {
        DeveloperFeatures.showJavaScriptConsole(for: self)
    }
    
    func showPageResources() {
        DeveloperFeatures.showPageResources(for: self)
    }
    
    var isAudioMuted: Bool {
        MediaControls.isAudioMuted(for: self)
    }
    
    /// Toggles the page muted state
    func toggleMute() {
        MediaControls.toggleAudioMute(for: self)
    }
    
    /// Gets if the page has an active now playing session
    var hasActiveNowPlayingSession: Bool {
        MediaControls.hasActiveNowPlayingSession(for: self)
    }
    
    func togglePictureInPicture() {
        guard let pipScript = JavaScript.getBundled("TogglePictureInPicture") else { return }
        evaluateJavaScript(pipScript)
    }
    
    /// Gets the currently selected text on the page
    func getSelectedText() async -> String? {
        do {
            let result = try await evaluateJavaScript("window.getSelection().toString()")
            return result as? String
        } catch {
            return nil
        }
    }
    
    //MARK: - Variables for Context Menus
    weak var currentNSSavePanel: NSSavePanel?
    var rightMouseDownPosition = CGPoint.zero
}
