//
//  ContextMenuImage.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 23/1/26.
//

extension MyWKWebView {
    /// Creates the custom context menu for images
    /// - Parameter menu: The context menu to modify
    func handleImageContextMenu(_ menu: NSMenu) {
        let openInWindowItem = menu.items.first { $0.title.contains("Window") }
        if let openInWindowItem, let copy = openInWindowItem.copy() as? NSMenuItem {
            copy.title = "Open Image in New Tab"
            menu.insertItem(copy, at: 1)
            menu.removeItem(openInWindowItem)
        }

        if let downloadImageItem = menu.items.first(where: { $0.identifier?.rawValue == "WKMenuItemIdentifierDownloadImage" }),
           let copy = downloadImageItem.copy() as? NSMenuItem {
            copy.isEnabled = Preferences.shared.hasDownloadLocationSet
            menu.insertItem(copy, at: 1)
            menu.removeItem(downloadImageItem)
        }

        let saveImageAsItem = NSMenuItem(title: "Save Image As...", action: #selector(saveImageAs), keyEquivalent: "")
        saveImageAsItem.target = self
        menu.insertItem(saveImageAsItem, at: 2)

        // Copy Image (index 3)
    }

    /// Opens an NSSavePanel and saves the clicked image to disk.
    @objc func saveImageAs() {
        getImageURL { imageURL in
            let savePanel = NSSavePanel()
            savePanel.title = "Save Image As..."
            savePanel.canCreateDirectories = true
            savePanel.nameFieldStringValue = imageURL.lastPathComponent + (imageURL.pathExtension.isReallyEmpty ? ".jpg" : "")
            savePanel.allowedContentTypes = [.image]
            savePanel.begin { response in
                guard response == .OK, let destinationURL = savePanel.url else { return }

                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: imageURL)
                        try data.write(to: destinationURL, options: .atomic)
                    } catch {
                        NSAlert(error: error).runModal()
                    }
                }
            }
        }
    }

    private func getImageURL(completion: @escaping (URL) -> Void) {
        let x = Int(rightMouseDownPosition.x.rounded())
        let y = Int(rightMouseDownPosition.y.rounded())

        let js = """
        var el = document.elementFromPoint(\(x), \(y));
        var img = el?.closest('img');
        img ? (img.currentSrc || img.src) : null;
        """

        evaluateJavaScript(js) { result, error in
            guard error == nil,
                  let urlString = result as? String,
                  let url = URL(string: urlString) else {
                NSAlert(error: "Couldn't get image URL.").runModal()
                return
            }

            completion(url)
        }
    }
}
