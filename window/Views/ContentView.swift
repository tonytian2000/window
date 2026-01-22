import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var alertsViewModel = AlertsViewModel()
    @StateObject private var notesViewModel = NotesViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Window")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if alertsViewModel.unreadCount > 0 {
                    Text("\(alertsViewModel.unreadCount)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Tab selection
            Picker("", selection: $selectedTab) {
                Text("Alerts").tag(0)
                Text("Notes").tag(1)
                Text("Settings").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // Content based on selected tab
            Group {
                switch selectedTab {
                case 0:
                    AlertsView(viewModel: alertsViewModel)
                case 1:
                    NotesView(viewModel: notesViewModel)
                case 2:
                    SettingsView()
                default:
                    AlertsView(viewModel: alertsViewModel)
                }
            }
        }
        .frame(width: 360, height: 500)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
