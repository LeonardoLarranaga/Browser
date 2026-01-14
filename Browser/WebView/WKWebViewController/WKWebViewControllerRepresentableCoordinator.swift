//
//  WKWebViewControllerRepresentableCoordinator.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/22/25.
//

import Combine
import SwiftUI
import SwiftData
import WebKit

extension WKWebViewControllerRepresentable {
    /// Coordinator class to handle view controller events between SwiftUI and WebKit
    class Coordinator: NSObject {
        var parent: WKWebViewControllerRepresentable
        
        private var cancellables = Set<AnyCancellable>()
        
        init(_ parent: WKWebViewControllerRepresentable) {
            self.parent = parent
        }
        
        /// Presents an alert with a message and a system image
        func presentActionAlert(message: String, systemImage: String) {
            self.parent.browserWindowState.presentActionAlert(message: message, systemImage: systemImage)
        }
        
        /// Starts a Google search with the query in a new tab
        func searchWebAction(_ query: String) {
            let newTab = BrowserTab(title: query, url: URL(string: "https://www.google.com/search?q=\(query)")!, order: self.parent.tab.order + 1, browserSpace: self.parent.browserSpace)
            self.parent.browserSpace.openNewTab(newTab, using: self.parent.modelContext)
        }
        
        /// Opens a link in a new tab
        func openLinkInNewTabAction(_ url: URL) {
            let newTab = BrowserTab(title: url.cleanHost, url: url, order: self.parent.tab.order + 1, browserSpace: self.parent.browserSpace)
            self.parent.browserSpace.openNewTab(newTab, using: self.parent.modelContext, select: false)
        }
        
        func addTabToHistory() {
            guard NSApp.isKeyWindowOfTypeMain else { return }
            do {
                var fetchDescriptor = FetchDescriptor<BrowserHistoryEntry>(
                    sortBy: [.init(\.date, order: .reverse)],
                )
                fetchDescriptor.fetchLimit = 1
                
                let lastHistoryEntry = try self.parent.modelContext.fetch(fetchDescriptor).first
                
                if let lastHistoryEntry, lastHistoryEntry.url == self.parent.tab.url {
                    lastHistoryEntry.date = Date()
                } else {
                    let historyEntry = BrowserHistoryEntry(title: self.parent.tab.title, url: self.parent.tab.url, favicon: self.parent.tab.favicon)
                    self.parent.modelContext.insert(historyEntry)
                }
                
                try self.parent.modelContext.save()
            } catch {
                print("Error saving history tab: \(error)")
            }
        }
        
        func toggleDownloadAnimation() {
            self.parent.sidebarModel.isAnimatingDownloads.toggle()
        }
        
        func createNewTabFromAction(_ navigationAction: WKNavigationAction) {
            if let url = navigationAction.request.url {
                let newTab = BrowserTab(title: url.cleanHost, url: url, order: self.parent.tab.order + 1, browserSpace: self.parent.browserSpace)
                self.parent.browserSpace.openNewTab(newTab, using: self.parent.modelContext, select: false)
                self.parent.browserSpace.currentTab = newTab
            }
        }
        
        /// Observes the webview to update the tab's properties, such as the title, favicon, url, and navigation buttons...
        func observeWebView(_ webview: MyWKWebView) {
            self.parent.tab.webview = webview
                        
            webview.publisher(for: \.canGoBack)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] canGoBack in
                    self?.parent.tab.canGoBack = canGoBack
                }
                .store(in: &cancellables)
            
            webview.publisher(for: \.canGoForward)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] canGoForward in
                    self?.parent.tab.canGoForward = canGoForward
                }
                .store(in: &cancellables)
            
            webview.publisher(for: \.url)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    guard let url else { return }
                    self?.parent.tab.url = url
                }
                .store(in: &cancellables)
            
            webview.publisher(for: \.title)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] title in
                    if let title, !title.isEmpty {
                        self?.parent.tab.title = title
                    } else {
                        self?.parent.tab.title = self?.parent.tab.url.cleanHost ?? ""
                    }
                }
                .store(in: &cancellables)
            
            webview.publisher(for: \.estimatedProgress)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] estimatedProgress in
                    self?.parent.tab.estimatedProgress = estimatedProgress
                }
                .store(in: &cancellables)
            webview.publisher(for: \.isLoading)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isLoading in
                    self?.parent.tab.isLoading = isLoading
                }
                .store(in: &cancellables)
        }
        
        func stopObservingWebView() {
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
            self.parent.tab.webview = nil
        }
        
        func setHoverURL(to url: String) {
            self.parent.hoverURL.wrappedValue = url
        }
    }
}
