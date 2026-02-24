//
//  NewProfileView.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 23/2/26.
//

import SwiftUI
import SymbolPicker

struct NewProfileView: View {

    @Environment(\.modelContext) var modelContext

    @Binding var selectedProfile: BrowserProfile?
    @Binding var isPresented: Bool

    /// When non-nil, we are editing an existing profile instead of creating one.
    var editingProfile: BrowserProfile? = nil

    @State var name = ""
    @State var systemImage = "person.crop.circle"
    @State var color = Color.blue

    @FocusState var focusedField: Bool
    @State var showSymbolPicker = false
    @State var showColorPicker = false

    var isEditing: Bool { editingProfile != nil }

    var body: some View {
        Section(isEditing ? "Edit Profile" : "New Profile") {
            HStack {
                TextField("Profile Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField)
                    .onAppear {
                        // Pre-populate fields when editing
                        if let p = editingProfile {
                            name = p.name
                            systemImage = p.systemImage
                            color = p.color
                        }
                        focusedField = true
                    }

                Spacer()

                Button("Icon", systemImage: systemImage) {
                    showSymbolPicker.toggle()
                }

                Spacer()

                Circle().fill(color)
                    .frame(width: 20, height: 20)
                    .onTapGesture { showColorPicker.toggle() }
                    .popover(isPresented: $showColorPicker) {
                        WheelColorPicker(color: $color)
                    }
            }

            HStack {
                Spacer()
                Button(role: .cancel) {
                    withAnimation(.browserDefault) {
                        focusedField = false
                        isPresented = false
                    }
                }
                Button("Save", role: .confirm) {
                    withAnimation(.browserDefault) {
                        saveProfile()
                    }
                }
                .disabled(name.isReallyEmpty)
            }
        }
        .sheet(isPresented: $showSymbolPicker) {
            SymbolPicker(symbol: $systemImage)
        }
    }

    func saveProfile() {
        if let profile = editingProfile {
            // Edit existing profile
            profile.name = name
            profile.systemImage = systemImage
            profile.color = color
        } else {
            // Create new profile
            let newProfile = BrowserProfile(name: name, systemImage: systemImage, color: color)
            modelContext.insert(newProfile)
            withAnimation(.browserDefault) {
                selectedProfile = newProfile
            }
        }

        try? modelContext.save()
        isPresented = false
    }
}
