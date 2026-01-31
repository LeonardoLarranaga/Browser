//
//  String.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 11/1/26.
//

extension String {
    /// A Boolean value indicating whether a string has no characters (including whitespace and newlines).
    var isReallyEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Get a JavaScript script from the main bundle in WebView/JavaScript directory
    static func javascriptScript(_ script: String) -> String? {
        guard let url = Bundle.main.url(forResource: script, withExtension: "js"),
              let script = try? String(contentsOf: url, encoding: .utf8)
        else { return nil }
        return script
    }
}
