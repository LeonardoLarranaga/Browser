//
//  Settings View.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    var body: some View {
        Form {
            Toggle("Close Selected Tab When Clearing Space", systemImage: "xmark.square", isOn: $userPreferences.clearSelectedTab)
            Toggle("Open Picture in Picture Automatically", systemImage: "inset.filled.topright.rectangle", isOn: $userPreferences.openPipOnTabChange)
            Toggle("Warn Before Quitting", systemImage: "exclamationmark.triangle", isOn: $userPreferences.warnBeforeQuitting)
            
            DownloadFolderSection()
            
            CustomWebsiteSearchersSection()
        }
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettingsView()
}
