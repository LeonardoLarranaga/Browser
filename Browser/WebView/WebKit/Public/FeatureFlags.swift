//
//  FeatureFlags.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 25/1/26.
//

import SwiftUI

typealias WKFeature = _WKFeature

enum FeatureFlags {
    static func getAll() -> [WKFeature] {
        WKPreferences._experimentalFeatures()
    }

    static func getAllGrouped() -> [WebFeatureCategory: [WKFeature]] {
        Dictionary(grouping: getAll(), by: { $0.category })
    }

    static func userToggleFeature(_ feature: WKFeature, enabled: Bool) {
        Preferences.shared.configuredFeatureFlags[feature.key] = enabled
    }

    private static func toggleFeature(_ feature: WKFeature, enabled: Bool, for preferences: WKPreferences? = nil) {
        preferences?._setEnabled(enabled, for: feature)
    }

    private static func toggleFeature(_ key: String, enabled: Bool, for preferences: WKPreferences? = nil) {
        if let feature = getFeature(key: key) {
            toggleFeature(feature, enabled: enabled, for: preferences)
        }
    }

    static func isEnabled(_ feature: WKFeature) -> Bool {
        // Check if user has configured this feature flag
        if let userConfigured = Preferences.shared.configuredFeatureFlags[feature.key] {
            return userConfigured
        }
        // Fall back to the actual WKPreferences state
        return SharedWebViewConfiguration.shared.configuration.preferences._isEnabled(for: feature)
    }

    static func getFeature(key: String) -> WKFeature? {
        getAll().first { $0.key == key }
    }

    /// Applies the default feature flags, browser-specific defaults, and user-defined to a WKPreferences.
    static func applyFeatureFlags(to preferences: WKPreferences) {
        // Apply browser defaults first
        browserDefaultFeatureFlags.forEach { key, defaultValue in
            toggleFeature(key, enabled: defaultValue, for: preferences)
        }

        // Apply user-configured flags (these override browser defaults)
        Preferences.shared.configuredFeatureFlags.forEach { key, enabled in
            toggleFeature(key, enabled: enabled, for: preferences)
        }
    }
    
    static var browserDefaultFeatureFlags: [String: Bool] {
        ["PreferPageRenderingUpdatesNear60FPSEnabled": false]
    }

    static func isFeatureFlagUserConfigured(_ feature: WKFeature) -> Bool {
        Preferences.shared.configuredFeatureFlags[feature.key] != nil
    }
}

extension WebFeatureStatus {
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .embedder: "Embedder"
        case .unstable: "Unstable"
        case .internal: "Internal"
        case .developer: "Developer"
        case .testable: "Testable"
        case .preview: "Preview"
        case .stable: "Stable"
        case .mature: "Mature"
        @unknown default: "Unknown"
        }
    }
}

extension WebFeatureCategory {
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .none: "Uncategorized"
        case .animation: "Animation"
        case .CSS: "CSS"
        case .DOM: "DOM"
        case .javascript: "JavaScript"
        case .media: "Media"
        case .networking: "Networking"
        case .privacy: "Privacy"
        case .security: "Security"
        case .HTML: "HTML"
        case .extensions: "Extensions"
        @unknown default: "Unknown"
        }
    }
}
