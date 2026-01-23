import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
            loadBundle()
        }
    }
    
    private var bundle: Bundle?
    
    enum Language: String, CaseIterable {
        case english = "en"
        case chinese = "zh-Hans"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .chinese: return "简体中文"
            }
        }
    }
    
    private init() {
        // Load saved language preference or use system default
        let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage")
        
        if let saved = savedLanguage {
            self.currentLanguage = saved
        } else {
            // Detect system language
            let preferredLanguages = Locale.preferredLanguages
            if preferredLanguages.first?.hasPrefix("zh") == true {
                self.currentLanguage = Language.chinese.rawValue
            } else {
                self.currentLanguage = Language.english.rawValue
            }
        }
        
        loadBundle()
    }
    
    private func loadBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            self.bundle = Bundle.main
            return
        }
        self.bundle = bundle
    }
    
    func localizedString(_ key: String, comment: String = "") -> String {
        guard let bundle = bundle else {
            return NSLocalizedString(key, comment: comment)
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
    
    // Convenience method for SwiftUI
    func localized(_ key: String) -> String {
        localizedString(key)
    }
}

// SwiftUI Environment Key
struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var localization: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}
