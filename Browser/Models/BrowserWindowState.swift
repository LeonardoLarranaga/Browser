//
//  BrowserWindowState.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/28/25.
//

import SwiftUI

class BrowserWindowState: ObservableObject {
    
    @Published var currentSpace: BrowserSpace? = nil {
        willSet {
            if let newValue {
                UserDefaults.standard.set(newValue.id.uuidString, forKey: "currentBrowserSpace")
            }
        }
    }
    @Published var viewScrollState: UUID?
    @Published var tabBarScrollState: UUID?
    
    @Sendable
    func loadCurrentSpace(browserSpaces: [BrowserSpace]) {
        guard let spaceId = UserDefaults.standard.string(forKey: "currentBrowserSpace"),
              let uuid = UUID(uuidString: spaceId) else { return }
        
        if let space = browserSpaces.first(where: { $0.id == uuid }) {
            currentSpace = space
            viewScrollState = uuid
            tabBarScrollState = uuid
        }
    }
}
