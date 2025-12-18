import SwiftUI

/// 设置侧边栏视图
/// 显示导航菜单项
struct SettingsSidebar: View {
    @Bindable var router = SettingsRouter.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(SettingsRoute.allCases) { route in
                SidebarItem(
                    title: route.rawValue,
                    icon: route.icon,
                    isSelected: router.currentRoute == route
                ) {
                    router.navigate(to: route)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .frame(width: Constants.Window.sidebarWidth)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

/// 侧边栏菜单项
struct SidebarItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 13))
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .foregroundColor(isSelected ? .accentColor : .primary)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }
}
