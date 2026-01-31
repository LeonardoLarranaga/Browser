//
//  ContentView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var browserWindow = BrowserWindow()
    var body: some View {
        MainFrame()
            .glassEffect(in: .rect)
            .ignoresSafeArea(.container, edges: .top)
            .focusedSceneValue(\.browserActiveWindowState, browserWindow)
            .environment(browserWindow)
            .sheet(isPresented: $browserWindow.showURLQRCode) {
                if let currentTab = browserWindow.currentSpace?.currentTab {
                    URLQRCodeView(browserTab: currentTab)
                }
            }
            .floatingPanel(isPresented: $browserWindow.showAcknowledgements, size: CGSize(width: 500, height: 300)) {
                Acknowledgments()
                    .environment(browserWindow)
            }
    }
}
