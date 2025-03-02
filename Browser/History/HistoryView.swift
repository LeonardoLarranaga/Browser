//
//  HistoryView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Bindable var browserTab: BrowserTab
    var body: some View {
        TabView {
            Tab("Closed Tabs", systemImage: "xmark.app.fill") {
                Text("Not yet implemented")
                    .foregroundColor(.secondary)
            }
            
            Tab("All History", systemImage: "clock.fill") {
                HistoryEntryList(browserTab: browserTab)
            }
        }
    }
}
