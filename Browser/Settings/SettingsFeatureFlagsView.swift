//
//  SettingsFeatureFlagsView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 25/1/26.
//

import SwiftUI

struct SettingsFeatureFlagsView: View {

    let groupedFeatureFlags = Array(FeatureFlags.getAllGrouped())

    @State var showGrouped = true
    @State var searchText = ""

    var body: some View {
        VStack {
            TextField("Search Feature Flags...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding([.horizontal, .top])

            Form {
                ForEach(groupedFeatureFlags, id: \.key) { category, featureFlags in
                    let filteredFlags = filteredFeatureFlags(for: featureFlags)
                    if !filteredFlags.isEmpty {
                        Section(category.localizedStringKey) {
                            List(filteredFlags, id: \.key) { featureFlag in
                                FeatureFlagRow(featureFlag: featureFlag)
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
    }

    func filteredFeatureFlags(for featureFlags: [WKFeature]) -> [WKFeature] {
        featureFlags.filter { featureFlag in
            searchText.isReallyEmpty || featureFlag.name.localizedCaseInsensitiveContains(searchText) ||
            "\(featureFlag.status.localizedStringKey)".localizedCaseInsensitiveContains(searchText)
        }
    }
}

private struct FeatureFlagRow: View {

    let featureFlag: WKFeature
    @State private var showPopover = false

    var body: some View {
        HStack {
            Toggle(featureFlag.name, isOn: Binding(get: {
                FeatureFlags.isEnabled(featureFlag)
            }, set: { newValue in
                FeatureFlags.userToggleFeature(featureFlag, enabled: newValue)
            }))
            .bold(FeatureFlags.isFeatureFlagUserConfigured(featureFlag))

            if featureFlag.details != nil {
                Button("", systemImage: "info.circle") {
                    showPopover = true
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                    Text(featureFlag.details ?? "No details available.")
                        .padding()
                }
            }

            Spacer()

            Text(featureFlag.status.localizedStringKey)
                .padding(2)
                .padding(.horizontal, 2)
                .glassEffect()
        }
    }
}
