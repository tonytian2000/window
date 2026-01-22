# Window - macOS Menu Bar App

A lightweight macOS menu bar application for monitoring production environments and taking quick notes.

## Overview

**Window** is a native macOS application that sits in your menu bar, providing instant access to:
- 🔔 **Production Alerts**: Monitor real-time alerts and messages from your production environment
- 📝 **Quick Notes**: Capture thoughts, tasks, and reminders throughout your workday

## Features

### Production Monitoring
- Real-time alerts from configurable API endpoints
- Color-coded severity levels (Error, Warning, Info)
- Unread badge counter on menu bar icon
- Auto-refresh with configurable intervals
- Mark alerts as read/unread
- Alert history and search

### Note Taking
- Quick note entry with keyboard shortcuts
- Optional categorization
- Search through notes
- Edit and delete functionality
- Export notes to Markdown
- Automatic timestamps

### Settings
- Configure production API endpoints
- API key authentication support
- Adjustable refresh intervals
- Notification preferences
- Dark mode support

## Quick Start

### Prerequisites
- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/tonytian2000/window.git
   cd window
   ```

2. **Open in Xcode**:
   - Follow the detailed instructions in [SETUP.md](SETUP.md)
   - Create an Xcode project and add the source files
   - Configure code signing with your Apple ID

3. **Build and Run**:
   - Press `⌘+R` in Xcode
   - Look for the bell icon in your menu bar

For detailed setup instructions, see [SETUP.md](SETUP.md).

## Usage

### First Run
1. Click the menu bar icon (bell icon)
2. Navigate to Settings tab
3. (Optional) Configure your production API endpoint
4. Start using alerts and notes immediately with sample data

### API Integration

Configure your production monitoring endpoint in Settings. The API should return JSON:

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

See [SETUP.md](SETUP.md) for complete API documentation.

## Project Structure

```
window/
├── CLAUDE.md              # AI assistant documentation
├── README.md             # This file
├── SETUP.md              # Detailed setup instructions
└── window/               # Source code
    ├── WindowApp.swift   # Main app entry point
    ├── Models/           # Data models
    ├── Views/            # SwiftUI views
    ├── ViewModels/       # View models
    └── Services/         # Business logic
```

## Tech Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: MVVM pattern
- **Platform**: macOS 12.0+
- **Storage**: UserDefaults for local persistence
- **Networking**: URLSession for API calls

## Screenshots

_Coming soon - will include menu bar icon, alerts view, notes view, and settings_

## Roadmap

- [ ] Native macOS notifications for new alerts
- [ ] Global keyboard shortcuts
- [ ] Multiple environment support (dev, staging, prod)
- [ ] iCloud sync for notes
- [ ] Custom alert filters and rules
- [ ] Menu bar icon customization
- [ ] Export/import settings
- [ ] Slack/email integration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Documentation

- [SETUP.md](SETUP.md) - Detailed setup and configuration guide
- [CLAUDE.md](CLAUDE.md) - AI assistant context and development guide

## License

[To be determined]

## Acknowledgments

- Built with SwiftUI for native macOS experience
- Inspired by the need for quick production monitoring and note-taking
- Designed to be lightweight and non-intrusive

## Support

For issues, questions, or feature requests, please open an issue on GitHub.
