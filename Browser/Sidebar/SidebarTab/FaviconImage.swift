//
//  FaviconImage.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 26/1/26.
//

import SwiftUI

/// The favicon image for a sidebar tab
struct SidebarTabFaviconImage: View {

    @Environment(BrowserTab.self) var browserTab

    var body: some View {
        Group {
            if Preferences.shared.loadingIndicatorPosition == .onTab && browserTab.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else if let favicon = browserTab.favicon, let nsImage = NSImage(data: favicon) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray))
            }
        }
        .frame(width: 16, height: 16)
        .padding(.leading, 5)
    }
}
