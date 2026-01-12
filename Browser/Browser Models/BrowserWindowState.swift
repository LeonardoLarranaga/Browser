//
//  BrowserWindowState.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/28/25.
//

import SwiftUI
import SwiftData

/// The BrowserWindowState is an Observable class that holds the current state of the browser window
@Observable class BrowserWindowState {
    
    var currentSpace: BrowserSpace? = nil {
        didSet {
            if isMainBrowserWindow && !isNoTraceWindow {
                if let newValue = currentSpace {
                    UserDefaults.standard.set(newValue.id.uuidString, forKey: "currentBrowserSpace")
                } else {
                    UserDefaults.standard.removeObject(forKey: "currentBrowserSpace")
                }
            } else if isNoTraceWindow {
                print("No Trace Window", currentSpace?.name as Any)
            }
        }
    }
    var viewScrollState: UUID?
    
    var searchOpenLocation: SearchOpenLocation? = .none
    var searchPanelOrigin: CGPoint {
        searchOpenLocation == .fromNewTab || Preferences.shared.urlBarPosition == .onToolbar ? .zero : CGPoint(x: 5, y: 50)
    }
    var searchPanelSize: CGSize {
        searchOpenLocation == .fromNewTab || Preferences.shared.urlBarPosition == .onToolbar ? CGSize(width: 700, height: 300) : CGSize(width: 400, height: 300)
    }
    
    var showURLQRCode = false
    var showAcknowledgements = false
    
    var actionAlertMessage = ""
    var actionAlertSystemImage = ""
    var showActionAlert = false
    
    var isFullScreen = false
    
    var showTabSwitcher = false

    private(set) var isMainBrowserWindow: Bool = true
    private(set) var isNoTraceWindow: Bool = false
    
    init() {
        DispatchQueue.main.async {
            if let windowId = NSApp.keyWindow?.identifier?.rawValue {
                self.isMainBrowserWindow = windowId.hasPrefix("BrowserWindow")
                self.isNoTraceWindow = windowId.hasPrefix("BrowserNoTraceWindow")
            }
        }
    }
    
    /// Loads the current space from the UserDefaults and sets it as the current space
    @Sendable
    func loadCurrentSpace(browserSpaces: [BrowserSpace]) {
        guard let spaceId = UserDefaults.standard.string(forKey: "currentBrowserSpace"),
              let uuid = UUID(uuidString: spaceId) else { return }
        
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
        actionAlertMessage = message
        actionAlertSystemImage = systemImage
        withAnimation(.browserDefault) {
            showActionAlert = true
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
