//
//  BrowserCommands.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/7/25.
//

import SwiftUI

struct BrowserCommands: Commands {
    
    @FocusedValue(\.browserActiveWindowState) private var browserActiveWindowState

    private var isDefaultBrowser: Bool {
        NSWorkspace.shared.urlForDefaultBrowser == Bundle.main.bundleURL
    }
    
    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button("Acknowledgements...") {
                browserActiveWindowState?.showAcknowledgements.toggle()
            }
            
            Button("Set as Default Browser") {
                let appURL = Bundle.main.bundleURL
                let schemes = ["http", "https", "html"]
                for scheme in schemes {
                    NSWorkspace.shared.setDefaultApplication(at: appURL, toOpenURLsWithScheme: scheme)
                }
            }
            .disabled(isDefaultBrowser)
        }
        
        FileCommands()
        EditCommands()
        ViewCommands()
        HistoryCommands()
    }
}
