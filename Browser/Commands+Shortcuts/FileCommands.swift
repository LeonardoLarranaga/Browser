//
//  FileCommands.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/7/25.
//

import KeyboardShortcuts
import SwiftUI

struct FileCommands: Commands {
    
    @Environment(\.openWindow) private var openWindow

    @FocusedValue(\.browserActiveWindowState) private var browserWindow
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Tab", action: browserWindow?.toggleNewTabSearch)
                .globalKeyboardShortcut(.newTab)
            
            Button("New Window") { openWindow(id: "BrowserWindow") }
                .globalKeyboardShortcut(.newWindow)
            Button("New Temporary Window") { openWindow(id: "BrowserTemporaryWindow") }
                .globalKeyboardShortcut(.newTemporaryWindow)
            Button("New No-Trace Window") { openWindow(id: "BrowserNoTraceWindow") }
                .globalKeyboardShortcut(.newNoTraceWindow)
            
            Divider()
            
            Button("Open File", action: nil)
                .disabled(true)
                .globalKeyboardShortcut(.openFile)
        }
        
        CommandGroup(replacing: .saveItem) {
            if let currentTab = browserWindow?.currentSpace?.currentTab {
                Button("Close Tab") {
                    browserWindow?.currentSpace?.closeTab(
                        currentTab,
                        tabUndoManager: browserWindow?.tabUndoManager
                    )
                }
                .globalKeyboardShortcut(.closeTab)
            }
            
            Button("Close Window", action: NSApp.keyWindow?.close)
                .globalKeyboardShortcut(.closeWindow)
            Button("Close All Windows", action: NSApp.closeAllWindows)
                .globalKeyboardShortcut(.closeAllWindows)
            
            Divider()
        }
        
        CommandGroup(after: .saveItem) {
            if let url = browserWindow?.currentSpace?.currentTab?.url {
                Button("Create QR Code") { browserWindow?.showURLQRCode.toggle() }
                    .globalKeyboardShortcut(.createQRCode)
                
                ShareLink("Share", item: url)
                    .globalKeyboardShortcut(.share)
                
                Button("Snapshot Current Page Portion", action: copyCurrentPagePortion)
                    .globalKeyboardShortcut(.snapshotCurrentPagePortion)
                Button("Snapshot Full Page", action: copyFullPage)
                    .globalKeyboardShortcut(.snapshotFullPage)
                
                Divider()
                
                Button("Save Page As...", action: browserWindow?.currentSpace?.currentTab?.webview?.savePageAs)
                    .globalKeyboardShortcut(.savePageAs)
                
                Divider()
                
                Button("Print", action: browserWindow?.currentSpace?.currentTab?.webview?.printPage)
                    .globalKeyboardShortcut(.print)
            }
        }
    }
    
    private func copyCurrentPagePortion() {
        let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.png")
        browserWindow?.currentSpace?.currentTab?.webview?.savePageAsPNG(temporaryURL)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([temporaryURL as NSPasteboardWriting])
        browserWindow?.presentActionAlert(message: "Current Page Portion Snapshot Copied!", systemImage: "camera.viewfinder")
    }
    
    private func copyFullPage() {
        let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.png")
        browserWindow?.currentSpace?.currentTab?.webview?.saveFullPageAsPNG(temporaryURL)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([temporaryURL as NSPasteboardWriting])
        browserWindow?.presentActionAlert(message: "Full Page Snapshot Copied!", systemImage: "camera.viewfinder")
    }
}

extension KeyboardShortcuts.Name {
    static let newTab = Self(localized: "New Tab", default: .init(.t, modifiers: .command))
    static let newWindow = Self(localized: "New Window", default: .init(.n, modifiers: [.command]))
    static let newTemporaryWindow = Self(localized: "New Temporary Window", default: .init(.n, modifiers: [.command, .option]))
    static let newNoTraceWindow = Self(localized: "New No-Trace Window", default: .init(.n, modifiers: [.command, .shift]))
    
    static let openFile = Self(localized: "Open File", default: .init(.o, modifiers: .command))
    
    static let closeTab = Self(localized: "Close Tab", default: .init(.w, modifiers: .command))
    static let closeWindow = Self(localized: "Close Window", default: .init(.w, modifiers: [.command, .shift]))
    static let closeAllWindows = Self(localized: "Close All Windows", default: .init(.w, modifiers: [.command, .option]))
    
    static let createQRCode = Self(localized: "Create QR Code")
    static let share = Self(localized: "Share")
    static let snapshotCurrentPagePortion = Self(localized: "Snapshot Current Page Portion")
    static let snapshotFullPage = Self(localized: "Snapshot Full Page", default: .init(.two, modifiers: [.command, .shift]))
    
    static let savePageAs = Self(localized: "Save Page As...", default: .init(.s, modifiers: [.command, .shift]))
    
    static let print = Self(localized: "Print", default: .init(.p, modifiers: .command))
}

extension [KeyboardShortcuts.Name] {
    static let allFileCommands: [KeyboardShortcuts.Name] = [.newTab, .newWindow, .newTemporaryWindow, .newNoTraceWindow, .openFile, .closeTab, .closeWindow, .closeAllWindows, .createQRCode, .share, .snapshotCurrentPagePortion, .snapshotFullPage, .savePageAs, .print]
}
