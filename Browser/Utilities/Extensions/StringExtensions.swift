//
//  StringExtensions.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 11/1/26.
//

import Foundation

extension String {
    /// A Boolean value indicating whether a string has no characters (including whitespace and newlines).
    var isReallyEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension LocalizedStringResource: @retroactive Comparable {
    public static func < (lhs: LocalizedStringResource, rhs: LocalizedStringResource) -> Bool {
        String(localized: lhs) < String(localized: rhs)
    }
}
