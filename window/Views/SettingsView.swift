import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Language Settings
                GroupBox(label: Label(localization.localized("settings.language"), systemImage: "globe")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker(localization.localized("settings.language.select"), selection: $localization.currentLanguage) {
                            ForEach(LocalizationManager.Language.allCases, id: \.rawValue) { language in
                                Text(language.displayName).tag(language.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text("Language changes take effect immediately")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Window Size Settings
                GroupBox(label: Label(localization.localized("settings.window"), systemImage: "rectangle.resize")) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(localization.localized("settings.window") + " " + "Width")
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
                                Text(localization.localized("settings.window") + " " + "Height")
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
                
                // Info message
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Settings are automatically saved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}
