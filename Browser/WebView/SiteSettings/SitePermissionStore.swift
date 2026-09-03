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
        case .camera: return "Camera"
        case .microphone: return "Microphone"
        }
    }

    var systemImage: String {
        switch self {
        case .camera: return "camera"
        case .microphone: return "mic"
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
        case .ask: return "Ask"
        case .allow: return "Allow"
        case .deny: return "Block"
        }
    }
}

final class SitePermissionStore {

    static let shared = SitePermissionStore()

    private let defaults = UserDefaults.standard

    private func key(host: String, type: SitePermissionType) -> String {
        "sitePermission.\(type.rawValue).\(host)"
    }

    func decision(host: String, type: SitePermissionType) -> SitePermissionDecision {
        guard let raw = defaults.string(forKey: key(host: host, type: type)) else { return .ask }
        return SitePermissionDecision(rawValue: raw) ?? .ask
    }

    func set(_ decision: SitePermissionDecision, host: String, type: SitePermissionType) {
        defaults.set(decision.rawValue, forKey: key(host: host, type: type))
    }
}
