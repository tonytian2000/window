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
        case japanese = "ja"
        case german = "de"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .chinese: return "简体中文"
            case .japanese: return "日本語"
            case .german: return "Deutsch"
            }
        }
        
        var flag: String {
            switch self {
            case .english: return "🇬🇧"
            case .chinese: return "🇨🇳"
            case .japanese: return "🇯🇵"
            case .german: return "🇩🇪"
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
            if let firstLang = preferredLanguages.first {
                if firstLang.hasPrefix("zh") {
                    self.currentLanguage = Language.chinese.rawValue
                } else if firstLang.hasPrefix("ja") {
                    self.currentLanguage = Language.japanese.rawValue
                } else if firstLang.hasPrefix("de") {
                    self.currentLanguage = Language.german.rawValue
                } else {
                    self.currentLanguage = Language.english.rawValue
                }
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
