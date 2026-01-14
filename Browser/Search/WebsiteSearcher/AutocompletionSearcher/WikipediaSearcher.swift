//
//  WikipediaSearcher.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/9/25.
//

import SwiftUI

/// Searcher for Wikipedia
struct WikipediaSearcher: WebsiteSearcher {
    var title = "Wikipedia"
    var hexColor = "#A3A9B0"
    
    func queryURL(for query: String) -> URL? {
        URL(string: "https://en.wikipedia.org/w/rest.php/v1/search/title?q=\(query)&limit=10")!
    }
    
    func itemURL(for query: String) -> URL {
        URL(string: "https://en.wikipedia.org/wiki/Special:Search?go=Go&search=\(query)")!
    }
    
    func parseSearchSuggestions(from result: String) throws -> [SearchSuggestion] {
        struct Response: Decodable {
            struct Page: Decodable {
                let id: Int
                let key: String
                let title: String
                let description: String?
                let thumbnail: Thumbnail?
                
                struct Thumbnail: Decodable {
                    let url: String
                }
            }
            
            let pages: [Page]
        }
        
        let data = Data(result.utf8)
        let response = try JSONDecoder().decode(Response.self, from: data)
        
        return response.pages.map { page in
            SearchSuggestion(
                "\(page.title) (\(page.description ?? ""))",
                itemURL: itemURL(for: page.key),
                favicon: page.thumbnail.flatMap { URL(string: "https:\($0.url)") }
            )
        }
    }
}
