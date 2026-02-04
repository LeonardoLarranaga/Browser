//
//  SearchTextField.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/3/25.
//

import SwiftUI

/// Search text field that shows the favicon of the search engine
struct SearchTextField: View {
    
    @Environment(BrowserWindow.self) var browserWindow
    
    /// Enum to focus the search text field when it appears
    enum FocusedField {
        case search
        case unfocused
    }
    
    @Bindable var searchManager: SearchManager
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        HStack {
            searchIcon
                .padding(.leading, 5)
            
            if searchManager.isUsingWebsiteSearcher {
                Text(searchManager.activeWebsiteSearcher.title)
                    .padding(5)
                    .background(searchManager.activeWebsiteSearcher.color)
                    .clipShape(.rect(cornerRadius: 8))
            }
            
            ZStack(alignment: .leading) {
                // Autocomplete overlay text
                if !searchManager.autocompleteText.isEmpty {
                    TextField("", text: .constant(searchManager.autocompleteText))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .disabled(true)
                }
                
                TextField("Where to?", text: $searchManager.searchText)
                    .focused($focusedField, equals: .search)

            }
            .textFieldStyle(.plain)
            .font(browserWindow.searchOpenLocation == .fromNewTab ? .title2.weight(.semibold) : .body)

            Spacer()
            
            Group {
              if !searchManager.isUsingWebsiteSearcher && !searchManager.matchedWebsiteSearcher.equals(Preferences.shared.defaultWebsiteSearcher) {
                    Text("Search with \(searchManager.matchedWebsiteSearcher.title)")
                    
                    Text("Tab")
                        .padding(5)
                        .background(.secondary.opacity(0.2))
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .foregroundStyle(.secondary)
            .padding(.trailing, 5)
        }
        .onChange(of: browserWindow.searchOpenLocation) { _, newValue in
            focusedField = newValue != .none ? .search : .unfocused
            if newValue == .fromURLBar {
                NSApp.selectAllText()
            } else {
                searchManager.searchText = ""
            }
        }
    }
    
    var searchIcon: some View {
        Group {
            if let favicon = searchManager.favicon, let nsImage = NSImage(data: favicon) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "magnifyingglass")
            }
        }
        .frame(width: 15, height: 15)
    }
}
