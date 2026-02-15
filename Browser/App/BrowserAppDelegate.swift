//
//  BrowserAppDelegate.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/23/25.
//

import AppKit

/// The app delegate is responsible for handling window events and saving the window position and size
class BrowserAppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    var lastWindows: [NSWindow] = []
    var windowWasClosed = false

    /// Add window observers to save the window position and size
    func applicationWillFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey(_:)), name: NSWindow.didBecomeKeyNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResizeOrMove(_:)), name: NSWindow.didResizeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResizeOrMove(_:)), name: NSWindow.didMoveNotification, object: nil)

        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        closeNotMainWindows()
        deleteTemporaryImages()
    }

    func applicationWillTerminate(_ notification: Notification) {
        closeNotMainWindows()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        urls.forEach { url in
            print(url)
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if Preferences.warnBeforeQuitting {
            let alert = NSAlert()
            alert.messageText = "Are you sure you want to quit?"
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Quit").hasDestructiveAction = true

            let checkbox = NSButton(checkboxWithTitle: "Warn before quitting", target: self, action: #selector(setWarnBeforeQuitting(_:)))
            checkbox.state = .on

            alert.accessoryView = checkbox

            if alert.runModal() == .alertFirstButtonReturn {
                return .terminateCancel
            } else {
                return .terminateNow
            }
        }

        return .terminateNow
    }

    /// Restore the window position and size when the window becomes key
    @objc func windowDidBecomeKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              NSWindow.hasPrefix("Browser", in: window)
        else { return }

        checkForNewWindows(window)

        if windowWasClosed {
            var frame = window.frame
            frame.origin.x = Preferences.windowFrame.originX
            frame.origin.y = Preferences.windowFrame.originY
            frame.size.width = Preferences.windowFrame.width
            frame.size.height = Preferences.windowFrame.height

            window.setFrame(frame, display: true)
            windowWasClosed = false
        }

        window.backgroundColor = .clear
        window.toolbar?.allowsDisplayModeCustomization = false

        if Preferences.sidebarPosition == .trailing {
            NSApp.setBrowserWindowControls(hidden: !Preferences.showWindowControlsOnTrailingSidebar)
        }
    }

    @objc func windowDidResizeOrMove(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              NSWindow.hasPrefix("BrowserWindow", in: window)
        else { return }
        saveWindowPositionAndSize(window)
    }

    @objc func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              NSWindow.hasPrefix("Browser", in: window)
        else { return }
        window.isReleasedWhenClosed = true
        lastWindows.removeAll { $0 == window }
        windowWasClosed = NSApp.windows.filter { $0.identifier?.rawValue.hasPrefix("Browser") == true }.count - 1 == 0
    }

    @objc func checkForNewWindows(_ sender: NSWindow) {
        let currentWindows = NSApp.windows.filter { $0.identifier?.rawValue.hasPrefix("Browser") == true }
        lastWindows = currentWindows
    }

    /// Save the window position and size when the window is closed
    /// - Parameter window: The window to save the position and size
    /// - Note: Only save the window position and size if the window is a BrowserWindow
    func saveWindowPositionAndSize(_ window: NSWindow) {
        guard !windowWasClosed else { return }
        guard NSWindow.hasPrefix("BrowserWindow", in: window) else { return }

        let windowFrame = window.frame
        Preferences.windowFrame = .init(
            originX: windowFrame.origin.x,
            originY: window.frame.origin.y,
            width: windowFrame.size.width,
            height: windowFrame.size.height
        )
    }

    func closeNotMainWindows() {
        NSApp.windows.filter { $0.identifier?.rawValue.hasPrefix("BrowserWindow") == false }.forEach {
            $0.close()
        }
    }

    @objc func setWarnBeforeQuitting(_ sender: NSButton) {
        Preferences.warnBeforeQuitting = sender.state == .on
    }

    func deleteTemporaryImages() {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil, options: [])
            for file in files {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("Error deleting temporary files: \(error)")
        }
    }
}
