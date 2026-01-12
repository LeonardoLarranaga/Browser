//
//  YoutubeSearcher.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/8/25.
//

import SwiftUI

/// Searcher for YouTube
struct YouTubeSearcher: WebsiteSearcher {
    var title = "Youtube"
    var color = Color.red
    
    func queryURL(for query: String) -> URL? {
        URL(string: "https://suggestqueries-clients6.youtube.com/complete/search?ds=yt&client=youtube&q=\(query)")
    }
    
    func itemURL(for query: String) -> URL {
        URL(string: "https://www.youtube.com/results?search_query=\(query)")!
    }
    
    func parseSearchSuggestions(from result: String) throws -> [SearchSuggestion] {
        try parseSearchSuggestions(from: result, droppingFirst: 1, droppingLast: 3)
    }
}
