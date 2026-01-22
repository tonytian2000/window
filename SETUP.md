# Window - Setup Guide

This guide will help you set up and run the Window macOS menu bar application.

## Prerequisites

- **macOS**: 12.0 (Monterey) or later
- **Xcode**: 14.0 or later
- **Apple Developer Account**: Required for code signing (can use free account for local development)

## Project Structure

```
window/
├── CLAUDE.md              # AI assistant documentation
├── README.md             # Project overview
├── SETUP.md             # This file - setup instructions
├── .gitignore           # Git ignore rules
└── window/              # Application source code
    ├── WindowApp.swift          # Main app entry point
    ├── Info.plist              # App configuration
    ├── Models/                 # Data models
    │   ├── Alert.swift
    │   ├── Note.swift
    │   └── AppSettings.swift
    ├── Views/                  # UI components
    │   ├── ContentView.swift
    │   ├── AlertsView.swift
    │   ├── NotesView.swift
    │   └── SettingsView.swift
    ├── ViewModels/            # View models
    │   ├── AlertsViewModel.swift
    │   └── NotesViewModel.swift
    └── Services/              # Business logic
        ├── StorageService.swift
        └── AlertService.swift
```

## Setting Up the Xcode Project

### Option 1: Using Xcode GUI (Recommended)

1. **Open Xcode** (version 14.0 or later)

2. **Create a new project**:
   - File → New → Project
   - Select "macOS" → "App"
   - Click "Next"

3. **Configure the project**:
   - Product Name: `Window`
   - Team: Select your development team
   - Organization Identifier: `com.yourname` (or your preferred identifier)
   - Interface: SwiftUI
   - Language: Swift
   - Uncheck "Use Core Data"
   - Uncheck "Include Tests" (optional, can add later)
   - Click "Next"

4. **Save the project**:
   - Choose the parent directory of your `window` folder
   - Click "Create"

5. **Replace the default files**:
   - Delete the default `WindowApp.swift` and `ContentView.swift` files that Xcode created
   - Add all the files from the `window/` directory to your Xcode project:
     - Drag the entire `window` folder structure into Xcode's Project Navigator
     - Make sure "Copy items if needed" is UNCHECKED
     - Make sure "Create groups" is selected
     - Make sure your target is checked

6. **Configure Info.plist**:
   - Select the project in Project Navigator
   - Select the "Window" target
   - Go to the "Info" tab
   - Add a new entry:
     - Key: "Application is agent (UIElement)" or `LSUIElement`
     - Type: Boolean
     - Value: YES
   - This makes the app run as a menu bar app without a dock icon

7. **Set deployment target**:
   - In project settings, set "macOS Deployment Target" to 12.0 or later

### Option 2: Using Command Line

If you prefer to create the Xcode project via command line:

```bash
# Navigate to your project directory
cd /Users/qtian/open/window

# Create Xcode project (requires xcodeproj or manual creation)
# You'll still need to open Xcode to configure signing and capabilities
```

Note: Creating a proper Xcode project file is best done through Xcode GUI as it handles all the necessary configurations automatically.

## Building and Running

### First Run

1. **Open the project** in Xcode (Window.xcodeproj)

2. **Select your signing team**:
   - Select the project in Project Navigator
   - Select the "Window" target
   - Go to "Signing & Capabilities"
   - Select your team from the dropdown

3. **Build the project**:
   - Press `⌘+B` or Product → Build
   - Fix any build errors if they occur

4. **Run the application**:
   - Press `⌘+R` or Product → Run
   - The app will launch and appear in your menu bar (top-right corner)
   - Look for the bell icon

5. **First-time setup**:
   - Click the menu bar icon
   - Navigate to the Settings tab
   - Configure your production API endpoint (optional)
   - The app will work with sample data even without an API

### Development Workflow

```bash
# Open project in Xcode
open Window.xcodeproj

# Or use xed (Xcode editor) from command line
xed .
```

## Configuration

### API Endpoint Setup

To connect to your production monitoring system:

1. Click the Window icon in the menu bar
2. Navigate to "Settings"
3. Enter your API endpoint URL
4. (Optional) Enter your API key for authentication
5. Set the refresh interval (default: 5 minutes)
6. Click "Save Settings"

### Expected API Response Format

Your API should return JSON in this format:

```json
[
  {
    "title": "Database Connection Error",
    "message": "Failed to connect to primary database",
    "type": "error",
    "timestamp": "2026-01-22T12:00:00Z",
    "source": "Production"
  }
]
```

- **type**: Must be one of: `"error"`, `"warning"`, or `"info"`
- **timestamp**: ISO 8601 format (optional, defaults to current time)
- **source**: String identifier (optional, defaults to "Production")

## Features

### Production Alerts
- Displays real-time alerts from your production environment
- Color-coded by severity (red=error, orange=warning, blue=info)
- Unread badge counter
- Mark as read/unread functionality
- Auto-refresh every 5 minutes (configurable)
- Manual refresh button

### Notes
- Quick note-taking with keyboard shortcut (Enter to submit)
- Optional categorization
- Search functionality
- Edit and delete notes
- Export notes to Markdown file
- Timestamps for all notes

### Settings
- Configure production API endpoint
- Set API authentication key
- Adjust refresh interval
- Enable/disable notifications
- View API format documentation

## Troubleshooting

### App doesn't appear in menu bar
- Check that `LSUIElement` is set to `YES` in Info.plist
- Restart the app
- Check Console.app for error messages

### Alerts not loading
- Verify your API endpoint is correct and accessible
- Check that the API returns valid JSON in the expected format
- Review Console.app logs for network errors
- Try the manual refresh button

### Build errors
- Clean build folder: Product → Clean Build Folder (`⌘+Shift+K`)
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Restart Xcode
- Verify all files are properly added to the target

### Code signing issues
- Ensure you're signed in to Xcode with your Apple ID
- Select your development team in project settings
- For distribution, you'll need a proper developer certificate

## Distribution

### For Personal Use
- Build the app in Xcode
- Archive: Product → Archive
- Export as a Mac app
- The app will be in your Archives
- Copy to Applications folder

### For Team Distribution
- Use Developer ID signing
- Notarize the app with Apple
- Distribute the .app or create a .dmg installer

### For App Store
- Configure App Sandbox capabilities
- Submit through App Store Connect
- Follow Apple's review guidelines

## Development Tips

### Hot Reload
- SwiftUI supports live previews in Xcode
- Use `#Preview` macros for quick UI iteration
- Changes to Swift files require rebuild

### Debugging
- Use `print()` statements for simple debugging
- Use Xcode debugger with breakpoints for complex issues
- Check Console.app for system-level logs
- Use Instruments for performance profiling

### Testing
- Manual testing is currently the primary method
- Consider adding unit tests for view models and services
- Test on different macOS versions if possible

## Next Steps

1. **Customize the icon**: Replace the bell icon with a custom icon
2. **Add keyboard shortcuts**: Implement global hotkeys for quick access
3. **Improve notifications**: Add native macOS notifications for new alerts
4. **Cloud sync**: Consider adding iCloud sync for notes
5. **Themes**: Add dark/light mode customization
6. **Multiple environments**: Support dev, staging, and production

## Support

For issues, questions, or contributions:
- Check CLAUDE.md for AI assistant context
- Review the code comments and documentation
- Check existing issues on GitHub (if applicable)

## License

[To be determined based on project requirements]
