//
//  ContextMenuFrame.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/4/25.
//

import WebKit
import PDFKit

/// Custom context menu for frames (background, not an element)
extension MyWKWebView {
    /// Creates the custom context menu for frames
    /// - Parameter menu: The context menu to modify
    func handleFrameContextMenu(_ menu: NSMenu) {
        // Remove default back and forward items and add custom ones for consistency
        menu.items.removeAll { $0.identifier?.rawValue == "WKMenuItemIdentifierGoBack" }
        menu.items.removeAll { $0.identifier?.rawValue == "WKMenuItemIdentifierGoForward" }
        
        let backItem = NSMenuItem(title: "Back", action: #selector(goBack(_:)), keyEquivalent: "")
        backItem.isEnabled = canGoBack
        
        let forwardItem = NSMenuItem(title: "Forward", action: #selector(goForward(_:)), keyEquivalent: "")
        forwardItem.isEnabled = canGoForward
        
        menu.insertItem(backItem, at: 0)
        menu.insertItem(forwardItem, at: 1)
        // Reload item is at index 2
        menu.insertItem(.separator(), at: 3)
        
        let savePageAsItem = NSMenuItem(title: "Save Page As...", action: #selector(savePageAs), keyEquivalent: "")
        menu.insertItem(savePageAsItem, at: 4)
        
        let printItem = NSMenuItem(title: "Print...", action: #selector(printPage), keyEquivalent: "")
        menu.insertItem(printItem, at: 5)
        
        let translationMenu = translationMenuItem()
        menu.insertItem(translationMenu, at: 6)
        
        let findItem = NSMenuItem(title: "Find...", action: #selector(_toggleFindUI), keyEquivalent: "")
        menu.insertItem(findItem, at: 7)
    }
    
    /// Opens an `NSSavePanel` to save the page as a solicited format
    @objc func savePageAs() {
        let savePanel = NSSavePanel()
        
        savePanel.title = "Save Page As..."
        savePanel.nameFieldStringValue = title ?? url?.cleanHost ?? "Web Page"
        savePanel.canCreateDirectories = true
        
        // Add a custom accessory view to select the format
        // Using an NSView to center the NSStackView
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 60))
        
        let titleLabel = NSTextField(labelWithString: "Format:")
        titleLabel.frame.size.width = 50
        
        let formatMenu = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 150, height: 24))
        formatMenu.addItem(withTitle: "Page Source (HTML)")
        formatMenu.addItem(withTitle: "Safari Web Archive")
        formatMenu.addItem(withTitle: "Current Page Portion Snapshot (PNG)")
        formatMenu.addItem(withTitle: "Full Page Image (PNG)")
        formatMenu.addItem(withTitle: "Single Page PDF")
        formatMenu.addItem(withTitle: "Paginated Page PDF")
        formatMenu.action = #selector(changeFileFormat(_:))
        formatMenu.target = self
        
        let accessoryView = NSStackView()
        accessoryView.orientation = .horizontal
        accessoryView.alignment = .centerY
        accessoryView.distribution = .equalSpacing
        accessoryView.spacing = 8
        accessoryView.addArrangedSubview(titleLabel)
        accessoryView.addArrangedSubview(formatMenu)
        
        containerView.addSubview(accessoryView)
        
        // Center the accessory view in the container
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            accessoryView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            accessoryView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        savePanel.accessoryView = containerView
        
        currentNSSavePanel = savePanel
        
        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }
            switch formatMenu.titleOfSelectedItem {
            case "Page Source (HTML)":
                self.savePageAsHTML(url)
            case "Safari Web Archive":
                self.savePageAsWebArchive(url)
            case "Current Page Portion Snapshot (PNG)":
                self.savePageAsPNG(url)
            case "Full Page Image (PNG)":
                self.saveFullPageAsPNG(url)
            case "Single Page PDF":
                self.savePageAsPDF(url)
            case "Paginated Page PDF":
                self.savePageAsPDF(url, paginated: true)
            default:
                break
            }
        }
    }
    
    /// Gets the html content with JavaScript and saves it to a file
    /// - Parameter url: The URL to save the HTML content
    func savePageAsHTML(_ url: URL) {
        self.evaluateJavaScript("document.documentElement.outerHTML.toString()") { result, error in
            if let html = result as? String {
                do {
                    try html.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    NSAlert(error: error).runModal()
                }
            } else if let error {
                NSAlert(error: error).runModal()
            }
        }
    }
    
    /// Saves the page as a web archive
    /// - Parameter url: The URL to save the web archive
    func savePageAsWebArchive(_ url: URL) {
        self.createWebArchiveData { result in
            do {
                let data = try result.get()
                try data.write(to: url)
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }
    
    /// Saves the page as a PNG image
    /// - Parameter url: The URL to save the PNG image
    /// - Parameter configuration: The snapshot configuration
    func savePageAsPNG(_ url: URL, configuration: WKSnapshotConfiguration? = nil) {
        self.takeSnapshot(with: configuration) { nsImage, error in
            if let nsImage {
                do {
                    if let pngData = nsImage.pngData {
                        try pngData.write(to: url, options: .atomic)
                    } else {
                        throw "Failed to create PNG data"
                    }
                } catch {
                    NSAlert(error: error).runModal()
                }
            } else if let error {
                NSAlert(error: error).runModal()
            }
        }
    }
    
    /// Saves the full page as a PNG image
    /// - Parameter url: The URL to save the PNG
    func saveFullPageAsPNG(_ url: URL) {
        self.evaluateJavaScript("[document.body.scrollWidth, document.body.scrollHeight, document.documentElement.scrollTop || document.body.scrollTop]") { result, error in
            if let frame = result as? NSArray,
               let width = frame[0] as? CGFloat,
               let height = frame[1] as? CGFloat {
                let originalFrame = self.frame
                self.frame = CGRect(x: 0, y: 0, width: width, height: height)
                let configuration = WKSnapshotConfiguration()
                configuration.rect = self.frame
                self.savePageAsPNG(url, configuration: configuration)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.frame = originalFrame
                    if let scrollPosition = frame[2] as? CGFloat {
                        self.evaluateJavaScript("window.scrollTo(0, \(scrollPosition))")
                    }
                }
            } else if let error {
                NSAlert(error: error).runModal()
            }
        }
    }
    
    /// Saves the page as a single-page PDF
    /// - Parameter url: The URL to save the PDF
    /// - Parameter paginated: If the PDF should be paginated
    func savePageAsPDF(_ url: URL, paginated: Bool = false) {
        Task {
            do {
                var data = try await self.pdf()
                if paginated {
                    data = try PDFDocument.splitLongDocument(pdfData: data)
                }
                try data.write(to: url)
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }
    
    /// Prints the page
    @objc func printPage() {
        Task {
            do {
                let pdfData = try await self.pdf()
                let pdfDocument = PDFDocument(data: try PDFDocument.splitLongDocument(pdfData: pdfData))
                
                let pdfView = PDFView()
                pdfView.document = pdfDocument
                pdfView.autoScales = true
                pdfView.displaysPageBreaks = false
                pdfView.isHidden = true
                
                let printInfo = NSPrintInfo.shared
                printInfo.topMargin = 0
                printInfo.bottomMargin = 0
                printInfo.leftMargin = 0
                printInfo.rightMargin = 0
                printInfo.isVerticallyCentered = true
                printInfo.isHorizontallyCentered = true
                printInfo.verticalPagination = .automatic
                printInfo.horizontalPagination = .automatic
                
                if let firstPage = pdfDocument?.page(at: 0) {
                    let bounds = firstPage.bounds(for: .mediaBox)
                    printInfo.orientation = bounds.width > bounds.height ? .landscape : .portrait
                }
                
                guard let window = self.window else { return }
                window.contentView?.addSubview(pdfView)
                
                let printOperation = pdfDocument?.printOperation(for: printInfo, scalingMode: .pageScaleToFit, autoRotate: false)
                
                DispatchQueue.main.async {
                    printOperation?.run()
                }
                
                pdfView.removeFromSuperview()
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }
    
    @objc func changeFileFormat(_ sender: Any?) {
        guard let formatMenu = sender as? NSPopUpButton else { return }
        guard let savePanel = self.currentNSSavePanel else { return }
        
        switch formatMenu.titleOfSelectedItem {
        case "Page Source (HTML)":
            savePanel.allowedContentTypes = [.html]
            break
        case "Safari Web Archive":
            savePanel.allowedContentTypes = [.webArchive]
            break
        case "Current Page Portion Snapshot (PNG)":
            fallthrough
        case "Full Page Image (PNG)":
            savePanel.allowedContentTypes = [.png]
        case "Single Page PDF":
            fallthrough
        case "Paginated Page PDF":
            savePanel.allowedContentTypes = [.pdf]
        default:
            break
        }
    }

    @objc private func _toggleFindUI() {
        toggleFindUI?()
    }
}
