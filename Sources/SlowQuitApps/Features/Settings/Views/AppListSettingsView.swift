import SwiftUI

/// 应用列表设置视图
/// 管理排除列表（白名单）
struct AppListSettingsView: View {
    @Bindable var appState = AppState.shared
    @State private var showingAppPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部说明
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("排除列表")
                        .font(.headline)
                    Text("以下应用无需长按即可直接退出")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingAppPicker = true
                } label: {
                    Label("添加", systemImage: "plus")
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
            InstalledAppPicker { app in
                appState.addExcludedApp(app)
                showingAppPicker = false
            } onCancel: {
                showingAppPicker = false
            }
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "暂无排除应用",
            systemImage: "app.badge.checkmark",
            description: Text("点击「添加」按钮来添加应用")
        )
    }
    
    private var appListView: some View {
        List {
            ForEach(appState.excludedApps) { app in
                HStack(spacing: 12) {
                    // 使用与 InstalledAppRow 相同的图标加载方式
                    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleIdentifier) {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                            .resizable()
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "app.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.name)
                            .font(.system(size: 13, weight: .medium))
                        
                        Text(app.bundleIdentifier)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(role: .destructive) {
                        appState.removeExcludedApp(app)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.inset)
    }
}

// MARK: - 应用列表行

struct AppListRow: View {
    let app: ManagedApp
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AppIconView(bundleIdentifier: app.bundleIdentifier)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 13, weight: .medium))
                
                Text(app.bundleIdentifier)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 应用图标视图

struct AppIconView: View {
    let bundleIdentifier: String
    
    var body: some View {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                .resizable()
        } else {
            Image(systemName: "app.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 已安装应用选择器

struct InstalledAppPicker: View {
    let onSelect: (ManagedApp) -> Void
    let onCancel: () -> Void
    
    @State private var searchText = ""
    @State private var installedApps: [AppInfo] = []
    @State private var isLoading = true
    
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
            if isLoading {
                ProgressView("正在加载应用列表...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredApps, id: \.bundleIdentifier) { app in
                    Button {
                        selectApp(app)
                    } label: {
                        InstalledAppRow(app: app)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.inset)
            }
        }
        .frame(width: 400, height: 500)
        .onAppear {
            loadInstalledApps()
        }
    }
    
    private var filteredApps: [AppInfo] {
        guard !searchText.isEmpty else { return installedApps }
        let query = searchText.lowercased()
        return installedApps.filter {
            $0.name.lowercased().contains(query) ||
            $0.bundleIdentifier.lowercased().contains(query)
        }
    }
    
    private func selectApp(_ app: AppInfo) {
        let managedApp = ManagedApp(
            bundleIdentifier: app.bundleIdentifier,
            name: app.name,
            iconPath: nil,
            isExcluded: true
        )
        onSelect(managedApp)
    }
    
    /// 加载已安装应用
    private func loadInstalledApps() {
        isLoading = true
        
        // 在后台线程扫描应用
        DispatchQueue.global(qos: .userInitiated).async {
            let appURLs = findInstalledApplications()
            
            var apps: [AppInfo] = []
            for url in appURLs {
                guard let bundle = Bundle(url: url),
                      let bundleId = bundle.bundleIdentifier else { continue }
                
                let name = bundle.infoDictionary?["CFBundleName"] as? String
                    ?? bundle.infoDictionary?["CFBundleDisplayName"] as? String
                    ?? url.deletingPathExtension().lastPathComponent
                
                apps.append(AppInfo(bundleIdentifier: bundleId, name: name, url: url))
            }
            
            // 按名称排序
            apps.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            
            // 主线程更新 UI
            DispatchQueue.main.async {
                self.installedApps = apps
                self.isLoading = false
            }
        }
    }
}

// MARK: - 应用扫描工具

/// 扫描已安装的应用（线程安全）
private func findInstalledApplications() -> [URL] {
    var urls: [URL] = []
    
    let searchPaths = [
        "/Applications",
        "/System/Applications",
        NSHomeDirectory() + "/Applications"
    ]
    
    let fileManager = FileManager.default
    
    for path in searchPaths {
        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.isApplicationKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { continue }
        
        for case let url as URL in enumerator {
            if url.pathExtension == "app" {
                urls.append(url)
            }
        }
    }
    
    return urls
}

// MARK: - 应用信息

struct AppInfo: Identifiable {
    let bundleIdentifier: String
    let name: String
    let url: URL
    
    var id: String { bundleIdentifier }
}

// MARK: - 已安装应用行

struct InstalledAppRow: View {
    let app: AppInfo
    
    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: app.url.path))
                .resizable()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 13, weight: .medium))
                
                Text(app.bundleIdentifier)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
