//
//  ExtensionsView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 9/27/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsExtensionsView: View {
    @State private var manager = SafariExtensions.shared

    var body: some View {
        VStack(spacing: 0) {
            if manager.entries.isEmpty {
                ContentUnavailableView {
                    Label("No Extensions", systemImage: "puzzlepiece.extension")
                } description: {
                    Text("Add a Safari web extension from an app on your Mac.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(manager.entries) { entry in
                        extensionRow(entry)
                    }
                }
                .listStyle(.inset)
            }

            Divider()

            HStack {
                Spacer()
                Button(action: chooseExtensionApp) {
                    Label("Add Safari Extension from App", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .alert(
            "Safari Extension Error",
            isPresented: Binding(
                get: { manager.errorMessage != nil },
                set: { if !$0 { manager.errorMessage = nil } }
            )
        ) {
            Button("OK") { manager.errorMessage = nil }
        } message: {
            Text(manager.errorMessage ?? "")
        }
    }

    private func extensionRow(_ entry: SafariExtensionEntry) -> some View {
        HStack(spacing: 12) {
            Group {
                if let icon = entry.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "puzzlepiece.extension")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                        .padding(5)
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(.rect(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.name)
                    .font(.body)
                Text(versionDescription(for: entry))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Toggle(
                "Enable \(entry.name)",
                isOn: Binding(
                    get: { entry.installation.isExtensionEnabled },
                    set: { isEnabled in
                        Task { await manager.setEnabled(isEnabled, for: entry.id) }
                    }
                )
            )
            .labelsHidden()

            Menu {
                Button("Launch Extension Console", systemImage: "terminal") {
                    manager.launchExtensionConsole(for: entry)
                }
                .disabled(!entry.installation.isExtensionEnabled || !entry.webExtension.hasBackgroundContent)
                .help("Open the extension’s background console in a new Eva window.")

                Divider()

                Menu {
                    ForEach(SafariExtensionAccessChoice.allCases) { choice in
                        Button {
                            manager.setDefaultAccessChoice(choice, for: entry.id)
                        } label: {
                            if choice == entry.installation.allWebsitesChoice {
                                Label(choice.title, systemImage: "checkmark")
                            } else {
                                Text(choice.title)
                            }
                        }
                    }
                } label: {
                    Label("Website Access", systemImage: "hand.raised")
                }

                Divider()

                Button("Remove Extension", systemImage: "trash", role: .destructive) {
                    manager.remove(entry)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .accessibilityLabel("More actions for \(entry.name)")
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .contain)
        .accessibilityAction(named: Text("Launch Extension Console")) {
            manager.launchExtensionConsole(for: entry)
        }
    }

    private func versionDescription(for entry: SafariExtensionEntry) -> String {
        if let version = entry.version {
            return "Version \(version) · \(entry.installation.allWebsitesChoice.title)"
        }
        return entry.installation.allWebsitesChoice.title
    }

    private func chooseExtensionApp() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.applicationBundle]
        panel.prompt = "Add Safari Extension"

        panel.begin { response in
            guard response == .OK, let applicationURL = panel.url else { return }
            Task { await manager.addExtensions(from: applicationURL) }
        }
    }
}
