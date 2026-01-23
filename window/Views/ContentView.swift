import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingAlertSettings = false
    @State private var showingNotesSettings = false
    @StateObject private var alertsViewModel = AlertsViewModel()
    @StateObject private var notesViewModel = NotesViewModel()
    
    var body: some View {
        HStack(spacing: 0) {
            // Left sidebar with tabs
            VStack(spacing: 0) {
                TabButton(title: "Alerts", icon: "bell.fill", tag: 0, selectedTab: $selectedTab, badgeCount: alertsViewModel.unreadCount)
                TabButton(title: "Notes", icon: "note.text", tag: 1, selectedTab: $selectedTab)
                TabButton(title: "Settings", icon: "gearshape.fill", tag: 2, selectedTab: $selectedTab)
                Spacer()
            }
            .frame(width: 50)
            .background(Color.white.opacity(0.95))
            
            Divider()
            
            // Main content area
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
        .frame(width: 450, height: 500)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        )
        .sheet(isPresented: $showingAlertSettings) {
            AlertSettingsView()
        }
        .sheet(isPresented: $showingNotesSettings) {
            NotesSettingsView()
        }
    }
    
    private func exportNotes() {
        let content = notesViewModel.exportNotes()
        if let url = StorageService.shared.exportNotesToFile(content) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let tag: Int
    @Binding var selectedTab: Int
    var badgeCount: Int = 0
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .help(title)
                
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 1)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(selectedTab == tag ? Color.accentColor.opacity(0.15) : Color.clear)
            .foregroundColor(selectedTab == tag ? .accentColor : .secondary)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
