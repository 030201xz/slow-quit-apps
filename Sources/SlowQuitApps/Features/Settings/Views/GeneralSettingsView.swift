import SwiftUI
import UniformTypeIdentifiers

/// 通用设置视图
struct GeneralSettingsView: View {
    @Bindable var appState = AppState.shared
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var importError: String?
    
    /// 是否在有效的应用包环境中运行
    private var isValidAppBundle: Bool {
        Bundle.main.bundleIdentifier != nil && Bundle.main.bundleURL.pathExtension == "app"
    }
    
    var body: some View {
        Form {
            // 权限状态（置顶）
            Section {
                AccessibilityStatusRow()
            }
            
            // 功能开关
            Section {
                Toggle("启用长按退出", isOn: $appState.isEnabled)
                
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("开机自动启动", isOn: $appState.launchAtLogin)
                        .disabled(!isValidAppBundle)
                    
                    if !isValidAppBundle {
                        Text("需要构建为 .app 包后才能使用")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Toggle("显示进度动画", isOn: $appState.showProgressAnimation)
            }
            
            // 长按时间
            Section {
                LabeledContent("长按时间") {
                    Text(String(format: "%.1f 秒", appState.holdDuration))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                
                Slider(
                    value: $appState.holdDuration,
                    in: Constants.Progress.minHoldDuration...Constants.Progress.maxHoldDuration,
                    step: 0.1
                )
            }
            
            // 配置管理
            Section("配置管理") {
                HStack {
                    Button("导出") { showingExporter = true }
                    Divider().frame(height: 16)
                    Button("导入") { showingImporter = true }
                }
                
                Button("恢复默认设置", role: .destructive) {
                    appState.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .fileExporter(
            isPresented: $showingExporter,
            document: ConfigDocument(),
            contentType: .json,
            defaultFilename: "slow-quit-apps-config"
        ) { result in
            if case .failure(let error) = result {
                print("导出失败: \(error)")
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case .success(let url):
                do {
                    _ = url.startAccessingSecurityScopedResource()
                    defer { url.stopAccessingSecurityScopedResource() }
                    try appState.importConfig(from: url)
                } catch {
                    importError = error.localizedDescription
                }
            case .failure(let error):
                importError = error.localizedDescription
            }
        }
        .alert("导入失败", isPresented: .constant(importError != nil)) {
            Button("确定") { importError = nil }
        } message: {
            Text(importError ?? "")
        }
    }
}

// MARK: - 配置文档（用于导出）

struct ConfigDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    init() {}
    
    init(configuration: ReadConfiguration) throws {
        // 不需要从文件读取
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let config = ConfigManager.shared.load()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - 无障碍权限状态

struct AccessibilityStatusRow: View {
    @State private var isEnabled = AccessibilityManager.shared.isAccessibilityEnabled
    
    var body: some View {
        LabeledContent {
            if isEnabled {
                Text("已启用")
                    .foregroundStyle(.green)
            } else {
                Button("授权") {
                    AccessibilityManager.shared.openAccessibilitySettings()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        } label: {
            Label(
                "无障碍权限",
                systemImage: isEnabled ? "checkmark.shield.fill" : "exclamationmark.shield"
            )
        }
        .foregroundStyle(isEnabled ? Color.primary : Color.orange)
        .onAppear {
            isEnabled = AccessibilityManager.shared.isAccessibilityEnabled
        }
    }
}
