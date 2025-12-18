import SwiftUI

/// 设置窗口主视图
/// 左右布局：左侧导航栏 + 右侧内容区
struct SettingsWindowView: View {
    var body: some View {
        HStack(spacing: 0) {
            // 左侧导航栏
            SettingsSidebar()
            
            Divider()
            
            // 右侧内容区
            SettingsContent()
        }
        .frame(
            minWidth: Constants.Window.settingsWidth,
            minHeight: Constants.Window.settingsHeight
        )
    }
}
