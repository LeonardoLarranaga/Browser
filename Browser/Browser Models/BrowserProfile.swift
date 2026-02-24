//
//  BrowserProfile.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 23/2/26.
//

import SwiftData
import SwiftUI

/// A model representing a browser profiles, which separates website data stores and history.
@Model
final class BrowserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var systemImage: String
    private var colorHex: String

    @Relationship var browserSpaces: [BrowserSpace]
    @Relationship(deleteRule: .cascade) var historyEntries: [BrowserHistoryEntry]

    init(name: String, systemImage: String, color: Color) {
        self.id = UUID()
        self.name = name
        self.systemImage = systemImage
        self.colorHex = color.hexString()
        self.browserSpaces = []
        self.historyEntries = []
    }

    var color: Color {
        get { Color(hex: colorHex)! }
        set { colorHex = newValue.hexString() }
    }
}
