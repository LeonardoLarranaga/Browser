//
//  ViewCommands.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/9/25.
//

import SwiftUI
import KeyboardShortcuts

struct ViewCommands: Commands {
    
    @FocusedValue(\.browserActiveWindowState) var browserWindow
    @FocusedValue(\.sidebarModel) var sidebarModel
    
    var body: some Commands {
        CommandGroup(replacing: .toolbar) {
            Button("Toggle Sidebar", action: sidebarModel?.toggleSidebar)
                .globalKeyboardShortcut(.toggleSidebar)
            
            Divider()
            
            Button("Show Tab Switcher") {
                browserWindow?.showTabSwitcher = true
            }
            .globalKeyboardShortcut(.showTabSwitcher)
            
            Divider()
            
            if let tab = browserWindow?.currentSpace?.currentTab, let webView = tab.webview {
                Button("Stop Loading") { webView.stopLoading() }
                    .globalKeyboardShortcut(.stopLoading)
                    .disabled(!webView.isLoading)
                Button("Reload This Page") {
                    tab.clearError()
                    webView.reload()
                }
                .globalKeyboardShortcut(.reload)
                Button("Clear Cookies And Reload") {
                    tab.clearError()
                    webView.clearCookiesAndReload()
                }
                .globalKeyboardShortcut(.clearCookiesAndReload)
                Button("Clear Cache And Reload") {
                    tab.clearError()
                    webView.clearCacheAndReload()
                }
                .globalKeyboardShortcut(.clearCacheAndReload)
                
                Divider()
                
                Button("Toggle Picture In Picture", action: webView.togglePictureInPicture)
                    .globalKeyboardShortcut(.togglePictureInPicture)
                
                Divider()
                
                Button("Zoom Actual Size", action: webView.zoomActualSize)
                    .globalKeyboardShortcut(.zoomActualSize)
                Button("Zoom In", action: webView.zoomIn)
                    .keyboardShortcut("+", modifiers: .command)
                Button("Zoom Out", action: webView.zoomOut)
                    .globalKeyboardShortcut(.zoomOut)
                
                Divider()

                Menu("Developer") {
                    Button("Toggle Web Inspector", action: webView.toggleDeveloperTools)
                        .globalKeyboardShortcut(.openDeveloperTools)

                    Button("Show JavaScript Console", action: webView.showJavaScriptConsole)
                        .globalKeyboardShortcut(.showJavaScriptConsole)

                    Button("Show Page Resources", action: webView.showPageResources)
                        .globalKeyboardShortcut(.showPageResources)
                }

                Divider()
            }
        }
    }
}

extension KeyboardShortcuts.Name {
    static let toggleSidebar = Self("toggle_sidebar", default: .init(.s, modifiers: .command))
    
    static let showTabSwitcher = Self("show_tab_switcher", default: .init(.tab, modifiers: .control))
    
    static let stopLoading = Self("stop_loading", default: .init(.period, modifiers: .command))
    static let reload = Self("reload", default: .init(.r, modifiers: .command))
    static let clearCookiesAndReload = Self("clear_cookies_and_reload")
    static let clearCacheAndReload = Self("clear_cache_and_reload")
    
    static let togglePictureInPicture = Self("toggle_picture_in_picture")
    
    static let zoomActualSize = Self("zoom_actual_size", default: .init(.zero, modifiers: .command))
    static let zoomIn = Self("zoom_in", default: .init(.equal, modifiers: .command))
    static let zoomOut = Self("zoom_out", default: .init(.minus, modifiers: .command))
    
    static let openDeveloperTools = Self("open_developer_tools", default: .init(.i, modifiers: [.option, .command]))
    static let showJavaScriptConsole = Self("show_javascript_console", default: .init(.c, modifiers: [.option, .command]))
    static let showPageResources = Self("show_page_resources", default: .init(.u, modifiers: [.option, .command]))
}

extension [KeyboardShortcuts.Name] {
    static let allViewCommands: [KeyboardShortcuts.Name] = [.toggleSidebar, .showTabSwitcher, .stopLoading, .reload, .clearCookiesAndReload, .clearCacheAndReload, .togglePictureInPicture, .zoomActualSize, .zoomIn, .zoomOut, .openDeveloperTools, .showJavaScriptConsole, .showPageResources]
}
