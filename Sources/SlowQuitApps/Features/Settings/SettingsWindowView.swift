import SwiftUI

/// 设置窗口主视图
/// 左右布局：左侧导航栏 + 右侧内容区，支持 Liquid Glass 效果
struct SettingsWindowView: View {
    var body: some View {
        HStack(spacing: 0) {
            // 左侧导航栏
            SettingsSidebar()
            
            // 右侧内容区
            SettingsContent()
        }
        .frame(
            minWidth: Constants.Window.settingsWidth,
            minHeight: Constants.Window.settingsHeight
        )
        .modifier(WindowGlassModifier())
    }
}

/// 窗口玻璃效果修饰器
private struct WindowGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            // macOS 26+ 使用 Liquid Glass 容器
            GlassEffectContainer {
                content
            }
        } else {
            content
        }
    }
}
