import SwiftUI

struct NotesView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var newNoteText = ""
    @State private var selectedCategory = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Quick note input
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    TextEditor(text: $newNoteText)
                        .font(.body)
                        .frame(minHeight: 60, maxHeight: 80)
                        .focused($isTextFieldFocused)
                    
                    Button(action: addNote) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                
                // Category input (optional)
                TextField("Category (optional)", text: $selectedCategory)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(4)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
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
            .background(Color(NSColor.controlBackgroundColor))
            
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
                    Text(viewModel.searchText.isEmpty ? "Add your first note above" : "Try a different search term")
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
            
            // Export button
            if !viewModel.notes.isEmpty {
                Divider()
                Button(action: exportNotes) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Notes")
                    }
                    .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func addNote() {
        let trimmedText = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let category = selectedCategory.isEmpty ? nil : selectedCategory
        viewModel.addNote(content: trimmedText, category: category)
        newNoteText = ""
        selectedCategory = ""
        isTextFieldFocused = true
    }
    
    private func exportNotes() {
        let content = viewModel.exportNotes()
        if let url = StorageService.shared.exportNotesToFile(content) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
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
