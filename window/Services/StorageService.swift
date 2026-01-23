import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let alertsKey = "window.alerts"
    private let notesKey = "window.notes"
    
    private let fileManager = FileManager.default
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private init() {}
    
    // MARK: - Alerts Storage
    
    func saveAlerts(_ alerts: [Alert]) {
        do {
            let data = try JSONEncoder().encode(alerts)
            UserDefaults.standard.set(data, forKey: alertsKey)
        } catch {
            print("Failed to save alerts: \(error)")
        }
    }
    
    func loadAlerts() -> [Alert] {
        guard let data = UserDefaults.standard.data(forKey: alertsKey) else {
            return Alert.sampleAlerts // Return sample data if no saved data
        }
        
        do {
            let alerts = try JSONDecoder().decode([Alert].self, from: data)
            return alerts
        } catch {
            print("Failed to load alerts: \(error)")
            return Alert.sampleAlerts
        }
    }
    
    // MARK: - Notes Storage
    
    func saveNotes(_ notes: [Note]) {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: notesKey)
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    func loadNotes() -> [Note] {
        guard let data = UserDefaults.standard.data(forKey: notesKey) else {
            return Note.sampleNotes // Return sample data if no saved data
        }
        
        do {
            let notes = try JSONDecoder().decode([Note].self, from: data)
            return notes
        } catch {
            print("Failed to load notes: \(error)")
            return Note.sampleNotes
        }
    }
    
    // MARK: - Settings
    // Settings are now handled directly by AppSettings.shared using UserDefaults
    
    // MARK: - Export Notes
    
    func exportNotesToFile(_ content: String) -> URL? {
        let filename = "window-notes-\(Date().timeIntervalSince1970).md"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to export notes: \(error)")
            return nil
        }
    }
}
