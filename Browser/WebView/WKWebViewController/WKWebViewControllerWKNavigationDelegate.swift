//
//  WKWebViewControllerWKNavigationDelegate.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/2/25.
//

import WebKit

/// WKNavigationDelegate implementation for WKWebViewController
extension WKWebViewController: WKNavigationDelegate {
    
    /// Called when the web view starts loading a page
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        print("🔵 Loading \(url.absoluteString)")
        
        if self.tab.url.cleanHost != url.cleanHost {
            print("🔵 New domain detected")
            self.tab.updateFavicon(with: url)
        }
    }
    
    /// Called when the web view finishes loading a page
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        print("🟢 Finished loading \(url.absoluteString)")
        
        // Save to history
        do {
            let historyEntry = BrowserHistoryEntry(title: self.tab.title, url: url, favicon: self.tab.favicon)
            self.modelContext.insert(historyEntry)
            try self.modelContext.save()
        } catch {
            print("🔴 Failed saving history entry: \(error.localizedDescription)")
        }
        
        self.webView.setZoomFactor(self.webView.savedZoomFactor())
    }
    
    /// Called when the web view fails loading a page
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard let url = webView.url else { return }
        print("🔴 Failed loading \(url.absoluteString) with error: \(error.localizedDescription)")
    }
    
    /// Called when the web view wants to create a new web view (open new tab)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("🔵 Creating new")
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void) {
        guard navigationResponse.response.mimeType != nil else {
            decisionHandler(.allow)
            return
        }
        
        if navigationResponse.canShowMIMEType {
            decisionHandler(.allow)
        } else {
            print("🔵 Decision is of type download")
            decisionHandler(.download)
        }
    }
}
