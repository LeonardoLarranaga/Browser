//
//  ProfileCardList.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 23/2/26.
//

import SwiftData
import SwiftUI

struct ProfileCardList: View {
    
    let profiles: [BrowserProfile]
    
    @Binding var showAddProfile: Bool
    @Binding var selectedProfile: BrowserProfile?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.fixed(110))], spacing: 12) {
                AddProfileButton(showAddProfile: $showAddProfile)
                ProfileCard(nil, selectedProfile: $selectedProfile)
                ForEach(profiles) { profile in
                    ProfileCard(profile, selectedProfile: $selectedProfile)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
