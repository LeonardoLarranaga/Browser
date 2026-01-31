//
//  Settings View.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    var body: some View {
        @Bindable var preferences = Preferences.shared
        Form {
            Toggle("Close Selected Tab When Clearing Space", systemImage: "xmark.square", isOn: $preferences.clearSelectedTab)
            Toggle("Open Picture in Picture Automatically", systemImage: "inset.filled.topright.rectangle", isOn: $preferences.openPipOnTabChange)
            Toggle("Warn Before Quitting", systemImage: "exclamationmark.triangle", isOn: $preferences.warnBeforeQuitting)
            Toggle("Automatic Page Suspension", systemImage: "hand.raised.fill", isOn: $preferences.automaticPageSuspension)
            Toggle("Show Hover URL", systemImage: "dot.circle.and.cursorarrow", isOn: $preferences.showHoverURL)

            DownloadFolderSection()

            CustomWebsiteSearchersSection()

            Toggle("Show Feature Flags for Web Developers", systemImage: "flag.2.crossed.fill", isOn: $preferences.shouldShowFeatureFlagSettings)
        }
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettingsView()
}
