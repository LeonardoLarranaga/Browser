//
//  Model.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 23/2/26.
//

import SwiftData

enum BrowserModel {
    static let appModels: [any PersistentModel.Type] = [
        BrowserFolder.self,
        BrowserHistoryEntry.self,
        BrowserProfile.self,
        BrowserSpace.self,
        BrowserTab.self
    ]
}
