//
//  SafariExtensionToolbarMenu.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 9/27/26.
//

import SwiftUI

struct SafariExtensionToolbarMenu: View {
    @Bindable var manager: SafariExtensions
    let entry: SafariExtensionEntry
    let tab: BrowserTab

    private var currentChoice: SafariExtensionAccessChoice {
        manager.accessChoice(for: entry)
    }

    var body: some View {
        Menu {
            Button("Open \(entry.name)", systemImage: "puzzlepiece.extension") {
                manager.performAction(for: entry, in: tab)
            }

            Section("Website Access") {
                ForEach(SafariExtensionAccessChoice.allCases) { choice in
                    Button {
                        manager.setDefaultAccessChoice(choice, for: entry.id)
                    } label: {
                        if choice == currentChoice {
                            Label(choice.title, systemImage: "checkmark")
                        } else {
                            Text(choice.title)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 7) {
                if let icon = entry.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: "puzzlepiece.extension")
                        .frame(width: 16, height: 16)
                }
                Text(entry.name)
            }
        }
    }
}
