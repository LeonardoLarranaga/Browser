//
//  WKWebViewControllerWKDownloadDelegate.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

import WebKit

extension WKWebViewController {
    /// Called when a download is about to begin.
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        print("Download started for \(navigationResponse.response.url?.lastPathComponent ?? "Unknown file")")
        download.delegate = DownloadManager.shared
    }
    
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        print("Download started from a navigation action in \(navigationAction.request.url?.absoluteString ?? "Unknown link").")
        download.delegate = DownloadManager.shared
    }
}
