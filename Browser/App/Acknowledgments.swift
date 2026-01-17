//
//  Acknowledgments.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/5/25.
//

import SwiftUI

fileprivate struct Acknowledgment: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let description: String
    let url: String
    
    static var acknowledgments: [Acknowledgment] {
        [
            Acknowledgment(title: "SymbolPicker", author: "Yubo Qin (xnth97)", description: "A simple and cross-platform SFSymbol picker for SwiftUI.", url: "https://github.com/xnth97/SymbolPicker"),
            Acknowledgment(title: "KeyboardShortcuts", author: "Sindre Sorhus", description: "⌨️ Add user-customizable global keyboard shortcuts (hotkeys) to your macOS app in minutes", url: "https://github.com/sindresorhus/KeyboardShortcuts"),
            Acknowledgment(title: "Make a floating panel in SwiftUI for macOS", author: "João Gabriel", description: "Learn how to make a versatile floating panel component for Mac using SwiftUI and AppKit.", url: "https://cindori.com/developer/floating-panel")
        ]
    }
}

struct Acknowledgments: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(BrowserWindowState.self) var browserWindowState
    
    var body: some View {
        VStack {
            Text("Acknowledgments")
                .font(.title.bold())
                .padding()
            
            Text("A big thanks ♡ to the following projects and articles:")
            
            List(Acknowledgment.acknowledgments) { acknowledgment in
                AcknowledgmentRow(acknowledgment)
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    @ViewBuilder
    fileprivate func AcknowledgmentRow(_ acknowledgment: Acknowledgment) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(acknowledgment.title)
                    .font(.headline)
                    .padding(.top)
                Text("by \(acknowledgment.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(acknowledgment.description)
                    .font(.body)
                    .padding(.bottom)
            }
            
            Spacer()
            
            Button("Visit") {
                visit(acknowledgment)
            }
            .buttonStyle(.borderedProminent)
            .padding(.trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .clipShape(.rect(cornerRadius: 10))
        .padding(5)
    }
    
    fileprivate func visit(_ a: Acknowledgment) {
        let newTab = BrowserTab(title: a.title, url: URL(string: a.url)!, browserSpace: browserWindowState.currentSpace)
        browserWindowState.currentSpace?.openNewTab(newTab, using: modelContext)
        browserWindowState.showAcknowledgements = false
    }
}
