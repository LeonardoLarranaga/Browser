//
//  DownloadsList.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/22/25.
//

import SwiftUI

struct DownloadsList: View {
    private let rowHeight: CGFloat = 42
    private let maximumVisibleRows = 6

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(DownloadManager.shared.downloads) { download in
                    DownloadRow(download: download)
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(height: listHeight)
        .browserTransition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var listHeight: CGFloat {
        min(CGFloat(DownloadManager.shared.downloads.count) * rowHeight, CGFloat(maximumVisibleRows) * rowHeight)
    }
}

#Preview {
    DownloadsList()
}
