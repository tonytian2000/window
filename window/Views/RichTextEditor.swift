import SwiftUI
import AppKit

struct RichTextEditor: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    let placeholder: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        // Configure text view for rich text
        textView.isRichText = true
        textView.allowsUndo = true
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textView.textStorage?.setAttributedString(attributedText)
        textView.delegate = context.coordinator
        
        // Enable rich text features
        textView.usesRuler = true
        textView.isRulerVisible = false
        textView.importsGraphics = false
        textView.usesFontPanel = true
        textView.usesInspectorBar = false
        
        // Hide scrollbar
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        if textView.attributedString() != attributedText {
            textView.textStorage?.setAttributedString(attributedText)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.attributedText = textView.attributedString()
        }
        
        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            // Check if user pressed Return/Enter
            guard let replacementString = replacementString, replacementString == "\n" else {
                return true
            }
            
            guard let textStorage = textView.textStorage else {
                return true
            }
            
            let text = textStorage.string as NSString
            
            // Find the current line
            let lineRange = text.lineRange(for: NSRange(location: affectedCharRange.location, length: 0))
            let currentLine = text.substring(with: lineRange).trimmingCharacters(in: .newlines)
            
            // Check for bullet list
            if currentLine.hasPrefix("• ") {
                let afterBullet = String(currentLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                
                // If the line only has the bullet (empty content), remove the bullet instead of continuing
                if afterBullet.isEmpty {
                    // Remove the bullet from current line
                    let bulletRange = NSRange(location: lineRange.location, length: 2)
                    textStorage.replaceCharacters(in: bulletRange, with: "")
                    return false
                }
                
                // Insert newline and bullet
                textView.insertText("\n• ", replacementRange: affectedCharRange)
                return false
            }
            
            // Check for numbered list
            if let match = currentLine.range(of: "^(\\d+)\\.\\s+", options: .regularExpression) {
                let prefix = String(currentLine[match])
                let numberString = prefix.dropLast(2) // Remove ". "
                
                if let currentNumber = Int(numberString) {
                    let afterNumber = String(currentLine.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
                    
                    // If the line only has the number (empty content), remove the number instead of continuing
                    if afterNumber.isEmpty {
                        // Remove the number from current line
                        let numberRange = NSRange(location: lineRange.location, length: prefix.count)
                        textStorage.replaceCharacters(in: numberRange, with: "")
                        return false
                    }
                    
                    // Insert newline and next number
                    let nextNumber = currentNumber + 1
                    textView.insertText("\n\(nextNumber). ", replacementRange: affectedCharRange)
                    return false
                }
            }
            
            return true
        }
    }
}

struct RichTextToolbar: View {
    let textView: NSTextView?
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        HStack(spacing: 8) {
            // Text Style
            Group {
                ToolbarButton(icon: "bold", action: { toggleBold() })
                //ToolbarButton(icon: "italic", action: { toggleItalic() })
                ToolbarButton(icon: "underline", action: { toggleUnderline() })
            }
            
            Divider()
                .frame(height: 16)
            
            // Lists
            Group {
                ToolbarButton(icon: "list.bullet", action: { insertBulletList() })
                ToolbarButton(icon: "list.number", action: { insertNumberList() })
            }
            
            Divider()
                .frame(height: 16)
            
            // Font Family
            Group {
                FontPickerButton(textView: textView, localization: localization)
            }
            
            Divider()
                .frame(height: 16)
            
            // Font Size
            Group {
                ToolbarButton(icon: "textformat.size.smaller", action: { decreaseFontSize() })
                ToolbarButton(icon: "textformat.size.larger", action: { increaseFontSize() })
            }
            
            Divider()
                .frame(height: 16)
            
            // Colors
            Group {
                ColorPickerButton(textView: textView, localization: localization)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.5))
    }
    
    private func toggleBold() {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        textView.window?.makeFirstResponder(textView)
        
        let selectedRange = textView.selectedRange()
        guard selectedRange.length > 0 else { return }
        
        // Check if selection has bold using stroke width attribute as well
        var hasBold = false
        textStorage.enumerateAttributes(in: selectedRange, options: []) { attributes, range, stop in
            if let font = attributes[.font] as? NSFont {
                let traits = font.fontDescriptor.symbolicTraits
                if traits.contains(.bold) {
                    hasBold = true
                    stop.pointee = true
                }
            }
            // Also check for simulated bold via stroke width
            if let strokeWidth = attributes[.strokeWidth] as? NSNumber, strokeWidth.floatValue < 0 {
                hasBold = true
                stop.pointee = true
            }
        }
        
        // Apply formatting
        textStorage.beginEditing()
        textStorage.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, stop in
            let currentFont = (value as? NSFont) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            
            if hasBold {
                // Remove bold
                if let regularFont = findRegularFont(for: currentFont) {
                    textStorage.addAttribute(.font, value: regularFont, range: range)
                }
                // Remove stroke width if it was used for simulated bold
                textStorage.removeAttribute(.strokeWidth, range: range)
            } else {
                // Add bold
                if let boldFont = findBoldFont(for: currentFont) {
                    textStorage.addAttribute(.font, value: boldFont, range: range)
                } else {
                    // Fallback: Use stroke width to simulate bold if no bold font variant exists
                    textStorage.addAttribute(.strokeWidth, value: -3.0, range: range)
                }
            }
        }
        textStorage.endEditing()
    }
    
    private func findBoldFont(for font: NSFont) -> NSFont? {
        let size = font.pointSize
        let fontName = font.fontName
        
        // Method 1: Try font descriptor with bold trait
        var descriptor = font.fontDescriptor
        var traits = descriptor.symbolicTraits
        traits.insert(.bold)
        if let newDescriptor = NSFontDescriptor(fontAttributes: [
            .family: font.familyName ?? "",
            .traits: [NSFontDescriptor.TraitKey.weight: NSFont.Weight.bold],
            .size: size
        ]) as NSFontDescriptor?, let boldFont = NSFont(descriptor: newDescriptor, size: size) {
            return boldFont
        }
        
        // Method 2: Try common bold naming patterns
        let boldPatterns = [
            fontName.replacingOccurrences(of: "Regular", with: "Bold"),
            fontName.replacingOccurrences(of: "-Regular", with: "-Bold"),
            fontName + "-Bold",
            fontName.replacingOccurrences(of: "Roman", with: "Bold"),
            fontName + "Bold",
            fontName.replacingOccurrences(of: "MT", with: "-BoldMT"),
            fontName.replacingOccurrences(of: "PS", with: "PS-Bold"),
            fontName + "PS-Bold"
        ]
        
        for pattern in boldPatterns {
            if let found = NSFont(name: pattern, size: size) {
                return found
            }
        }
        
        // Method 3: Try NSFontManager
        let boldFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
        if boldFont.fontDescriptor.symbolicTraits.contains(.bold) && boldFont.fontName != fontName {
            return boldFont
        }
        
        // Method 4: Search font family for bold member
        if let family = font.familyName {
            let members = NSFontManager.shared.availableMembers(ofFontFamily: family) ?? []
            for member in members {
                if let memberName = member[0] as? String,
                   let weight = member[2] as? Int,
                   weight >= 7 { // 7+ typically indicates bold
                    if let found = NSFont(name: memberName, size: size) {
                        return found
                    }
                }
            }
        }
        
        return nil
    }
    
    private func findRegularFont(for font: NSFont) -> NSFont? {
        let size = font.pointSize
        let fontName = font.fontName
        
        // Method 1: Try font descriptor with regular weight
        if let newDescriptor = NSFontDescriptor(fontAttributes: [
            .family: font.familyName ?? "",
            .traits: [NSFontDescriptor.TraitKey.weight: NSFont.Weight.regular],
            .size: size
        ]) as NSFontDescriptor?, let regularFont = NSFont(descriptor: newDescriptor, size: size) {
            if !regularFont.fontDescriptor.symbolicTraits.contains(.bold) {
                return regularFont
            }
        }
        
        // Method 2: Try common regular naming patterns
        let regularPatterns = [
            fontName.replacingOccurrences(of: "Bold", with: "Regular"),
            fontName.replacingOccurrences(of: "-Bold", with: "-Regular"),
            fontName.replacingOccurrences(of: "-Bold", with: ""),
            fontName.replacingOccurrences(of: "Bold", with: ""),
            fontName.replacingOccurrences(of: "-BoldMT", with: "MT"),
            fontName.replacingOccurrences(of: "PS-Bold", with: "PS"),
            fontName.replacingOccurrences(of: "Bold", with: "Roman")
        ]
        
        for pattern in regularPatterns {
            if let found = NSFont(name: pattern, size: size) {
                return found
            }
        }
        
        // Method 3: Try NSFontManager
        let regularFont = NSFontManager.shared.convert(font, toNotHaveTrait: .boldFontMask)
        if !regularFont.fontDescriptor.symbolicTraits.contains(.bold) && regularFont.fontName != fontName {
            return regularFont
        }
        
        // Method 4: Search font family for regular member
        if let family = font.familyName {
            let members = NSFontManager.shared.availableMembers(ofFontFamily: family) ?? []
            for member in members {
                if let memberName = member[0] as? String,
                   let weight = member[2] as? Int,
                   weight <= 5 { // 5 or less typically indicates regular
                    if let found = NSFont(name: memberName, size: size) {
                        return found
                    }
                }
            }
        }
        
        return nil
    }
    
    private func toggleItalic() {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        textView.window?.makeFirstResponder(textView)
        
        let selectedRange = textView.selectedRange()
        guard selectedRange.length > 0 else { return }
        
        // Check if any character in selection is italic to determine toggle direction
        var hasItalic = false
        textStorage.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, stop in
            if let font = value as? NSFont, font.fontDescriptor.symbolicTraits.contains(.italic) {
                hasItalic = true
                stop.pointee = true
            }
        }
        
        // Apply formatting to each character with its current font
        textStorage.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, stop in
            let currentFont = (value as? NSFont) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let newFont: NSFont
            
            if hasItalic {
                newFont = NSFontManager.shared.convert(currentFont, toNotHaveTrait: .italicFontMask)
            } else {
                newFont = NSFontManager.shared.convert(currentFont, toHaveTrait: .italicFontMask)
            }
            
            textStorage.addAttribute(.font, value: newFont, range: range)
        }
    }
    
    private func toggleUnderline() {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        textView.window?.makeFirstResponder(textView)
        
        let selectedRange = textView.selectedRange()
        guard selectedRange.length > 0 else { return }
        
        // Check if any character in selection is underlined to determine toggle direction
        var hasUnderline = false
        textStorage.enumerateAttribute(.underlineStyle, in: selectedRange, options: []) { value, range, stop in
            if let underline = value as? Int, underline != 0 {
                hasUnderline = true
                stop.pointee = true
            }
        }
        
        // Apply underline to entire selection
        let newUnderline = hasUnderline ? 0 : NSUnderlineStyle.single.rawValue
        textStorage.addAttribute(.underlineStyle, value: newUnderline, range: selectedRange)
    }
    
    private func insertBulletList() {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        textView.window?.makeFirstResponder(textView)
        
        let selectedRange = textView.selectedRange()
        let text = textStorage.string
        
        // If no selection, just insert bullet at cursor
        if selectedRange.length == 0 {
            textView.insertText("• ", replacementRange: selectedRange)
            return
        }
        
        // Get the full line range(s) that contain the selection
        let lineRange = (text as NSString).lineRange(for: selectedRange)
        let selectedAttributedText = textStorage.attributedSubstring(from: lineRange)
        let selectedText = selectedAttributedText.string
        
        // Process each line
        let lines = selectedText.components(separatedBy: .newlines)
        let result = NSMutableAttributedString()
        var currentIndex = 0
        
        for (index, line) in lines.enumerated() {
            let lineLength = (line as NSString).length
            let lineRange = NSRange(location: currentIndex, length: lineLength)
            
            if lineLength > 0 && currentIndex < selectedAttributedText.length {
                // Get attributes from the start of the line
                let attributes = selectedAttributedText.attributes(at: currentIndex, effectiveRange: nil)
                
                var processedLine = line
                
                // Remove existing numbered list prefix
                if let range = processedLine.range(of: "^\\d+\\.\\s+", options: .regularExpression) {
                    processedLine.removeSubrange(range)
                }
                
                // Toggle bullet
                if processedLine.hasPrefix("• ") {
                    processedLine.removeFirst(2) // Remove "• "
                } else if !processedLine.trimmingCharacters(in: .whitespaces).isEmpty {
                    processedLine = "• " + processedLine
                }
                
                // Create attributed string with preserved formatting
                let attributedLine = NSMutableAttributedString(string: processedLine, attributes: attributes)
                result.append(attributedLine)
            } else {
                result.append(NSAttributedString(string: line))
            }
            
            // Add newline between lines (except last)
            if index < lines.count - 1 {
                result.append(NSAttributedString(string: "\n"))
                currentIndex += lineLength + 1 // +1 for newline
            } else {
                currentIndex += lineLength
            }
        }
        
        // Replace the line range with formatted text
        textStorage.replaceCharacters(in: lineRange, with: result)
        
        // Update selection to cover the modified range
        textView.setSelectedRange(NSRange(location: lineRange.location, length: result.length))
    }
    
    private func insertNumberList() {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        textView.window?.makeFirstResponder(textView)
        
        let selectedRange = textView.selectedRange()
        let text = textStorage.string
        
        // If no selection, just insert number at cursor
        if selectedRange.length == 0 {
            textView.insertText("1. ", replacementRange: selectedRange)
            return
        }
        
        // Get the full line range(s) that contain the selection
        let lineRange = (text as NSString).lineRange(for: selectedRange)
        let selectedAttributedText = textStorage.attributedSubstring(from: lineRange)
        let selectedText = selectedAttributedText.string
        
        // Process each line
        let lines = selectedText.components(separatedBy: .newlines)
        let result = NSMutableAttributedString()
        var currentIndex = 0
        var lineNumber = 1
        
        for (index, line) in lines.enumerated() {
            let lineLength = (line as NSString).length
            let lineRange = NSRange(location: currentIndex, length: lineLength)
            
            if lineLength > 0 && currentIndex < selectedAttributedText.length {
                // Get attributes from the start of the line
                let attributes = selectedAttributedText.attributes(at: currentIndex, effectiveRange: nil)
                
                var processedLine = line
                
                // Remove existing bullet list prefix
                if processedLine.hasPrefix("• ") {
                    processedLine.removeFirst(2)
                }
                
                // Remove existing numbered list prefix
                if let range = processedLine.range(of: "^\\d+\\.\\s+", options: .regularExpression) {
                    processedLine.removeSubrange(range)
                }
                
                // Add or toggle number
                if !processedLine.trimmingCharacters(in: .whitespaces).isEmpty {
                    processedLine = "\(lineNumber). " + processedLine
                    lineNumber += 1
                }
                
                // Create attributed string with preserved formatting
                let attributedLine = NSMutableAttributedString(string: processedLine, attributes: attributes)
                result.append(attributedLine)
            } else {
                result.append(NSAttributedString(string: line))
            }
            
            // Add newline between lines (except last)
            if index < lines.count - 1 {
                result.append(NSAttributedString(string: "\n"))
                currentIndex += lineLength + 1 // +1 for newline
            } else {
                currentIndex += lineLength
            }
        }
        
        // Replace the line range with formatted text
        textStorage.replaceCharacters(in: lineRange, with: result)
        
        // Update selection to cover the modified range
        textView.setSelectedRange(NSRange(location: lineRange.location, length: result.length))
    }
    
    private func increaseFontSize() {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        textView.window?.makeFirstResponder(textView)
        
        let selectedRange = textView.selectedRange()
        guard selectedRange.length > 0 else { return }
        
        // Apply font size increase to each character with its current font
        textStorage.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, stop in
            let currentFont = (value as? NSFont) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let newSize = min(currentFont.pointSize + 2, 48)
            
            if let newFont = NSFont(descriptor: currentFont.fontDescriptor, size: newSize) {
                textStorage.addAttribute(.font, value: newFont, range: range)
            }
        }
    }
    
    private func decreaseFontSize() {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        textView.window?.makeFirstResponder(textView)
        
        let selectedRange = textView.selectedRange()
        guard selectedRange.length > 0 else { return }
        
        // Apply font size decrease to each character with its current font
        textStorage.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, stop in
            let currentFont = (value as? NSFont) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let newSize = max(currentFont.pointSize - 2, 8)
            
            if let newFont = NSFont(descriptor: currentFont.fontDescriptor, size: newSize) {
                textStorage.addAttribute(.font, value: newFont, range: range)
            }
        }
    }
}

struct ToolbarButton: View {
    let icon: String
    let action: () -> Void
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(PlainButtonStyle())
        .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.5))
        .cornerRadius(4)
    }
}

struct FontPickerButton: View {
    let textView: NSTextView?
    @ObservedObject var localization: LocalizationManager
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        Menu {
            ForEach(popularFonts, id: \.self) { fontName in
                Button(action: {
                    applyFont(fontName)
                }) {
                    Text(fontName)
                        .font(.custom(fontName, size: 14))
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "textformat")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(width: 40, height: 24)
        }
        .buttonStyle(PlainButtonStyle())
        .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.5))
        .cornerRadius(4)
    }
    
    private var popularFonts: [String] {
        [
            "System Font",
            "Arial",
            "Helvetica",
            "Times New Roman",
            "Courier New",
            "Georgia",
            "Verdana",
            "Monaco",
            "Menlo",
            "SF Mono",
            "Comic Sans MS",
            "Impact"
        ]
    }
    
    private func applyFont(_ fontName: String) {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        textView.window?.makeFirstResponder(textView)
        
        let selectedRange = textView.selectedRange()
        guard selectedRange.length > 0 else { return }
        
        // Apply font to each character with its current size and traits
        textStorage.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, stop in
            let currentFont = (value as? NSFont) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let currentSize = currentFont.pointSize
            let currentTraits = currentFont.fontDescriptor.symbolicTraits
            
            let newFont: NSFont
            if fontName == "System Font" {
                newFont = NSFont.systemFont(ofSize: currentSize)
            } else if let font = NSFont(name: fontName, size: currentSize) {
                newFont = font
            } else {
                newFont = currentFont
            }
            
            // Preserve bold/italic traits
            var finalFont = newFont
            if currentTraits.contains(.bold) {
                finalFont = NSFontManager.shared.convert(finalFont, toHaveTrait: .boldFontMask)
            }
            if currentTraits.contains(.italic) {
                finalFont = NSFontManager.shared.convert(finalFont, toHaveTrait: .italicFontMask)
            }
            
            textStorage.addAttribute(.font, value: finalFont, range: range)
        }
    }
}

struct ColorPickerButton: View {
    let textView: NSTextView?
    @ObservedObject var localization: LocalizationManager
    @ObservedObject var settings = AppSettings.shared
    @State private var showingColorPicker = false
    @State private var selectedColor: Color = .black
    
    var body: some View {
        Menu {
            ForEach(predefinedColors, id: \.0) { name, color in
                Button(action: {
                    applyColor(color)
                }) {
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                        Text(name)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(width: 40, height: 24)
        }
        .buttonStyle(PlainButtonStyle())
        .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.5))
        .cornerRadius(4)
    }
    
    private var predefinedColors: [(String, Color)] {
        [
            ("Black", .black),
            ("Red", .red),
            ("Blue", .blue),
            ("Green", .green),
            ("Orange", .orange),
            ("Purple", .purple),
            ("Gray", .gray)
        ]
    }
    
    private func applyColor(_ color: Color) {
        guard let textView = textView else { return }
        textView.window?.makeFirstResponder(textView)
        
        let selectedRange = textView.selectedRange()
        guard selectedRange.length > 0 else { return }
        
        let nsColor = NSColor(color)
        textView.textStorage?.addAttribute(.foregroundColor, value: nsColor, range: selectedRange)
    }
}
