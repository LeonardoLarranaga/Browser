//
//  FindInPageManager.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 30/1/26.
//

import WebKit

/// Result from Find in Page JavaScript operations
struct FindInPageResult {
    let totalMatches: Int
    let currentMatch: Int

    static let empty = FindInPageResult(totalMatches: 0, currentMatch: 0)
}



/// Manages Find in Page functionality using JavaScript injection
@Observable
@MainActor
final class FindInPageManager {

    var totalMatches: Int = 0
    var currentMatch: Int = 0
    var searchQuery: String = ""

    private weak var webView: WKWebView?

    init(webView: WKWebView? = nil) {
        self.webView = webView
    }

    /// Sets the webView to use for find operations
    func setWebView(_ webView: WKWebView?) {
        self.webView = webView
    }

    /// Injects the Find in Page JavaScript if not already present on the page
    private func ensureScriptInjected() async throws {
        guard let webView = webView else { return }

        // Check if the script is already injected on this page
        let checkScript = "typeof window.BrowserFindInPage !== 'undefined'"
        let isInjected = try await webView.evaluateJavaScript(checkScript) as? Bool ?? false

        if !isInjected {
            guard let script = JavaScript.getBundled("FindInPage") else {
                print("FindInPageManager: Could not load FindInPage.js")
                return
            }
            _ = try await webView.evaluateJavaScript(script)
        }
    }

    /// Parses the JavaScript result dictionary
    private func parseResult(_ result: Any?) -> FindInPageResult {
        guard let dict = result as? [String: Any],
              let totalMatches = dict["totalMatches"] as? Int,
              let currentMatch = dict["currentMatch"] as? Int else {
            return .empty
        }
        return FindInPageResult(totalMatches: totalMatches, currentMatch: currentMatch)
    }

    /// Updates the published state from a result
    private func updateState(from result: FindInPageResult) {
        self.totalMatches = result.totalMatches
        self.currentMatch = result.currentMatch
    }

    /// Searches for text in the page
    func search(_ query: String) async {
        searchQuery = query

        guard let webView = webView else {
            updateState(from: .empty)
            return
        }

        do {
            try await ensureScriptInjected()

            let escapedQuery = query
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "'", with: "\\'")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")

            let js = "window.BrowserFindInPage.search('\(escapedQuery)')"
            let result = try await webView.evaluateJavaScript(js)
            let parsedResult = parseResult(result)
            updateState(from: parsedResult)
        } catch {
            print("FindInPageManager search error: \(error)")
            updateState(from: .empty)
        }
    }

    /// Goes to the next match
    func goToNextMatch() async {
        guard let webView = webView else { return }

        do {
            try await ensureScriptInjected()
            let result = try await webView.evaluateJavaScript("window.BrowserFindInPage.goToNextMatch()")
            let parsedResult = parseResult(result)
            updateState(from: parsedResult)
        } catch {
            print("FindInPageManager goToNextMatch error: \(error)")
        }
    }

    /// Goes to the previous match
    func goToPreviousMatch() async {
        guard let webView = webView else { return }

        do {
            try await ensureScriptInjected()
            let result = try await webView.evaluateJavaScript("window.BrowserFindInPage.goToPreviousMatch()")
            let parsedResult = parseResult(result)
            updateState(from: parsedResult)
        } catch {
            print("FindInPageManager goToPreviousMatch error: \(error)")
        }
    }

    /// Clears the find highlights
    func clear() async {
        guard let webView = webView else {
            updateState(from: .empty)
            searchQuery = ""
            return
        }

        do {
            try await ensureScriptInjected()
            _ = try await webView.evaluateJavaScript("window.BrowserFindInPage.clear()")
            updateState(from: .empty)
            searchQuery = ""
        } catch {
            print("FindInPageManager clear error: \(error)")
        }
    }

    /// Gets the current state from JavaScript
    func refreshState() async {
        guard let webView = webView else { return }

        do {
            try await ensureScriptInjected()
            let result = try await webView.evaluateJavaScript("window.BrowserFindInPage.getState()")
            let parsedResult = parseResult(result)
            updateState(from: parsedResult)
        } catch {
            print("FindInPageManager refreshState error: \(error)")
        }
    }
}
