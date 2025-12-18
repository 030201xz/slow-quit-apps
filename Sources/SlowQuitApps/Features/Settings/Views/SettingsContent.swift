import SwiftUI

/// 设置内容区视图
/// 根据当前路由显示对应的设置页面
struct SettingsContent: View {
    @Bindable var router = SettingsRouter.shared
    
    var body: some View {
        Group {
            switch router.currentRoute {
            case .general:
                GeneralSettingsView()
            case .appList:
                AppListSettingsView()
            case .about:
                AboutView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
