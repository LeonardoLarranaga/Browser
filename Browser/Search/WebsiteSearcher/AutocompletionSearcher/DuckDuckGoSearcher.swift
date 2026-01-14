//
//  DuckDuckGoSearcher.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 11/1/26.
//

import SwiftUI

struct DuckDuckGoSearcher: WebsiteSearcher {
    var title = "DuckDuckGo"
    var hexColor = "#E37151"

    func queryURL(for query: String) -> URL? {
        URL(string: "https://duckduckgo.com/ac/?q=\(query)&type=list")!
    }

    func itemURL(for query: String) -> URL {
        URL(string: "https://duckduckgo.com/?q=\(query)")!
    }

    func parseSearchSuggestions(from result: String) throws -> [SearchSuggestion] {
        try parseSearchSuggestions(from: result, droppingFirst: 1, droppingLast: 0)
    }
}
