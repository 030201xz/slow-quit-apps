import SwiftUI

/// 设置侧边栏视图
/// 显示导航菜单项，支持 Liquid Glass 效果
struct SettingsSidebar: View {
    @Bindable var router = SettingsRouter.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
        .padding(.vertical, 12)
        .frame(width: Constants.Window.sidebarWidth)
        .background(.regularMaterial)
    }
}

/// 侧边栏菜单项
struct SidebarItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .frame(width: 22)
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(itemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 10)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
    
    /// 菜单项背景
    @ViewBuilder
    private var itemBackground: some View {
        if isSelected {
            // 选中状态使用渐变
            RoundedRectangle(cornerRadius: 8)
                .fill(.linearGradient(
                    colors: [.accentColor, .accentColor.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        } else if isHovered {
            // 悬停状态
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
        }
    }
}
