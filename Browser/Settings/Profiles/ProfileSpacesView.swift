//
//  ProfileSpacesView.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 23/2/26.
//

import SwiftData
import SwiftUI

/// Shows the list of BrowserSpaces belonging to the selected profile.
/// When `selectedProfile` is nil it shows the Default profile's spaces (those with no profile attached).
struct ProfileSpacesView: View {
    
    let profiles: [BrowserProfile]
    let selectedProfile: BrowserProfile?
    let spaces: [BrowserSpace]
    
    var body: some View {
        if spaces.isEmpty {
            ContentUnavailableView(
                "No Spaces",
                systemImage: "rectangle.stack",
                description: Text("This profile has no spaces yet.")
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(spaces) { space in
                    SpaceRow(space: space, profiles: profiles)
                }
            }
        }
    }
}

private struct SpaceRow: View {
    
    @Environment(\.modelContext) var modelContext
    
    let space: BrowserSpace
    let profiles: [BrowserProfile]
    
    @State var showMoveAlert = false
    @State var profileToMoveTo: BrowserProfile?
    
    var spaceColor: Color {
        space.getColors.first ?? .primary
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: space.systemImage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(spaceColor)
                .frame(width: 28, height: 28)
                .background(spaceColor.opacity(0.15), in: Circle())
            
            VStack(alignment: .leading, spacing: 1) {
                Text(space.name)
                    .fontWeight(.medium)
                Text("\(space.tabs.count) tab\(space.tabs.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Menu("Move Space", systemImage: "rectangle.portrait.and.arrow.right.fill") {
                if space.profile != nil {
                    Button("Default Profile", systemImage: "person.crop.circle") {
                        startMovingSpace(to: nil)
                    }
                }
                
                ForEach(profiles.filter { !$0.browserSpaces.contains(space) }) { profile in
                    Button(profile.name, systemImage: profile.systemImage) {
                        startMovingSpace(to: profile)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .alert("Move \(space.name) to \(profileToMoveTo?.name ?? "Default")", isPresented: $showMoveAlert) {
            Button(role: .cancel, action: {})
            Button("Move", role: .confirm, action: moveSpace)
        } message: {
            Text("Are you sure you want to move \(space.name)? Close and reopen the tabs in the space to apply the change.")
        }
    }
    
    func startMovingSpace(to profile: BrowserProfile?) {
        profileToMoveTo = profile
        showMoveAlert = true
    }
    
    func moveSpace() {
        space.profile = profileToMoveTo
        try? modelContext.save()
    }
}
