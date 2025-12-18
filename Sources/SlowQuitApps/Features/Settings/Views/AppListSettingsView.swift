import SwiftUI

/// 应用列表设置视图
/// 管理排除列表（白名单）
struct AppListSettingsView: View {
    @Bindable var appState = AppState.shared
    @State private var showingAppPicker = false
    @State private var runningApps: [NSRunningApplication] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部说明
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("排除列表")
                        .font(.headline)
                    Text("以下应用无需长按即可直接退出")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    refreshRunningApps()
                    showingAppPicker = true
                } label: {
                    Label("添加应用", systemImage: "plus")
                }
            }
            .padding()
            
            Divider()
            
            // 应用列表
            if appState.excludedApps.isEmpty {
                emptyStateView
            } else {
                appListView
            }
        }
        .sheet(isPresented: $showingAppPicker) {
            AppPickerSheet(
                runningApps: runningApps,
                onSelect: { app in
                    appState.addExcludedApp(app)
                    showingAppPicker = false
                },
                onCancel: {
                    showingAppPicker = false
                }
            )
        }
    }
    
    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "app.badge.checkmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("暂无排除应用")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("点击上方「添加应用」按钮来添加")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// 应用列表视图
    private var appListView: some View {
        List {
            ForEach(appState.excludedApps) { app in
                AppListRow(app: app) {
                    appState.removeExcludedApp(app)
                }
            }
        }
        .listStyle(.inset)
    }
    
    /// 刷新正在运行的应用列表
    private func refreshRunningApps() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .filter { $0.bundleIdentifier != nil }
    }
}

/// 应用列表行
struct AppListRow: View {
    let app: ManagedApp
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 应用图标
            appIcon
            
            // 应用信息
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 13, weight: .medium))
                
                Text(app.bundleIdentifier)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 删除按钮
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
    
    /// 应用图标视图
    @ViewBuilder
    private var appIcon: some View {
        if let iconPath = app.iconPath,
           let image = NSImage(contentsOfFile: iconPath) {
            Image(nsImage: image)
                .resizable()
                .frame(width: 32, height: 32)
        } else {
            Image(systemName: "app.fill")
                .font(.system(size: 24))
                .foregroundColor(.secondary)
                .frame(width: 32, height: 32)
        }
    }
}

/// 应用选择器弹窗
struct AppPickerSheet: View {
    let runningApps: [NSRunningApplication]
    let onSelect: (ManagedApp) -> Void
    let onCancel: () -> Void
    
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("选择应用")
                    .font(.headline)
                
                Spacer()
                
                Button("取消", action: onCancel)
            }
            .padding()
            
            // 搜索框
            TextField("搜索应用...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Divider()
                .padding(.top, 8)
            
            // 应用列表
            List(filteredApps, id: \.processIdentifier) { app in
                Button {
                    selectApp(app)
                } label: {
                    RunningAppRow(app: app)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.inset)
        }
        .frame(width: 400, height: 500)
    }
    
    /// 过滤后的应用列表
    private var filteredApps: [NSRunningApplication] {
        if searchText.isEmpty {
            return runningApps
        }
        return runningApps.filter { app in
            let name = app.localizedName ?? ""
            let bundleId = app.bundleIdentifier ?? ""
            let query = searchText.lowercased()
            return name.lowercased().contains(query) || bundleId.lowercased().contains(query)
        }
    }
    
    /// 选择应用
    private func selectApp(_ app: NSRunningApplication) {
        guard let bundleId = app.bundleIdentifier else { return }
        let managedApp = ManagedApp(
            bundleIdentifier: bundleId,
            name: app.localizedName ?? "未知应用",
            iconPath: app.bundleURL?.appendingPathComponent("Contents/Resources/AppIcon.icns").path,
            isExcluded: true
        )
        onSelect(managedApp)
    }
}

/// 运行中应用行
struct RunningAppRow: View {
    let app: NSRunningApplication
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
            } else {
                Image(systemName: "app.fill")
                    .frame(width: 32, height: 32)
            }
            
            // 信息
            VStack(alignment: .leading, spacing: 2) {
                Text(app.localizedName ?? "未知应用")
                    .font(.system(size: 13, weight: .medium))
                
                Text(app.bundleIdentifier ?? "")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
