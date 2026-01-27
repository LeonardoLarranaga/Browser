//
//  HistoryCommands.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

/// Commands for the history menu
struct HistoryCommands: Commands {
    
    @Environment(\.modelContext) var modelContext
    
    @FocusedValue(\.browserActiveWindowState) var browserWindowState: BrowserWindowState?
    
    var body: some Commands {
        CommandMenu("History") {
            if let webView = browserWindowState?.currentSpace?.currentTab?.webview {
                
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
            
            Button("Clear History") {
                BrowserHistoryEntry.deleteAllHistory(using: modelContext)
            }
            .globalKeyboardShortcut(.clearHistory)
        }
    }
    
    func showHistory() {
        guard let currentSpace = browserWindowState?.currentSpace else { return }

        let favicon = ImageRenderer(content: Image(systemName: "arrow.counterclockwise.square.fill").resizable().frame(width: 32, height: 32).scaledToFit().foregroundStyle(.gray)).nsImage?.pngData
        let historyTab = BrowserTab(title: "History", favicon: favicon, url: URL(string: "History")!, order: 0, browserSpace: currentSpace, contentType: .history)

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
    static let goBack = Self("go_back", default: .init(.leftBracket, modifiers: .command))
    static let goForward = Self("go_forward", default: .init(.rightBracket, modifiers: .command))
    
    static let showHistory = Self("show_history", default: .init(.y, modifiers: .command))
    static let clearHistory = Self("clear_history")
}

extension [KeyboardShortcuts.Name] {
    static let allHistoryCommands: [KeyboardShortcuts.Name] = [.goBack, .goForward, .showHistory, .clearHistory]
}
