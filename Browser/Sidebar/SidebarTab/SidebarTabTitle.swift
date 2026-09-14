//
//  Title.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 26/1/26.
//

import SwiftUI

struct SidebarTabTitle: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(BrowserSpace.self) private var browserSpace

    @Binding var title: String?
    let displayTitle: String
    @Binding var isEditingTitle: Bool

    @FocusState private var isTextFieldFocused: Bool
    @State private var customTitle = ""
    
    var body: some View {
        if isEditingTitle {
            TextField("", text: $customTitle, onCommit: {
                isEditingTitle = false
                if customTitle.isReallyEmpty {
                    title = nil
                } else {
                    title = customTitle
                }
            })
            .focused($isTextFieldFocused)
            .onAppear {
                DispatchQueue.main.async {
                    customTitle = title ?? ""
                    isTextFieldFocused = true
                    NSApp.selectAllText()
                }
            }
        } else {
            Text(displayTitle)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}
