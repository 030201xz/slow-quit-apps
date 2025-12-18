import SwiftUI

/// 设置内容区视图
/// 根据当前路由显示对应的设置页面
struct SettingsContent: View {
    @Bindable var router = SettingsRouter.shared
    
    var body: some View {
        // appList 自带 List，不需要外层 ScrollView
        // 其他页面内容较少，使用 ScrollView 包裹
        switch router.currentRoute {
        case .appList:
            AppListSettingsView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
        default:
            ScrollView {
                contentView
                    .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
        }
    }
    
    /// 根据路由返回对应视图
    @ViewBuilder
    private var contentView: some View {
        switch router.currentRoute {
        case .general:
            GeneralSettingsView()
        case .appList:
            EmptyView() // 已在上方处理
        case .about:
            AboutView()
        }
    }
}
