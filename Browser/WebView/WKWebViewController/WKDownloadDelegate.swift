//
//  WKWebViewControllerWKDownloadDelegate.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

import WebKit

extension WKWebViewController: WKDownloadDelegate {
    
    /// Called when a download is about to begin.
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        print("⬇️ 🔵 Download started for \(navigationResponse.response.url?.lastPathComponent ?? "Unknown file")")
        download.delegate = self
    }
    
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        print("⬇️ 🔵 Download started from a navigation action in \(navigationAction.request.url?.absoluteString ?? "Unknown link").")
        download.delegate = self
    }
    
    /// Called when a download should decide where to save the file and start.
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping @MainActor @Sendable (URL?) -> Void) {
        if let bookmarkData = UserDefaults.standard.data(forKey: "download_location_bookmark") {
            var isStale = false
            do {
                let downloadLocation = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
                if !isStale {
                    if downloadLocation.startAccessingSecurityScopedResource() {
                        let destinationURL = downloadLocation.appendingPathComponent("\(suggestedFilename).browserdownload").uniqueFileURL()
                        activeDownloads.append((download: download, bookmarkData: bookmarkData, fileName: destinationURL.lastPathComponent))
                        completionHandler(destinationURL)
                        coordinator.toggleDownloadAnimation()
                        downloadLocation.stopAccessingSecurityScopedResource()
                        return
                    }
                }
            } catch {
                print("⬇️ 🔴 Error resolving bookmark data: \(error.localizedDescription)")
            }
        } else {
            print("⬇️ ⛔️ No download location bookmark available")
        }
        
        // Fallback to open panel if bookmark data is stale or not available
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.title = "Select Download Location For \"\(suggestedFilename)\""
        panel.begin { response in
            if response == .OK, let url = panel.url {
                completionHandler(url.appendingPathComponent("\(suggestedFilename).browserdownload").uniqueFileURL())
                self.coordinator.toggleDownloadAnimation()
            } else {
                completionHandler(nil)
            }
        }
    }
    
    /// Download did finish.
    /// Rename the file to remove the .browserdownload extension.
    func downloadDidFinish(_ download: WKDownload) {
        guard let activeDownload = activeDownloads.first(where: { $0.download == download }) else {
            return print("⬇️ 🔴 Could not find bookmark data for download.")
        }
        
        do {
            var isStale = false
            var downloadLocation = try URL(resolvingBookmarkData: activeDownload.bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
            
            if isStale {
                print("⬇️ ⚠️ Download bookmark is stale.")
                return
            }
            
            guard downloadLocation.startAccessingSecurityScopedResource() else {
                return print("⬇️ 🔴 Could not access security-scoped resource.")
            }
            
            downloadLocation = downloadLocation.appendingPathComponent(activeDownload.fileName)
            
            let destinationURL = downloadLocation.deletingPathExtension().uniqueFileURL()
            
            try FileManager.default.moveItem(at: downloadLocation, to: destinationURL)
            print("⬇️ 🟢 Download finished for \(destinationURL.lastPathComponent)")
            activeDownloads.removeAll { $0.download == download }
            
            downloadLocation.stopAccessingSecurityScopedResource()
        } catch {
            print("⬇️ 🔴 Error renaming download: \(error.localizedDescription)")
        }
    }
    
    func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
        print("🔴 Download failed for \(download.originalRequest?.url?.lastPathComponent ?? "Unknown file") with error: \(error.localizedDescription)")
    }
}
