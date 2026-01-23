import SwiftUI

struct NotesView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var newNoteText = ""
    @State private var selectedCategory = ""
    @State private var showingSettings = false
    @State private var selectedNotesTab = 0 // 0: Editor, 1: History
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Icon selector - minimalist clickable icons
                HStack(spacing: 16) {
                    Button(action: { selectedNotesTab = 0 }) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 14))
                            Text("Editor")
                                .font(.caption)
                        }
                        .foregroundColor(selectedNotesTab == 0 ? .accentColor : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { selectedNotesTab = 1 }) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 14))
                            Text("History")
                                .font(.caption)
                        }
                        .foregroundColor(selectedNotesTab == 1 ? .accentColor : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.5))
                
                Divider()
                
                // Content based on selected icon
                if selectedNotesTab == 0 {
                    editorView
                } else {
                    historyView
                }
            }
            
            // Config buttons at bottom right
            HStack(spacing: 8) {
                if !viewModel.notes.isEmpty {
                    Button(action: exportNotes) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                }
                
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)
            }
            .padding(8)
        }
        .sheet(isPresented: $showingSettings) {
            NotesSettingsView()
        }
        .onAppear {
            if selectedNotesTab == 0 {
                isTextFieldFocused = true
            }
        }
    }
    
    private var editorView: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Category input - no label
                TextField("Category (optional)", text: $selectedCategory)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.3))
                
                Divider()
                
                // Note content editor with hidden scrollbar
                NoScrollBarTextEditor(text: $newNoteText, placeholder: "Write your note here...")
                    .focused($isTextFieldFocused)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(3)
                    .background(Color.white)
            }
            
            // Save button above config icons (shown when there's content)
            if hasContent {
                Button(action: addNote) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 50)
                .padding(.trailing, 8)
            }
        }
        .background(Color.white)
    }
    
    private var hasContent: Bool {
        !newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedCategory.isEmpty
    }
    
    private var historyView: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search notes...", text: $viewModel.searchText)
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
            .background(Color.white.opacity(0.5))
            
            Divider()
            
            // Notes list
            if viewModel.filteredNotes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: viewModel.searchText.isEmpty ? "note.text" : "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text(viewModel.searchText.isEmpty ? "No notes yet" : "No matching notes")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(viewModel.searchText.isEmpty ? "Add your first note in Editor" : "Try a different search term")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredNotes) { note in
                            NoteRow(note: note, viewModel: viewModel)
                            Divider()
                        }
                    }
                }
            }
        }
    }
    
    private func addNote() {
        let trimmedText = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let category = selectedCategory.isEmpty ? nil : selectedCategory
        viewModel.addNote(content: trimmedText, category: category)
        newNoteText = ""
        selectedCategory = ""
        selectedNotesTab = 1 // Switch to History after adding
    }
    
    private func exportNotes() {
        let content = viewModel.exportNotes()
        if let url = StorageService.shared.exportNotesToFile(content) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
}

struct NotesTabButton: View {
    let title: String
    let tag: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            Text(title)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(selectedTab == tag ? Color.accentColor.opacity(0.15) : Color.clear)
                .foregroundColor(selectedTab == tag ? .accentColor : .secondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NoScrollBarTextEditor: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textView.isRichText = false
        textView.delegate = context.coordinator
        textView.string = text
        
        // Hide scrollbar
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NoScrollBarTextEditor
        
        init(_ parent: NoScrollBarTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}

struct NoteRow: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
    @State private var isHovered = false
    @State private var isEditing = false
    @State private var editedContent = ""
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextEditor(text: $editedContent)
                        .font(.system(size: 13))
                        .frame(minHeight: 60)
                } else {
                    Text(note.content)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
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
                        .foregroundColor(.secondary)
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
        .background(Color(NSColor.textBackgroundColor).opacity(0.5))
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button("Edit") {
                startEditing()
            }
            Button("Delete") {
                viewModel.deleteNote(note)
            }
        }
    }
    
    private func startEditing() {
        editedContent = note.content
        isEditing = true
    }
    
    private func saveEdit() {
        let trimmedContent = editedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedContent.isEmpty {
            viewModel.updateNote(note, content: trimmedContent, category: note.category)
        }
        isEditing = false
    }
}
