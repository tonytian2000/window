import Foundation

enum AlertType: String, Codable {
    case error = "error"
    case warning = "warning"
    case info = "info"
}

struct Alert: Identifiable, Codable {
    let id: UUID
    let title: String
    let message: String
    let type: AlertType
    let timestamp: Date
    var isRead: Bool
    let source: String
    
    init(id: UUID = UUID(), title: String, message: String, type: AlertType, timestamp: Date = Date(), isRead: Bool = false, source: String = "Production") {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.timestamp = timestamp
        self.isRead = isRead
        self.source = source
    }
}

extension Alert {
    static var sampleAlerts: [Alert] {
        [
            Alert(title: "Database Connection Error", message: "Failed to connect to primary database. Failover initiated.", type: .error),
            Alert(title: "High Memory Usage", message: "Server memory usage at 85%. Consider scaling.", type: .warning, timestamp: Date().addingTimeInterval(-3600)),
            Alert(title: "Deployment Successful", message: "Version 2.1.4 deployed to production.", type: .info, timestamp: Date().addingTimeInterval(-7200), isRead: true)
        ]
    }
}
