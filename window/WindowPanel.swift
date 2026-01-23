import AppKit
import SwiftUI

class WindowPanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func resignKey() {
        super.resignKey()
        // Don't hide if there's a sheet or child window open
        if sheets.isEmpty && childWindows?.isEmpty ?? true {
            close()
        }
    }
}
