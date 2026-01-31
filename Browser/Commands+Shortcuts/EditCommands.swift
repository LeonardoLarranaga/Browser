//
//  EditCommands.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/11/25.
//

import SwiftUI
import KeyboardShortcuts

struct EditCommands: Commands {
    
    @Environment(\.undoManager) var undoManager
    
    @FocusedValue(\.browserActiveWindowState) var browserWindow
    
    @State var isEditable = false
    
    var body: some Commands {
        let webView = browserWindow?.currentSpace?.currentTab?.webview
        CommandGroup(replacing: .undoRedo) {
            
        }
        
        CommandGroup(after: .undoRedo) {
            Button("Copy Current URL", action: browserWindow?.copyURLToClipboard)
                .globalKeyboardShortcut(.copyCurrentURL)
            
            Divider()
            
            if let webView {
                Button(isEditable ? "Stop Editing Text On Page" : "Edit Text On Page") {
                    isEditable.toggle()
                    webView.toggleEditable()
                    browserWindow?.presentActionAlert(message: isEditable ? "You Can Now Edit The Text On The Page" : "You Are No Longer Editing The Text On The Page", systemImage: isEditable ? "pencil.and.outline" : "pencil.slash")
                }
                .globalKeyboardShortcut(.toggleEditing)
            }
        }
        
        CommandGroup(before: .textEditing) {
            Menu("Find") {
                Button("Find...", action: webView?.toggleFindUI)
                    .globalKeyboardShortcut(.find)
                Button("Find Next", action: findNext)
                    .globalKeyboardShortcut(.findNext)
                    .disabled(currentTab?.findInPageManager?.totalMatches == 0)
                Button("Find Previous", action: findPrevious)
                    .globalKeyboardShortcut(.findPrevious)
                    .disabled(currentTab?.findInPageManager?.totalMatches == 0)
                Button("Use Selection For Find", action: useSelectionForFind)
                    .globalKeyboardShortcut(.useSelectionForFind)
            }
            .id("BrowserFindMenu")
        }
    }

    var currentTab: BrowserTab? {
        browserWindow?.currentSpace?.currentTab
    }

    func findNext() {
        Task {
            await currentTab?.findInPageManager?.goToNextMatch()
        }
    }

    func findPrevious() {
        Task {
            await currentTab?.findInPageManager?.goToPreviousMatch()
        }
    }

    func useSelectionForFind() {
        guard let tab = currentTab, let webView = tab.webview else { return }

        Task {
            // Get selected text from the page
            guard let selectedText = await webView.getSelectedText(), !selectedText.isEmpty else { return }

            // Ensure find manager exists
            if tab.findInPageManager == nil {
                tab.findInPageManager = FindInPageManager(webView: webView)
            }

            // Show the find UI
            tab.showFindUI = true

            // Search for the selected text
            await tab.findInPageManager?.search(selectedText)
        }
    }
}

extension KeyboardShortcuts.Name {
    static let copyCurrentURL = Self("copy_current_url", default: .init(.c, modifiers: [.command, .shift]))
    
    static let toggleEditing = Self("toggle_editing")
    
    static let find = Self("find", default: .init(.f, modifiers: [.command]))
    static let findNext = Self("find_next", default: .init(.g, modifiers: [.command]))
    static let findPrevious = Self("find_previous", default: .init(.g, modifiers: [.command, .shift]))
    static let useSelectionForFind = Self("use_selection_for_find", default: .init(.e, modifiers: [.command]))
}

extension [KeyboardShortcuts.Name] {
    static let allEditCommands: [KeyboardShortcuts.Name] = [
        .copyCurrentURL, .toggleEditing,
        .find, .findNext, .findPrevious, .useSelectionForFind
    ]
}
