//
//  WebsiteSearcher.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/8/25.
//

import SwiftUI

/// Protocol to define a website searcher, used to fetch search suggestions directly from a website.
protocol WebsiteSearcher: Codable {
    /// The title of the website searcher, example: "Google"
    var title: String { get }
    /// The hex color representation of the website searcher, example: "#4285F4"
    var hexColor: String { get }
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
    /// The color of the website searcher, used to display the search suggestions
    var color: Color { Color(hex: hexColor)! }

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

        // Store history suggestions to preserve them
        let historySuggestions = searchManager.searchSuggestions
        
        // Insert the query suggestion at the beginning
        searchManager.searchSuggestions = [SearchSuggestion(query, itemURL: itemURL(for: query))] + historySuggestions

        guard let queryURL = queryURL(for: query) else { return }
        searchManager.searchTask = URLSession.shared.dataTask(with: queryURL) { data, response, error in
            guard let data = data, error == nil else {
                if let error = error as? URLError, error.code != .cancelled {
                    print("🔍📡 Error fetching search \"\(query)\" suggestions: \(error.localizedDescription)")
                }
                return
            }

            guard let resultString = String(data: data, encoding: .isoLatin1) else {
                print("🔍📡 Error parsing search suggestions. Invalid string data.")
                return
            }

            do {
                let suggestions = try parseSearchSuggestions(from: resultString)
                // Preserve the query suggestion (first item) and history suggestions, then append search results
                if let first = searchManager.searchSuggestions.first {
                    searchManager.searchSuggestions = [first] + historySuggestions + suggestions
                }
            } catch {
                print("🔍📡 Error parsing search suggestions: \(error.localizedDescription)")
            }
        }
        searchManager.searchTask?.resume()
    }

    func equals(_ other: WebsiteSearcher) -> Bool {
        self.title == other.title &&
        self.itemURL(for: "").absoluteString == other.itemURL(for: "").absoluteString
    }
}
