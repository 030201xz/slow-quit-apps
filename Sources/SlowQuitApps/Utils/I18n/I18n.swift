import Foundation

/// Internationalization engine
/// Loads JSON locale files, supports dot-path key access
@MainActor
@Observable
final class I18n {
    static let shared = I18n()

    /// Current language (used to trigger view refresh)
    private(set) var currentLanguage: Language = .en

    /// Cached translation dictionary
    private var translations: [String: Any] = [:]

    private init() {
        // Load default language on init
        loadTranslations(for: .en)
    }

    // MARK: - Public API

    /// Core translation function
    /// Supports dot-path: t("settings.general.title")
    func t(_ key: String) -> String {
        let components = key.split(separator: ".")
        var current: Any = translations

        // Traverse the path components
        for component in components {
            guard let dict = current as? [String: Any],
                  let next = dict[String(component)] else {
                // Return the key itself when translation is missing (aids debugging)
                return key
            }
            current = next
        }

        return (current as? String) ?? key
    }

    /// Switch language
    func setLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        loadTranslations(for: language)
        currentLanguage = language
    }

    // MARK: - Private

    /// Load JSON locale file from Bundle
    private func loadTranslations(for language: Language) {
        // SPM resources use Bundle.module
        guard let url = Bundle.module.url(
            forResource: language.fileName,
            withExtension: "json",
            subdirectory: "Locales"
        ) else {
            print("⚠️ Locale file not found: \(language.fileName).json")
            // Fall back to English if a non-English locale fails to load
            if language != .en {
                loadTranslations(for: .en)
            }
            return
        }

        do {
            let data = try Data(contentsOf: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ Invalid locale file format: \(language.fileName).json")
                return
            }
            translations = json
        } catch {
            print("❌ Failed to load locale file: \(error)")
        }
    }
}

// MARK: - Global Helper

/// Global translation helper, similar to React i18n's t()
/// Usage: Text(t("settings.general.title"))
@MainActor
func t(_ key: String) -> String {
    I18n.shared.t(key)
}
