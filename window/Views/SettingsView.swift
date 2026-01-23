import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Window Size Settings
                GroupBox(label: Label("Window Size", systemImage: "rectangle.resize")) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Width")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(settings.windowWidth) px")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: Binding(
                                get: { Double(settings.windowWidth) },
                                set: { settings.windowWidth = Int($0) }
                            ), in: 300...600, step: 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Height")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(settings.windowHeight) px")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: Binding(
                                get: { Double(settings.windowHeight) },
                                set: { settings.windowHeight = Int($0) }
                            ), in: 400...800, step: 20)
                        }
                        
                        Text("Restart app for window size changes to take effect")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Font Size Settings
                GroupBox(label: Label("Font Size", systemImage: "textformat.size")) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Base Font Size")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(settings.baseFontSize) pt")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: Binding(
                                get: { Double(settings.baseFontSize) },
                                set: { settings.baseFontSize = Int($0) }
                            ), in: 10...18, step: 1)
                        }
                        
                        Text("Adjusts text size throughout the app")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Info message
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Settings are automatically saved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
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
}
