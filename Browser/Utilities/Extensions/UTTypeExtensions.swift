//
//  UTTypeExtensions.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/2/25.
//

import UniformTypeIdentifiers

extension UTType {
    /// Check if the UTType conforms to the given type
    /// - Parameter type: The type to check
    /// - Returns: True if the UTType conforms to the given type
    func conforms(toAny types: [UTType]) -> Bool {
        types.contains { conforms(to: $0) }
    }
}
