//
//  WebsiteSearcher.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/8/25.
//

import SwiftUI

/// Protocol to define a website searcher, used to fetch search suggestions directly from a website.
protocol WebsiteSearcher {
    /// The title of the website searcher, example: "Google"
    var title: String { get }
    /// The color of the website searcher, used to display the search suggestions
    var color: Color { get }
    /// The URL to query the search suggestions, example: "https://suggestqueries.google.com/complete/search?client=safari&q="
    func queryURL(for query: String) -> URL?
    /// An optional URL to fetch the item, example: "https://www.google.com/search?q="
    func itemURL(for query: String) -> URL
    /// Parses the search suggestions from the string data fetched from the website
    func parseSearchSuggestions(from result: String) throws -> [SearchSuggestion]
    /// General implementation of the search suggestions fetcher
    func parseSearchSuggestions(from result: String, droppingFirst: Int, droppingLast: Int) throws -> [SearchSuggestion]
}

extension WebsiteSearcher {
    /// Empty implementation for searches without suggestions.
    func queryURL(for query: String) -> URL? {
        nil
    }
    
    /// Empty implementation for searches without suggestions.
    func parseSearchSuggestions(from result: String) throws -> [SearchSuggestion] {
        []
    }
    
    /// General implementation of the search suggestions parser.
    func parseSearchSuggestions(from result: String, droppingFirst: Int, droppingLast: Int) throws -> [SearchSuggestion] {
        let components = result.components(separatedBy: ",")
        guard !components.isEmpty else {
            print("🔍👓 Error parsing search suggestions. Empty components.")
            return []
        }
        
        let regex = try NSRegularExpression(pattern: #""(.*?)""#)
        
        let extractedStrings = components.flatMap { string -> [String] in
            let matches = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
            return matches.compactMap { match -> String? in
                if let range = Range(match.range(at: 1), in: string) {
                    let extracted = String(string[range])
                    return extracted.isEmpty || extracted.count == 1 ? nil :
                    // Process Unicode characters
                    extracted.applyingTransform(StringTransform("Hex-Any"), reverse: false) ?? extracted
                }
                return nil
            }
        }
        
        return extractedStrings.dropFirst(droppingFirst).dropLast(droppingLast).map {
            SearchSuggestion($0, itemURL: itemURL(for: $0))
        }
    }
    
    /// General implementation of the search suggestions fetcher.
    func fetchSearchSuggestions(for query: String, in searchManager: SearchManager) {
        searchManager.searchTask?.cancel()
        searchManager.highlightedSearchSuggestionIndex = 0
        
        guard !query.isEmpty else {
            searchManager.searchSuggestions = []
            return
        }
        
        if !searchManager.searchSuggestions.isEmpty {
            searchManager.searchSuggestions.removeFirst()
        }
        
        searchManager.searchSuggestions.insert(SearchSuggestion(query, itemURL: itemURL(for: query)), at: 0)
               
        guard let queryURL = queryURL(for: query) else { return }
        searchManager.searchTask = URLSession.shared.dataTask(with: queryURL) { data, response, error in
            guard let data = data, error == nil else {
                print("🔍📡 Error fetching search \"\(query)\" suggestions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let resultString = String(data: data, encoding: .isoLatin1) else {
                print("🔍📡 Error parsing search suggestions. Invalid string data.")
                return
            }
            
            do {
                let suggestions = try parseSearchSuggestions(from: resultString)
                if !suggestions.isEmpty && !searchManager.searchSuggestions.isEmpty {
                    if let first = searchManager.searchSuggestions.first {
                        searchManager.searchSuggestions = [first]
                    }
                }
                
                searchManager.searchSuggestions.append(contentsOf: suggestions)
            } catch {
                print("🔍📡 Error parsing search suggestions: \(error.localizedDescription)")
            }
        }
        searchManager.searchTask?.resume()
    }
}
