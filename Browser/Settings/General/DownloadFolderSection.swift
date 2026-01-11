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

        Menu(content: {
          if Preferences.shared.hasDownloadLocationSet {
            Button {
            } label: {
              HStack {
                Image(systemName: "checkmark")
                downloadLabel
              }
            }
          }

          Button("Ask for each download", action: Preferences.shared.removeDownloadLocation)
          Button("Choose...", action: chooseDownloadLocation)
        }, label: {
          downloadLabel
        })
      }
    }
  }

  var downloadLabel: some View {
    Group {
      if let downloadLocation = Preferences.shared.downloadURL {
        Label {
          Text(downloadLocation.path())
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
  }

  func chooseDownloadLocation() {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.prompt = "Select Download Location"
    panel.begin { response in
      if response == .OK, let url = panel.url {
        Preferences.shared.downloadURL = url
      }
    }
  }
}

#Preview {
  DownloadFolderSection()
}
