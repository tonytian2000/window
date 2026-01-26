import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Theme Settings
                GroupBox(label: Label(localization.localized("settings.theme"), systemImage: "paintbrush.fill")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker(localization.localized("settings.theme.picker"), selection: $settings.theme) {
                            Text(localization.localized("settings.theme.light")).tag("light")
                            Text(localization.localized("settings.theme.dark")).tag("dark")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text(localization.localized("settings.theme.info"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Language Settings
                GroupBox(label: Label(localization.localized("settings.language"), systemImage: "globe")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker(localization.localized("settings.language.select"), selection: $localization.currentLanguage) {
                            ForEach(LocalizationManager.Language.allCases, id: \.rawValue) { language in
                                Text(language.displayName).tag(language.rawValue)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Text(localization.localized("settings.language.info"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Background Color Settings (only in light theme)
                if settings.theme == "light" {
                    GroupBox(label: Label(localization.localized("settings.background"), systemImage: "square.fill")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(localization.localized("settings.background.colors"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 8) {
                                ForEach(popularColors, id: \.name) { colorOption in
                                    Button(action: {
                                        settings.backgroundColor = colorOption.name
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(colorOption.color)
                                                .frame(width: 44, height: 44)
                                            
                                            if settings.backgroundColor == colorOption.name {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 20))
                                                    .shadow(radius: 2)
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .help(colorOption.name.capitalized)
                                }
                            }
                            
                            Text(localization.localized("settings.background.info"))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Window Size Settings
                GroupBox(label: Label(localization.localized("settings.window"), systemImage: "macwindow")) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(localization.localized("settings.window") + " " + localization.localized("settings.window.width"))
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
                            ), in: 400...600, step: 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(localization.localized("settings.window") + " " + localization.localized("settings.window.height"))
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
                        
                        Text(localization.localized("settings.window.info"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Info message
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text(localization.localized("settings.auto.save.info"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
    
    private var popularColors: [(name: String, color: Color)] {
        [
            ("white", .white),
            ("lightGray", Color(white: 0.95)),
            ("beige", Color(red: 0.96, green: 0.96, blue: 0.86)),
            ("lightBlue", Color(red: 0.93, green: 0.95, blue: 1.0)),
            ("lightGreen", Color(red: 0.93, green: 1.0, blue: 0.93)),
            ("lightPink", Color(red: 1.0, green: 0.94, blue: 0.96)),
            ("lightYellow", Color(red: 1.0, green: 1.0, blue: 0.88)),
            ("lavender", Color(red: 0.95, green: 0.95, blue: 1.0))
        ]
    }
}
