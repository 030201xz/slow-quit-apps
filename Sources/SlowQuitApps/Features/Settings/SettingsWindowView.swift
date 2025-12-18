import SwiftUI

/// 设置窗口主视图
/// 使用 Apple 官方推荐的 TabView 设置模式，自动适配 Liquid Glass 效果
struct SettingsWindowView: View {
    @State private var i18n = I18n.shared
    
    var body: some View {
        // 通过访问 currentLanguage 确保语言变化时视图刷新
        let _ = i18n.currentLanguage
        
        TabView {
            Tab(t("settings.tabs.general"), systemImage: "gearshape") {
                GeneralSettingsView()
                    .fixedSize()
            }
            
            Tab(t("settings.tabs.appList"), systemImage: "app.badge.checkmark") {
                AppListSettingsView()
                    .frame(minWidth: 450, minHeight: 300)
            }
            
            Tab(t("settings.tabs.about"), systemImage: "info.circle") {
                AboutView()
                    .fixedSize()
            }
        }
        .scenePadding()
    }
}

