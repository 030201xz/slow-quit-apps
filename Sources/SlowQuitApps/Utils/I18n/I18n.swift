import Foundation

/// 国际化翻译引擎
/// 采用 JSON 资源文件，支持点分路径访问
@MainActor
@Observable
final class I18n {
    static let shared = I18n()
    
    /// 当前语言（用于触发视图刷新）
    private(set) var currentLanguage: Language = .en
    
    /// 翻译字典缓存
    private var translations: [String: Any] = [:]
    
    private init() {
        // 初始加载默认语言
        loadTranslations(for: .en)
    }
    
    // MARK: - 公开 API
    
    /// 核心翻译函数
    /// 支持点分路径: t("settings.general.title")
    func t(_ key: String) -> String {
        let components = key.split(separator: ".")
        var current: Any = translations
        
        // 逐层解析路径
        for component in components {
            guard let dict = current as? [String: Any],
                  let next = dict[String(component)] else {
                // 找不到翻译时返回 key 本身，便于调试
                return key
            }
            current = next
        }
        
        return (current as? String) ?? key
    }
    
    /// 切换语言
    func setLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        loadTranslations(for: language)
        currentLanguage = language
    }
    
    // MARK: - 内部实现
    
    /// 从 Bundle 加载 JSON 翻译文件
    private func loadTranslations(for language: Language) {
        // SPM 资源使用 Bundle.module
        guard let url = Bundle.module.url(
            forResource: language.fileName,
            withExtension: "json",
            subdirectory: "Locales"
        ) else {
            print("⚠️ 找不到翻译文件: \(language.fileName).json")
            // 如果非英语语言加载失败，回退到英语
            if language != .en {
                loadTranslations(for: .en)
            }
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ 翻译文件格式错误: \(language.fileName).json")
                return
            }
            translations = json
        } catch {
            print("❌ 加载翻译文件失败: \(error)")
        }
    }
}

// MARK: - 全局便捷函数

/// 全局翻译函数，类似 React i18n 的 t()
/// 用法: Text(t("settings.general.title"))
@MainActor
func t(_ key: String) -> String {
    I18n.shared.t(key)
}
