//
//  SearchManager.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/3/25.
//

import SwiftUI
import SwiftData

/// `SearchManager` manages the search action and search suggestions
@Observable
class SearchManager {

    var searchText = ""
    var searchSuggestions: [SearchSuggestion] = []
    var highlightedSearchSuggestionIndex: Int = 0
    var favicon: Data?
    
    /// The autocomplete text from the first history suggestion
    var autocompleteText: String {
        guard !searchText.isEmpty,
              let firstHistoryItem = searchSuggestions.first(where: { $0.isHistoryItem }),
              firstHistoryItem.title.lowercased().hasPrefix(searchText.lowercased()) else {
            return ""
        }
        let remainingText = String(firstHistoryItem.title.dropFirst(searchText.count))
        return searchText + remainingText
    }
    
    /// The autocomplete suggestion to use when Enter is pressed
    var autocompleteSuggestion: SearchSuggestion? {
        guard !autocompleteText.isEmpty else { return nil }
        return searchSuggestions.first(where: { $0.isHistoryItem && $0.title.lowercased().hasPrefix(searchText.lowercased()) })
    }

    private var _accentColor: Color?
    var accentColor: Color {
        if isUsingWebsiteSearcher {
            return activeWebsiteSearcher.color
        } else {
            return _accentColor ?? Preferences.shared.defaultWebsiteSearcher.color
        }
    }

    var matchedWebsiteSearcher: any WebsiteSearcher {
        guard !searchText.isEmpty else { return Preferences.shared.defaultWebsiteSearcher }
        return SearchEngine.allSearchers.first(where: { $0.title.lowercased().hasPrefix(searchText.lowercased()) }) ?? Preferences.shared.defaultWebsiteSearcher
    }
    var isUsingWebsiteSearcher: Bool = false
    private var _activeWebsiteSearcher: (any WebsiteSearcher)?
    var activeWebsiteSearcher: any WebsiteSearcher {
        get { _activeWebsiteSearcher ?? Preferences.shared.defaultWebsiteSearcher }
        set { _activeWebsiteSearcher = newValue }
    }

    var searchTask: URLSessionDataTask?

    /// Sets the initial values from the `BrowserWindow`
    /// - Parameter browserWindow: The `BrowserWindow` to get the initial values from
    func setInitialValuesFromWindowState(_ browserWindow: BrowserWindow) {
        if let accentColor = Color(hex: browserWindow.currentSpace?.colors.first ?? "") {
            self._accentColor = accentColor
        }

        if browserWindow.searchOpenLocation == .fromURLBar {
            searchText = browserWindow.currentSpace?.currentTab?.url.absoluteString ?? ""
            favicon = browserWindow.currentSpace?.currentTab?.favicon
        }
    }

    /// Handles the search action
    /// - Parameters: searchText: The autocomplete text to search
    func fetchSearchSuggestions(_ searchText: String, historyEntries: [BrowserHistoryEntry]) {
        searchInHistory(in: historyEntries, for: searchText)
        activeWebsiteSearcher.fetchSearchSuggestions(for: searchText, in: self)
    }

    /// Move the highlighted search suggestion index up
    func handleUpArrow() -> KeyPress.Result {
        guard !searchSuggestions.isEmpty else { return .ignored }

        if highlightedSearchSuggestionIndex > 0 {
            highlightedSearchSuggestionIndex -= 1
        } else {
            highlightedSearchSuggestionIndex = searchSuggestions.count - 1
        }
        return .handled
    }

    /// Move the highlighted search suggestion index down
    func handleDownArrow() -> KeyPress.Result {
        guard !searchSuggestions.isEmpty else { return .ignored }

        if highlightedSearchSuggestionIndex < searchSuggestions.count - 1 {
            highlightedSearchSuggestionIndex += 1
        } else {
            highlightedSearchSuggestionIndex = 0
        }
        return .handled
    }

    /// Handle the tab key press, switches the search engine
    func handleTab() -> KeyPress.Result {
        withAnimation(.browserDefault) {
            if isUsingWebsiteSearcher {
                resetWebsiteSearcher()
            } else if matchedWebsiteSearcher.title != Preferences.shared.defaultWebsiteSearcher.title {
                isUsingWebsiteSearcher = true
                activeWebsiteSearcher = matchedWebsiteSearcher
                searchText = ""
            }
        }

        return .handled
    }

    /// Open a new tab with the selected search suggestion
    /// - Parameters: searchSuggestion: The selected search suggestion
    /// - Parameters: browserWindow: The current `BrowserWindow`
    /// - Parameters: modelContext: The current `ModelContext`
    private func openNewTab(_ searchSuggestion: SearchSuggestion, browserWindow: BrowserWindow, using modelContext: ModelContext) {
        guard let currentSpace = browserWindow.currentSpace else { return }
        let newTab = BrowserTab(title: searchSuggestion.title, url: searchSuggestion.suggestedURL, order: 0, browserSpace: currentSpace)

        do {
            currentSpace.tabs.append(newTab)
            try modelContext.save()
        } catch {
            print("Error opening new tab: \(error)")
        }

        currentSpace.currentTab = newTab
    }

    /// Opens the search suggestion in the current tab
    /// - Parameters: searchSuggestion: The selected search suggestion
    /// - Parameters: browserWindow: The current `BrowserWindow`
    /// - Parameters: modelContext: The current `ModelContext`
    private func openInCurrentTab(_ searchSuggestion: SearchSuggestion, browserWindow: BrowserWindow, using modelContext: ModelContext) {
        if let currentTab = browserWindow.currentSpace?.currentTab {
            currentTab.url = searchSuggestion.suggestedURL
            currentTab.webview?.load(URLRequest(url: searchSuggestion.suggestedURL))
            currentTab.updateFavicon(with: searchSuggestion.suggestedURL)
        } else {
            openNewTab(searchSuggestion, browserWindow: browserWindow, using: modelContext)
        }
    }

    func searchAction(_ searchSuggestion: SearchSuggestion, browserWindow: BrowserWindow, using modelContext: ModelContext) {
        if browserWindow.searchOpenLocation == .fromNewTab {
            openNewTab(searchSuggestion, browserWindow: browserWindow, using: modelContext)
        } else {
            openInCurrentTab(searchSuggestion, browserWindow: browserWindow, using: modelContext)
        }

        // Closes the search bar
        DispatchQueue.main.async {
            browserWindow.searchOpenLocation = .none
        }
    }

    func resetWebsiteSearcher() {
        isUsingWebsiteSearcher = false
        _activeWebsiteSearcher = nil
    }

    /// Adds history entries that match the search query to the search suggestions
    private func searchInHistory(in historyEntries: [BrowserHistoryEntry], for query: String) {
        guard !query.isReallyEmpty else {
            searchSuggestions = []
            return
        }

        let matchedEntries = historyEntries
            .filter { "\($0.title)\($0.url)".localizedCaseInsensitiveContains(query) }

        let suggestions = matchedEntries.map {
            SearchSuggestion($0.title, itemURL: $0.url, favicon: $0.favicon)
        }
        searchSuggestions = suggestions
    }
}
