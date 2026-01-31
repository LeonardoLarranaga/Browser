//
//  WKWebViewControllerWKNavigationDelegate.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/2/25.
//

import WebKit
import UniformTypeIdentifiers

/// WKNavigationDelegate implementation for WKWebViewController
extension WKWebViewController: WKNavigationDelegate {
    
    /// Called when the web view starts loading a page
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        print("🔵 Loading \(url.absoluteString)")
        
        if self.tab.url.cleanHost != url.cleanHost {
            self.tab.updateFavicon(with: url)
        }

        if Preferences.shared.showHoverURL {
            addHoverURLListener()
        }
    }
    
    /// Called when the web view finishes loading a page
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        print("🟢 Finished loading \(url.absoluteString)")
        
        coordinator.addTabToHistory()
                
        self.tab.webviewErrorCode = nil
        self.tab.webviewErrorDescription = nil
    }
    
    /// Called when the web view fails loading a page
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard let url = webView.url else { return }
        print("🔴 Failed loading \(url.absoluteString) with error: \(error.localizedDescription)")
    }
    
    /// Called when the web view wants to create a new web view (open new tab)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        coordinator.createNewTabFromAction(navigationAction)
        return nil
    }
    
    /// Decided what type of navigation to allow (download, allow.)
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void) {
        resetSuspendTimer()
        guard let mimeType = navigationResponse.response.mimeType, let type = UTType(mimeType: mimeType)  else {
            decisionHandler(.allow)
            return
        }
        
        if !navigationResponse.canShowMIMEType {
            decisionHandler(.download)
        } else {
            if type.conforms(toAny: [.image, .video, .audio]) {
                decisionHandler(.download)
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        resetSuspendTimer()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        let error = error as NSError
        self.tab.webviewErrorDescription = error.localizedDescription
        self.tab.webviewErrorCode = error.code
        print("🔴 Failed provisional navigation with error: \(error.localizedDescription) with code \(error.code)")
    }
}
