//
//  ReadSize.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/23/25.
//

import SwiftUI

extension View {
    /// Creates a View with a conditional modifier
    /// - Parameter modifier: The modifier to apply to the view
    /// - Parameter condition: The condition to apply the modifier
    @ViewBuilder
    func conditionalModifier<T: View>(condition: Bool, _ transform: (Self) -> T) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Reads the size of the view and updates the given binding with the width
    /// - Parameter width: Binding to update with the width of the view
    func readingWidth(width: Binding<CGFloat>) -> some View {
        background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        updateWidthIfNeeded(geometry.size.width, into: width)
                    }
                    .onChange(of: geometry.size.width) { _, newValue in
                        updateWidthIfNeeded(newValue, into: width)
                    }
            }
        }
    }
}

private func updateWidthIfNeeded(_ newWidth: CGFloat, into binding: Binding<CGFloat>) {
    // Avoid feedback loops during constraint/layout passes by:
    // 1) ignoring tiny changes, and
    // 2) deferring the write to the next runloop.
    let tolerance: CGFloat = 0.5

    let current = binding.wrappedValue
    guard abs(current - newWidth) > tolerance else { return }

    DispatchQueue.main.async {
        let latest = binding.wrappedValue
        guard abs(latest - newWidth) > tolerance else { return }
        binding.wrappedValue = newWidth
    }
}
