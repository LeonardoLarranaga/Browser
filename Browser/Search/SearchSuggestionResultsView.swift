//
//  SearchResultsView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/3/25.
//

import SwiftUI

/// View that displays the search suggestions
struct SearchSuggestionResultsView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(BrowserWindow.self) var browserWindow
    
    var searchManager: SearchManager
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 5) {
                    // Based on index for the highlighted search suggestion
                    ForEach(Array(zip(searchManager.searchSuggestions.indices, searchManager.searchSuggestions)), id: \.0) { index, searchSuggestion in
                        SearchSuggestionResultItem(searchManager: searchManager, index: index, searchSuggestion: searchSuggestion, searchOpenLocation: browserWindow.searchOpenLocation)
                            .id(index)
                            .onTapGesture {
                                searchManager.searchAction(searchSuggestion, browserWindow: browserWindow, using: modelContext)
                            }
                    }
                }
                .padding(.top, 5)
            }
            .scrollIndicators(.never)
            .scrollContentBackground(.hidden)
            // Scroll to the highlighted search suggestion
            .onChange(of: searchManager.highlightedSearchSuggestionIndex) { _, newValue in
                withAnimation(.browserDefault) {
                    proxy.scrollTo(newValue, anchor: .bottom)
                }
            }
        }
    }
}
