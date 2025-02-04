//
//  SearchSuggestionResultItem.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/3/25.
//

import SwiftUI

/// A view that represents a search suggestion result item
struct SearchSuggestionResultItem: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Bindable var searchManager: SearchManager
    let index: Int
    let searchSuggestion: SearchSuggestion
    
    @State var isHovering = false
    
    var body: some View {
        HStack {
            searchSuggestion.searchIcon
                .padding(.leading, .sidebarPadding)
            
            Text(searchSuggestion.title)
                .font(searchManager.searchOpenLocation == .fromNewTab ? .title3 : .body)
        }
        .frame(height: 45)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Highlight the selected search suggestion item or the hovered item
        .background(searchManager.highlightedSearchSuggestionIndex == index ?
                    searchManager.accentColor :
                        isHovering ?
                    colorScheme == .light ? AnyShapeStyle(.ultraThinMaterial) :
                        AnyShapeStyle(.gray.opacity(0.5)) :
                        AnyShapeStyle(.clear)
        )
        .clipShape(.rect(cornerRadius: 10))
        .onHover { isHovering = $0 }
    }
}
