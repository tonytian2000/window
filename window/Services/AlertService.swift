import Foundation

class AlertService {
    static let shared = AlertService()
    
    private let storageService = StorageService.shared
    
    private init() {}
    
    func fetchAlerts(completion: @escaping ([Alert]) -> Void) {
        let settings = storageService.loadSettings()
        
        // Check if endpoint is configured
        guard !settings.apiEndpoint.isEmpty else {
            // No endpoint configured, return empty array
            completion([])
            return
        }
        
        guard let url = URL(string: settings.apiEndpoint) else {
            print("Invalid API endpoint URL")
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        // Add API key if configured
        if !settings.apiKey.isEmpty {
            request.setValue("Bearer \(settings.apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch alerts: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion([])
                return
            }
            
            do {
                // Try to decode the response as an array of alerts
                let alerts = try JSONDecoder().decode([Alert].self, from: data)
                completion(alerts)
            } catch {
                print("Failed to decode alerts: \(error)")
                
                // Try to decode as a wrapper object with "alerts" key
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let alertsData = json["alerts"] as? [[String: Any]] {
                    let alerts = self.parseAlertsFromJSON(alertsData)
                    completion(alerts)
                } else {
                    completion([])
                }
            }
        }.resume()
    }
    
    private func parseAlertsFromJSON(_ jsonArray: [[String: Any]]) -> [Alert] {
        var alerts: [Alert] = []
        
        for json in jsonArray {
            guard let title = json["title"] as? String,
                  let message = json["message"] as? String else {
                continue
            }
            
            let typeString = json["type"] as? String ?? "info"
            let type = AlertType(rawValue: typeString) ?? .info
            
            let source = json["source"] as? String ?? "Production"
            
            let timestamp: Date
            if let timestampString = json["timestamp"] as? String,
               let date = ISO8601DateFormatter().date(from: timestampString) {
                timestamp = date
            } else {
                timestamp = Date()
            }
            
            let alert = Alert(title: title, message: message, type: type, timestamp: timestamp, source: source)
            alerts.append(alert)
        }
        
        return alerts
    }
}
