//
//  SidebarResizer.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/28/25.
//

import SwiftUI

/// A made-from-scratch view that allows the user to resize the sidebar
struct SidebarResizer: View {
    
    @Environment(SidebarModel.self) var sidebarModel
    
    @State var isDragging = false
    @State var isHovering = false
    @State var hoverTask: Task<Void, Never>? = nil

    var body: some View {
        // View base
        Color.clear
            .frame(width: 0.1)
            .overlay(alignment: .top) {
                // Visual dragger
                Color.secondary.opacity(isDragging || isHovering && sidebarModel.currentSidebarWidth != 0 ? 0.5 : 0)
                    .animation(.browserDefault, value: isDragging || isHovering)
                    .clipShape(.rect(cornerRadius: 12))
                    .frame(width: 5)
                    .padding(.vertical)
            }
            .overlay(alignment: .top) {
                // Actual dragger
                Rectangle()
                    .fill(.clear)
                    .contentShape(.rect)
                    .frame(width: 15)
                    .onHover(perform: onHoverChange)
                    .gesture(
                        DragGesture()
                            .onChanged(resizeSidebar)
                            .onEnded(endDragging)
                    )
            }
            .onDisappear {
                hoverTask?.cancel()
                hoverTask = nil
            }
    }

    /// On hover change handler
    /// Shows the resize dragger after a delay
    private func onHoverChange(_ hovering: Bool) {
        hoverTask?.cancel()
        if hovering {
            hoverTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                if Task.isCancelled { return }
                isHovering = true
                setResizeLeftRightNSCursor()
            }
        } else {
            isHovering = false
            if !isDragging {
                setArrowNSCursor()
            }
        }
    }

    /// Resize the sidebar depending on the drag gesture value
    private func resizeSidebar(with value: DragGesture.Value) {
        // Save the last sidebar width before dragging
        // This is used to animate the sidebar back to its original width
        if isDragging == false {
            sidebarModel.lastSidebarWidth = sidebarModel.currentSidebarWidth
        } else {
            setResizeLeftRightNSCursor()
        }
        
        isDragging = true
        // Adjust the sidebar width
        let newWidth = sidebarModel.currentSidebarWidth + value.translation.width
        if newWidth >= .minimumSidebarWidth && newWidth <= .maximumSidebarWidth {
            // Snap the sidebar width to the preferred width
            let fixedWidth = newWidth / .preferredSidebarWidth
            if fixedWidth > 0.95 && fixedWidth < 1.06 {
                sidebarModel.currentSidebarWidth = .preferredSidebarWidth
            } else {
                sidebarModel.currentSidebarWidth = newWidth
            }
        } else {
            // Collapse the sidebar if the width is less than half of the minimum width
            if newWidth < .minimumSidebarWidth * 0.5 {
                sidebarModel.currentSidebarWidth = 0
            }
        }
    }
    
    /// End the dragging gesture
    private func endDragging(with value: DragGesture.Value) {
        isDragging = false
        setArrowNSCursor()
        
        if sidebarModel.currentSidebarWidth == 0 {
            sidebarModel.sidebarCollapsed = true
        }
    }
    
    /// Set the arrow NSCursor
    private func setArrowNSCursor() {
        // Pop all the NSCursors until the arrow cursor is set
        while NSCursor.current != .arrow {
            NSCursor.pop()
        }
    }
    
    private func setResizeLeftRightNSCursor() {
        while NSCursor.current != .resizeLeftRight {
            NSCursor.resizeLeftRight.push()
        }
    }
}
