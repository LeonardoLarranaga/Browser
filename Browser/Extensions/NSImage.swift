//
//  NSImage.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/4/25.
//

import AppKit
import CoreImage

extension NSImage {
    /// Convert an NSImage to PNG data
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation else { return nil }
        return NSBitmapImageRep(data: tiffRepresentation)?.representation(using: .png, properties: [:])
    }

    var averageColor: NSColor? {
        guard let tiff = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let cgImage = bitmap.cgImage else { return nil }

        let inputImage = CIImage(cgImage: cgImage)
        let extent = inputImage.extent
        guard extent.width > 0, extent.height > 0 else { return nil }

        let context = CIContext(options: [.workingColorSpace: NSNull()])
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: inputImage,
            kCIInputExtentKey: CIVector(cgRect: extent)
        ]), let output = filter.outputImage else { return nil }

        var bitmapPixel = [UInt8](repeating: 0, count: 4)
        context.render(
            output,
            toBitmap: &bitmapPixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        let r = CGFloat(bitmapPixel[0]) / 255
        let g = CGFloat(bitmapPixel[1]) / 255
        let b = CGFloat(bitmapPixel[2]) / 255
        let a = CGFloat(bitmapPixel[3]) / 255
        guard a > 0 else { return nil }
        return NSColor(red: r, green: g, blue: b, alpha: 1)
    }
}
