import SwiftUI

struct SettingsView: View {
    @State private var settings: AppSettings
    @State private var showingSaveConfirmation = false
    
    private let storageService = StorageService.shared
    
    init() {
        _settings = State(initialValue: StorageService.shared.loadSettings())
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Production Monitoring Settings
                GroupBox(label: Label("Production Monitoring", systemImage: "server.rack")) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("API Endpoint")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("https://api.example.com/alerts", text: $settings.apiEndpoint)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("URL endpoint that returns alerts in JSON format")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("API Key (Optional)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            SecureField("Enter API key", text: $settings.apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("Will be sent as Bearer token in Authorization header")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Refresh Interval")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Slider(value: Binding(
                                    get: { Double(settings.refreshInterval) },
                                    set: { settings.refreshInterval = Int($0) }
                                ), in: 60...600, step: 60)
                                Text("\(settings.refreshInterval / 60) min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 50)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Notifications Settings
                GroupBox(label: Label("Notifications", systemImage: "bell.badge")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Enable Notifications", isOn: $settings.enableNotifications)
                            .toggleStyle(SwitchToggleStyle())
                        
                        Text("Show system notifications for new alerts")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // API Format Info
                GroupBox(label: Label("API Format", systemImage: "doc.text")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expected JSON format:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("""
                        [
                          {
                            "title": "Error title",
                            "message": "Error description",
                            "type": "error|warning|info",
                            "timestamp": "2026-01-22T12:00:00Z",
                            "source": "Production"
                          }
                        ]
                        """)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(4)
                    }
                    .padding(.vertical, 4)
                }
                
                // Save button
                Button(action: saveSettings) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Settings")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                
                if showingSaveConfirmation {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Settings saved successfully")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // Version info
                VStack(spacing: 4) {
                    Text("Window v1.0.0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Menu bar app for production monitoring and notes")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .padding()
        }
    }
    
    private func saveSettings() {
        storageService.saveSettings(settings)
        showingSaveConfirmation = true
        
        // Hide confirmation after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingSaveConfirmation = false
        }
    }
}
