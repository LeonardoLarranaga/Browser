//
//  CustomSlider.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/11/25.
//

import SwiftUI

/// An iOS-System-Like Slider
struct CustomSlider<V: BinaryFloatingPoint>: View where V.Stride: BinaryFloatingPoint {
    
    let value: Binding<V>
    let range: ClosedRange<V>
    let height: CGFloat
    let scaleEffect: CGFloat
    let scaleHeight: CGFloat
    let backgroundColor: Color
    let valueColor: Color
    let disabled: Bool
    
    init(
        value: Binding<V>,
        in range: ClosedRange<V>,
        height: CGFloat = 32,
        scaleEffect: CGFloat = 1.05,
        scaleHeight: CGFloat = 1.1,
        backgroundColor: Color = .blue.opacity(0.2),
        valueColor: Color = .blue,
        disabled: Bool = false
    ) {
        self.value = value
        self.range = range
        self.height = height
        self.scaleEffect = scaleEffect
        self.scaleHeight = scaleHeight
        self.backgroundColor = backgroundColor
        self.valueColor = valueColor
        self.disabled = disabled
    }
    
    @State private var sliderWidth: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    @State private var dragging: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(disabled ? .gray : backgroundColor)
                
                Rectangle()
                    .fill(disabled ? .gray.opacity(0.2) : valueColor)
                    .frame(width: sliderWidth)
            }
            .clipShape(.rect(cornerRadius: dragging ? 16 : 8))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation(.browserDefault) {
                            dragging = true
                        }
                        
                        let translation = value.translation.width + lastDragValue
                        sliderWidth = min(max(translation, 0), geometry.size.width)
                        
                        let progress = sliderWidth / geometry.size.width
                        self.value.wrappedValue = range.lowerBound + V(progress) * (range.upperBound - range.lowerBound)
                    }
                    .onEnded { _ in
                        withAnimation(.browserDefault) {
                            dragging = false
                        }
                        lastDragValue = sliderWidth
                    }
            )
            .disabled(disabled)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    let normalizedValue = (value.wrappedValue - range.lowerBound) / (range.upperBound - range.lowerBound)
                    sliderWidth = geometry.size.width * CGFloat(normalizedValue)
                    lastDragValue = sliderWidth
                }
            }
        }
        .scaleEffect(dragging ? scaleEffect : 1, anchor: .leading)
        .frame(height: height * (dragging ? scaleHeight : 1.0))
    }
}

#Preview {
    struct CustomSlider_Preview: View {
        @State private var number = 0.0
        var body: some View {
            CustomSlider(value: $number, in: 0...1, backgroundColor: .secondary.opacity(0.2), valueColor: .primary.opacity(0.6))
                .padding(.horizontal)
                .padding()
                .overlay { Text(number.description)}
        }
    }
    return CustomSlider_Preview()
}
