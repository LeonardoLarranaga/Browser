//
//  DownloadRow.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/22/25.
//

import SwiftUI

struct DownloadRow: View {
    
    @Environment(SidebarModel.self) private var sidebarModel
    let download: Download
    
    @State private var hover = false
    @State private var cancelHover = false
    
    var body: some View {
        HStack(spacing: 5) {
            Button {
                DownloadManager.shared.activateDownload(download.id)
            } label: {
                HStack(spacing: 5) {
                    leadingIcon

                    VStack(alignment: .leading, spacing: 2) {
                        Text(download.name)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        if download.state == .downloading {
                            if download.opensWhenFinished {
                                Text(openingStatus)
                                    .font(.system(size: 11))
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            } else {
                                progressDetails
                            }
                        } else if download.state == .failed {
                            Text("Download failed")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .disabled(download.state == .failed)
            .accessibilityLabel(rowActionLabel)

            if download.state == .downloading {
                Button {
                    DownloadManager.shared.cancelDownload(download.id)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)
                .layoutPriority(1)
                .foregroundStyle(.primary)
                .background(.primary.opacity(cancelHover ? 0.12 : 0))
                .clipShape(.rect(cornerRadius: 6))
                .onHover { cancelHover = $0 }
                .animation(.snappy(duration: 0.22), value: cancelHover)
                .help("Cancel download")
                .accessibilityLabel("Cancel \(download.name)")
            }
        }
        .frame(minHeight: 38)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .background(sidebarModel.allowDownloadHover && hover ? Color.primary.opacity(0.08) : Color.clear)
        .clipShape(.rect(cornerRadius: 10))
        .onHover { hover = $0 }
        .disabled(!sidebarModel.allowDownloadHover)
    }

    private var rowActionLabel: String {
        if download.state == .downloading {
            return download.opensWhenFinished
                ? "Stop opening \(download.name) when download finishes"
                : "Open \(download.name) when download finishes"
        }
        return "Open \(download.name)"
    }

    private var openingStatus: String {
        guard let interval = download.estimatedTimeRemaining else {
            return Date.now.timeIntervalSince(download.date) < 5
                ? "Opening when ready…"
                : "Opening when download finishes"
        }
        return "Opening in \(formatTimeRemaining(interval))"
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if download.state == .downloading {
            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.25), lineWidth: 3)

                Circle()
                    .trim(from: 0, to: CGFloat(download.progress ?? 0))
                    .stroke(.tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Image(systemName: "arrow.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(width: 24, height: 24)
            .accessibilityLabel("Download progress \(Int((download.progress ?? 0) * 100)) percent")
        } else if download.state == .failed {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 26)
        } else {
            Image(nsImage: NSWorkspace.shared.icon(for: download.url.fileType ?? .item))
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .frame(width: 26, height: 26)
        }
    }

    private var progressDetails: some View {
        HStack(spacing: 3) {
            Text(transferDetails)
                .monospacedDigit()
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("•")

            Text(timeRemainingDetails)
                .monospacedDigit()
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 64, alignment: .leading)
        }
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
    }

    private var transferDetails: String {
        guard let completedBytes = download.completedBytes,
              let totalBytes = download.totalBytes else {
            return "Preparing download…"
        }

        let (unit, divisor) = transferUnit(for: totalBytes)
        let completed = (Double(completedBytes) / divisor).formatted(.number.precision(.fractionLength(1)))
        let total = (Double(totalBytes) / divisor).formatted(.number.precision(.fractionLength(1)))
        return "\(completed)/\(total) \(unit)"
    }

    private var timeRemainingDetails: String {
        guard let interval = download.estimatedTimeRemaining else {
            return Date.now.timeIntervalSince(download.date) < 5 ? "Estimating…" : "ETA n/a"
        }
        return "\(formatTimeRemaining(interval)) left"
    }

    private func transferUnit(for totalBytes: Int64) -> (name: String, divisor: Double) {
        let bytes = Double(totalBytes)
        if bytes >= 999_950_000_000_000 { return ("TB", 1_000_000_000_000) }
        if bytes >= 999_950_000_000 { return ("GB", 1_000_000_000) }
        if bytes >= 999_950_000 { return ("MB", 1_000_000) }
        if bytes >= 999_950 { return ("KB", 1_000) }
        return ("B", 1)
    }

    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        guard interval.isFinite, interval >= 0, interval < Double(Int.max) else { return "ETA n/a" }

        let seconds = max(0, Int(interval.rounded(.up)))
        let hours = seconds / 3_600
        let minutes = (seconds % 3_600) / 60
        let remainingSeconds = seconds % 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        }
        return "\(seconds)s"
    }
}
