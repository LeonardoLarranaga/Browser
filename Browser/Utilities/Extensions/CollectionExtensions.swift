//
//  CollectionExtensions.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/1/25.
//

extension Collection {
    /// Return the element at the specified index if it is within bounds, otherwise nil.
    /// - Parameter index: The index of the element to return.
    /// - Returns: The element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
