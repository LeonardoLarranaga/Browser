//
//  ProfileCard.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 23/2/26.
//

import SwiftUI

struct ProfileCard: View {

    let profile: BrowserProfile?
    @Binding var selectedProfile: BrowserProfile?

    @State var isHovering = false

    init(_ profile: BrowserProfile?, selectedProfile: Binding<BrowserProfile?>) {
        self.profile = profile
        self._selectedProfile = selectedProfile
    }

    var isSelected: Bool {
        selectedProfile?.id == profile?.id
    }

    var color: Color {
        profile?.color ?? .accentColor
    }

    var body: some View {
        Button {
            selectedProfile = profile
        } label: {
            VStack(spacing: 8) {
                Image(systemName: profile?.systemImage ?? "person.crop.circle")
                    .font(.system(size: 40))
                Spacer()
                Text(profile?.name ?? "Default")
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(color.opacity(isSelected ? 0.2 : isHovering ? 0.1 : 0), in: .rect(cornerRadius: 12))
            .foregroundStyle(color)
            .contentShape(.rect(cornerRadius: 12))
        }
        .animation(.browserDefault, value: isSelected)
        .buttonStyle(.plain)
        .onHover { hover in
            withAnimation(.browserDefault) {
                isHovering = hover
            }
        }
    }
}
