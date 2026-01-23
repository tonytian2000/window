import SwiftUI

struct AlertsView: View {
    @ObservedObject var viewModel: AlertsViewModel
    @ObservedObject var localization = LocalizationManager.shared
    @State private var showingSettings = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button(action: {
                    viewModel.refreshAlerts()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
                .help(localization.localized("alerts.refresh"))
                
                Spacer()
                
                if !viewModel.alerts.isEmpty {
                    Button(action: {
                        viewModel.markAllAsRead()
                    }) {
                        Text(localization.localized("alerts.mark.all.read"))
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Alerts list
            if viewModel.alerts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text(localization.localized("alerts.empty.title"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(localization.localized("alerts.empty.subtitle"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.alerts) { alert in
                            AlertRow(alert: alert, viewModel: viewModel)
                            Divider()
                        }
                    }
                }
            }
        }
        
        // Config button at bottom right
        Button(action: { showingSettings = true }) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.secondary)
                .padding(8)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .padding(8)
        }
        .sheet(isPresented: $showingSettings) {
            AlertSettingsView()
        }
    }
}

struct AlertRow: View {
    let alert: Alert
    @ObservedObject var viewModel: AlertsViewModel
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Type indicator
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.title)
                        .font(.system(size: 13, weight: alert.isRead ? .regular : .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(alert.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(alert.source)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(0.7)
            }
            
            if isHovered {
                Button(action: {
                    viewModel.deleteAlert(alert)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(alert.isRead ? Color.clear : Color.blue.opacity(0.05))
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            if !alert.isRead {
                viewModel.markAsRead(alert)
            }
        }
        .contextMenu {
            Button(alert.isRead ? LocalizationManager.shared.localized("alert.mark.unread") : LocalizationManager.shared.localized("alert.mark.read")) {
                viewModel.markAsRead(alert)
            }
            Button(LocalizationManager.shared.localized("alert.delete")) {
                viewModel.deleteAlert(alert)
            }
        }
    }
    
    private var iconName: String {
        switch alert.type {
        case .error: return "exclamationmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch alert.type {
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}
