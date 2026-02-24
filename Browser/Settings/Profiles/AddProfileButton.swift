//
//  AddProfileButton.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 23/2/26.
//


import SwiftUI

struct AddProfileButton: View {
    
    @Binding var showAddProfile: Bool
    
    var body: some View {
        Button {
            withAnimation(.browserDefault) {
                showAddProfile = true
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 40))
                Spacer()
                Text("Add")
            }
            .padding()
            .background(.gray.opacity(0.2), in: .rect(cornerRadius: 12))
            .foregroundStyle(.gray)
        }
        .buttonStyle(.plain)
    }
}
