//
//  HistoryEntryRow.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

import SwiftUI

struct HistoryEntryRow: View {
    
    @Bindable var entry: BrowserHistoryEntry
    
    var body: some View {
        HStack(spacing: 15) {
            Text(entry.date.formatted(date: .omitted, time: .shortened))
                .bold()
                .frame(width: 66)
                .multilineTextAlignment(.leading)
            
            Group {
                if let favicon = entry.favicon, let nsImage = NSImage(data: favicon) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "globe")
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 16, height: 16)
            .clipShape(.rect(cornerRadius: 4))
            
            Text(entry.title)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            Text(entry.url.absoluteString)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.secondary)
                .font(.system(.callout, design: .monospaced))
        }
        .padding(.vertical, 5)
    }
}
