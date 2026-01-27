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
    private var sizeObserver: NSKeyValueObservation?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Load custom icon from bundle resources
            if let customImage = NSImage(named: "win") {
                // Resize to standard menu bar size (18pt is optimal for menu bar icons)
                customImage.size = NSSize(width: 18, height: 18)
                // Use the actual icon colors instead of template mode for better visibility
                // This makes the icon stand out more in both light and dark themes
                customImage.isTemplate = false
                button.image = customImage
            } else {
                // Fallback to system icon if custom image not found
                let fallbackImage = NSImage(systemSymbolName: "macwindow", accessibilityDescription: "Window")
                fallbackImage?.isTemplate = true
                button.image = fallbackImage
            }
            button.action = #selector(handleClick)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Get initial window size from settings
        let settings = AppSettings.shared
        
        // Create the panel with Itsycal-style appearance
        let panel = WindowPanel(
            contentRect: NSRect(x: 0, y: 0, width: settings.windowWidth, height: settings.windowHeight),
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
        
        // Observe settings changes for dynamic window size updates
        setupSettingsObserver()
        
        // Hide dock icon - this app only lives in menu bar
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func setupSettingsObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowSizeDidChange),
            name: NSNotification.Name("WindowSizeChanged"),
            object: nil
        )
    }
    
    @objc private func windowSizeDidChange() {
        guard let panel = panel else { return }
        let settings = AppSettings.shared
        
        // Calculate new frame maintaining position relative to menu bar
        var newFrame = panel.frame
        let oldSize = newFrame.size
        newFrame.size = NSSize(width: settings.windowWidth, height: settings.windowHeight)
        
        // Adjust Y position to keep panel positioned below menu bar icon
        newFrame.origin.y += (oldSize.height - newFrame.size.height)
        
        panel.setFrame(newFrame, display: true, animate: true)
    }
    
    @objc func handleClick() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            // Show context menu on right-click
            showContextMenu()
        } else {
            // Toggle panel on left-click
            togglePanel()
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        // Show/Hide Window option
        let toggleText = (panel?.isVisible ?? false) ? "Hide Window" : "Show Window"
        let toggleItem = NSMenuItem(title: toggleText, action: #selector(togglePanel), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit option
        let quitItem = NSMenuItem(title: LocalizationManager.shared.localized("menu.quit"), action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
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
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
