//
//  SearchSuggestion.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/3/25.
//

import SwiftUI

/// A search suggestion that can be displayed in the search suggestions list
struct SearchSuggestion: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let itemURL: URL
    let favicon: (url: URL?, data: Data?)
    let isHistoryItem: Bool

    private var url: URL? {
        URL(string: title.startsWithHTTP ? title : "https://\(title)")
    }
    
    var isURLValid: Bool {
        title.isValidURL
    }
    
    var suggestedURL: URL {
        isURLValid ? url! : itemURL
    }
    
    init(_ title: String, itemURL: URL, favicon: URL? = nil) {
        self.title = title
        self.itemURL = itemURL
        self.favicon = (favicon, nil)
        self.isHistoryItem = false
    }

    init(_ title: String, itemURL: URL, favicon: Data?) {
        self.title = title
        self.itemURL = itemURL
        self.favicon = (nil, favicon)
        self.isHistoryItem = true
    }

    /// The icon of the search suggestion
    var searchIcon: some View {
        Group {
            if let url = favicon.url {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "globe")
                }
            } else if let data = favicon.data, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: isURLValid ? "globe" : "magnifyingglass")
            }
        }
        .frame(width: 15, height: 15)
    }
    
    // MARK: - Equatable
    static func == (lhs: SearchSuggestion, rhs: SearchSuggestion) -> Bool {
        lhs.id == rhs.id
    }
}
