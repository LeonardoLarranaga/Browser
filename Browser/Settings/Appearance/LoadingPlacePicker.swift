//
//  LoadingPlacePicker.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 3/11/25.
//

import SwiftUI

struct LoadingPlacePicker: View {

    var body: some View {
        VStack(alignment: .leading) {
            Label("Loading Indicator Position", systemImage: "progress.indicator")
            HStack {
                LoadingPickerButton(.onURL, image: .loadingPlaceURL)
                LoadingPickerButton(.onTab, image: .loadingPlaceTab)
                LoadingPickerButton(.onWebView, image: .loadingPlaceWebView)
            }
            .frame(height: 155)
        }
    }
    
    @ViewBuilder
    func LoadingPickerButton(_ value: Preferences.LoadingIndicatorPosition, image: ImageResource) -> some View {
        Button {
            Preferences.shared.loadingIndicatorPosition = value
        } label: {
            Image(image)
                .resizable()
                .scaledToFit()
                .overlay {
                    Rectangle()
                        .strokeBorder(.blue, lineWidth: Preferences.shared.loadingIndicatorPosition == value ? 2 : 0)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoadingPlacePicker()
}
