//
//  BrowserWindow.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/28/25.
//

import SwiftUI
import SwiftData

/// The BrowserWindow is an Observable class that holds the current state of the browser window
@Observable class BrowserWindow {

    var currentSpace: BrowserSpace? = nil {
        didSet {
            if isMainBrowserWindow && !isNoTraceWindow {
                Preferences.currentBrowserSpace = currentSpace?.id
            }
        }
    }
    var viewScrollState: UUID?

    var searchOpenLocation: SearchOpenLocation? = .none
    var searchPanelOrigin: CGPoint {
        searchOpenLocation == .fromNewTab || Preferences.urlBarPosition == .onToolbar ? .zero : CGPoint(x: 5, y: 50)
    }
    var searchPanelSize: CGSize {
        searchOpenLocation == .fromNewTab || Preferences.urlBarPosition == .onToolbar ? CGSize(width: 700, height: 300) : CGSize(width: 400, height: 300)
    }

    var showURLQRCode = false
    var showAcknowledgements = false

    var actionAlert = ActionAlert()

    var isFullScreen = false

    var showTabSwitcher = false

    private(set) var isMainBrowserWindow: Bool = true
    private(set) var isNoTraceWindow: Bool = false

    let tabUndoManager: TabUndoManager

    init() {
        self.tabUndoManager = TabUndoManager()
        DispatchQueue.main.async {
            if let windowId = NSApp.keyWindow?.identifier?.rawValue {
                self.isMainBrowserWindow = windowId.hasPrefix("BrowserWindow")
                self.isNoTraceWindow = windowId.hasPrefix("BrowserNoTraceWindow")
            }
        }
        self.tabUndoManager.browserWindow = self
    }

    /// Loads the current space from Preferences and sets it as the current space
    @Sendable
    func loadCurrentSpace(browserSpaces: [BrowserSpace]) {
        guard let uuid = Preferences.currentBrowserSpace else { return }
        if let space = browserSpaces.first(where: { $0.id == uuid }) {
            goToSpace(space)
        }
    }

    /// Toggles the search open location between the URL bar and the new tab
    func toggleNewTabSearch() {
        if spaceCanOpenNewTab() {
            searchOpenLocation = searchOpenLocation == .fromNewTab ? .none : .fromNewTab
        } else {
            searchOpenLocation = .none
        }
    }

    /// Checks if the current space can open a new tab
    func spaceCanOpenNewTab() -> Bool {
        !(currentSpace == nil || currentSpace?.name.isEmpty == true)
    }

    /// Goes to a space in the browser
    func goToSpace(_ space: BrowserSpace?) {
        withAnimation(.browserDefault) {
            self.currentSpace = space
            self.viewScrollState = space?.id
        }
    }

    /// Copies the URL of the current tab to the clipboard
    func copyURLToClipboard() {
        if let currentTab = currentSpace?.currentTab {
            currentTab.copyLink()
            presentActionAlert(message: "Copied Current URL", systemImage: "link")
        }
    }

    /// Presents an action alert with a message and a system image
    func presentActionAlert(message: String, systemImage: String) {
        withAnimation(.browserDefault) {
            actionAlert.present(message: message, systemImage: systemImage)
        }
    }

    func backButtonAction() {
        guard let currentSpace = currentSpace,
              let currentTab = currentSpace.currentTab,
              let backItem = currentTab.webview?.backForwardList.backItem
        else { return }

        if NSEvent.modifierFlags.contains(.command) {
            let newTab = BrowserTab(title: backItem.title ?? "", favicon: nil, url: backItem.url, browserSpace: currentSpace)
            currentSpace.tabs.insert(newTab, at: currentTab.order + 1)
            currentSpace.currentTab = newTab
        } else {
            currentTab.webview?.goBack()
        }
    }

    func forwardButtonAction() {
        guard let currentSpace = currentSpace,
              let currentTab = currentSpace.currentTab,
              let forwardItem = currentTab.webview?.backForwardList.forwardItem
        else { return }

        if NSEvent.modifierFlags.contains(.command) {
            let newTab = BrowserTab(title: forwardItem.title ?? "", favicon: nil, url: forwardItem.url, browserSpace: currentSpace)
            currentSpace.tabs.insert(newTab, at: currentTab.order + 1)
            currentSpace.currentTab = newTab
        } else {
            currentTab.webview?.goForward()
        }
    }

    func refreshButtonAction() {
        guard let currentSpace = currentSpace,
              let currentTab = currentSpace.currentTab
        else { return }

        if NSEvent.modifierFlags.contains(.command) {
            let newTab = BrowserTab(title: currentTab.title, favicon: currentTab.favicon, url: currentTab.url, browserSpace: currentSpace)
            currentSpace.tabs.insert(newTab, at: currentTab.order + 1)
            currentSpace.currentTab = newTab
        } else {
            currentTab.reload()
        }
    }
}
