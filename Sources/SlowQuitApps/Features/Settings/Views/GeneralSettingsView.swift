import SwiftUI

/// 通用设置视图
/// 配置基本功能参数
struct GeneralSettingsView: View {
    @Bindable var appState = AppState.shared
    
    var body: some View {
        Form {
            // 功能开关区域
            Section {
                Toggle("启用长按退出", isOn: $appState.isEnabled)
                    .toggleStyle(.switch)
                
                Toggle("显示菜单栏图标", isOn: $appState.showMenuBarIcon)
                    .toggleStyle(.switch)
                
                Toggle("开机自动启动", isOn: $appState.launchAtLogin)
                    .toggleStyle(.switch)
                
                Toggle("显示进度动画", isOn: $appState.showProgressAnimation)
                    .toggleStyle(.switch)
            } header: {
                Text("基本设置")
            }
            
            // 长按时间配置
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("长按持续时间")
                        Spacer()
                        Text(String(format: "%.1f 秒", appState.holdDuration))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: $appState.holdDuration,
                        in: Constants.Progress.minHoldDuration...Constants.Progress.maxHoldDuration,
                        step: 0.1
                    )
                }
                
                // 快捷预设按钮
                HStack(spacing: 12) {
                    ForEach([0.5, 1.0, 1.5, 2.0], id: \.self) { duration in
                        Button("\(String(format: "%.1f", duration))s") {
                            appState.setHoldDuration(duration)
                        }
                        .buttonStyle(.bordered)
                        .tint(appState.holdDuration == duration ? .accentColor : .secondary)
                    }
                    Spacer()
                }
            } header: {
                Text("退出延迟")
            }
            
            // 无障碍权限状态
            Section {
                AccessibilityStatusRow()
            } header: {
                Text("权限状态")
            }
            
            // 重置按钮
            Section {
                Button("恢复默认设置", role: .destructive) {
                    appState.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

/// 无障碍权限状态行
struct AccessibilityStatusRow: View {
    @State private var isEnabled = AccessibilityManager.shared.isAccessibilityEnabled
    
    var body: some View {
        HStack {
            Text("无障碍权限")
            
            Spacer()
            
            if isEnabled {
                Label("已授权", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button("去授权") {
                    AccessibilityManager.shared.openAccessibilitySettings()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            // 刷新权限状态
            isEnabled = AccessibilityManager.shared.isAccessibilityEnabled
        }
    }
}
