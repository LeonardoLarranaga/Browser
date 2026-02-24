//
//  ColorString.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 1/30/25.
//

import SwiftUI

extension Color {
    /// Creates a new color from a hex string.
    /// - Parameter hex: The hex string to create the color from.
    init?(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 1
        
        let length = cleanHex.count
        
        guard Scanner(string: cleanHex).scanHexInt64(&rgb) else {
            return nil
        }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255
            b = CGFloat(rgb & 0x0000FF) / 255
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255
            a = CGFloat(rgb & 0x000000FF) / 255
        } else {
            return nil
        }
        
        self.init(.sRGB, red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
    
    /// - Returns: The hex string representation of the color.
    func hexString() -> String {
        let nsColor = NSColor(self)
        guard let components = nsColor.cgColor.components, components.count >= 3 else {
            return "000000"
        }
        
        let r = Float(components[0] * 255)
        let g = Float(components[1] * 255)
        let b = Float(components[2] * 255)
        let a = components.count >= 4 ? Float(components[3]) : 1.0
        
        if a != 1.0 {
            return String(format: "%02X%02X%02X%02X", Int(r), Int(g), Int(b), Int(a))
        } else {
            return String(format: "%02X%02X%02X", Int(r), Int(g), Int(b))
        }
    }
}
