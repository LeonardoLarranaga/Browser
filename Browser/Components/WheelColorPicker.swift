//
//  WheelColorPicker.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/11/25.
//

import SwiftUI

struct WheelColorPicker: View {
    
    let radius: CGFloat
    private var diameter: CGFloat {
        radius * 2
    }
    
    let color: Binding<Color>?
    let hex: Binding<String>?
    
    init(radius: CGFloat = 100, color: Binding<Color>? = nil, hex: Binding<String>? = nil) {
        self.radius = radius
        self.color = color
        self.hex = hex
    }
    
    @State private var location = CGPoint.zero
    
    var body: some View {
        GeometryReader { geometry in
            let startLocation = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            ZStack {
                Circle()
                    .fill(AngularGradient.colorfulAngularGradient)
                    .overlay(.radialGradient(colors: [.white, .white.opacity(0.001)], center: .center, startRadius: 0, endRadius: radius), in: .circle)
                
                Circle()
                    .fill(color?.wrappedValue ?? Color(hex: hex?.wrappedValue ?? "") ?? .white)
                    .frame(width: diameter * 0.2)
                    .position(location)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Attach inner circle to border when dragging outside
                        let distanceX = value.location.x - startLocation.x
                        let distanceY = value.location.y - startLocation.y
                        let direction = CGPoint(x: distanceX, y: distanceY)
                        
                        let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
                        
                        if distance < radius {
                            location = value.location
                        } else {
                            let attachedX = direction.x / distance * radius
                            let attachedY = direction.y / distance * radius
                            location = CGPoint(x: startLocation.x + attachedX, y: startLocation.y + attachedY)
                        }
                        
                        if distance == 0 { return }
                        
                        
                        // Calculate color from location
                        var angle = Angle(radians: -Double(atan(direction.y / direction.x)))
                        angle.degrees += direction.x < 0 ? 180 : direction.x > 0 && direction.y > 0 ? 360 : 0
                        
                        let hue = angle.degrees / 360
                        let saturation = min(distance / radius, 1.0)
                        let color = Color(hue: hue, saturation: saturation, brightness: 0.9)
                        self.color?.wrappedValue = color
                        self.hex?.wrappedValue = color.hexString()
                    }
                    .onEnded { value in
                        withAnimation(.browserDefault) {
                            location = startLocation
                        }
                    }
            )
            .onAppear {
                location = startLocation
            }
        }
        .frame(width: diameter, height: diameter)
    }
}

#Preview {
    struct Preview: View {
        @State private var color = Color.red
        @State private var hex = "#FF0000"
        
        var body: some View {
            WheelColorPicker(color: $color, hex: $hex)
        }
    }
    
    return Preview()
}
