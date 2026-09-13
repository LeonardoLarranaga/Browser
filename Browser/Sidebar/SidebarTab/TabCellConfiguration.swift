//
//  CellConfiguration.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 1/3/26.
//

import SwiftUI

struct TabCellConfiguration<Background: ShapeStyle>: ViewModifier {

    let onTap: (() -> Void)
    let onDoubleTap: (() -> Void)
    let background: Background

    @State var isPressed = false

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 30)
            .padding(3)
            .background(background, in: .rect(cornerRadius: 10))
            .contentShape(.rect)
            .simultaneousGesture(TapGesture().onEnded({
                onTap()
                if Preferences.disableAnimations { return }
                // Scale bounce effect
                Task {
                    isPressed = true
                    try? await Task.sleep(for: .milliseconds(100))
                    isPressed = false
                }
            }))
            .simultaneousGesture(TapGesture(count: 2).onEnded(onDoubleTap))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.bouncy(duration: 0.15), value: isPressed)
    }
}

extension View {
    func tabCellConfiguration<Background: ShapeStyle>(
        onTap: @escaping () -> Void,
        onDoubleTap: @escaping () -> Void,
        background: Background
    ) -> some View {
        self.modifier(TabCellConfiguration(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            background: background
        ))
    }
}
