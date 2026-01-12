//
//  GoogleSearcher.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/8/25.
//

import SwiftUI

/// Searcher for Google
struct GoogleSearcher: WebsiteSearcher {
    var title = "Google"
    var color = Color(hex: "#5383EC")!
    
    func queryURL(for query: String) -> URL? {
        URL(string: "https://suggestqueries.google.com/complete/search?client=safari&q=\(query)")
    }
    
    func itemURL(for query: String) -> URL {
        URL(string: "https://www.google.com/search?q=\(query)")!
    }
    
    func parseSearchSuggestions(from result: String) throws -> [SearchSuggestion] {
        return try parseSearchSuggestions(from: result, droppingFirst: 1, droppingLast: 3)
    }
}
    

