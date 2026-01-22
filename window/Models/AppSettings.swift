import Foundation

struct AppSettings: Codable {
    var apiEndpoint: String
    var apiKey: String
    var refreshInterval: Int // in seconds
    var enableNotifications: Bool
    
    init(apiEndpoint: String = "", apiKey: String = "", refreshInterval: Int = 300, enableNotifications: Bool = true) {
        self.apiEndpoint = apiEndpoint
        self.apiKey = apiKey
        self.refreshInterval = refreshInterval
        self.enableNotifications = enableNotifications
    }
}
