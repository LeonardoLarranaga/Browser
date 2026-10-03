//
//  ViewCommands.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/9/25.
//

import KeyboardShortcuts
import SwiftUI

struct ViewCommands: Commands {

    @FocusedValue(\.browserActiveWindowState) private var browserWindow
    @FocusedValue(\.sidebarModel) private var sidebarModel

    private var currentTab: BrowserTab? {
        browserWindow?.currentSpace?.currentTab
    }

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

            if let currentTab {
                Button("Stop Loading", action: currentTab.webview?.stopLoading)
                    .globalKeyboardShortcut(.stopLoading)
                    .disabled(currentTab.webview?.isLoading != true)
                Button("Reload This Page", action: currentTab.reload)
                    .globalKeyboardShortcut(.reload)
                Button("Clear Cookies And Reload") {
                    currentTab.clearError()
                    currentTab.webview?.clearCookiesAndReload()
                }
                .globalKeyboardShortcut(.clearCookiesAndReload)
                Button("Clear Cache And Reload") {
                    currentTab.clearError()
                    currentTab.webview?.clearCacheAndReload()
                }
                .globalKeyboardShortcut(.clearCacheAndReload)

                Divider()

                Button("Toggle Picture In Picture", action: currentTab.webview?.togglePictureInPicture)
                    .globalKeyboardShortcut(.togglePictureInPicture)

                Divider()

                Button("Zoom Actual Size", action: currentTab.webview?.zoomActualSize)
                    .globalKeyboardShortcut(.zoomActualSize)
                Button("Zoom In", action: currentTab.webview?.zoomIn)
                    .globalKeyboardShortcut(.zoomIn)
                Button("Zoom Out", action: currentTab.webview?.zoomOut)
                    .globalKeyboardShortcut(.zoomOut)

                Divider()

                Menu("Developer") {
                    Button("Toggle Web Inspector", action: currentTab.webview?.toggleDeveloperTools)
                        .globalKeyboardShortcut(.openDeveloperTools)

                    Button("Show JavaScript Console", action: currentTab.webview?.showJavaScriptConsole)
                        .globalKeyboardShortcut(.showJavaScriptConsole)

                    Button("Show Page Resources", action: currentTab.webview?.showPageResources)
                        .globalKeyboardShortcut(.showPageResources)
                }

                Divider()
            }
        }
    }
}

extension KeyboardShortcuts.Name {
    static let toggleSidebar = Self(localized: "Toggle Sidebar", default: .init(.s, modifiers: .command))

    static let showTabSwitcher = Self(localized: "Show Tab Switcher", default: .init(.tab, modifiers: .control))
    
    static let stopLoading = Self(localized: "Stop Loading", default: .init(.period, modifiers: .command))
    static let reload = Self(localized: "Reload This Page", default: .init(.r, modifiers: .command))
    static let clearCookiesAndReload = Self(localized: "Clear Cookies And Reload")
    static let clearCacheAndReload = Self(localized: "Clear Cache And Reload")

    static let togglePictureInPicture = Self(localized: "Toggle Picture In Picture")

    static let zoomActualSize = Self(localized: "Zoom Actual Size", default: .init(.zero, modifiers: .command))
    static let zoomIn = Self(localized: "Zoom In", default: .init(.equal, modifiers: .command))
    static let zoomOut = Self(localized: "Zoom Out", default: .init(.minus, modifiers: .command))

    static let openDeveloperTools = Self(localized: "Toggle Web Inspector", default: .init(.i, modifiers: [.option, .command]))
    static let showJavaScriptConsole = Self(localized: "Show JavaScript Console", default: .init(.c, modifiers: [.option, .command]))
    static let showPageResources = Self(localized: "Show Page Resources", default: .init(.u, modifiers: [.option, .command]))
}

extension [KeyboardShortcuts.Name] {
    static let allViewCommands: [KeyboardShortcuts.Name] = [.toggleSidebar, .showTabSwitcher, .stopLoading, .reload, .clearCookiesAndReload, .clearCacheAndReload, .togglePictureInPicture, .zoomActualSize, .zoomIn, .zoomOut, .openDeveloperTools, .showJavaScriptConsole, .showPageResources]
}
