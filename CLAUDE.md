# CLAUDE.md - Window Menu Bar Application

## Project Overview

**Window** is a macOS menu bar application designed to provide quick access to production environment alerts and personal note-taking capabilities. The application sits in the macOS menu bar and displays a compact window when clicked, serving as both a monitoring dashboard and a productivity tool.

## Purpose

This application addresses two primary use cases:

1. **Production Monitoring**: Display real-time alerts and messages from production environments, allowing developers and operations teams to stay informed without constantly checking dashboards or terminals.

2. **Daily Work Notes**: Provide a quick, accessible location for recording short notes, tasks, and reminders throughout the workday.

## Key Features

### Core Functionality
- **Menu Bar Integration**: Native macOS menu bar icon that remains accessible at all times
- **Popup Window**: Compact, non-intrusive window that appears below the menu bar icon when clicked
- **Alert Display**: Shows notifications and alerts from production environments
- **Note Recording**: Quick note-taking interface for daily work items
- **Persistent Storage**: Saves notes and alert history locally

### Technical Characteristics
- **Platform**: macOS native application
- **UI Pattern**: Menu bar app with dropdown window (similar to system notifications)
- **Always Available**: Runs in background, minimal resource usage
- **Quick Access**: Single-click access to information and note-taking

## Technology Stack

### Expected Technologies
- **Language**: Swift (recommended for macOS development)
- **UI Framework**: SwiftUI or AppKit
- **Menu Bar Integration**: NSStatusBar / NSStatusItem
- **Data Persistence**: UserDefaults, Core Data, or local file storage
- **Network**: URLSession for production environment monitoring
- **Notifications**: User Notifications framework for alerts

## Project Structure

```
window/
├── .gitignore              # Git ignore rules
├── README.md              # Project readme
├── CLAUDE.md             # This file - AI assistant documentation
├── window/               # Main application code (to be created)
│   ├── App/              # Application entry point
│   ├── Views/            # UI components
│   │   ├── MenuBarView/  # Menu bar icon and window
│   │   ├── AlertsView/   # Production alerts display
│   │   └── NotesView/    # Note-taking interface
│   ├── Models/           # Data models
│   ├── Services/         # API clients, storage services
│   └── Resources/        # Assets, icons, configurations
└── window.xcodeproj/     # Xcode project file (to be created)
```

## Development Setup

### Prerequisites
- macOS 12.0 or later
- Xcode 14.0 or later
- Apple Developer account (for distribution)

### Getting Started
1. Clone the repository
2. Open the project in Xcode
3. Configure signing & capabilities
4. Build and run the application
5. Grant necessary permissions (notifications, network access)

## Feature Details

### 1. Production Environment Monitoring
- **Alert Sources**: Configurable endpoints for production monitoring
- **Real-time Updates**: Periodic polling or webhook-based updates
- **Alert Types**: Errors, warnings, info messages
- **Visual Indicators**: Badge count on menu bar icon for unread alerts
- **Alert History**: View and search past alerts

### 2. Note Recording
- **Quick Entry**: Fast text input for capturing thoughts and tasks
- **Categories**: Optional tagging or categorization
- **Timestamps**: Automatic time tracking for each note
- **Search**: Quick search through note history
- **Export**: Ability to export notes to text files

## User Interface

### Menu Bar Icon
- Minimal, clean design
- Badge indicator for unread alerts
- Click to toggle window display

### Popup Window
- Positioned directly below menu bar icon
- Tabs or sections for:
  - Production Alerts
  - Daily Notes
  - Settings
- Compact size (approximately 300-400px wide, 400-500px tall)
- Dark mode support
- Keyboard shortcuts for quick actions

## Configuration

### Settings Options
- **Production Endpoints**: Configure API endpoints for monitoring
- **Refresh Interval**: Set polling frequency for alerts
- **Notification Preferences**: Choose which alerts trigger system notifications
- **Note Storage**: Configure local storage location
- **Appearance**: Toggle dark/light mode, window size preferences

## Security Considerations

- **API Keys**: Secure storage of production environment credentials (Keychain)
- **Network Security**: HTTPS only for production endpoints
- **Data Privacy**: Notes stored locally, not transmitted
- **Permissions**: Request only necessary macOS permissions

## Future Enhancements

### Planned Features
- **Multiple Environments**: Support for dev, staging, and production
- **Integrations**: Slack, email, or other notification channels
- **Rich Text Notes**: Support for formatting, links, and attachments
- **Cloud Sync**: Optional sync of notes across devices
- **Custom Alert Rules**: Filter and customize alert conditions
- **Analytics**: Track alert patterns and note-taking habits

### Technical Improvements
- **Widget Support**: macOS widget for quick glance
- **Menu Bar Customization**: Different icon states based on alert severity
- **Keyboard Shortcuts**: Global hotkeys for quick access
- **Export/Import**: Backup and restore settings and data

## Development Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftLint for code quality
- Document public APIs with inline documentation
- Write unit tests for business logic

### Version Control
- Use semantic versioning
- Meaningful commit messages
- Feature branches for new development
- Pull requests for code review

### Testing
- Unit tests for models and services
- UI tests for critical user flows
- Manual testing on different macOS versions
- Beta testing before releases

## Troubleshooting

### Common Issues
- **Menu bar icon not showing**: Check app permissions and system preferences
- **Alerts not updating**: Verify network connectivity and API endpoints
- **Notes not saving**: Check file system permissions
- **Window position incorrect**: Reset preferences in settings

## Contributing

When contributing to this project:
1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commits
4. Test thoroughly on macOS
5. Submit a pull request with description

## Resources

### macOS Development
- [Apple Human Interface Guidelines - Menu Bar Extras](https://developer.apple.com/design/human-interface-guidelines/menu-bar-extras)
- [NSStatusBar Documentation](https://developer.apple.com/documentation/appkit/nsstatusbar)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### Similar Projects
- Study other menu bar apps for UX patterns
- Research best practices for non-intrusive notifications
- Explore efficient polling and caching strategies

## License

[To be determined based on project requirements]

## Contact & Support

[To be added - project maintainer contact information]

---

## AI Assistant Notes

This documentation is designed to help AI assistants (like Claude) understand the project context and assist with development tasks. When working on this project:

- **Architecture**: This is a native macOS application using menu bar pattern
- **User Experience**: Focus on minimalism and quick access
- **Performance**: Keep resource usage low as it runs continuously
- **Reliability**: Handle network failures gracefully for production monitoring
- **Data Safety**: Protect user notes and credentials properly

### Common Tasks
- Creating the Xcode project structure
- Implementing menu bar integration with NSStatusBar
- Building the popup window UI with SwiftUI or AppKit
- Setting up network layer for production monitoring
- Implementing local storage for notes
- Adding notification support
- Configuring app icons and assets
