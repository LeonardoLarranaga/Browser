//
//  SearchView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/3/25.
//

import SwiftData
import SwiftUI

/// View that displays the search view with a text field and search suggestion results
struct SearchView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(BrowserWindow.self) var browserWindow
    
    @State var searchManager = SearchManager()
    @Query(BrowserHistoryEntry.searchDescriptor) var historyEntries: [BrowserHistoryEntry]

    var body: some View {
        VStack(spacing: 0) {
            SearchTextField(searchManager: searchManager)
                .frame(height: 25)
            
            Divider()
                .padding(.top, 5)
            
            SearchSuggestionResultsView(searchManager: searchManager)
        }
        .foregroundStyle(colorScheme == .light ? .black : .white)
        .padding([.horizontal, .top], 15)
        .onKeyPress(.escape) {
            closeSearchView()
            return .handled
        }
        .onKeyPress(.return) {
            // Use autocomplete suggestion if available and user is at the default (first) selection
            let suggestionToUse: SearchSuggestion
            if searchManager.highlightedSearchSuggestionIndex == 0,
               let autocompleteSuggestion = searchManager.autocompleteSuggestion {
                suggestionToUse = autocompleteSuggestion
            } else if !searchManager.searchSuggestions.isEmpty {
                suggestionToUse = searchManager.searchSuggestions[searchManager.highlightedSearchSuggestionIndex]
            } else {
                return .ignored
            }
            
            searchManager.searchAction(suggestionToUse, browserWindow: browserWindow, using: modelContext)
            return .handled
        }
        .onKeyPress(.upArrow, action: searchManager.handleUpArrow)
        .onKeyPress(.downArrow, action: searchManager.handleDownArrow)
        .onKeyPress(.tab, action: searchManager.handleTab)
        .onChange(of: searchManager.searchText) { _, newValue in
            if newValue.last != " " {
                searchManager.fetchSearchSuggestions(newValue, historyEntries: historyEntries)
            }
        }
        .onChange(of: browserWindow.searchOpenLocation) {
            if browserWindow.searchOpenLocation != .none {
                searchManager.setInitialValuesFromWindowState(browserWindow)
            } else {
                searchManager.isUsingWebsiteSearcher = false
                searchManager.activeWebsiteSearcher = Preferences.shared.defaultWebsiteSearcher
            }
        }
    }
    
    func closeSearchView() {
        DispatchQueue.main.async {
            browserWindow.searchOpenLocation = .none
        }
    }
}

#Preview {
    SearchView()
}
