//
//  LegalView.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 23/9/26.
//

import LicenseList
import SwiftUI

struct SettingsLegalView: View {
    var body: some View {
        Form {
            ForEach(Library.libraries) { library in
                Section {
                    LicenseView(library: library)
                } header: {
                    Text(library.name)
                } footer: {
                    if let url = library.url {
                        Link(url.absoluteString, destination: url)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
