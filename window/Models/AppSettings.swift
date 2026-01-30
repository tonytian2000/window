import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // Alert settings
    @Published var apiEndpoint: String {
        didSet { UserDefaults.standard.set(apiEndpoint, forKey: "apiEndpoint") }
    }
    
    @Published var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "apiKey") }
    }
    
    @Published var refreshInterval: Int {
        didSet { UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval") }
    }
    
    @Published var autoRefresh: Bool {
        didSet { UserDefaults.standard.set(autoRefresh, forKey: "autoRefresh") }
    }
    
    @Published var showErrors: Bool {
        didSet { UserDefaults.standard.set(showErrors, forKey: "showErrors") }
    }
    
    @Published var showWarnings: Bool {
        didSet { UserDefaults.standard.set(showWarnings, forKey: "showWarnings") }
    }
    
    @Published var showInfo: Bool {
        didSet { UserDefaults.standard.set(showInfo, forKey: "showInfo") }
    }
    
    // Notes settings
    @Published var defaultNoteCategory: String {
        didSet { UserDefaults.standard.set(defaultNoteCategory, forKey: "defaultNoteCategory") }
    }
    
    @Published var defaultNoteFont: String {
        didSet { UserDefaults.standard.set(defaultNoteFont, forKey: "defaultNoteFont") }
    }
    
    @Published var showNoteTimestamps: Bool {
        didSet { UserDefaults.standard.set(showNoteTimestamps, forKey: "showNoteTimestamps") }
    }
    
    @Published var showNoteCategories: Bool {
        didSet { UserDefaults.standard.set(showNoteCategories, forKey: "showNoteCategories") }
    }
    
    @Published var autoFocusNoteEditor: Bool {
        didSet { UserDefaults.standard.set(autoFocusNoteEditor, forKey: "autoFocusNoteEditor") }
    }
    
    @Published var maxNotes: Int {
        didSet { UserDefaults.standard.set(maxNotes, forKey: "maxNotes") }
    }
    
    // General settings
    @Published var enableNotifications: Bool {
        didSet { UserDefaults.standard.set(enableNotifications, forKey: "enableNotifications") }
    }
    
    @Published var windowWidth: Int {
        didSet {
            UserDefaults.standard.set(windowWidth, forKey: "windowWidth")
            NotificationCenter.default.post(name: NSNotification.Name("WindowSizeChanged"), object: nil)
        }
    }
    
    @Published var windowHeight: Int {
        didSet {
            UserDefaults.standard.set(windowHeight, forKey: "windowHeight")
            NotificationCenter.default.post(name: NSNotification.Name("WindowSizeChanged"), object: nil)
        }
    }
    
    @Published var baseFontSize: Int {
        didSet { UserDefaults.standard.set(baseFontSize, forKey: "baseFontSize") }
    }
    
    @Published var backgroundColor: String {
        didSet { UserDefaults.standard.set(backgroundColor, forKey: "backgroundColor") }
    }
    
    @Published var theme: String {
        didSet {
            UserDefaults.standard.set(theme, forKey: "theme")
            NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
        }
    }

    @Published var hasPremium: Bool {
        didSet { UserDefaults.standard.set(hasPremium, forKey: "hasPremium") }
    }
    
    private init() {
        // Alert settings
        self.apiEndpoint = UserDefaults.standard.string(forKey: "apiEndpoint") ?? "https://api.example.com/alerts"
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        self.refreshInterval = UserDefaults.standard.integer(forKey: "refreshInterval") == 0 ? 5 : UserDefaults.standard.integer(forKey: "refreshInterval")
        self.autoRefresh = UserDefaults.standard.object(forKey: "autoRefresh") == nil ? true : UserDefaults.standard.bool(forKey: "autoRefresh")
        self.showErrors = UserDefaults.standard.object(forKey: "showErrors") == nil ? true : UserDefaults.standard.bool(forKey: "showErrors")
        self.showWarnings = UserDefaults.standard.object(forKey: "showWarnings") == nil ? true : UserDefaults.standard.bool(forKey: "showWarnings")
        self.showInfo = UserDefaults.standard.object(forKey: "showInfo") == nil ? true : UserDefaults.standard.bool(forKey: "showInfo")
        
        // Notes settings
        self.defaultNoteCategory = UserDefaults.standard.string(forKey: "defaultNoteCategory") ?? ""
        self.defaultNoteFont = UserDefaults.standard.string(forKey: "defaultNoteFont") ?? "System Font"
        self.showNoteTimestamps = UserDefaults.standard.object(forKey: "showNoteTimestamps") == nil ? true : UserDefaults.standard.bool(forKey: "showNoteTimestamps")
        self.showNoteCategories = UserDefaults.standard.object(forKey: "showNoteCategories") == nil ? true : UserDefaults.standard.bool(forKey: "showNoteCategories")
        self.autoFocusNoteEditor = UserDefaults.standard.object(forKey: "autoFocusNoteEditor") == nil ? true : UserDefaults.standard.bool(forKey: "autoFocusNoteEditor")
        self.maxNotes = UserDefaults.standard.integer(forKey: "maxNotes") == 0 ? 100 : UserDefaults.standard.integer(forKey: "maxNotes")
        
        // General settings
        self.enableNotifications = UserDefaults.standard.object(forKey: "enableNotifications") == nil ? true : UserDefaults.standard.bool(forKey: "enableNotifications")
        self.windowWidth = UserDefaults.standard.integer(forKey: "windowWidth") == 0 ? 360 : UserDefaults.standard.integer(forKey: "windowWidth")
        self.windowHeight = UserDefaults.standard.integer(forKey: "windowHeight") == 0 ? 500 : UserDefaults.standard.integer(forKey: "windowHeight")
        self.baseFontSize = UserDefaults.standard.integer(forKey: "baseFontSize") == 0 ? 13 : UserDefaults.standard.integer(forKey: "baseFontSize")
        self.backgroundColor = UserDefaults.standard.string(forKey: "backgroundColor") ?? "white"
        self.theme = UserDefaults.standard.string(forKey: "theme") ?? "light"
        self.hasPremium = UserDefaults.standard.object(forKey: "hasPremium") == nil ? false : UserDefaults.standard.bool(forKey: "hasPremium")
    }
}
