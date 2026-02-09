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
    var scaledZoomFactor: CGFloat = 1.0

    /// The "Search With Google" action (passed from the WKWebViewController)
    var searchWebAction: ((String) -> Void)? = nil
    /// The "Open Link In New Tab" action (passed from the WKWebViewController)
    var openLinkInNewTabAction: ((URL) -> Void)? = nil
    /// Present an action alert from the WKWebView (passed from the WKWebViewController)
    var presentActionAlert: ((String, String) -> Void)? = nil
    /// Toggle the Find UI action (passed from the WKWebViewController)
    var toggleFindUI: (() -> Void)? = nil

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
        scaledZoomFactor = 1.0
    }

    /// Handle Zoom In
    func zoomIn() {
        let currentIndex = zoomFactors.firstIndex(of: scaledZoomFactor) ?? 3
        let nextIndex = currentIndex + 1
        if nextIndex < zoomFactors.count {
            let nextZoomFactor = zoomFactors[nextIndex]
            setZoomFactor(nextZoomFactor)
            self.scaledZoomFactor = nextZoomFactor
        }
    }

    /// Handle Zoom Out
    func zoomOut() {
        let currentIndex = zoomFactors.firstIndex(of: scaledZoomFactor) ?? 3
        let nextIndex = currentIndex - 1
        if nextIndex >= 0 {
            let nextZoomFactor = zoomFactors[nextIndex]
            setZoomFactor(nextZoomFactor)
            self.scaledZoomFactor = nextZoomFactor
        }
    }

    /// Sets the zoom factor
    /// - Parameter zoomFactor: The zoom factor to set
    func setZoomFactor(_ zoomFactor: CGFloat) {
        let clamped = max(zoomFactors.first!, min(zoomFactor, zoomFactors.last!))
        let systemImage = clamped > pageZoom ? "plus.magnifyingglass" : "minus.magnifyingglass"
        pageZoom = clamped
        presentActionAlert?("Zoom Set to \(Int(clamped * 100))%", systemImage)
    }

    /// Toggles the page editable
    func toggleEditable() {
        isEditable.toggle()
    }

    /// Clears the cookies of the specific host and reloads
    func clearCookiesAndReload() {
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            for cookie in cookies where self.url?.host()?.contains(cookie.domain) == true {
                cookieStore.delete(cookie)
            }
        }
        reload()
    }

    /// Clears the cache of the specific host and reloads
    func clearCacheAndReload() {
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            for record in records where self.url?.host()?.contains(record.displayName) == true {
                let types = record.dataTypes.filter { $0.contains("Cache") }
                WKWebsiteDataStore.default().removeData(ofTypes: types, for: [record], completionHandler: {})
            }
        }
        reload()
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
