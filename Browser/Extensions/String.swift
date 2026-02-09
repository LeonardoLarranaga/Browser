//
//  String.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 11/1/26.
//

extension String {
    /// A Boolean value indicating whether a string has no characters (including whitespace and newlines).
    var isReallyEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
