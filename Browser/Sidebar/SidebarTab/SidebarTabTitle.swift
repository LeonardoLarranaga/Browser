//
//  Title.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 26/1/26.
//

import SwiftUI

struct SidebarTabTitle: View {

    @Environment(BrowserTab.self) var browserTab

    @Binding var isEditingTitle: Bool
    @FocusState var isTextFieldFocused: Bool

    @State var customTitle = ""
    
    var body: some View {
        if isEditingTitle {
            TextField("", text: $customTitle, onCommit: {
                isEditingTitle = false
                if customTitle.isReallyEmpty {
                    browserTab.customTitle = nil
                } else {
                    browserTab.customTitle = customTitle
                }
            })
            .focused($isTextFieldFocused)
            .onAppear {
                customTitle = browserTab.displayTitle
                isTextFieldFocused = true
                NSApp.selectAllText()
            }
        } else {
            Text(browserTab.displayTitle)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}
