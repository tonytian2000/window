import SwiftUI

struct AlertSettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Alert Settings")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // API Endpoint
                    VStack(alignment: .leading, spacing: 4) {
                        Text("API Endpoint")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("https://api.example.com/alerts", text: $settings.apiEndpoint)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // API Key
                    VStack(alignment: .leading, spacing: 4) {
                        Text("API Key (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        SecureField("Enter API key", text: $settings.apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Divider()
                    
                    // Refresh Interval
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Auto-refresh interval")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(settings.refreshInterval) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(settings.refreshInterval) },
                            set: { settings.refreshInterval = Int($0) }
                        ), in: 1...30, step: 1)
                    }
                    
                    // Auto-refresh toggle
                    Toggle("Auto-refresh alerts", isOn: $settings.autoRefresh)
                        .font(.caption)
                    
                    Divider()
                    
                    // Alert filtering
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Show Alert Types")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Toggle("Errors", isOn: $settings.showErrors)
                            .font(.caption)
                        Toggle("Warnings", isOn: $settings.showWarnings)
                            .font(.caption)
                        Toggle("Info", isOn: $settings.showInfo)
                            .font(.caption)
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(width: 300, height: 400)
    }
}
