# Window - macOS Menu Bar Monitoring App

## Project Overview

Window is a lightweight macOS menu bar application designed to display production alerts and serve as a quick note-taking tool for daily work. It provides an elegant, Itsycal-style borderless panel interface that appears when clicking the menu bar icon.

## Architecture

### Platform & Framework
- **Platform**: macOS 12.0+
- **Framework**: SwiftUI
- **Language**: Swift 5.0
- **Build System**: Xcode project
- **Localization**: English (en) and Simplified Chinese (zh-Hans)

### Project Structure

```
window/
├── WindowApp.swift          # Main app entry point with menu bar integration
├── WindowPanel.swift        # Custom NSPanel for keyboard input support
├── Info.plist              # App configuration (includes localization settings)
├── Views/
│   ├── ContentView.swift        # Main view with left sidebar navigation
│   ├── AlertsView.swift         # Production alerts display
│   ├── NotesView.swift          # Quick notes interface
│   ├── SettingsView.swift       # General app settings
│   ├── AlertSettingsView.swift  # Alert-specific settings (modal)
│   └── NotesSettingsView.swift  # Notes-specific settings (modal)
├── Models/
│   ├── Alert.swift         # Alert data model
│   ├── Note.swift          # Note data model
│   └── AppSettings.swift   # Settings singleton with UserDefaults
├── ViewModels/
│   ├── AlertsViewModel.swift    # Alerts business logic
│   └── NotesViewModel.swift     # Notes business logic
├── Services/
│   ├── StorageService.swift     # Data persistence
│   └── AlertService.swift       # API integration for alerts
└── Resources/
    ├── en.lproj/
    │   └── Localizable.strings  # English localization
    └── zh-Hans.lproj/
        └── Localizable.strings  # Simplified Chinese localization
```

## Key Features

### 1. Menu Bar Integration
- Lives in the macOS menu bar with a bell icon
- Click icon to show/hide the panel
- Itsycal-style borderless window with shadow
- 360x500px compact interface
- Dismisses when clicking outside

### 2. Production Alerts
- Fetches alerts from configurable API endpoint
- Supports custom API keys (Bearer token authentication)
- Real-time alert monitoring with auto-refresh
- Alert types: Error (red), Warning (orange), Info (blue)
- Mark as read/unread functionality
- Badge counter for unread alerts on menu bar icon
- Configurable refresh interval (1-30 minutes)
- Alert type filtering options

### 3. Quick Notes
- Fast note-taking interface with auto-focus
- Optional categorization with visual badges
- Full-text search across all notes
- Edit/delete notes with hover actions
- Markdown export to Documents folder
- Persistent storage via UserDefaults
- Configurable retention limits (10-500 notes)

### 4. Settings System
- **General Settings Tab**: Global app configuration in left sidebar
  - API endpoint configuration
  - API key management
  - Refresh interval
  - Notifications toggle
  - API format documentation
  
- **Alert Settings Modal**: Accessible via gear icon in Alerts view
  - API endpoint and key
  - Auto-refresh toggle
  - Refresh interval slider
  - Alert type filters (errors, warnings, info)
  
- **Notes Settings Modal**: Accessible via gear icon in Notes view
  - Default category
  - Timestamp display toggle
  - Category display toggle
  - Auto-focus behavior
  - Maximum notes retention

### 5. User Interface
- **Left Sidebar Navigation** (50px wide)
  - Icon-based tabs with tooltips
  - Badge counter on Alerts icon
  - Active tab highlighting with blue accent
  - Icons: bell (Alerts), note (Notes), gear (Settings)
  
- **Content Area** (400px wide)
  - Scrollable views
  - Consistent styling across tabs
  - Modal sheets for app-specific settings
  - Auto-saving for all settings
  - Fully localized interface
  
### 6. Internationalization (i18n)
- **Supported Languages**:
  - English (en) - Default
  - Simplified Chinese (zh-Hans)
  
- **Localization Scope**:
  - All UI text (buttons, labels, placeholders)
  - Tab names and navigation
  - Alert and note empty states
  - Settings screens
  - Context menus
  - Tooltips and help text
  
- **Language Selection**:
  - Automatically follows system language preference
  - Switches between English and Chinese based on macOS settings
  - No manual language selector needed (system-driven)
  
- **Technical Implementation**:
  - `NSLocalizedString()` for all user-facing text
  - Separate `.strings` files for each language
  - Variant groups in Xcode project
  - `CFBundleLocalizations` in Info.plist

## Technical Implementation

### Custom Window Panel
```swift
class WindowPanel: NSPanel {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
    override var acceptsFirstResponder: Bool { return true }
}
```
This custom panel enables keyboard input in the borderless panel window, solving the issue where TextEditor and TextField wouldn't accept input in a standard NSPanel with borderless style.

### Settings Architecture
Settings are managed through a singleton `AppSettings` class that uses `@Published` properties with automatic UserDefaults persistence:

```swift
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var apiEndpoint: String {
        didSet { UserDefaults.standard.set(apiEndpoint, forKey: "apiEndpoint") }
    }
    
    private init() {
        self.apiEndpoint = UserDefaults.standard.string(forKey: "apiEndpoint") ?? ""
        // ... load other settings
    }
}
```

All settings auto-save to UserDefaults when changed, providing a seamless user experience.

### Data Persistence
- **Alerts & Notes**: JSON encoding to UserDefaults via StorageService
- **Settings**: Direct UserDefaults via AppSettings singleton with didSet observers
- **Notes Export**: Markdown files exported to ~/Documents with timestamp

## API Integration

### Expected Alert JSON Format
```json
[
  {
    "title": "Error title",
    "message": "Error description",
    "type": "error|warning|info",
    "timestamp": "2026-01-22T12:00:00Z",
    "source": "Production"
  }
]
```

Alternative wrapper format also supported:
```json
{
  "alerts": [
    { /* alert object */ }
  ]
}
```

### HTTP Request
- Method: GET
- Headers: `Authorization: Bearer {apiKey}` (if configured)
- Timeout: 10 seconds
- Response: JSON array or JSON object with "alerts" key

## Development

### Build Requirements
- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.0 or later

### Building the Project
```bash
# Open in Xcode
open Window.xcodeproj

# Or use convenience script
./open-in-xcode.sh

# Build from command line
xcodebuild -project Window.xcodeproj -scheme Window -configuration Debug build
```

### Running the App
1. Build the project in Xcode (⌘+R)
2. The bell icon appears in the menu bar
3. Click to open the panel
4. Configure API settings before monitoring alerts
5. Start adding notes immediately

## User Workflows

### Adding Notes
1. Click bell icon in menu bar
2. Switch to Notes tab (or already selected)
3. Type note in text editor (auto-focused)
4. Optionally add category
5. Click + button to save
6. Note appears in list below with timestamp
7. Hover over notes to edit or delete

### Monitoring Alerts
1. Open Settings tab
2. Configure API endpoint (e.g., `https://api.example.com/alerts`)
3. Optionally add API key
4. Switch to Alerts tab
5. Click refresh button or wait for auto-refresh
6. View alerts by severity (color-coded)
7. Click alert to mark as read
8. Badge on menu bar icon shows unread count

### Configuring Alert Monitoring
1. Open Alerts tab
2. Click gear icon (top right)
3. Modal sheet opens with alert settings
4. Configure API endpoint and key
5. Set refresh interval (1-30 minutes)
6. Toggle auto-refresh
7. Filter alert types (errors, warnings, info)
8. Settings auto-save on change
9. Close sheet to return to alerts

### Searching Notes
1. Open Notes tab
2. Type search query in search bar
3. Notes filter in real-time
4. Clear search to show all notes

### Exporting Notes
1. Open Notes tab
2. Click "Export Notes" button at bottom
3. Markdown file created in Documents folder
4. Finder opens to show the file
5. File named `window-notes-{timestamp}.md`

## Design Patterns

1. **MVVM Architecture**: Clear separation between Views, ViewModels, and Models
2. **Singleton Pattern**: Services (StorageService, AlertService) and Settings use shared instances
3. **Observer Pattern**: SwiftUI's @Published and @ObservedObject for reactive updates
4. **Repository Pattern**: StorageService abstracts data persistence details
5. **Dependency Injection**: ViewModels passed to views, services injected where needed

## Key Implementation Details

### Window Management
- Uses `NSPanel` with `.nonactivatingPanel` removed to allow key window status
- Custom `WindowPanel` class provides `canBecomeKey` for keyboard input
- Window positioned below menu bar icon when shown
- Dismisses on outside click via `.resignKey()`

### State Management
- `@StateObject` for view models in parent views
- `@ObservedObject` when passing to child views
- `@State` for local UI state
- `@Published` in models for reactive data
- `@FocusState` for keyboard focus management

### Navigation
- Tab-based navigation with left sidebar
- Modal sheets for app-specific settings
- Context menus for item actions (right-click)
- Hover effects for interactive elements

### Styling
- Consistent use of SF Symbols for icons
- System colors for semantic meaning (red=error, orange=warning, blue=info/accent)
- Rounded corners and shadows for depth
- Subtle backgrounds to differentiate sections

## Files for AI Context

When working with Claude on this project, these files are most relevant:

**Core Application:**
- `WindowApp.swift` - App entry point and menu bar setup
- `WindowPanel.swift` - Custom panel class for keyboard input

**Main Views:**
- `ContentView.swift` - Sidebar navigation and tab switching
- `AlertsView.swift` - Alerts display and management
- `NotesView.swift` - Notes creation and editing
- `SettingsView.swift` - General settings interface

**Settings Views:**
- `AlertSettingsView.swift` - Alert-specific configuration modal
- `NotesSettingsView.swift` - Notes-specific configuration modal

**Models:**
- `AppSettings.swift` - Settings singleton with UserDefaults
- `Alert.swift` - Alert data model and sample data
- `Note.swift` - Note data model and sample data

**ViewModels:**
- `AlertsViewModel.swift` - Alerts business logic
- `NotesViewModel.swift` - Notes business logic

**Services:**
- `AlertService.swift` - API integration for fetching alerts
- `StorageService.swift` - Data persistence layer

**Localization:**
- `Resources/en.lproj/Localizable.strings` - English translations
- `Resources/zh-Hans.lproj/Localizable.strings` - Chinese translations
- `Info.plist` - Includes `CFBundleLocalizations` array

**Documentation:**
- `README.md` - Project overview and quick start
- `SETUP.md` - Detailed setup instructions
- `CLAUDE.md` - This file (AI context document)

## Known Behaviors

1. **Auto-saving**: All settings automatically save to UserDefaults on change
2. **Window Dismissal**: Panel dismisses when clicking outside or pressing Escape
3. **Keyboard Support**: Full keyboard input works in all text fields (via WindowPanel)
4. **Sample Data**: If no saved data exists, sample alerts and notes are displayed
5. **Error Handling**: Network errors gracefully handled, user sees empty state
6. **Refresh Behavior**: Manual refresh always works; auto-refresh uses configured interval

## Future Enhancement Ideas

- Push notifications for critical alerts
- Alert history and archiving
- Note synchronization across devices
- Custom alert sound/badge options
- Keyboard shortcuts for quick actions
- Note tagging system beyond categories
- Alert acknowledgment workflow
- Multiple API endpoint support
- Rich text notes formatting
- Note attachments or links

## Troubleshooting

**Window doesn't show keyboard focus:**
- Ensure using `WindowPanel` class, not standard `NSPanel`
- Check that `canBecomeKey` returns true

**Alerts not loading:**
- Verify API endpoint is correctly configured
- Check API key if authentication required
- Look for errors in console logs
- Ensure API returns correct JSON format

**Settings not persisting:**
- Settings should auto-save via UserDefaults
- Check that AppSettings.shared is being used
- Verify UserDefaults aren't being cleared

**Build errors:**
- Ensure macOS deployment target is 12.0+
- Verify all files are in Xcode project
- Check Swift version compatibility (5.0+)

## Adding New Languages

To add support for additional languages:

1. **Create new .lproj directory**:
   ```bash
   mkdir -p window/Resources/ja.lproj  # Example: Japanese
   ```

2. **Copy and translate Localizable.strings**:
   ```bash
   cp window/Resources/en.lproj/Localizable.strings window/Resources/ja.lproj/
   # Edit the file to translate all values (keep keys the same)
   ```

3. **Update Info.plist**:
   ```xml
   <key>CFBundleLocalizations</key>
   <array>
       <string>en</string>
       <string>zh-Hans</string>
       <string>ja</string>  <!-- Add new language code -->
   </array>
   ```

4. **Update project.pbxproj**:
   - Add file reference for new language variant
   - Add to variant group
   - Add to known regions

5. **Test**: Change macOS system language to verify translations

## Project Status

✅ **Completed Features:**
- Menu bar integration with icon and badge
- Borderless panel with keyboard input support
- Left sidebar navigation (50px with icons)
- Production alerts monitoring
- Quick notes with search and export
- General settings interface
- App-specific settings modals
- Auto-saving configuration
- Full MVVM architecture
- Data persistence
- API integration
- Multi-language support (English & Chinese)
- Automatic language detection from system preferences

This project is production-ready for personal or team use as a production monitoring and note-taking tool.
