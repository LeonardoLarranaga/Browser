//
//  SidebarURL.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/20/25.
//

import SwiftUI

struct SidebarURL: View {

    @Environment(\.colorScheme) var colorScheme
    @Environment(BrowserWindow.self) var browserWindow

    @State var hover = false

    var body: some View {
        HStack {
            if let currentTab = browserWindow.currentSpace?.currentTab {
                Text(currentTab.url.cleanHost)
                    .padding(.leading, .sidebarPadding)

                Spacer()

                if hover {
                    Button("Refresh", systemImage: "arrow.clockwise", action: browserWindow.refreshButtonAction)
                        .buttonStyle(.sidebarHover(hoverStyle: AnyShapeStyle(.ultraThinMaterial) ,cornerRadius: 7))
                        .browserTransition(.opacity)

                    Button("Copy URL To Clipboard", systemImage: "link", action: browserWindow.copyURLToClipboard)
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
            browserWindow.currentSpace?.textColor(in: colorScheme) == .black ?
            AnyShapeStyle(.ultraThinMaterial).opacity(hover ? 0.6 : 0.3) :
                browserWindow.currentSpace?.colors.isEmpty == true && colorScheme == .light ?
            AnyShapeStyle(.gray).opacity(hover ? 0.3 : 0.2) :
                AnyShapeStyle(Color.white).opacity(hover ? 0.1 : 0.05)
        )
        .overlay(alignment: .bottom) {
            if Preferences.shared.loadingIndicatorPosition == .onURL && browserWindow.currentSpace?.currentTab?.isLoading == true {
                ProgressView(value: browserWindow.currentSpace?.currentTab?.estimatedProgress ?? 0)
                    .progressViewStyle(.linear)
                    .frame(height: 2)
                    .tint(browserWindow.currentSpace?.getColors.first ?? .accentColor)
            }
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding(.leading, .sidebarPadding)
        .onTapGesture {
            browserWindow.searchOpenLocation = .fromURLBar
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
