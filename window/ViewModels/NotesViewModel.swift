import Foundation

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText: String = ""
    
    private let storageService = StorageService.shared
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }
    
    init() {
        loadNotes()
    }
    
    func loadNotes() {
        notes = storageService.loadNotes()
    }
    
    func addNote(content: String, category: String? = nil) {
        let note = Note(content: content, category: category)
        notes.insert(note, at: 0)
        storageService.saveNotes(notes)
    }
    
    func updateNote(_ note: Note, content: String, category: String? = nil) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = Note(id: note.id, content: content, timestamp: note.timestamp, category: category)
            storageService.saveNotes(notes)
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        storageService.saveNotes(notes)
    }
    
    func exportNotes() -> String {
        var exportText = "# Window Notes Export\n\n"
        exportText += "Generated: \(Date())\n\n"
        
        for note in notes.sorted(by: { $0.timestamp > $1.timestamp }) {
            exportText += "## \(note.timestamp.formatted())\n"
            if let category = note.category {
                exportText += "**Category:** \(category)\n\n"
            }
            exportText += "\(note.content)\n\n"
            exportText += "---\n\n"
        }
        
        return exportText
    }
}
