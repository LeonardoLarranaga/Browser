//
//  CustomWebsiteSearchersSection.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/9/25.
//

import SwiftUI

/// Section to manage the custom website searchers
struct CustomWebsiteSearchersSection: View {
    
    @State var showWebsiteSearcherEditor = false
    @State var selectedWebsiteSearcher: BrowserCustomSearcher?
    
    @State var website = ""
    @State var queryURL = ""
    
    var body: some View {
        Section {
            Button("Add Website Searcher", systemImage: "plus") {
                selectedWebsiteSearcher = nil
                showWebsiteSearcherEditor = true
                website = ""
                queryURL = ""
            }
            List(Preferences.shared.customWebsiteSearchers) { searcher in
                HStack {
                    Text(searcher.website)
                    
                    Spacer()
                    
                    Button("Edit", systemImage: "pencil") {
                        selectedWebsiteSearcher = searcher
                        website = searcher.website
                        queryURL = searcher.queryURL
                        showWebsiteSearcherEditor = true
                    }
                    
                    Button("Remove", systemImage: "trash.fill") {
                        Preferences.shared.customWebsiteSearchers.removeAll(where: { $0.id == searcher.id })
                    }
                }
            }
        } header: {
            Text("Custom Website Searchers")
        } footer: {
            Text("Note: This searchers will not have autosuggestions.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .alert("Custom Website Searcher", isPresented: $showWebsiteSearcherEditor) {
            TextField("Website e.g. Google", text: $website)
            TextField("https://www.google.com/search?q=", text: $queryURL)
            
            Button("Cancel", role: .cancel) {
                showWebsiteSearcherEditor = false
                website = ""
                queryURL = ""
            }
            
            Button("Save") {
                if let selectedWebsiteSearcher, let index = Preferences.shared.customWebsiteSearchers.firstIndex(where: { $0.id == selectedWebsiteSearcher.id }) {
                    Preferences.shared.customWebsiteSearchers[index].website = website
                    Preferences.shared.customWebsiteSearchers[index].queryURL = queryURL
                } else {
                    Preferences.shared.customWebsiteSearchers.append(BrowserCustomSearcher(website: website, queryURL: queryURL))
                }
            }
            .disabled(website.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || queryURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text(selectedWebsiteSearcher == nil ? "New Website Searcher" : "Edit \"\(selectedWebsiteSearcher?.website ?? "")\"")
        }
    }
}
