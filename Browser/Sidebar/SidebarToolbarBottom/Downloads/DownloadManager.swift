//
//  DownloadManager.swift
//  Browser
//

import AppKit
import Observation
import WebKit

/// Owns every WebKit download so downloads remain visible across tabs and windows.
@MainActor
@Observable
final class DownloadManager: NSObject, WKDownloadDelegate {
    static let shared = DownloadManager()

    private(set) var downloads: [Download] = []
    private(set) var lastStartedDownloadID: UUID?

    @ObservationIgnored
    private var activeDownloads: [ObjectIdentifier: ActiveDownload] = [:]

    @ObservationIgnored
    private var progressObservations: [ObjectIdentifier: NSKeyValueObservation] = [:]

    @ObservationIgnored
    private var reservedTemporaryPaths = Set<String>()

    @ObservationIgnored
    private var cancellingDownloadIDs = Set<UUID>()

    private struct ActiveDownload {
        let itemID: UUID
        let webKitDownload: WKDownload
        let temporaryURL: URL
        let suggestedFilename: String
        let folderURL: URL
        let didStartSecurityScope: Bool
        var lastProgressSampleAt: Date
        var lastProgressSampleBytes: Int64
        var estimatedBytesPerSecond: Double?
    }

    private override init() {
        super.init()
    }

    func cancelDownload(_ itemID: UUID) {
        guard let (key, activeDownload) = activeDownloads.first(where: { $0.value.itemID == itemID }) else { return }
        cancellingDownloadIDs.insert(itemID)
        activeDownload.webKitDownload.cancel { [weak self] _ in
            self?.finishCancellation(itemID: itemID, key: key)
        }
    }

    func toggleOpenWhenFinished(_ itemID: UUID) {
        guard let index = downloads.firstIndex(where: { $0.id == itemID }),
              downloads[index].state == .downloading else { return }
        downloads[index].opensWhenFinished.toggle()
    }

    func activateDownload(_ itemID: UUID) {
        guard let download = downloads.first(where: { $0.id == itemID }) else { return }
        if download.state == .downloading {
            toggleOpenWhenFinished(itemID)
        } else {
            open(download)
        }
    }

    func open(_ download: Download) {
        guard download.state != .downloading else { return }
        do {
            let didOpen = try withAccessToFile(download.url) { url in
                NSWorkspace.shared.open(url)
            }
            if !didOpen {
                NSAlert(error: "Could not open \(download.name).").runModal()
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    func showInFinder(_ download: Download) {
        guard download.state != .downloading else { return }
        do {
            try withAccessToFile(download.url) { url in
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    func moveToTrash(_ download: Download) {
        guard download.state != .downloading else { return }
        do {
            try withAccessToFile(download.url) { url in
                try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            }
            downloads.removeAll { $0.id == download.id }
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String,
        completionHandler: @escaping @MainActor @Sendable (URL?) -> Void
    ) {
        if let folderURL = Preferences.downloadURL {
            begin(
                download,
                in: folderURL,
                securityScoped: Preferences.downloadLocationRequiresSecurityScope,
                suggestedFilename: suggestedFilename,
                completionHandler: completionHandler
            )
            return
        }

        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.title = "Select Download Location For \"\(suggestedFilename)\""
        panel.begin { [weak self] response in
            guard let self, response == .OK, let folderURL = panel.url else {
                completionHandler(nil)
                return
            }

            self.begin(
                download,
                in: folderURL,
                securityScoped: Preferences.downloadLocationNeedsSecurityScope(folderURL),
                suggestedFilename: suggestedFilename,
                completionHandler: completionHandler
            )
        }
    }

    func downloadDidFinish(_ download: WKDownload) {
        let key = ObjectIdentifier(download)
        guard let activeDownload = activeDownloads.removeValue(forKey: key) else { return }
        progressObservations.removeValue(forKey: key)?.invalidate()
        defer { release(activeDownload) }

        if cancellingDownloadIDs.remove(activeDownload.itemID) != nil {
            try? FileManager.default.removeItem(at: activeDownload.temporaryURL)
            downloads.removeAll { $0.id == activeDownload.itemID }
            return
        }

        do {
            let destinationURL = activeDownload.folderURL
                .appendingPathComponent(activeDownload.suggestedFilename)
                .uniqueFileURL()
            try FileManager.default.moveItem(at: activeDownload.temporaryURL, to: destinationURL)

            guard let index = downloads.firstIndex(where: { $0.id == activeDownload.itemID }) else { return }
            let item = downloads[index]
            downloads[index] = Download(
                id: item.id,
                url: destinationURL,
                name: destinationURL.lastPathComponent,
                state: .completed,
                progress: 1,
                opensWhenFinished: item.opensWhenFinished,
                date: item.date
            )
            if item.opensWhenFinished {
                NSWorkspace.shared.open(destinationURL)
            }
            print("Download finished for \(destinationURL.lastPathComponent)")
        } catch {
            markFailed(activeDownload.itemID)
            print("Error finishing download: \(error.localizedDescription)")
        }
    }

    func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
        let key = ObjectIdentifier(download)
        progressObservations.removeValue(forKey: key)?.invalidate()
        if let activeDownload = activeDownloads.removeValue(forKey: key) {
            if cancellingDownloadIDs.contains(activeDownload.itemID) {
                try? FileManager.default.removeItem(at: activeDownload.temporaryURL)
                downloads.removeAll { $0.id == activeDownload.itemID }
            } else {
                markFailed(activeDownload.itemID)
            }
            release(activeDownload)
        }
        print("Download failed for \(download.originalRequest?.url?.lastPathComponent ?? "Unknown file"): \(error.localizedDescription)")
    }

    func refreshDownloads() {
        let activeIDs = Set(activeDownloads.values.map(\.itemID))
        let activeItems = downloads
            .filter { activeIDs.contains($0.id) }
            .sorted { $0.date > $1.date }

        var fileURLs: [URL] = []
        for folderURL in Preferences.downloadHistoryFolders {
            fileURLs.append(contentsOf: contentsOfFolder(folderURL))
        }

        var knownPaths = Set(activeItems.map { $0.url.standardizedFileURL.path })
        let diskDownloads = fileURLs
            .filter { knownPaths.insert($0.standardizedFileURL.path).inserted }
            .sorted { modificationDate(for: $0) > modificationDate(for: $1) }
            .map { url in
                Download(
                    url: url,
                    state: url.pathExtension.lowercased() == "browserdownload" ? .failed : .completed,
                    date: modificationDate(for: url)
                )
            }

        downloads = activeItems + diskDownloads
    }

    func openDownloadsFolder() {
        let configuredFolder = Preferences.downloadURL
        guard let folderURL = configuredFolder ?? Preferences.defaultDownloadURL else { return }
        let needsSecurityScope = configuredFolder != nil && Preferences.downloadLocationRequiresSecurityScope

        if needsSecurityScope && !folderURL.startAccessingSecurityScopedResource() { return }
        NSWorkspace.shared.open(folderURL)
        if needsSecurityScope {
            folderURL.stopAccessingSecurityScopedResource()
        }
    }

    private func begin(
        _ download: WKDownload,
        in folderURL: URL,
        securityScoped: Bool,
        suggestedFilename: String,
        completionHandler: @escaping @MainActor @Sendable (URL?) -> Void
    ) {
        var didStartSecurityScope = false
        if securityScoped {
            guard folderURL.startAccessingSecurityScopedResource() else {
                completionHandler(nil)
                markFailed(for: download)
                return
            }
            didStartSecurityScope = true
        }

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            if didStartSecurityScope {
                folderURL.stopAccessingSecurityScopedResource()
            }
            completionHandler(nil)
            markFailed(for: download)
            print("Could not create download folder: \(error.localizedDescription)")
            return
        }

        Preferences.rememberDownloadFolder(folderURL)

        let safeFilename = (suggestedFilename as NSString).lastPathComponent
        let filename = safeFilename.isEmpty || safeFilename == "." || safeFilename == ".." ? "Download" : safeFilename
        let temporaryURL = reserveTemporaryURL(in: folderURL, suggestedFilename: filename)
        let itemID = UUID()
        let item = Download(
            id: itemID,
            url: temporaryURL,
            name: filename,
            state: .downloading,
            progress: 0
        )

        activeDownloads[ObjectIdentifier(download)] = ActiveDownload(
            itemID: itemID,
            webKitDownload: download,
            temporaryURL: temporaryURL,
            suggestedFilename: filename,
            folderURL: folderURL,
            didStartSecurityScope: didStartSecurityScope,
            lastProgressSampleAt: .now,
            lastProgressSampleBytes: 0,
            estimatedBytesPerSecond: nil
        )
        downloads.insert(item, at: 0)
        observeProgress(of: download, itemID: itemID)
        lastStartedDownloadID = UUID()
        completionHandler(temporaryURL)
    }

    private func observeProgress(of download: WKDownload, itemID: UUID) {
        let key = ObjectIdentifier(download)
        progressObservations[key] = download.progress.observe(\.fractionCompleted, options: [.initial, .new]) { [weak self] progress, _ in
            let fractionCompleted = progress.fractionCompleted
            let completedBytes = max(0, progress.completedUnitCount)
            let totalBytes = progress.totalUnitCount > 0 ? progress.totalUnitCount : nil
            let estimatedTimeRemaining = progress.estimatedTimeRemaining
            let throughput = progress.throughput
            let sampledAt = Date()
            Task { @MainActor [weak self] in
                self?.updateProgress(
                    for: itemID,
                    downloadKey: key,
                    fractionCompleted: fractionCompleted,
                    completedBytes: completedBytes,
                    totalBytes: totalBytes,
                    estimatedTimeRemaining: estimatedTimeRemaining,
                    throughput: throughput,
                    sampledAt: sampledAt
                )
            }
        }
    }

    private func updateProgress(
        for itemID: UUID,
        downloadKey: ObjectIdentifier,
        fractionCompleted: Double,
        completedBytes: Int64,
        totalBytes: Int64?,
        estimatedTimeRemaining: TimeInterval?,
        throughput: Int?,
        sampledAt: Date
    ) {
        guard let index = downloads.firstIndex(where: { $0.id == itemID }) else { return }

        var activeDownload = activeDownloads[downloadKey]
        if var tracker = activeDownload {
            let elapsed = sampledAt.timeIntervalSince(tracker.lastProgressSampleAt)
            let bytesTransferred = completedBytes - tracker.lastProgressSampleBytes
            if elapsed >= 0.2, bytesTransferred > 0 {
                let measuredThroughput = Double(bytesTransferred) / elapsed
                if measuredThroughput.isFinite, measuredThroughput > 0 {
                    tracker.estimatedBytesPerSecond = tracker.estimatedBytesPerSecond.map {
                        $0 * 0.7 + measuredThroughput * 0.3
                    } ?? measuredThroughput
                }
                tracker.lastProgressSampleAt = sampledAt
                tracker.lastProgressSampleBytes = completedBytes
                self.activeDownloads[downloadKey] = tracker
                activeDownload = tracker
            }
        }

        let measuredThroughput = activeDownload?.estimatedBytesPerSecond
        let reportedThroughput = throughput.flatMap { $0 > 0 ? Double($0) : nil }
        let availableThroughput = reportedThroughput ?? measuredThroughput
        let calculatedTimeRemaining: TimeInterval? = {
            guard let totalBytes, totalBytes > completedBytes,
                  let availableThroughput, availableThroughput > 0 else { return nil }
            return Double(totalBytes - completedBytes) / availableThroughput
        }()
        let reportedTimeRemaining = estimatedTimeRemaining.flatMap {
            $0.isFinite && $0 >= 0 ? $0 : nil
        }

        downloads[index].progress = min(1, max(0, fractionCompleted))
        downloads[index].completedBytes = completedBytes
        downloads[index].totalBytes = totalBytes
        downloads[index].estimatedTimeRemaining = reportedTimeRemaining ?? calculatedTimeRemaining
    }

    private func finishCancellation(itemID: UUID, key: ObjectIdentifier) {
        if let activeDownload = activeDownloads.removeValue(forKey: key) {
            progressObservations.removeValue(forKey: key)?.invalidate()
            try? FileManager.default.removeItem(at: activeDownload.temporaryURL)
            release(activeDownload)
        }
        cancellingDownloadIDs.remove(itemID)
        downloads.removeAll { $0.id == itemID }
    }

    private func markFailed(for download: WKDownload) {
        let key = ObjectIdentifier(download)
        if let activeDownload = activeDownloads.removeValue(forKey: key) {
            markFailed(activeDownload.itemID)
            release(activeDownload)
        }
    }

    private func markFailed(_ itemID: UUID) {
        guard let index = downloads.firstIndex(where: { $0.id == itemID }) else { return }
        downloads[index].state = .failed
        downloads[index].progress = nil
    }

    private func stopSecurityScope(for activeDownload: ActiveDownload) {
        if activeDownload.didStartSecurityScope {
            activeDownload.folderURL.stopAccessingSecurityScopedResource()
        }
    }

    private func release(_ activeDownload: ActiveDownload) {
        reservedTemporaryPaths.remove(activeDownload.temporaryURL.path)
        stopSecurityScope(for: activeDownload)
    }

    private func reserveTemporaryURL(in folderURL: URL, suggestedFilename: String) -> URL {
        let fileManager = FileManager.default
        var temporaryURL = folderURL.appendingPathComponent("\(suggestedFilename).browserdownload")
        var count = 1

        while fileManager.fileExists(atPath: temporaryURL.path) || reservedTemporaryPaths.contains(temporaryURL.path) {
            temporaryURL = folderURL.appendingPathComponent("\(suggestedFilename) (\(count)).browserdownload")
            count += 1
        }

        reservedTemporaryPaths.insert(temporaryURL.path)
        return temporaryURL
    }

    private func modificationDate(for url: URL) -> Date {
        let values = try? url.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
        return max(values?.creationDate ?? .distantPast, values?.contentModificationDate ?? .distantPast)
    }

    private func contentsOfFolder(_ folderURL: URL) -> [URL] {
        let needsSecurityScope = Preferences.downloadLocationNeedsSecurityScope(folderURL)
        if needsSecurityScope && !folderURL.startAccessingSecurityScopedResource() {
            print("Could not access download folder at \(folderURL.path)")
            return []
        }
        defer {
            if needsSecurityScope {
                folderURL.stopAccessingSecurityScopedResource()
            }
        }

        do {
            if folderURL.standardizedFileURL == Preferences.defaultDownloadURL?.standardizedFileURL {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
            return try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
        } catch {
            print("Failed to read download folder at \(folderURL.path): \(error.localizedDescription)")
            return []
        }
    }

    private func withAccessToFile<T>(_ fileURL: URL, operation: (URL) throws -> T) throws -> T {
        let parentFolder = fileURL.deletingLastPathComponent()
        guard Preferences.downloadLocationNeedsSecurityScope(parentFolder) else {
            return try operation(fileURL)
        }

        let standardizedParent = parentFolder.standardizedFileURL
        guard let bookmarkedFolder = Preferences.downloadHistoryFolders.first(where: {
            $0.standardizedFileURL == standardizedParent
        }) else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoPermissionError)
        }
        guard bookmarkedFolder.startAccessingSecurityScopedResource() else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoPermissionError)
        }
        defer { bookmarkedFolder.stopAccessingSecurityScopedResource() }
        return try operation(fileURL)
    }
}
