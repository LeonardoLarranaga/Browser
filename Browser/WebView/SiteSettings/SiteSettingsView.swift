//
//  SiteSettingsView.swift
//  Browser
//

import SwiftUI
import WebKit

struct SiteSettingsView: View {

    @Environment(\.dismiss) var dismiss

    @Bindable var tab: BrowserTab

    @State private var permissions: [SitePermissionType: SitePermissionDecision] = [:]
    @State private var hasStoredData = false
    @State private var checkingData = true

    private var host: String { tab.url.host() ?? tab.url.absoluteString }
    private var isSecure: Bool { tab.url.scheme == "https" }

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    connectionSection
                    permissionsSection
                    dataSection
                }
                .padding(20)
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(12)
        }
        .frame(width: 520, height: 560)
        .onAppear(perform: load)
    }

    private var header: some View {
        HStack(spacing: 12) {
            favicon
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(host)
                    .font(.headline)
                    .lineLimit(1)
                Label(isSecure ? "Connection is secure" : "Connection is not secure",
                      systemImage: isSecure ? "lock.fill" : "lock.open.fill")
                    .font(.caption)
                    .foregroundStyle(isSecure ? .green : .orange)
            }

            Spacer()
        }
        .padding(20)
    }

    @ViewBuilder
    private var favicon: some View {
        if let data = tab.favicon, let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: 6))
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.systemGray))
        }
    }

    private var connectionSection: some View {
        section("Connection") {
            row("Protocol", value: (tab.url.scheme ?? "").uppercased())
            row("Encryption", value: isSecure ? "Encrypted (TLS)" : "None")
            row("Status", value: isSecure ? "Secure" : "Not secure")
        }
    }

    private var permissionsSection: some View {
        section("Permissions") {
            ForEach(SitePermissionType.allCases) { type in
                HStack {
                    Label(type.title, systemImage: type.systemImage)
                    Spacer()
                    Picker("", selection: binding(for: type)) {
                        ForEach(SitePermissionDecision.allCases) { decision in
                            Text(decision.title).tag(decision)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .fixedSize()
                }
            }
        }
    }

    private var dataSection: some View {
        section("Website Data") {
            HStack {
                Text(checkingData ? "Checking…" : (hasStoredData ? "This site has stored data" : "No stored data"))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            VStack(spacing: 8) {
                Button {
                    tab.webview?.clearCookiesAndReload()
                    refreshDataState()
                } label: {
                    Label("Clear Cookies", systemImage: "trash").frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    tab.webview?.clearCacheAndReload()
                    refreshDataState()
                } label: {
                    Label("Clear Cache", systemImage: "trash.slash").frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(role: .destructive) {
                    clearAllData()
                } label: {
                    Label("Clear All Site Data", systemImage: "xmark.bin").frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.primary.opacity(0.05))
            .clipShape(.rect(cornerRadius: 10))
        }
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }

    private func binding(for type: SitePermissionType) -> Binding<SitePermissionDecision> {
        Binding(
            get: { permissions[type] ?? .ask },
            set: { newValue in
                permissions[type] = newValue
                SitePermissionStore.shared.set(newValue, host: host, type: type)
            }
        )
    }

    private func load() {
        for type in SitePermissionType.allCases {
            permissions[type] = SitePermissionStore.shared.decision(host: host, type: type)
        }
        refreshDataState()
    }

    private var dataStore: WKWebsiteDataStore {
        tab.webview?.configuration.websiteDataStore ?? .default()
    }

    private func matchingRecords(_ records: [WKWebsiteDataRecord]) -> [WKWebsiteDataRecord] {
        records.filter { host.contains($0.displayName) || $0.displayName.contains(host) }
    }

    private func refreshDataState() {
        checkingData = true
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            let matching = matchingRecords(records)
            DispatchQueue.main.async {
                hasStoredData = !matching.isEmpty
                checkingData = false
            }
        }
    }

    private func clearAllData() {
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            let matching = matchingRecords(records)
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: matching) {
                DispatchQueue.main.async {
                    tab.webview?.reload()
                    refreshDataState()
                }
            }
        }
    }
}
