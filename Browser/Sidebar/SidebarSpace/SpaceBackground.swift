//
//  SidebarSpaceBackground.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/11/25.
//

import SwiftUI

struct SidebarSpaceBackground: View {
    
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
    
    var gradient: some View {
        LinearGradient(colors: Preferences.shared.sidebarPosition == .trailing && Preferences.shared.reverseColorsOnTrailingSidebar ? browserSpace.getColors.reversed() : browserSpace.getColors, startPoint: .leading, endPoint: .trailing).opacity(browserSpace.colorOpacity)
    }
    
    var color: some View {
        browserSpace.getColors.first?.opacity(browserSpace.colorOpacity) ?? .clear
    }
    
    var background: some View {
        Group {
            if isSidebarCollapsed {
                color
            } else {
                gradient
            }
        }
    }
}
