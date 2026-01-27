import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    @State private var showingAlertSettings = false
    @State private var showingNotesSettings = false
    @StateObject private var alertsViewModel = AlertsViewModel()
    @StateObject private var notesViewModel = NotesViewModel()
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        HStack(spacing: 0) {
            // Left sidebar with tabs
            VStack(spacing: 0) {
                // Temporarily hiding Alerts tab
                // TabButton(title: localization.localized("tab.alerts"), icon: "bell.fill", tag: 0, selectedTab: $selectedTab, badgeCount: alertsViewModel.unreadCount)
                TabButton(title: localization.localized("tab.notes"), icon: "note.text", tag: 1, selectedTab: $selectedTab)
                TabButton(title: localization.localized("settings.title"), icon: "gearshape.fill", tag: 2, selectedTab: $selectedTab)
                
                Spacer()
                
                // Donation button
                Button(action: {
                    if let url = URL(string: "https://buymeacoffee.com/zero2me") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .help("Support Development")
                
                // App icon at bottom
                Image("win")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .padding(.vertical, 8)
            }
            .frame(width: 50)
            .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.95))
            
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
        .frame(width: CGFloat(settings.windowWidth), height: CGFloat(settings.windowHeight))
        .background(backgroundColorFromString(settings.backgroundColor))
        .preferredColorScheme(settings.theme == "dark" ? .dark : .light)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
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
    
    private func backgroundColorFromString(_ colorName: String) -> Color {
        // Dark theme always uses black background
        if settings.theme == "dark" {
            return .black
        }
        
        // Light theme uses selected background color
        switch colorName {
        case "white": return Color(red: 1.0, green: 1.0, blue: 1.0)
        case "lightGray": return Color(white: 0.98)
        case "beige": return Color(red: 0.96, green: 0.96, blue: 0.86)
        case "lightBlue": return Color(red: 0.93, green: 0.95, blue: 1.0)
        case "lightGreen": return Color(red: 0.93, green: 1.0, blue: 0.93)
        case "lightPink": return Color(red: 1.0, green: 0.94, blue: 0.96)
        case "lightYellow": return Color(red: 1.0, green: 1.0, blue: 0.88)
        case "lavender": return Color(red: 0.95, green: 0.95, blue: 1.0)
        default: return .white
        }
    }
    
    // Helper function to get adaptive background color for all components
    static func adaptiveBackgroundColor(theme: String, backgroundColor: String, opacity: Double = 1.0) -> Color {
        if theme == "dark" {
            return Color.black.opacity(opacity * 0.3)
        }
        
        let baseColor: Color
        switch backgroundColor {
        case "white": baseColor = Color(red: 1.0, green: 1.0, blue: 1.0)
        case "lightGray": baseColor = Color(white: 0.98)
        case "beige": baseColor = Color(red: 0.96, green: 0.96, blue: 0.86)
        case "lightBlue": baseColor = Color(red: 0.93, green: 0.95, blue: 1.0)
        case "lightGreen": baseColor = Color(red: 0.93, green: 1.0, blue: 0.93)
        case "lightPink": baseColor = Color(red: 1.0, green: 0.94, blue: 0.96)
        case "lightYellow": baseColor = Color(red: 1.0, green: 1.0, blue: 0.88)
        case "lavender": baseColor = Color(red: 0.95, green: 0.95, blue: 1.0)
        default: baseColor = .white
        }
        
        return baseColor.opacity(opacity)
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
