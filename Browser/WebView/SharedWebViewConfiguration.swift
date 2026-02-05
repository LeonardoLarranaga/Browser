//
//  SharedWebViewConfiguration.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/2/25.
//

import WebKit

/// Shared configuration for WKWebView instances
class SharedWebViewConfiguration {
    /// Singleton to ensure a single shared configuration across tabs
    static func shared() -> SharedWebViewConfiguration { .init() }

    // Shared configuration with cache, cookies, and other settings
    let configuration: WKWebViewConfiguration

    private init() {
        configuration = WKWebViewConfiguration()

        configuration.allowsInlinePredictions = true
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.websiteDataStore = .default()
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // Configure shared preferences
        let preferences = WKPreferences()
        preferences.isElementFullscreenEnabled = true

        preferences._developerExtrasEnabled = true
        preferences._applePayEnabled = true
        preferences._applePayCapabilityDisclosureAllowed = true
        preferences._allowsPictureInPictureMediaPlayback = true

        FeatureFlags.applyFeatureFlags(to: preferences)
        configuration.preferences = preferences

        let webPagePreferences = WKWebpagePreferences()
        webPagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = webPagePreferences
    }
}
