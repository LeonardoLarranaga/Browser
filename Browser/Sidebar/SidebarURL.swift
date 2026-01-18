//
//  SidebarURL.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/20/25.
//

import SwiftUI

struct SidebarURL: View {

    @Environment(\.colorScheme) var colorScheme
    @Environment(BrowserWindowState.self) var browserWindowState

    @State var hover = false

    var body: some View {
        HStack {
            if let currentTab = browserWindowState.currentSpace?.currentTab {
                Text(currentTab.url.cleanHost)
                    .padding(.leading, .sidebarPadding)

                Spacer()

                if hover {
                    Button("Refresh", systemImage: "arrow.clockwise", action: browserWindowState.refreshButtonAction)
                        .buttonStyle(.sidebarHover(hoverStyle: AnyShapeStyle(.ultraThinMaterial) ,cornerRadius: 7))
                        .browserTransition(.opacity)

                    Button("Copy URL To Clipboard", systemImage: "link", action: browserWindowState.copyURLToClipboard)
                        .buttonStyle(.sidebarHover(hoverStyle: AnyShapeStyle(.ultraThinMaterial) ,cornerRadius: 7))
                        .padding(.trailing, .sidebarPadding)
                        .browserTransition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 30)
        .padding(3)
        .background(
            browserWindowState.currentSpace?.textColor(in: colorScheme) == .black ?
            AnyShapeStyle(.ultraThinMaterial).opacity(hover ? 0.6 : 0.3) :
                browserWindowState.currentSpace?.colors.isEmpty == true && colorScheme == .light ?
            AnyShapeStyle(.gray).opacity(hover ? 0.3 : 0.2) :
                AnyShapeStyle(Color.white).opacity(hover ? 0.1 : 0.05)
        )
        .overlay(alignment: .bottom) {
            if Preferences.shared.loadingIndicatorPosition == .onURL && browserWindowState.currentSpace?.currentTab?.isLoading == true {
                ProgressView(value: browserWindowState.currentSpace?.currentTab?.estimatedProgress ?? 0)
                    .progressViewStyle(.linear)
                    .frame(height: 2)
                    .tint(browserWindowState.currentSpace?.getColors.first ?? .accentColor)
            }
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding(.leading, .sidebarPadding)
        .onTapGesture {
            browserWindowState.searchOpenLocation = .fromURLBar
        }
        .onHover { hover in
            withAnimation(.browserDefault?.speed(2)) {
                self.hover = hover
            }
        }
        .zIndex(-1)
    }
}

#Preview {
    SidebarURL()
}
