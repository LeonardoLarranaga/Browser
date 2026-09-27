//
//  Download.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/22/25.
//

import Foundation

struct Download: Identifiable {
    enum State: Equatable {
        case downloading
        case completed
        case failed
    }

    let id: UUID
    let url: URL
    let name: String
    var state: State
    var progress: Double?
    var completedBytes: Int64?
    var totalBytes: Int64?
    var estimatedTimeRemaining: TimeInterval?
    var opensWhenFinished: Bool
    let date: Date
    
    init(
        id: UUID = UUID(),
        url: URL,
        name: String? = nil,
        state: State = .completed,
        progress: Double? = nil,
        completedBytes: Int64? = nil,
        totalBytes: Int64? = nil,
        estimatedTimeRemaining: TimeInterval? = nil,
        opensWhenFinished: Bool = false,
        date: Date = .now
    ) {
        self.id = id
        self.url = url
        self.name = name ?? url.lastPathComponent
        self.state = state
        self.progress = progress
        self.completedBytes = completedBytes
        self.totalBytes = totalBytes
        self.estimatedTimeRemaining = estimatedTimeRemaining
        self.opensWhenFinished = opensWhenFinished
        self.date = date
    }
    
}
