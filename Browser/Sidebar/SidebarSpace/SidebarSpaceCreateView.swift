//
//  SidebarSpaceCreateView.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/4/25.
//

import SwiftUI
import SymbolPicker

/// A view to create a new space in the sidebar
struct SidebarSpaceCreateView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Environment(BrowserWindow.self) var browserWindow
    
    let browserSpaces: [BrowserSpace]
    @Bindable var browserSpace: BrowserSpace
    @State var name = ""
    
    @State var hoverCreateButton = false
    
    @State var showIconPicker = false
    @State var colorPopoverIndex: Int? = nil
    
    @State var browserSpaceCopy: (name: String, systemImage: String, colors: [String], grainOpacity: Double, colorOpacity: Double, colorScheme: String)!
    
    var body: some View {
        VStack {
            Spacer()
            
            Button("Select Icon", systemImage: browserSpace.systemImage) {
                showIconPicker.toggle()
            }
            .buttonStyle(.sidebarHover(padding: 8, cornerRadius: 8))
            .background(RoundedRectangle(cornerRadius: 8).stroke(.gray))
            .sheet(isPresented: $showIconPicker) {
                SymbolPicker(symbol: $browserSpace.systemImage)
            }
            
            TextField("Space Name", text: $name)
                .textFieldStyle(.plain)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 8).stroke(.gray))
                .padding(.vertical, 5)
            
            HStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 5) {
                        ForEach(Array(zip(browserSpace.getColors.indices, browserSpace.getColors)), id: \.0) { index, color in
                            Circle()
                                .fill(color)
                                .stroke(.gray)
                                .frame(height: 20)
                                .onTapGesture {
                                    colorPopoverIndex = index
                                }
                                .popover(isPresented: Binding(get: {
                                    colorPopoverIndex == index
                                }, set: { newValue in
                                    if !newValue { colorPopoverIndex = nil }
                                })) {
                                    VStack {
                                        WheelColorPicker(radius: 75, hex: $browserSpace.colors[safe: index])
                                        
                                        Button("Delete", systemImage: "circle.slash.fill") {
                                            withAnimation(.browserDefault) {
                                                colorPopoverIndex = nil
                                                browserSpace.colors.remove(at: index)
                                            }
                                        }
                                    }
                                    .padding(5)
                                }
                        }
                    }
                    .padding(.horizontal, 5)
                    .frame(height: 25)
                }
                .scrollIndicators(.hidden)
                
                Button {
                    withAnimation(.browserDefault) {
                        browserSpace.colors.append(Color.blue.hexString())
                        colorPopoverIndex = browserSpace.colors.count - 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundStyle(AngularGradient.colorfulAngularGradient)
                        .background(.white, in: .circle)
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Label("Color Opacity", systemImage: "paintbrush")
                CustomSlider(value: $browserSpace.colorOpacity, in: 0...1, disabled: browserSpace.colors.isEmpty)
                
                Label("Grain Effect", systemImage: "circle.dotted.circle")
                CustomSlider(value: $browserSpace.grainOpacity, in: 0...0.33, disabled: browserSpace.colors.isEmpty)
            }
            .font(.body)
            .padding(.bottom, 25)
            
            Button(browserSpace.isEditing ? "Save" : "Create Space") {
                withAnimation(.browserDefault) {
                    browserSpace.name = name
                    browserSpace.isEditing = false
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .padding(5)
            .background(.blue, in: RoundedRectangle(cornerRadius: 8))
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .onHover { isHover in
                withAnimation(.browserDefault) {
                    if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        hoverCreateButton = isHover
                    } else {
                        hoverCreateButton = false
                    }
                }
            }
            .scaleEffect(hoverCreateButton ? 1.05 : 1)
            .shadow(color: .blue.opacity(0.4), radius: hoverCreateButton ? 10 : 0)
            
            Button("Cancel") {
                if !browserSpace.isEditing {
                    if let currentIndex = browserSpaces.firstIndex(of: browserSpace) {
                        let newSelection = currentIndex > 0 ? browserSpaces[currentIndex - 1] : currentIndex < browserSpaces.count - 1 ? browserSpaces[currentIndex + 1] : nil
                        
                        withAnimation(.browserDefault) {
                            modelContext.delete(browserSpace)
                            try? modelContext.save()
                        }
                        
                        // Update order
                        for (index, space) in browserSpaces.enumerated() {
                            space.order = index
                        }
                        try? modelContext.save()
                        
                        if let newSelection {
                            browserWindow.goToSpace(newSelection)
                        }
                    }
                } else {
                    withAnimation(.browserDefault) {
                        browserSpace.isEditing = false
                        browserSpace.name = browserSpaceCopy.name
                        browserSpace.systemImage = browserSpaceCopy.systemImage
                        browserSpace.colors = browserSpaceCopy.colors
                        browserSpace.grainOpacity = browserSpaceCopy.grainOpacity
                        browserSpace.colorOpacity = browserSpaceCopy.colorOpacity
                        browserSpace.colorScheme = browserSpaceCopy.colorScheme
                    }
                }
            }
            .buttonStyle(.sidebarHover(font: .title3.weight(.semibold), padding: 5, fixedWidth: nil, alignment: .center, cornerRadius: 8))
            .padding(.bottom, 25)
            .padding(.top, 5)
        }
        .padding(.horizontal)
        .font(.title3.weight(.semibold))
        .onAppear {
            name = browserSpace.name
            browserSpaceCopy = (name: browserSpace.name, systemImage: browserSpace.systemImage, colors: browserSpace.colors, grainOpacity: browserSpace.grainOpacity, colorOpacity: browserSpace.colorOpacity, colorScheme: browserSpace.colorScheme)
        }
    }
}
