//
//  BrowserFolder.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 1/3/26.
//

import SwiftData
import SwiftUI

/// A folder that groups tabs and sub-folders inside a space.
@Model
final class BrowserFolder: Identifiable, Comparable {

    @Attribute(.unique) var id: UUID
    var name: String
    var order: Int
    private(set) var isExpanded: Bool

    @Relationship(deleteRule: .cascade) private var _tabs: [BrowserTab]
    @Relationship(deleteRule: .cascade) private var _subfolders: [BrowserFolder]

    @Relationship var parentFolder: BrowserFolder?
    @Relationship var space: BrowserSpace?

    var tabs: [BrowserTab] {
        get { _tabs.sorted() }
        set {
            newValue.enumerated().forEach { index, tab in
                tab.order = index
            }
            _tabs = newValue
        }
    }

    var subfolders: [BrowserFolder] {
        get { _subfolders.sorted() }
        set {
            newValue.enumerated().forEach { index, folder in
                folder.order = index
            }
            _subfolders = newValue
        }
    }
    init(
        name: String,
        order: Int,
        space: BrowserSpace?,
        parentFolder: BrowserFolder? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.order = order
        self.space = space
        self.isExpanded = true
        self.parentFolder = parentFolder
        self._tabs = []
        self._subfolders = []
    }

    var isEmpty: Bool {
        tabs.isEmpty && subfolders.isEmpty
    }

    var depth: Int {
        var depth = 0
        var currentFolder = parentFolder
        while currentFolder != nil {
            depth += 1
            currentFolder = currentFolder?.parentFolder
        }
        return depth
    }

    func toggleExpansion() {
        withAnimation(.browserDefault) {
            self.isExpanded.toggle()
        }
    }

    static func < (lhs: BrowserFolder, rhs: BrowserFolder) -> Bool {
        lhs.order < rhs.order
    }
}
