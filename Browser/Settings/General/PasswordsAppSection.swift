//
//  PasswordsAppSection.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 4/2/26.
//

import SwiftUI

struct PasswordsAppSection: View {

    @State var showFileImporter = false

    var body: some View {
        @Bindable var preferences = Preferences

        Section {
            Toggle("Add Passwords App Shortcut to Text Fields", systemImage: "key.2.on.ring.fill", isOn: $preferences.injectOpenPasswordsApp)

            if preferences.injectOpenPasswordsApp, let passwordApp = preferences.selectedPasswordApp {
                Menu {
                    Button("Select Passwords App") {
                        showFileImporter = true
                    }
                } label: {
                    Label {
                        Text(passwordApp.deletingPathExtension().lastPathComponent)
                    } icon: {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: passwordApp.path))
                    }
                }
            }
        } footer: {
            Text("Due to system limitations, autofill is not supported. Enabling this option will add a shortcut to open your selected passwords app from text fields.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.application]) { result in
            switch result {
            case .success(let success):
                preferences.selectedPasswordApp = success
            case .failure(let failure):
                print("Couldn't get url for passwords app: \(failure.localizedDescription)")
            }
        }
        .fileDialogDefaultDirectory(URL.applicationDirectory)
    }
}
