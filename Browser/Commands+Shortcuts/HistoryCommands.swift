//
//  HistoryCommands.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

import KeyboardShortcuts
import SwiftData
import SwiftUI

/// Commands for the history menu
struct HistoryCommands: Commands {
    
    @Environment(\.modelContext) private var modelContext

    @FocusedValue(\.browserActiveWindowState) private var browserWindow: BrowserWindow?
    
    var body: some Commands {
        CommandMenu("History") {
            if let webView = browserWindow?.currentSpace?.currentTab?.webview {
                
                Button("Go Back") { webView.goBack() }
                    .disabled(!webView.canGoBack)
                    .globalKeyboardShortcut(.goBack)
                
                Button("Go Forward") { webView.goForward() }
                    .disabled(!webView.canGoForward)
                    .globalKeyboardShortcut(.goForward)
            }
            
            Divider()
            
            Button("Show History", action: showHistory)
                .globalKeyboardShortcut(.showHistory)
        }
    }
    
    private func showHistory() {
        guard let currentSpace = browserWindow?.currentSpace else { return }
        
        let favicon = ImageRenderer(content: Image(systemName: "arrow.counterclockwise.square.fill").resizable().frame(width: 32, height: 32).scaledToFit().foregroundStyle(.gray)).nsImage?.pngData
        let historyTitle = String(localized: "History")
        let historyTab = BrowserTab(title: historyTitle, favicon: favicon, url: URL(string: "History")!, order: 0, browserSpace: currentSpace, contentType: .history)
        
        do {
            currentSpace.tabs.append(historyTab)
            try modelContext.save()
            currentSpace.currentTab = historyTab
        } catch {
            print("Error saving history tab: \(error)")
        }
    }
}

extension KeyboardShortcuts.Name {
    static let goBack = Self(localized: "Go Back", default: .init(.leftBracket, modifiers: .command))
    static let goForward = Self(localized: "Go Forward", default: .init(.rightBracket, modifiers: .command))
    
    static let showHistory = Self(localized: "Show History", default: .init(.y, modifiers: .command))
}

extension [KeyboardShortcuts.Name] {
    static let allHistoryCommands: [KeyboardShortcuts.Name] = [.goBack, .goForward, .showHistory]
}
