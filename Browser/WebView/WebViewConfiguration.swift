//
//  WebViewConfiguration.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/2/25.
//

import WebKit

/// Factory that creates WKWebViewConfiguration instances
@MainActor
enum WebViewConfiguration {
    
    static func make(profile: BrowserProfile?, supportsExtensions: Bool = true) -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()

        if supportsExtensions {
            config.webExtensionController = SafariExtensions.shared.controller
        }
        
        config.allowsInlinePredictions = true
        config.allowsAirPlayForMediaPlayback = true
        
        if let profile {
            config.websiteDataStore = WKWebsiteDataStore(forIdentifier: profile.id)
        } else {
            config.websiteDataStore = .default()
        }
        
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Configure shared preferences
        let preferences = WKPreferences()
        preferences.isElementFullscreenEnabled = true
        
        preferences._developerExtrasEnabled = true
        preferences._applePayEnabled = true
        preferences._applePayCapabilityDisclosureAllowed = true
        preferences._allowsPictureInPictureMediaPlayback = true
        
        FeatureFlags.applyFeatureFlags(to: preferences)
        config.preferences = preferences
        
        let webPagePreferences = WKWebpagePreferences()
        webPagePreferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = webPagePreferences
        
        return config
    }
}
