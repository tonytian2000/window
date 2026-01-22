import Foundation
import Combine

class AlertsViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var unreadCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private let storageService = StorageService.shared
    private let alertService = AlertService.shared
    
    init() {
        loadAlerts()
        setupAutoRefresh()
        
        // Observe alerts to update unread count
        $alerts
            .map { alerts in alerts.filter { !$0.isRead }.count }
            .assign(to: &$unreadCount)
    }
    
    func loadAlerts() {
        alerts = storageService.loadAlerts()
    }
    
    func markAsRead(_ alert: Alert) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = true
            storageService.saveAlerts(alerts)
        }
    }
    
    func markAllAsRead() {
        alerts = alerts.map { alert in
            var updatedAlert = alert
            updatedAlert.isRead = true
            return updatedAlert
        }
        storageService.saveAlerts(alerts)
    }
    
    func deleteAlert(_ alert: Alert) {
        alerts.removeAll { $0.id == alert.id }
        storageService.saveAlerts(alerts)
    }
    
    func refreshAlerts() {
        alertService.fetchAlerts { [weak self] newAlerts in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Add new alerts to the beginning
                let uniqueNewAlerts = newAlerts.filter { newAlert in
                    !self.alerts.contains { $0.id == newAlert.id }
                }
                
                self.alerts.insert(contentsOf: uniqueNewAlerts, at: 0)
                self.storageService.saveAlerts(self.alerts)
            }
        }
    }
    
    private func setupAutoRefresh() {
        // Refresh alerts every 5 minutes
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshAlerts()
            }
            .store(in: &cancellables)
    }
}
