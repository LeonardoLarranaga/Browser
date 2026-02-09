//
//  JavaScript.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 4/2/26.
//

enum JavaScript {
    /// Get a JavaScript script from the main bundle in WebView/JavaScript directory
    static func getBundled(_ scriptName: String) -> String? {
        guard let url = Bundle.main.url(forResource: scriptName, withExtension: "js"),
              let script = try? String(contentsOf: url, encoding: .utf8)
        else { return nil }
        return script
    }
}
