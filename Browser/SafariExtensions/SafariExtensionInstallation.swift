//
//  SafariExtensionInstallation.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 9/27/26.
//

import Foundation

struct SafariExtensionInstallation: Codable, Equatable, Identifiable {
    var extensionIdentifier: String
    var applicationPath: String
    var applicationBookmark: Data?
    var extensionRelativePath: String
    var displayName: String
    var displayVersion: String?
    var isEnabled: Bool?
    var allWebsitesChoice: SafariExtensionAccessChoice = .allow
    var hasCustomizedWebsiteAccess: Bool?
    var grantedAPIPermissions: [String: Date]?

    var id: String { extensionIdentifier }
    var isExtensionEnabled: Bool { isEnabled ?? true }

    init(
        extensionIdentifier: String,
        applicationPath: String,
        applicationBookmark: Data?,
        extensionRelativePath: String,
        displayName: String,
        displayVersion: String?
    ) {
        self.extensionIdentifier = extensionIdentifier
        self.applicationPath = applicationPath
        self.applicationBookmark = applicationBookmark
        self.extensionRelativePath = extensionRelativePath
        self.displayName = displayName
        self.displayVersion = displayVersion
    }
}


enum SafariExtensionAccessChoice: String, CaseIterable, Codable, Identifiable {
    case ask
    case allow = "alwaysAllowForAllWebsites"
    case deny = "denyForAllWebsites"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ask: String(localized: "Ask")
        case .allow: String(localized: "Allow")
        case .deny: String(localized: "Deny")
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "ask", "allowForOneDay": self = .ask
        case "allow", "alwaysAllowForAllWebsites": self = .allow
        case "deny", "denyForAllWebsites": self = .deny
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown Safari extension access choice: \(value)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
