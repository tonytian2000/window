import SwiftUI
import AppKit

struct NotesViewWithRichText: View {
    @ObservedObject var viewModel: NotesViewModel
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var settings = AppSettings.shared
    @State private var newNoteAttributedText = NSAttributedString()
    @State private var selectedCategory = ""
    @State private var showingSettings = false
    @State private var selectedNotesTab = 0 // 0: Editor, 1: History
    @State private var editorTextView: NSTextView?
    @State private var isEditorExpanded = false // Track if editor is expanded
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Top bar - Tab selector with date
            HStack(spacing: 16) {
                // Date display on the left
                Text(formattedDate())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(settings.theme == "dark" ? .secondary : Color(white: 0.3))
                    .padding(.leading, 4)
                
                Spacer()
                
                Button(action: { selectedNotesTab = 0 }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16, weight: .medium))
                        Text(localization.localized("notes.editor"))
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .foregroundColor(selectedNotesTab == 0 ? .accentColor : (settings.theme == "dark" ? .secondary : Color(white: 0.3)))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { selectedNotesTab = 1 }) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text(localization.localized("notes.history"))
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .foregroundColor(selectedNotesTab == 1 ? .accentColor : (settings.theme == "dark" ? .secondary : Color(white: 0.3)))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.5))
            
            Divider()
            
            // 2-3. Content based on selected tab (fills available space)
            if selectedNotesTab == 0 {
                editorView
                    .frame(maxHeight: .infinity)
            } else {
                historyView
                    .frame(maxHeight: .infinity)
            }
            
            // 4. Bottom bar - Configuration buttons
            Divider()
            HStack(spacing: 12) {

                
                Spacer()
                
                Button(action: { showingSettings = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                            .font(.caption)
                        Text(localization.localized("notes.settings"))
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .foregroundColor(settings.theme == "dark" ? .secondary : Color(white: 0.3))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.5))
        }
        .sheet(isPresented: $showingSettings) {
            NotesSettingsView()
        }
    }
    
    private var editorView: some View {
        // Editor panel (toolbar + editor box)
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Rich text toolbar
                RichTextToolbar(textView: editorTextView)
                
                Divider()
                
                // Rich text editor (fills available space)
                RichTextEditorView(attributedText: $newNoteAttributedText, textView: $editorTextView, onTextChange: {
                    // Expand editor when user types
                    if newNoteAttributedText.length > 0 && !isEditorExpanded {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEditorExpanded = true
                        }
                    }
                })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(6)
                    .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor))
            }
            
            // Category and Save button (shown when there's content)
            if hasContent {
                HStack(spacing: 8) {
                    TextField(localization.localized("notes.category.placeholder"), text: $selectedCategory)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.9))
                        .cornerRadius(6)
                        .frame(width: 120)
                    
                    Button(action: addNote) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(localization.localized("notes.save"))
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 8)
                .padding(.trailing, 8)
            }
        }
        .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor))
    }
    
    private var hasContent: Bool {
        newNoteAttributedText.length > 0 || !selectedCategory.isEmpty
    }
    
    private var historyView: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(localization.localized("notes.search.placeholder"), text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
            .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.5))
            
            Divider()
            
            // Notes list
            if viewModel.filteredNotes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: viewModel.searchText.isEmpty ? "note.text" : "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text(viewModel.searchText.isEmpty ? localization.localized("notes.empty.title") : localization.localized("notes.search.empty.title"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(viewModel.searchText.isEmpty ? localization.localized("notes.empty.subtitle") : localization.localized("notes.search.empty.subtitle"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredNotes) { note in
                            RichNoteRow(note: note, viewModel: viewModel)
                            Divider()
                        }
                    }
                }
            }
        }
    }
    
    private func addNote() {
        guard newNoteAttributedText.length > 0 else { return }
        
        let category = selectedCategory.isEmpty ? nil : selectedCategory
        viewModel.addNote(attributedContent: newNoteAttributedText, category: category)
        newNoteAttributedText = NSAttributedString()
        selectedCategory = ""
        
        // Collapse editor after save
        withAnimation(.easeInOut(duration: 0.3)) {
            isEditorExpanded = false
        }
        
        selectedNotesTab = 1 // Switch to History after adding
    }
    
    private func exportNotes() {
        let content = viewModel.exportNotes()
        if let url = StorageService.shared.exportNotesToFile(content) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
    
    private func formattedDate() -> String {
        let now = Date()
        let formatter = DateFormatter()
        
        // Set locale based on current language
        switch localization.currentLanguage {
        case "zh-Hans":
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "M月d日 EEEE"
        case "ja":
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateFormat = "M月d日（E）"
        case "de":
            formatter.locale = Locale(identifier: "de_DE")
            formatter.dateFormat = "d. MMMM, EEEE"
        default: // English
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM d, EEEE"
        }
        
        return formatter.string(from: now)
    }
}

// Wrapper to capture NSTextView reference
struct RichTextEditorView: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var textView: NSTextView?
    var onTextChange: (() -> Void)? = nil
    @ObservedObject var settings = AppSettings.shared
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let tv = scrollView.documentView as! NSTextView
        
        // Configure text view for rich text
        tv.isRichText = true
        tv.allowsUndo = true
        
        // Set default font based on settings
        updateDefaultFont(for: tv)
        
        tv.textStorage?.setAttributedString(attributedText)
        tv.delegate = context.coordinator
        
        // Set background color
        tv.backgroundColor = NSColor(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor))
        tv.drawsBackground = true
        
        // Hide scrollbar
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        DispatchQueue.main.async {
            self.textView = tv
        }
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let tv = nsView.documentView as! NSTextView
        if tv.attributedString() != attributedText {
            tv.textStorage?.setAttributedString(attributedText)
        }
        
        // Update default font when settings change
        updateDefaultFont(for: tv)
        
        // Update background color when settings change
        tv.backgroundColor = NSColor(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor))
    }
    
    private func updateDefaultFont(for textView: NSTextView) {
        let fontSize = CGFloat(settings.baseFontSize)
        let defaultFont: NSFont
        if settings.defaultNoteFont == "System Font" {
            defaultFont = NSFont.systemFont(ofSize: fontSize)
        } else if let customFont = NSFont(name: settings.defaultNoteFont, size: fontSize) {
            defaultFont = customFont
        } else {
            defaultFont = NSFont.systemFont(ofSize: fontSize)
        }
        textView.font = defaultFont
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditorView
        
        init(_ parent: RichTextEditorView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.attributedText = textView.attributedString()
            parent.onTextChange?()
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

struct RichNoteRow: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
    @ObservedObject var settings = AppSettings.shared
    @State private var isHovered = false
    @State private var isEditing = false
    @State private var editedAttributedContent = NSAttributedString()
    @State private var editingTextView: NSTextView?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    VStack(spacing: 4) {
                        RichTextToolbar(textView: editingTextView)
                        RichTextEditorView(attributedText: $editedAttributedContent, textView: $editingTextView)
                            .frame(minHeight: 80)
                    }
                } else {
                    Text(AttributedString(note.attributedContent))
                        .font(.system(size: 16))
                        .foregroundColor(settings.theme == "dark" ? .primary : Color(white: 0.1))
                }
                
                HStack {
                    if let category = note.category {
                        Text(category)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                    
                    Text(note.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(settings.theme == "dark" ? .secondary : Color(white: 0.4))
                }
            }
            
            Spacer()
            
            if isHovered || isEditing {
                HStack(spacing: 8) {
                    if isEditing {
                        Button(action: saveEdit) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { isEditing = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: startEditing) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { viewModel.deleteNote(note) }) {
                            Image(systemName: "trash.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.5))
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button(LocalizationManager.shared.localized("note.edit")) {
                startEditing()
            }
            Button(LocalizationManager.shared.localized("note.delete")) {
                viewModel.deleteNote(note)
            }
        }
    }
    
    private func startEditing() {
        editedAttributedContent = note.attributedContent
        isEditing = true
    }
    
    private func saveEdit() {
        if editedAttributedContent.length > 0 {
            viewModel.updateNote(note, attributedContent: editedAttributedContent, category: note.category)
        }
        isEditing = false
    }
}
