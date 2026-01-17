//
//  MyWKWebViewErrorView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/20/25.
//

import SwiftUI

struct MyWKWebViewErrorView: View {
    
    private struct DisplayedError {
        let title: String
        let systemImage: String
    }
    
    let tab: BrowserTab
    
    private var displayedError: DisplayedError {
        switch tab.webviewErrorCode ?? 0 {
        case -1009:
            DisplayedError(title: "It appears you're not connected to the internet.", systemImage: "wifi.exclamationmark")
        default:
            DisplayedError(title: "An error occured while loading the page.\n\(tab.webviewErrorDescription ?? "")", systemImage: "exclamationmark.triangle.fill")
        }
    }
    
    var body: some View {
        VStack {
            ContentUnavailableView(displayedError.title, systemImage: displayedError.systemImage)
                .font(.largeTitle.bold())
            
            Button("Reload", action: tab.reload)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(in: .rect)
    }
}
