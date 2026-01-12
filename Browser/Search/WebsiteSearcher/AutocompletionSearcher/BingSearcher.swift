//
//  BingSearcher.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/8/25.
//

import SwiftUI

/// Searcher for Bing
struct BingSearcher: WebsiteSearcher {
    var title = "Bing"
    var color = Color(hex: "02B7E9")!
    
    func queryURL(for query: String) -> URL? {
        URL(string: "https://www.bing.com/asjson.aspx?query=\(query)")
    }
    
    func itemURL(for query: String) -> URL {
        URL(string: "https://www.bing.com/search?q=\(query)")!
    }
    
    func parseSearchSuggestions(from result: String) throws -> [SearchSuggestion] {
        try parseSearchSuggestions(from: result, droppingFirst: 1, droppingLast: 1)
    }
}
