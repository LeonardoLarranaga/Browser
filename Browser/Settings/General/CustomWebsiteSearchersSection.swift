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
    @State var hex = Color.blue.hexString()

    var body: some View {
        Section {
            Button("Add Website Searcher", systemImage: "plus") {
                selectedWebsiteSearcher = nil
                showWebsiteSearcherEditor = true
                website = ""
                queryURL = ""
                hex = Color.blue.hexString()
            }
            List(SearchEngine.allCases, id: \.title) { defaultSearcher in
                HStack {
                    Label { Text(defaultSearcher.title)
                    } icon: { Capsule().fill(defaultSearcher.searcher.color) }

                    Spacer()

                    ButtonMakeDefault(defaultSearcher.searcher)
                }
            }
            List(Preferences.customWebsiteSearchers) { searcher in
                HStack {
                    Label { Text(searcher.website)
                    } icon: { Capsule().fill(searcher.color) }

                    Spacer()

                    ButtonMakeDefault(searcher)

                    Button("Edit", systemImage: "pencil") {
                        selectedWebsiteSearcher = searcher
                        website = searcher.website
                        queryURL = searcher.queryURL
                        hex = searcher.color.hexString()
                        showWebsiteSearcherEditor = true
                    }

                    Button("Remove", systemImage: "trash.fill") {
                        Preferences.customWebsiteSearchers.removeAll(where: { $0.id == searcher.id })
                    }
                }
            }
        } header: {
            Text("Custom Website Searchers")
        } footer: {
            Text("Note: Custom searchers will not have autosuggestions.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .sheet(isPresented: $showWebsiteSearcherEditor) {
            NavigationStack {
                Form {
                    Section("Website") { TextField("", text: $website) }
                    Section {
                        TextField("", text: $queryURL)
                    } header: {
                        Text("Query URL")
                    } footer: {
                        Text("Use '%s' as the placeholder for the search query.")
                    }
                    Section("Color") { WheelColorPicker(hex: $hex) }
                    Button("Cancel", role: .cancel) {
                        showWebsiteSearcherEditor = false
                        website = ""
                        queryURL = ""
                        hex = Color.blue.hexString()
                    }

                    Button("Save") {
                        if let selectedWebsiteSearcher, let index = Preferences.customWebsiteSearchers.firstIndex(where: { $0.id == selectedWebsiteSearcher.id }) {
                            Preferences.customWebsiteSearchers[index].website = website
                            Preferences.customWebsiteSearchers[index].queryURL = queryURL
                            Preferences.customWebsiteSearchers[index].hexColor = hex
                        } else {
                            Preferences.customWebsiteSearchers.append(
                                BrowserCustomSearcher(
                                    website: website,
                                    queryURL: queryURL,
                                    hexColor: hex
                                )
                            )
                        }
                        showWebsiteSearcherEditor = false
                    }
                    .disabled(website.isReallyEmpty || !queryURL.contains("%s"))
                }
                .navigationTitle(selectedWebsiteSearcher == nil ? "Add Website Searcher" : "Edit Website Searcher")
                .formStyle(.grouped)
            }
        }
    }

    @ViewBuilder
    func ButtonMakeDefault(_ searcher: any WebsiteSearcher) -> some View {
        var isDefault: Bool { searcher.equals(Preferences.defaultWebsiteSearcher) }
        Button(isDefault ? "Default" : "Make Default", systemImage: isDefault ? "checkmark" : "star") {
            Preferences.defaultWebsiteSearcher = searcher
        }
        .disabled(isDefault)
    }
}
