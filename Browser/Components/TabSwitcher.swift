//
//  TabSwitcher.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/11/25.
//

import SwiftUI
import KeyboardShortcuts

/// A floating panel tht shows a tab switcher with the current loaded tabs
struct TabSwitcher: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(BrowserWindowState.self) var browserWindowState
    
    var browserSpaces: [BrowserSpace]
    var allLoadedTabs: [BrowserTab] {
        browserSpaces.flatMap { $0.loadedTabs }
    }
    
    @State var selectedTabIndex = 0
    @State var downEvent: Any?
    @State var upEvent: Any?
    @State var closeEvent: Any?
    
    var body: some View {
        ScrollView(.horizontal) {
            if browserWindowState.showTabSwitcher {
                LazyHStack(spacing: 0) {
                    ForEach(Array(zip(allLoadedTabs.indices, allLoadedTabs)), id: \.0) { index, tab in
                        TabView(index, tab)
                    }
                }
                .scrollTargetLayout()
                .padding()
                .onAppear {
                    // Get the key and modifiers for the shortcut
                    guard let key = KeyboardShortcuts.Name.showTabSwitcher.shortcut?.carbonKeyCode,
                          let modifiers = KeyboardShortcuts.Name.showTabSwitcher.shortcut?.modifiers
                    else { return print("Error getting the key for the shortcut") }
                    
                    // On key down, change the selected tab
                    downEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        if event.keyCode == key && event.modifierFlags.contains(modifiers) {
                            selectNextTab()
                        }
                        return event
                    }
                    
                    // On key up, change the current space to the selected tab
                    upEvent = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                        if !event.modifierFlags.contains(modifiers) {
                            if let selectedTab = allLoadedTabs[safe: selectedTabIndex] {
                                selectedTab.activateSpace(in: browserWindowState)
                                browserWindowState.currentSpace?.currentTab = selectedTab
                                browserWindowState.showTabSwitcher = false
                            }
                        }
                        return event
                    }
                    
                    // Add close tab shortcut
                    guard let closeKey = KeyboardShortcuts.Name.closeTab.shortcut?.carbonKeyCode else { return }
                    
                    closeEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        if event.keyCode == closeKey {
                            if let selectedTab = allLoadedTabs[safe: selectedTabIndex] {
                                browserSpaces.first(where: { $0.loadedTabs.contains(selectedTab) })?.closeTab(selectedTab, using: modelContext)
                                selectNextTab()
                            }
                        }
                        return event
                    }
                }
                // Remove the event monitors when the view disappears
                .onDisappear {
                    NSEvent.removeMonitor(downEvent as Any)
                    NSEvent.removeMonitor(upEvent as Any)
                    NSEvent.removeMonitor(closeEvent as Any)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .scrollPosition(id: .init(get: {
            selectedTabIndex
        }, set: { _ in } ))
    }
    
    func selectNextTab() {
        guard !allLoadedTabs.isEmpty else { return }
        selectedTabIndex = (selectedTabIndex + 1) % allLoadedTabs.count
    }
    
    @ViewBuilder
    func TabView(_ index: Int, _ tab: BrowserTab) -> some View {
        VStack {
            Group {
                switch tab.contentType {
                case .web:
                    Image(systemName: "arrow.counterclockwise.square.fill")
                        .font(.system(size: 50))
                case .history:
                    TabSnapshotView(tab: tab)
                        .shadow(radius: 10)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            
            HStack {
                if let favicon = tab.favicon, let nsImage = NSImage(data: favicon) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: "globe")
                        .resizable()
                        .font(.title)
                }
                
                Text(tab.title)
                    .lineLimit(1)
                    .fontWeight(.bold)
            }
        }
        .frame(width: 155)
        .padding()
        .background(index == selectedTabIndex ? browserWindowState.currentSpace?.getColors.first ?? .accentColor : .clear)
        .clipShape(.rect(cornerRadius: 10))
        .onHover { isHovered in
            if isHovered {
                selectedTabIndex = index
            }
        }
    }
}

struct TabSnapshotView: View {
    
    let tab: BrowserTab
    @State private var snapshot: NSImage?

    var body: some View {
        ZStack {
            if let snapshot {
                Image(nsImage: snapshot)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "safari")
                    .font(.largeTitle)
            }
        }
        .frame(width: 150, height: 100)
        .onAppear {
            loadSnapshot()
        }
    }

    func loadSnapshot() {
        Task {
            if let image = try await tab.webview?.takeSnapshot(configuration: nil) {
                DispatchQueue.main.async {
                    self.snapshot = image
                }
            }
        }
    }
}
