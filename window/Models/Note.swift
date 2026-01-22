import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    var content: String
    let timestamp: Date
    var category: String?
    
    init(id: UUID = UUID(), content: String, timestamp: Date = Date(), category: String? = nil) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.category = category
    }
}

extension Note {
    static var sampleNotes: [Note] {
        [
            Note(content: "Review pull request #234 - authentication changes", category: "Work"),
            Note(content: "Meeting at 3 PM with design team", timestamp: Date().addingTimeInterval(-1800), category: "Meeting"),
            Note(content: "Fix bug in payment processing", timestamp: Date().addingTimeInterval(-3600))
        ]
    }
}
