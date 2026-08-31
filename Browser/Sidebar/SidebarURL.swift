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

    private var currentTab: BrowserTab? {
        browserWindow.currentSpace?.currentTab
    }

    private var isSecure: Bool {
        currentTab?.url.scheme == "https"
    }

    var body: some View {
        HStack(spacing: 5) {
            if let currentTab {
                Image(systemName: isSecure ? "lock.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.leading, .sidebarPadding)

                Text(currentTab.url.cleanHost)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer(minLength: 0)

                if hover {
                    Button("Refresh", systemImage: "arrow.clockwise", action: browserWindow.refreshButtonAction)
                        .buttonStyle(.subtleURLBar)
                        .browserTransition(.opacity)

                    Button("Copy URL To Clipboard", systemImage: "link", action: browserWindow.copyURLToClipboard)
                        .buttonStyle(.subtleURLBar)
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
            if Preferences.loadingIndicatorPosition == .onURL && browserWindow.currentSpace?.currentTab?.isLoading == true {
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

struct SubtleURLBarButtonStyle: ButtonStyle {
    @State private var hover = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .frame(width: 22, height: 22)
            .background(hover ? Color.primary.opacity(0.08) : .clear)
            .clipShape(.rect(cornerRadius: 6))
            .onHover { hover = $0 }
    }
}

extension ButtonStyle where Self == SubtleURLBarButtonStyle {
    static var subtleURLBar: SubtleURLBarButtonStyle { SubtleURLBarButtonStyle() }
}
