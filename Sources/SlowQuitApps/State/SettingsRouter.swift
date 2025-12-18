import SwiftUI

/// 设置页路由枚举
/// 使用 React Query 理念：声明式路由，状态驱动导航
enum SettingsRoute: String, CaseIterable, Identifiable {
    case general = "通用"
    case appList = "应用列表"
    case about = "关于"
    
    var id: String { rawValue }
    
    /// 路由对应的图标
    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .appList: return "app.badge.checkmark"
        case .about: return "info.circle"
        }
    }
}

/// 设置路由状态管理器
/// 负责设置页面的导航状态
@MainActor
@Observable
final class SettingsRouter {
    /// 单例实例
    static let shared = SettingsRouter()
    
    /// 当前激活的路由
    var currentRoute: SettingsRoute = .general
    
    /// 路由历史记录（用于返回操作）
    private var history: [SettingsRoute] = []
    
    private init() {}
    
    // MARK: - 导航方法
    
    /// 导航到指定路由
    func navigate(to route: SettingsRoute) {
        guard route != currentRoute else { return }
        history.append(currentRoute)
        currentRoute = route
    }
    
    /// 返回上一个路由
    func goBack() {
        guard let previousRoute = history.popLast() else { return }
        currentRoute = previousRoute
    }
    
    /// 重置到初始路由
    func reset() {
        history.removeAll()
        currentRoute = .general
    }
    
    /// 检查是否可以返回
    var canGoBack: Bool {
        !history.isEmpty
    }
}
