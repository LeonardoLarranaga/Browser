//
//  SidebarTabNewButton.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/31/25.
//

import SwiftUI

struct SidebarTabNewButton: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Bindable var browserSpace: BrowserSpace
    @State var isHovering = false
    
    var body: some View {
        Button(action: addTab) {
            Label("New Tab", systemImage: "plus")
                .padding(.leading, .sidebarPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 30)
                .padding(3)
                .background(isHovering ? .white.opacity(0.1) : .clear)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.leading, .sidebarPadding)
        }
        .buttonStyle(.plain)
        .onHover { isHover in
            self.isHovering = isHover
        }
    }
    
    func addTab() {
        withAnimation(.bouncy) {
            let tab = BrowserTab(title: UUID().uuidString, url: URL(string: "https://www.google.com")!, browserSpace: browserSpace)
            modelContext.insert(tab)
            try? modelContext.save()
        }
    }
}
