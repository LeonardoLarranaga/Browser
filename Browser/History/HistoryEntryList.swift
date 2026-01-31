//
//  HistoryEntryList.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/16/25.
//

import SwiftUI
import SwiftData

struct HistoryEntryList: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(BrowserWindow.self) var browserWindow
    
    @Query(sort: \BrowserHistoryEntry.date, order: .reverse) var history: [BrowserHistoryEntry]
    
    var groupedHistory: [Date: [BrowserHistoryEntry]] {
        Dictionary(grouping: history.filter {
            searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) || $0.url.absoluteString.localizedCaseInsensitiveContains(searchText)
        }) { entry in
            let date = Calendar.current.startOfDay(for: entry.date)
            return date
        }
    }
    
    var allHistoryEntries: [BrowserHistoryEntry] {
        groupedHistory.values.flatMap { $0 }
    }
    
    @Bindable var browserTab: BrowserTab
    
    @State var selectedHistoryEntries = Set<BrowserHistoryEntry>()
    @State var searchText = ""
    
    var body: some View {
        VStack {
            if history.isEmpty {
                ContentUnavailableView("Start Navigating To Fill The History", systemImage: "clock.arrow.circlepath")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                HStack {
                    Button("Clear History") {
                        BrowserHistoryEntry.deleteAllHistory(using: modelContext)
                    }
                    
                    Spacer()
                    
                    TextField("Search History", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                
                List {
                    ForEach(groupedHistory.keys.sorted { $1 < $0 }, id: \.self) { date in
                        Section {
                            ForEach(groupedHistory[date] ?? []) { entry in
                                HistoryEntryRow(entry: entry)
                                    .modifier(HistoryEntryRowContextMenu(entry: entry, browserTab: browserTab))
//                                    .onTapGesture {
//                                        handleSelection(for: entry)
//                                    }
//                                    .overlay {
//                                        if selectedHistoryEntries.contains(entry) {
//                                            RoundedRectangle(cornerRadius: 4)
//                                                .stroke(Color.accentColor, lineWidth: 2)
//                                        }
//                                    }
                            }
                        } header: {
                            Text(date, style: .date)
                                .font(.title.bold())
                                .contextMenu {
                                    Button("Delete Entries From This Date") {
                                        for entry in groupedHistory[date] ?? [] {
                                            modelContext.delete(entry)
                                        }
                                        try? modelContext.save()
                                    }
                                }
                        }
                        .collapsible(true)
                        .headerProminence(.increased)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.sidebar)
            }
        }
        .foregroundColor(colorScheme == .dark ? .white : .black)
    }
    
    func handleSelection(for entry: BrowserHistoryEntry) {
        let isCommandPressed = NSEvent.modifierFlags.contains(.command)
        let isShiftPressed = NSEvent.modifierFlags.contains(.shift)
        
        if isCommandPressed {
            if selectedHistoryEntries.contains(entry) {
                selectedHistoryEntries.remove(entry)
            } else {
                selectedHistoryEntries.insert(entry)
            }
        } else if isShiftPressed {
            guard let endIndex = allHistoryEntries.firstIndex(of: entry),
                  let startIndex = allHistoryEntries.firstIndex(where: { selectedHistoryEntries.contains($0) })
            else { return }
            
            let range = min(startIndex, endIndex)...max(startIndex, endIndex)
            let entriesInRange = allHistoryEntries[range]
            
            selectedHistoryEntries.formUnion(entriesInRange)
        } else {
            selectedHistoryEntries = [entry]
        }
    }
}
