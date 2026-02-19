import Foundation

/// Supported language
/// Uses ISO 639-1 language codes
enum Language: String, Codable, CaseIterable, Sendable {
    case en = "en"
    case zhCN = "zh-CN"
    case ja = "ja"
    case ru = "ru"

    /// Localized display name
    var displayName: String {
        switch self {
        case .en: "English"
        case .zhCN: "简体中文"
        case .ja: "日本語"
        case .ru: "Русский"
        }
    }

    /// Corresponding JSON locale filename
    var fileName: String {
        rawValue
    }
}
