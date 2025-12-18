import Foundation

/// 支持的语言类型
/// 采用 ISO 639-1 标准语言代码
enum Language: String, Codable, CaseIterable, Sendable {
    case en = "en"
    case zhCN = "zh-CN"
    case ja = "ja"
    case ru = "ru"
    
    /// 语言的本地化显示名称
    var displayName: String {
        switch self {
        case .en: "English"
        case .zhCN: "简体中文"
        case .ja: "日本語"
        case .ru: "Русский"
        }
    }
    
    /// 对应的 JSON 文件名
    var fileName: String {
        rawValue
    }
}
