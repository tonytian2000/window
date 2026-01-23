import SwiftUI

struct NotesSettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Notes Settings")
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
                    // Default category
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Default Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Work", text: Binding(
                            get: { settings.defaultNoteCategory },
                            set: { settings.defaultNoteCategory = $0 }
                        ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Divider()
                    
                    // Display options
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Options")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Toggle("Show timestamps", isOn: Binding(
                            get: { settings.showNoteTimestamps },
                            set: { settings.showNoteTimestamps = $0 }
                        ))
                            .font(.caption)
                        
                        Toggle("Show categories", isOn: Binding(
                            get: { settings.showNoteCategories },
                            set: { settings.showNoteCategories = $0 }
                        ))
                            .font(.caption)
                    }
                    
                    Divider()
                    
                    // Note management
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note Management")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Toggle("Auto-focus text editor on open", isOn: Binding(
                            get: { settings.autoFocusNoteEditor },
                            set: { settings.autoFocusNoteEditor = $0 }
                        ))
                            .font(.caption)
                        
                        HStack {
                            Text("Keep last \(settings.maxNotes) notes")
                                .font(.caption)
                            Spacer()
                        }
                        
                        Slider(value: Binding(
                            get: { Double(settings.maxNotes) },
                            set: { settings.maxNotes = Int($0) }
                        ), in: 10...500, step: 10)
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(width: 300, height: 350)
    }
}
