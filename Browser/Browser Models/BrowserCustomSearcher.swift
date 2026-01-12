//
//  BrowserCustomSearcher.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/9/25.
//

import SwiftData
import SwiftUI

/// A custom website searcher that the user can add
struct BrowserCustomSearcher: Identifiable, Codable, WebsiteSearcher {
  var id = UUID().uuidString
  /// The name of the website to search, e.g. "Google"
  var website: String
  /// The query URL for the website, e.g. "https://www.google.com/search?q=%s"
  var queryURL: String
  /// The hex color code for the website
  var hexColor: String

  // WebsiteSearcher conformance
  var title: String { website }
  var color: Color { Color(hex: hexColor) ?? .blue }

  func itemURL(for query: String) -> URL {
    guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      return URL(string: queryURL)!
    }

    let pattern = "%s"
    let urlString = queryURL.replacingOccurrences(of: pattern, with: encodedQuery)

    return URL(string: urlString)!
  }
}
