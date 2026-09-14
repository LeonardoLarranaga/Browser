//
//  ManageWebsiteData.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 27/2/26.
//

import SwiftUI

struct ManageWebsiteDataView: View {

    @Environment(\.dismiss) private var dismiss

    let profile: BrowserProfile?
    let dataStore: WKWebsiteDataStore

    @State private var searchText = ""
    @State private var isLoading = false
    @State private var hasLoaded = false
    @State private var records: [WKWebsiteDataRecord] = []
    @State private var selectedRecords = Set<WKWebsiteDataRecord>()

    @State private var showRemoveAllConfirmation = false

    private var displayedRecords: [WKWebsiteDataRecord] {
        records.filter { record in
            searchText.isReallyEmpty || record.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    init(profile: BrowserProfile?) {
        self.profile = profile
        if let profile {
            dataStore = WKWebsiteDataStore(forIdentifier: profile.id)
        } else {
            dataStore = .default()
        }
    }

    var body: some View {
        VStack {
            Text("These websites have stored data that can be used to track your browsing. Removing the data may reduce tracking, but may also log you out of websites or change website behavior.")
                .multilineTextAlignment(.leading)

            Group {
                if !displayedRecords.isEmpty || isLoading {
                    List(displayedRecords, id: \.self, selection: $selectedRecords) { record in
                        VStack(alignment: .leading) {
                            Text(record.displayName)
                                .font(.headline)
                            Text(record.dataTypesDescriptions.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical)
                } else if hasLoaded {
                    ContentUnavailableView(
                        "No website data stored",
                        systemImage: "externaldrive.badge.xmark",
                        description: Text("The \(profile?.name ?? "Default") profile has no stored website data.")
                    )
                }
            }
            .frame(height: 320)

            HStack {
                Button("Remove", action: removeSelected)
                    .disabled(selectedRecords.isEmpty)

                Button("Remove All") { showRemoveAllConfirmation = true }

                Spacer()

                Button("Refresh") { Task { await load() } }
                    .disabled(isLoading)

                Button("Done", action: dismiss.callAsFunction)
                    .tint(.accentColor)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 650)
        .padding()
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .task(load)
        .alert("Are you sure you want to remove all data stored by the \(records.count) displayed websites on your computer?", isPresented: $showRemoveAllConfirmation) {
            Button(role: .cancel, action: {})
            Button("Remove Now", role: .destructive, action: removeAll)
        } message: {
            Text("You can't undo this action")
        }
        .searchable(text: $searchText)
    }

    @Sendable private func load() async {
        isLoading = true
        records = await withCheckedContinuation { continuation in
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                continuation.resume(returning: records.sorted { $0.displayName < $1.displayName })
            }
        }
        isLoading = false
        hasLoaded = true
    }

    private func remove(_ records: [WKWebsiteDataRecord]) {
        Task {
            await dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records)
            await load()
            selectedRecords = []
        }
    }

    private func removeSelected() {
        remove(Array(selectedRecords))
    }

    private func removeAll() {
        remove(records)
    }
}
