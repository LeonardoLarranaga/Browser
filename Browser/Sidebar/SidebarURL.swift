//
//  SidebarURL.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/20/25.
//

import SwiftUI

struct SidebarURL: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(BrowserWindow.self) private var browserWindow
    @State private var safariExtensions = SafariExtensions.shared

    @State private var hover = false
    @State private var showSiteSettings = false

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

                Text(currentTab.contentType == .history ? String(localized: "History") : currentTab.url.cleanHost)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer(minLength: 0)

                if currentTab.pageZoomLevel != 1.0 {
                    Button {
                        currentTab.webview?.zoomActualSize()
                    } label: {
                        Text(Double(currentTab.pageZoomLevel).formatted(.percent.precision(.fractionLength(0))))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.primary.opacity(0.1))
                            .clipShape(.capsule)
                    }
                    .buttonStyle(.plain)
                    .help("Reset zoom to \(Double(1).formatted(.percent.precision(.fractionLength(0))))")
                    .browserTransition(.opacity)
                }

                if hover {
                    Button("Refresh", systemImage: "arrow.clockwise", action: browserWindow.refreshButtonAction)
                        .buttonStyle(.subtleURLBar)
                        .browserTransition(.opacity)

                }

                siteMenu
                    .padding(.trailing, .sidebarPadding)
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
        .background(alignment: .trailing) {
            SafariExtensionPopoverAnchor(manager: safariExtensions)
                .frame(width: 18, height: 18)
                .padding(.trailing, .sidebarPadding + 3)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            if let currentTab, currentTab.isLoading {
                ProgressView(value: currentTab.estimatedProgress)
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
        .sheet(isPresented: $showSiteSettings) {
            if let currentTab {
                SiteSettingsView(tab: currentTab)
            }
        }
        .zIndex(-1)
    }

    private var siteMenu: some View {
        Menu {
            Section {
                Label(isSecure ? "Connection is secure" : "Connection is not secure",
                      systemImage: isSecure ? "lock.fill" : "lock.open.fill")
                Label(isSecure ? "Encrypted (HTTPS)" : "Not encrypted (HTTP)",
                      systemImage: isSecure ? "checkmark.shield.fill" : "xmark.shield.fill")
            } header: {
                Text(currentTab?.url.host() ?? "")
            }

            Section {
                Button("Copy Link", systemImage: "link", action: browserWindow.copyURLToClipboard)
                if let url = currentTab?.url {
                    ShareLink(item: url) {
                        Label("Share…", systemImage: "square.and.arrow.up")
                    }
                }
                Button("Reload", systemImage: "arrow.clockwise", action: browserWindow.refreshButtonAction)
            }

            Section {
                Menu {
                    Button("Zoom In", systemImage: "plus.magnifyingglass", action: zoomIn)
                    Button("Actual Size", systemImage: "1.magnifyingglass", action: zoomReset)
                    Button("Zoom Out", systemImage: "minus.magnifyingglass", action: zoomOut)
                } label: {
                    Label("Zoom", systemImage: "textformat.size")
                }

                Button("Web Inspector", systemImage: "hammer") {
                    currentTab?.webview?.toggleDeveloperTools()
                }
            }

            if let currentTab, !browserWindow.isNoTraceWindow, !safariExtensions.entries.isEmpty {
                Section("Extensions") {
                    ForEach(safariExtensions.entries.filter(\.installation.isExtensionEnabled)) { entry in
                        SafariExtensionToolbarMenu(manager: safariExtensions, entry: entry, tab: currentTab)
                    }
                }
            }

            Section("Privacy") {
                Button("Clear Cookies & Reload", systemImage: "trash") {
                    currentTab?.webview?.clearCookiesAndReload()
                }
                Button("Clear Cache & Reload", systemImage: "trash.slash") {
                    currentTab?.webview?.clearCacheAndReload()
                }
                Button("Site Settings & Permissions…", systemImage: "gearshape") {
                    showSiteSettings = true
                }
            }
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityLabel("Website Settings and Extensions")
        .help("Website Settings and Extensions")
    }

    private func zoomIn() {
        currentTab?.webview?.zoomIn()
    }

    private func zoomOut() {
        currentTab?.webview?.zoomOut()
    }

    private func zoomReset() {
        currentTab?.webview?.zoomActualSize()
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
