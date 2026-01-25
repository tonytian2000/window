import Foundation
import AppKit

struct Note: Identifiable, Codable {
    let id: UUID
    var contentData: Data // RTF data for rich text
    let timestamp: Date
    var category: String?
    
    init(id: UUID = UUID(), contentData: Data, timestamp: Date = Date(), category: String? = nil) {
        self.id = id
        self.contentData = contentData
        self.timestamp = timestamp
        self.category = category
    }
    
    // Convenience initializer for plain text (backwards compatibility)
    init(id: UUID = UUID(), content: String, timestamp: Date = Date(), category: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.category = category
        
        // Convert plain text to RTF data
        let attributedString = NSAttributedString(string: content)
        if let data = try? attributedString.data(from: NSRange(location: 0, length: attributedString.length),
                                                  documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
            self.contentData = data
        } else {
            self.contentData = Data()
        }
    }
    
    // Get plain text content for display/search
    var plainTextContent: String {
        guard let attributedString = try? NSAttributedString(data: contentData,
                                                             options: [.documentType: NSAttributedString.DocumentType.rtf],
                                                             documentAttributes: nil) else {
            return ""
        }
        return attributedString.string
    }
    
    // Get attributed string for rich text editing
    var attributedContent: NSAttributedString {
        guard let attributedString = try? NSAttributedString(data: contentData,
                                                             options: [.documentType: NSAttributedString.DocumentType.rtf],
                                                             documentAttributes: nil) else {
            return NSAttributedString(string: "")
        }
        return attributedString
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
