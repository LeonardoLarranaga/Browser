//
//  DownloadFolderSection.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/9/25.
//

import SwiftUI

/// Section that contains the download folder settings
struct DownloadFolderSection: View {
    
    var body: some View {
        Section {
            HStack {
                Label("File Download Location", systemImage: "arrowshape.down.circle")

                Menu {
                    Button(action: Preferences.useDefaultDownloadLocation) {
                        if Preferences.isUsingDefaultDownloadLocation {
                            Label("Downloads", systemImage: "checkmark")
                        } else {
                            Label("Downloads", systemImage: "folder")
                        }
                    }

                    Button(action: Preferences.removeDownloadLocation) {
                        if Preferences.askForDownloadLocation {
                            Label("Ask for each download", systemImage: "checkmark")
                        } else {
                            Text("Ask for each download")
                        }
                    }

                    Button("Choose...", action: chooseDownloadLocation)
                } label: {
                    downloadLabel
                }
            }
        }
    }
    
    @ViewBuilder
    var downloadLabel: some View {
        if Preferences.askForDownloadLocation {
            Text("Ask for each download")
        } else if let downloadLocation = Preferences.downloadURL {
            Label {
                Text((downloadLocation.path() as NSString).abbreviatingWithTildeInPath)
            } icon: {
                if downloadLocation.hasDirectoryPath {
                    Image(nsImage: NSWorkspace.shared.icon(for: .folder))
                } else {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: downloadLocation.path()))
                }
            }
        } else {
            Text("Ask for each download")
        }
    }
    
    private func chooseDownloadLocation() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Select Download Location"
        panel.begin { response in
            if response == .OK, let url = panel.url {
                Preferences.downloadURL = url
            }
        }
    }
}

#Preview {
    DownloadFolderSection()
}
