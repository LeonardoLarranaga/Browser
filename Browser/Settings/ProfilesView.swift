//
//  ProfilesView.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 23/2/26.
//

import SwiftData
import SwiftUI
import WebKit

struct SettingsProfilesView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var profiles: [BrowserProfile]
    @Query(sort: \BrowserSpace.order) var spaces: [BrowserSpace]
    
    @State var showAddProfile = false
    @State var showEditProfile = false
    @State var selectedProfile: BrowserProfile? = nil
    
    @State var showDeleteProfileAlert = false
    
    var selectedProfileSpaces: [BrowserSpace] {
        if let selectedProfile { selectedProfile.browserSpaces }
        else { spaces.filter { $0.profile == nil } }
    }
    
    var body: some View {
        Form {
            Section {
                ProfileCardList(profiles: profiles, showAddProfile: $showAddProfile, selectedProfile: $selectedProfile)
            } footer: {
                Text("The Default profile uses the shared website data store. Each additional profile has its own isolated cookies, cache, and history.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            if showAddProfile {
                NewProfileView(selectedProfile: $selectedProfile, isPresented: $showAddProfile)
            }
            
            if showEditProfile, let selectedProfile {
                NewProfileView(selectedProfile: $selectedProfile, isPresented: $showEditProfile, editingProfile: selectedProfile)
            }
            
            Section {
                ProfileSpacesView(profiles: profiles, selectedProfile: selectedProfile, spaces: selectedProfileSpaces)
                
                if selectedProfile != nil {
                    Button("Edit Profile", systemImage: "pencil") {
                        showAddProfile = false
                        withAnimation(.browserDefault) {
                            showEditProfile.toggle()
                        }
                    }
                    
                    if selectedProfileSpaces.isEmpty {
                        Button("Delete Profile", systemImage: "trash") {
                            showDeleteProfileAlert = true
                        }
                    }
                }
            } header: {
                Text("\(selectedProfile?.name ?? "Default") Spaces")
            } footer: {
                Text("You may only delete a profile if it has no associated spaces.")
                
            }
        }
        .formStyle(.grouped)
        .onChange(of: selectedProfile) {
            showEditProfile = false
            showAddProfile = false
        }
        .alert("Delete \(selectedProfile?.name ?? "")", isPresented: $showDeleteProfileAlert) {
            Button(role: .cancel, action: {})
            Button("Delete", role: .destructive, action: deleteSelectedProfile)
        } message: {
            Text("Are you sure you want to delete the \(selectedProfile?.name ?? "") profile? This will also delete all your history, cookies, and other browsing data associated with this profile. This action cannot be undone.")
        }
    }
    
    func deleteSelectedProfile() {
        guard let selectedProfile else { return }
        
        // 1. Wipe the isolated WKWebsiteDataStore (cookies, cache, IndexedDB, etc.)
        Task {
            do {
                try await WKWebsiteDataStore.remove(forIdentifier: selectedProfile.id)
            } catch {
                print("Failed to remove website data store for profile \(selectedProfile.name): \(error)")
            }
        }
        
        // 2. Delete all history entries belonging to this profile
        for entry in selectedProfile.historyEntries {
            modelContext.delete(entry)
        }
        
        // 3. Delete the profile itself
        modelContext.delete(selectedProfile)
        
        do {
            try modelContext.save()
        } catch {
            NSAlert(error: error).runModal()
        }
        
        self.selectedProfile = nil
    }
}

#Preview {
    SettingsProfilesView()
}
