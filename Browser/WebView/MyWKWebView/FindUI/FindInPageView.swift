//
//  FindInPageView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 30/1/26.
//

import SwiftUI

/// A custom view to find text in a web page.
struct FindInPageView: View {

    @Environment(BrowserTab.self) var tab

    @State var searchText: String = ""
    @FocusState var isFocused: Bool
    @State private var isSearching: Bool = false

    /// Debounce task for search
    @State private var searchTask: Task<Void, Never>?

    /// The find manager from the tab
    private var findManager: FindInPageManager {
        if tab.findInPageManager == nil {
            tab.findInPageManager = FindInPageManager(webView: tab.webview)
        }
        return tab.findInPageManager!
    }

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")

            HStack(spacing: 0) {
                TextField("Find In Page...", text: $searchText)
                    .focused($isFocused)
                    .task {
                        // Initialize search text from manager if it has one
                        if !findManager.searchQuery.isEmpty {
                            searchText = findManager.searchQuery
                        }
                    }
                    .textFieldStyle(.plain)
                    .frame(maxWidth: 200)
                    .onChange(of: searchText) { _, newValue in
                        performSearch(query: newValue)
                    }
                    .onSubmit {
                        goToNext()
                    }

                // Match count indicator
                if isSearching {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.leading, 4)
                } else if findManager.totalMatches > 0 {
                    Text("\(findManager.currentMatch) of \(findManager.totalMatches)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                } else if !searchText.isEmpty {
                    Text("No matches")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
            }

            Button("Go Previous", systemImage: "arrow.up", action: goToPrevious)
                .disabled(findManager.totalMatches == 0)

            Button("Go Next", systemImage: "arrow.down", action: goToNext)
                .disabled(findManager.totalMatches == 0)

            Button("Close", systemImage: "xmark", action: close)
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 8))
        .contentShape(.rect(cornerRadius: 8))
        .onKeyPress(.escape) {
            close()
            return .handled
        }
        .task {
            // Initialize the manager with the webView
            findManager.setWebView(tab.webview)
        }
        .onChange(of: tab.showFindUI) {
            if tab.showFindUI {
                isFocused = true
            }
        }
    }

    /// Performs search with debouncing
    private func performSearch(query: String) {
        searchTask?.cancel()
        
        // If query is empty, clear immediately
        if query.isEmpty {
            isSearching = false
            Task {
                await findManager.clear()
            }
            return
        }
        
        // Show searching state immediately
        isSearching = true
        
        searchTask = Task {
            // Small delay for debouncing
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
            
            await findManager.search(query)
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                isSearching = false
            }
        }
    }

    /// Go to the next match
    private func goToNext() {
        Task {
            await findManager.goToNextMatch()
        }
    }

    /// Go to the previous match
    private func goToPrevious() {
        Task {
            await findManager.goToPreviousMatch()
        }
    }

    /// Close the find UI (hides but preserves state)
    func close() {
        tab.showFindUI = false
    }
}
