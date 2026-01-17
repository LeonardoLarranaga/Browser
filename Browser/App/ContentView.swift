//
//  ContentView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var browserWindowState = BrowserWindowState()
    var body: some View {
        MainFrame()
            .glassEffect(in: .rect)
            .ignoresSafeArea(.container, edges: .top)
            .focusedSceneValue(\.browserActiveWindowState, browserWindowState)
            .environment(browserWindowState)
            .sheet(isPresented: $browserWindowState.showURLQRCode) {
                if let currentTab = browserWindowState.currentSpace?.currentTab {
                    URLQRCodeView(browserTab: currentTab)
                }
            }
            .floatingPanel(isPresented: $browserWindowState.showAcknowledgements, size: CGSize(width: 500, height: 300)) {
                Acknowledgments()
                    .environment(browserWindowState)
            }
    }
}
