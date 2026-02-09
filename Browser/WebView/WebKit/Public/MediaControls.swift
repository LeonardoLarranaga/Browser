//
//  MediaControls.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 8/2/26.
//

import WebKit

enum MediaControls {

    static func setPageMuted(_ mutedState: WKMediaMutedState, for webView: WKWebView) {
        webView._setPageMuted(mutedState)
    }

    static func getPageMutedState(for webView: WKWebView) -> WKMediaMutedState {
        return webView._mediaMutedState()
    }

    static func hasActiveNowPlayingSession(for webView: WKWebView) -> Bool {
        return webView._hasActiveNowPlayingSession()
    }

    static func stopMediaCapture(for webView: WKWebView) {
        webView._stopMediaCapture()
    }

    static func toggleAudioMute(for webView: WKWebView) {
        let currentState = getPageMutedState(for: webView)
        let newState = currentState.contains(.audioMuted) ? currentState.subtracting(.audioMuted) : currentState.union(.audioMuted)
        setPageMuted(newState, for: webView)
    }

    static func isAudioMuted(for webView: WKWebView) -> Bool {
        return getPageMutedState(for: webView).contains(.audioMuted)
    }

    static func areCaptureDevicesMuted(for webView: WKWebView) -> Bool {
        return getPageMutedState(for: webView).contains(.captureDevicesMuted)
    }

    static func isScreenCaptureMuted(for webView: WKWebView) -> Bool {
        return getPageMutedState(for: webView).contains(.screenCaptureMuted)
    }
}
