import SwiftUI

@main
struct WindowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var panel: NSPanel?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: "Window")
            button.action = #selector(togglePanel)
            button.target = self
        }
        
        // Create the panel with Itsycal-style appearance
        let panel = WindowPanel(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 500),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Configure panel appearance
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        panel.animationBehavior = .utilityWindow
        panel.isMovable = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        
        panel.contentView = NSHostingView(rootView: ContentView())
        
        self.panel = panel
        
        // Hide dock icon - this app only lives in menu bar
        NSApp.setActivationPolicy(.accessory)
    }
    
    @objc func togglePanel() {
        guard let panel = panel, let button = statusItem?.button else { return }
        
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            // Position panel below the menu bar icon
            let buttonFrame = button.window?.convertToScreen(button.convert(button.bounds, to: nil)) ?? .zero
            let panelX = buttonFrame.midX - panel.frame.width / 2
            let panelY = buttonFrame.minY - panel.frame.height - 8
            
            panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
            panel.makeKeyAndOrderFront(nil)
            
            // Ensure app activates to receive events
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
