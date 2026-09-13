//
//  SitePermissionStore.swift
//  Browser
//

import Foundation

enum SitePermissionType: String, CaseIterable, Identifiable {
    case camera
    case microphone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .camera: "Camera"
        case .microphone: "Microphone"
        }
    }

    var systemImage: String {
        switch self {
        case .camera: "camera"
        case .microphone: "mic"
        }
    }
}

enum SitePermissionDecision: String, CaseIterable, Identifiable {
    case ask
    case allow
    case deny

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ask: "Ask"
        case .allow: "Allow"
        case .deny: "Block"
        }
    }
}

final class SitePermissionStore {

    static let shared = SitePermissionStore()

    private let defaults = UserDefaults.standard

    private func key(host: String, type: SitePermissionType) -> String {
        "sitePermission.\(type.rawValue).\(host.lowercased())"
    }

    func decision(host: String, type: SitePermissionType) -> SitePermissionDecision {
        guard let raw = defaults.string(forKey: key(host: host, type: type)) else { return .ask }
        return SitePermissionDecision(rawValue: raw) ?? .ask
    }

    func set(_ decision: SitePermissionDecision, host: String, type: SitePermissionType) {
        defaults.set(decision.rawValue, forKey: key(host: host, type: type))
    }
}
