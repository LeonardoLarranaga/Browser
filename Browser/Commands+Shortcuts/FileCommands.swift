//
//  FileCommands.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/7/25.
//

import SwiftUI
import KeyboardShortcuts

struct FileCommands: Commands {
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.modelContext) var modelContext
    
    @FocusedValue(\.browserActiveWindowState) var browserWindow
    
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
                        using: modelContext,
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
                
                Button("Snaphost Current Page Portion", action: copyCurrentPagePortion)
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
    static let newTab = Self("new_tab", default: .init(.t, modifiers: .command))
    static let newWindow = Self("new_window", default: .init(.n, modifiers: [.command]))
    static let newTemporaryWindow = Self("new_temporary_window", default: .init(.n, modifiers: [.command, .option]))
    static let newNoTraceWindow = Self("new_notrace_window", default: .init(.n, modifiers: [.command, .shift]))
    
    static let openFile = Self("open_file", default: .init(.o, modifiers: .command))
    
    static let closeTab = Self("close_tab", default: .init(.w, modifiers: .command))
    static let closeWindow = Self("close_window", default: .init(.w, modifiers: [.command, .shift]))
    static let closeAllWindows = Self("close_all_windows", default: .init(.w, modifiers: [.command, .option]))
    
    static let createQRCode = Self("create_qr_code")
    static let share = Self("share")
    static let snapshotCurrentPagePortion = Self("snapshot_current_page_portion")
    static let snapshotFullPage = Self("snapshot_full_page", default: .init(.two, modifiers: [.command, .shift]))
    
    static let savePageAs = Self("save_page_as", default: .init(.s, modifiers: [.command, .shift]))
    
    static let print = Self("print", default: .init(.p, modifiers: .command))
}

extension [KeyboardShortcuts.Name] {
    static let allFileCommands: [KeyboardShortcuts.Name] = [.newTab, .newWindow, .newTemporaryWindow, .newNoTraceWindow, .openFile, .closeTab, .closeWindow, .closeAllWindows, .createQRCode, .share, .snapshotCurrentPagePortion, .snapshotFullPage, .savePageAs, .print]
}
