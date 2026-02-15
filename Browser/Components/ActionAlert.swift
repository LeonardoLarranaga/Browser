//
//  ActionAlert.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/12/25.
//

import SwiftUI

struct ActionAlert {
    private(set) var message: String
    private(set) var systemImage: String
    private(set) var isPresented: Bool

    init() {
        self.message = ""
        self.systemImage = ""
        self.isPresented = false
    }

    mutating func present(message: String, systemImage: String) {
        self.message = message
        self.systemImage = systemImage
        isPresented = true
    }

    mutating func dismiss() {
        isPresented = false
    }
}

/// An alert that displays an action that was performed by the user
fileprivate struct ActionAlertView: ViewModifier {

    @Environment(BrowserWindow.self) var browserWindow

    @State var dismissTimer: Timer?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if browserWindow.actionAlert.isPresented {
                    LazyVStack {
                        ScrollView {
                            LazyHStack(spacing: 10) {
                                Text(browserWindow.actionAlert.message)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: false, vertical: true)
                                Image(systemName: browserWindow.actionAlert.systemImage)
                                    .fontWeight(.bold)
                                    .frame(width: 20)
                            }
                            .font(.system(size: 14, weight: .medium))
                            .padding()
                            .background {
                                if let currentSpace = browserWindow.currentSpace, !currentSpace.colors.isEmpty {
                                    SidebarSpaceBackground(browserSpace: currentSpace, isSidebarCollapsed: true)
                                } else {
                                    GlassEffectView()
                                }
                            }
                            .clipShape(.rect(cornerRadius: 12))
                            .shadow(radius: 3)
                            .padding()
                        }
                        .scrollIndicators(.hidden)
                    }
                    .browserTransition(.scale.combined(with: .move(edge: .top)))
                    .onScrollPhaseChange { _, newPhase in
                        if newPhase == .interacting {
                            dismiss()
                        }
                    }
                    .onAppear(perform: startDismissTimer)
                    .onChange(of: browserWindow.actionAlert.message, startDismissTimer)
                    .onDisappear {
                        dismissTimer?.invalidate()
                    }
                }
            }
    }

    func dismiss() {
        withAnimation(.browserDefault) {
            browserWindow.actionAlert.dismiss()
        }
    }

    func startDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            dismiss()
        }
    }
}

extension View {
    func actionAlert() -> some View {
        modifier(ActionAlertView())
    }
}
