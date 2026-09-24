//
//  SidebarSpaceBackground.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/11/25.
//

import SwiftUI

struct SidebarSpaceBackground: View {
    
    private let browserSpaces: [BrowserSpace]
    private let scrollProgress: CGFloat
    let isSidebarCollapsed: Bool

    init(browserSpace: BrowserSpace, isSidebarCollapsed: Bool) {
        self.browserSpaces = [browserSpace]
        self.scrollProgress = 0
        self.isSidebarCollapsed = isSidebarCollapsed
    }

    init(browserSpaces: [BrowserSpace], scrollProgress: CGFloat, isSidebarCollapsed: Bool) {
        self.browserSpaces = browserSpaces
        self.scrollProgress = scrollProgress
        self.isSidebarCollapsed = isSidebarCollapsed
    }

    var body: some View {
        let lowerIndex = min(max(Int(scrollProgress.rounded(.down)), 0), max(browserSpaces.count - 1, 0))
        let upperIndex = min(lowerIndex + 1, max(browserSpaces.count - 1, 0))
        let blend = min(max(scrollProgress - CGFloat(lowerIndex), 0), 1)

        ZStack {
            if browserSpaces.indices.contains(lowerIndex) {
                SidebarSpaceBackgroundLayer(
                    browserSpace: browserSpaces[lowerIndex],
                    isSidebarCollapsed: isSidebarCollapsed
                )
                .opacity(1 - blend)
            }

            if upperIndex != lowerIndex, browserSpaces.indices.contains(upperIndex) {
                SidebarSpaceBackgroundLayer(
                    browserSpace: browserSpaces[upperIndex],
                    isSidebarCollapsed: isSidebarCollapsed
                )
                .opacity(blend)
            }
        }
    }
}

private struct SidebarSpaceBackgroundLayer: View {

    let browserSpace: BrowserSpace
    let isSidebarCollapsed: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 10)) { _ in
            if !browserSpace.colors.isEmpty && browserSpace.colorOpacity > 0 {
                let grainOpacity = browserSpace.grainOpacity
                background
                    .conditionalModifier(condition: browserSpace.grainOpacity > 0) {
                        $0
                            .visualEffect { content, proxy in
                                content
                                    .colorEffect(
                                        ShaderLibrary.noiseShader(
                                            .float2(proxy.size),
                                            .float(0)
                                        )
                                    )
                                    .opacity(grainOpacity)
                            }
                            .background(background)
                    }
                    .conditionalModifier(condition: browserSpace.grainOpacity == 0) {
                        $0
                            .opacity(browserSpace.colorOpacity)
                    }
            }
        }
    }
    
    private var gradient: some View {
        LinearGradient(colors: Preferences.sidebarPosition == .trailing && Preferences.reverseColorsOnTrailingSidebar ? browserSpace.getColors.reversed() : browserSpace.getColors, startPoint: .leading, endPoint: .trailing).opacity(browserSpace.colorOpacity)
    }
    
    private var color: some View {
        browserSpace.getColors.first?.opacity(browserSpace.colorOpacity) ?? .clear
    }
    
    private var background: some View {
        Group {
            if isSidebarCollapsed {
                color
            } else {
                gradient
            }
        }
    }
}
