//
//  ContentView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/18/25.
//

import SwiftUI

struct ContentView: View {
    @State private var browserWindow = BrowserWindow()
    var body: some View {
        MainFrame()
            .background(GlassEffectView())
            .ignoresSafeArea(.container, edges: .top)
            .focusedSceneValue(\.browserActiveWindowState, browserWindow)
            .environment(browserWindow)
    }
}
