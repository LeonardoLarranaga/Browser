//
//  SidebarModel.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/23/25.
//

import SwiftUI

/// Model for the sidebar
@Observable class SidebarModel {

    var currentSidebarWidth: CGFloat = 220
    var lastSidebarWidth: CGFloat = 220
    var sidebarCollapsed: Bool = false {
        // Start or stop the mouse monitor when the sidebar is collapsed
        didSet {
            if sidebarCollapsed {
                startMouseMonitor()
            } else {
                stopMouseMonitor()
            }
        }
    }

    var showDownloads: Bool = false
    var allowDownloadHover: Bool = false
    var isAnimatingDownloads: Bool = false

    /// Monitor for mouse movement
    private var mouseMonitor: Any?

    /// Toggle the sidebar
    func toggleSidebar() {
        // Only animate if the hover sidebar is not shown
        withAnimation(sidebarCollapsed && currentSidebarWidth != 0 ? nil : .smooth(duration: 0.2)) {
            sidebarCollapsed.toggle()
            if sidebarCollapsed {
                lastSidebarWidth = currentSidebarWidth
                currentSidebarWidth = 0
                if Preferences.shared.sidebarPosition == .leading {
                    NSApp.setBrowserWindowControls(hidden: true)
                }
            } else {
                self.currentSidebarWidth = self.lastSidebarWidth
                if Preferences.shared.sidebarPosition == .leading {
                    NSApp.setBrowserWindowControls(hidden: false)
                }
            }
        }
    }

    /// Start the mouse monitor
    func startMouseMonitor() {
        mouseMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved, handler: handleMouseMovement)
    }

    /// Handle the mouse movement
    /// Only show the sidebar when the cursor is near the window's edge + threshold
    /// - Parameter event: The mouse movement event
    func handleMouseMovement(event: NSEvent) -> NSEvent? {
        guard let keyWindow = NSApp.keyWindow else { return event }
        let sidebarPosition = Preferences.shared.sidebarPosition

        let windowX = sidebarPosition == .leading ? keyWindow.frame.minX : keyWindow.frame.maxX
        let cursorX = NSEvent.mouseLocation.x - windowX

        // Inside window threshold
        let threshold = currentSidebarWidth != 0 ? currentSidebarWidth + 25 : 50
        let inRange = sidebarPosition == .leading ?
        cursorX >= -50 && cursorX <= threshold :
        cursorX <= 50 && cursorX >= -threshold

        withAnimation(.smooth(duration: 0.2)) {
            if inRange {
                currentSidebarWidth = lastSidebarWidth
                if sidebarPosition == .leading {
                    NSApp.setBrowserWindowControls(hidden: false)
                }
            } else {
                if sidebarPosition == .leading {
                    NSApp.setBrowserWindowControls(hidden: true)
                }
                currentSidebarWidth = 0
            }
        }

        return event
    }

    /// Stop the mouse monitor
    func stopMouseMonitor() {
        NSEvent.removeMonitor(mouseMonitor as Any)
    }
}
