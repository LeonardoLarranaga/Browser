//
//  BrowserApp.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import SwiftUI
import SwiftData

@main
struct BrowserApp: App {
    
    @NSApplicationDelegateAdaptor(BrowserAppDelegate.self) var appDelegate
        
    var body: some Scene {
        WindowGroup(id: "BrowserWindow" + UUID().uuidString) {
            ContentView()
                .environmentObject(appDelegate.userPreferences)
                .transaction {
                    $0.disablesAnimations = appDelegate.userPreferences.disableAnimations
                }
                .frame(minWidth: 400, minHeight: 200)
        }
        .modelContainer(for: [BrowserSpace.self, BrowserTab.self])
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            BrowserCommands()
        }
        
        Settings {
            SettingsView()
                .frame(width: 750, height: 550)
                .environmentObject(appDelegate.userPreferences)
        }
    }
}
