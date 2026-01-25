import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    @State private var showingAlertSettings = false
    @State private var showingNotesSettings = false
    @StateObject private var alertsViewModel = AlertsViewModel()
    @StateObject private var notesViewModel = NotesViewModel()
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        HStack(spacing: 0) {
            // Left sidebar with tabs
            VStack(spacing: 0) {
                // Temporarily hiding Alerts tab
                // TabButton(title: localization.localized("tab.alerts"), icon: "bell.fill", tag: 0, selectedTab: $selectedTab, badgeCount: alertsViewModel.unreadCount)
                TabButton(title: localization.localized("tab.notes"), icon: "note.text", tag: 1, selectedTab: $selectedTab)
                TabButton(title: localization.localized("settings.title"), icon: "gearshape.fill", tag: 2, selectedTab: $selectedTab)
                
                Spacer()
                
                Divider()
                    .padding(.horizontal, 8)
                
                // App icon at bottom
                if let nsImage = NSImage(named: "win") {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .padding(.vertical, 12)
                } else {
                    Image(systemName: "square.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                        .padding(.vertical, 12)
                }
            }
            .frame(width: 50)
            .background(Color.white.opacity(0.95))
            
            Divider()
            
            // Main content area
            ZStack {
                NotesViewWithRichText(viewModel: notesViewModel)
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 1)
                
                if selectedTab == 2 {
                    SettingsView()
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
                    .frame(maxWidth: .infinity)
                
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
            .foregroundColor(selectedTab == tag ? .accentColor : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(selectedTab == tag ? Color.accentColor.opacity(0.15) : Color.clear)
        .help(title)
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
