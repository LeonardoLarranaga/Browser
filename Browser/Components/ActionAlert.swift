//
//  ActionAlert.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/12/25.
//

import SwiftUI

/// An alert that displays an action that was performed by the user
struct ActionAlert: ViewModifier {
    
    @Environment(BrowserWindowState.self) var browserWindowState
    
    @State var dismissTimer: Timer?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if browserWindowState.showActionAlert {
                    LazyVStack {
                        ScrollView {
                            LazyHStack(spacing: 10) {
                                Text(browserWindowState.actionAlertMessage)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: false, vertical: true)
                                Image(systemName: browserWindowState.actionAlertSystemImage)
                                    .fontWeight(.bold)
                                    .frame(width: 20)
                            }
                            .font(.system(size: 14, weight: .medium))
                            .padding()
                            .background {
                                if let currentSpace = browserWindowState.currentSpace, !currentSpace.colors.isEmpty {
                                    SidebarSpaceBackground(browserSpace: currentSpace, isSidebarCollapsed: true)
                                        .background(.ultraThinMaterial)
                                } else {
                                    VisualEffectView(material: .fullScreenUI, blendingMode: .withinWindow)
                                }
                            }
                            .clipShape(.rect(cornerRadius: 12))
                            .shadow(radius: 3)
                            .padding()
                        }
                        .scrollIndicators(.hidden)
                    }
                    .browserTransition(.scale.combined(with: .move(edge: .top)))
                    .onScrollPhaseChange { oldPhase, newPhase in
                        withAnimation(.browserDefault) {
                            if newPhase == .interacting {
                                browserWindowState.showActionAlert = false
                            }
                        }
                    }
                    .onAppear {
                        dismissTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                            withAnimation(.browserDefault) {
                                browserWindowState.showActionAlert = false
                            }
                        }
                    }
                    .onDisappear {
                        dismissTimer?.invalidate()
                    }
                }
            }
    }
}

extension View {
    func actionAlert() -> some View {
        modifier(ActionAlert())
    }
}
