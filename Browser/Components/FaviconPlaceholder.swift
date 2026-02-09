//
//  FaviconPlaceholder.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 8/2/26.
//

import SwiftUI

struct FaviconPlaceholder: View {
    let url: URL
    var body: some View {
        ZStack {
            Color.secondary
            Text(url.cleanHost.first?.uppercased() ?? "?")
                .font(.system(size: 500).bold())
                .minimumScaleFactor(0.01)
                .foregroundStyle(.white)
        }
        .frame(width: 256, height: 256)
    }

    static func nsImage(url: URL) -> NSImage? {
        ImageRenderer(content: FaviconPlaceholder(url: url)).nsImage
    }
}

#Preview {
    FaviconPlaceholder(url: URL(string: "https://www.example.com")!)
}
