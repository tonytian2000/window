import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
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
            .frame(width: 80)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            
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
        .frame(width: 360, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(NSColor.separatorColor).opacity(0.3), lineWidth: 0.5)
        )
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let tag: Int
    @Binding var selectedTab: Int
    var badgeCount: Int = 0
    
    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                    
                    if badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 8, y: -8)
                    }
                }
                
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selectedTab == tag ? Color.accentColor.opacity(0.15) : Color.clear)
            .foregroundColor(selectedTab == tag ? .accentColor : .secondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
