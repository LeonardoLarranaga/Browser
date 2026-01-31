//
//  HoverState.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 30/1/26.
//

import SwiftUI

@Observable
final class HoverState {
    var show = false
    var url = ""
    var timer: Timer?

    func handleChange() {
        guard !url.isEmpty else { return }
        timer?.invalidate()

        withAnimation(.browserDefault) {
            show = true
        }

        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            withAnimation(.browserDefault) {
                self.show = false
                self.url = ""
                timer.invalidate()
            }
        }
    }
}
