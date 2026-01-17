//
//  FloatingPanel.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/25/25.
//  https://cindori.com/developer/floating-panel
//

import SwiftUI

private struct FloatingPanelKey: EnvironmentKey {
    static let defaultValue: NSPanel? = nil
}

extension EnvironmentValues {
    var floatingPanel: NSPanel? {
        get { self[FloatingPanelKey.self] }
        set { self[FloatingPanelKey.self] = newValue }
    }
}

/// An NSPanel subclass that implements floating panel traits.
class FloatingPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    
    init(
        isPresented: Binding<Bool>,
        contentRect: NSRect,
        backing: NSWindow.BackingStoreType = .buffered,
        defer flag: Bool = false,
        glassStyle: NSGlassEffectView.Style,
        glassTintColor: Color? = nil,
        view: () -> Content
    ) {
        self._isPresented = isPresented
        
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .titled, .closable, .fullSizeContentView],
            backing: backing,
            defer: flag
        )
        
        // Allow the panel to be on top of other windows
        isFloatingPanel = true
        level = .floating
        backgroundColor = .clear
        
        // Allow the pannel to be overlaid in a fullscreen space
        collectionBehavior.insert(.fullScreenAuxiliary)
        
        // Don't show a window title, even if it's set
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        
        isMovableByWindowBackground = false
        isMovable = false
        
        // Hide when onfocused
        hidesOnDeactivate = true
        
        // Hide all traffic light buttons
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        // Set the content view
        // The safe area is ignored because the title bar still interferes with the geometry
        contentView = NSHostingView(rootView: view()
            .background(GlassEffectView(style: glassStyle, tintColor: glassTintColor))
            .ignoresSafeArea()
            .environment(\.floatingPanel, self)
        )
    }
    
    // Close automatically when out of focus, e.g. outside click
    override func resignMain() {
        super.resignMain()
        close()
    }
    
    // Close and toggle presentation, so that it matches the current state of the panel
    override func close() {
        super.close()
        isPresented = false
    }
    
    // `canBecomeKey` and `canBecomeMain` are both required so that text inputs inside the panel can receive focus
    override var canBecomeKey: Bool {
        true
    }
    
    override var canBecomeMain: Bool {
        true
    }
    
    /// Centers the panel using the current window
    func center(in window: NSWindow?) {
        guard let window else { return }
        
        let x = (window.frame.width - frame.width) / 2 + window.frame.origin.x
        let y = (window.frame.height - frame.height) / 2 + window.frame.origin.y
        
        setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    /// Moves the origin of the panel to a point in a window. Where (0, 0) is the top left corner of said window
    func move(to point: CGPoint, in window: NSWindow?) {
        guard let window else { return }
        
        let x = point.x + window.frame.origin.x
        let y = window.frame.origin.y + window.frame.size.height - frame.size.height - point.y
        
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}

/// Add a  ``FloatingPanel`` to a view hierarchy
fileprivate struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
    /// Determines wheter the panel should be presented or not
    @Binding var isPresented: Bool
    
    /// Determines the size and origin of the panel
    var origin: CGPoint
    var size: CGSize
    
    /// Determines if the panel should be centered in the key window
    var shouldCenter: Bool

    /// The liquid glass style of the panel's background
    var glassStyle: NSGlassEffectView.Style
    var glassTintColor: Color?

    /// Holds the panel content's view closure
    @ViewBuilder let view: () -> PanelContent
    
    /// Stores the panel instance with the same generic type as the view closure
    @State var panel: FloatingPanel<PanelContent>?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                panel = FloatingPanel(
                    isPresented: $isPresented,
                    contentRect: CGRect(origin: origin, size: size),
                    glassStyle: glassStyle,
                    glassTintColor: glassTintColor,
                    view: view
                )
                if isPresented {
                    present()
                }
            }
            .onDisappear {
                panel?.close()
                panel = nil
            }
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    // Save the current key window before it converts into the panel
                    let window = NSApp.keyWindow
                    
                    // Resize the panel to the new size
                    panel?.setFrame(CGRect(origin: origin, size: size), display: false)
                    present()
                    
                    if shouldCenter {
                        panel?.center(in: window)
                    } else {
                        panel?.move(to: origin, in: window)
                    }
                } else {
                    panel?.close()
                }
            }
    }
    
    /// Present the panel and make it the key window
    func present() {
        panel?.makeKeyAndOrderFront(nil)
        panel?.makeMain()
    }
}

extension View {
    /// Present a ``FloatingPanel`` in SwiftUI fashion
    /// - Parameter isPresented: A boolean binding that keeps track of the panel's presentation state
    /// - Parameter origin: The origin to present the panel in relation to the key window
    /// - Parameter size: The content panel's size
    /// - Parameter shouldCenter: Determines if the panel should be centered in the key window
    /// - Parameter glassStyle: The liquid glass style of the panel's background
    /// - Parameter glassTintColor: An optional tint color for the glass effect
    /// - Parameter content: The displayed content
    func floatingPanel<PanelContent: View>(
        isPresented: Binding<Bool>,
        origin: CGPoint = .zero,
        size: CGSize,
        shouldCenter: Bool = true,
        glassStyle: NSGlassEffectView.Style = .regular,
        glassTintColor: Color? = nil,
        @ViewBuilder content: @escaping () -> PanelContent
    ) -> some View {
        modifier(FloatingPanelModifier(
            isPresented: isPresented,
            origin: origin,
            size: size,
            shouldCenter: shouldCenter,
            glassStyle: glassStyle,
            glassTintColor: glassTintColor,
            view: content
        ))
    }
}
