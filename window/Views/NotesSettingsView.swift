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
                    // Default font size
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Font Size")
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
                }
                .padding()
            }
        }
        .padding()
        .frame(width: 300, height: 350)
    }
}
