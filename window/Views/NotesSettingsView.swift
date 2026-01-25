import SwiftUI

struct NotesSettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var localization = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(localization.localized("notes.settings.title"))
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
                    // Default font size
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.localized("notes.settings.default.font.size"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("\(settings.baseFontSize) pt")
                                .font(.caption)
                            Spacer()
                        }
                        
                        Slider(value: Binding(
                            get: { Double(settings.baseFontSize) },
                            set: { settings.baseFontSize = Int($0) }
                        ), in: 10...24, step: 1)
                    }
                    
                    Divider()
                    
                    // Default font family
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.localized("notes.settings.default.font"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $settings.defaultNoteFont) {
                            ForEach(availableFonts, id: \.self) { fontName in
                                Text(fontName)
                                    .font(.custom(fontName == "System Font" ? "" : fontName, size: 13))
                                    .tag(fontName)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Text(localization.localized("notes.settings.default.font.info"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Display options
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.localized("notes.settings.display.options"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Toggle(localization.localized("notes.settings.show.timestamps"), isOn: Binding(
                            get: { settings.showNoteTimestamps },
                            set: { settings.showNoteTimestamps = $0 }
                        ))
                            .font(.caption)
                        
                        Toggle(localization.localized("notes.settings.show.categories"), isOn: Binding(
                            get: { settings.showNoteCategories },
                            set: { settings.showNoteCategories = $0 }
                        ))
                            .font(.caption)
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(width: 300, height: 400)
    }
    
    private var availableFonts: [String] {
        [
            "System Font",
            "Arial",
            "Helvetica",
            "Times New Roman",
            "Courier New",
            "Georgia",
            "Verdana",
            "Monaco",
            "Menlo",
            "SF Mono"
        ]
    }
}
