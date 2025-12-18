# Slow Quit Apps

<p align="center">
  <img src="BuildAssets/AppIcon.png" width="128" height="128" alt="Slow Quit Apps 图标">
</p>

<p align="center">
  <strong>防止意外按下 ⌘Q 导致应用退出的小工具</strong>
</p>

<p align="center">
  <a href="#功能特性">功能特性</a> •
  <a href="#安装">安装</a> •
  <a href="#使用方法">使用方法</a> •
  <a href="#配置">配置</a> •
  <a href="#构建">构建</a> •
  <a href="#许可证">许可证</a>
</p>

<p align="center">
  <a href="README.md">English</a> |
  <a href="README.ja.md">日本語</a> |
  <a href="README.ru.md">Русский</a>
</p>

---

## 功能特性

- 🛡️ **防止误退出** - 需要长按 ⌘Q 才能退出应用
- ⏱️ **可调节时长** - 长按时间可在 0.3 秒到 3.0 秒之间调节
- 📋 **应用白名单** - 指定无需长按即可退出的应用
- 🌐 **多语言支持** - 支持英语、中文、日语、俄语
- 🎨 **原生 macOS 设计** - 与系统 UI 无缝集成
- 💾 **配置持久化** - 设置保存到 JSON 文件

## 系统要求

- macOS 15.0 (Sequoia) 或更高版本
- 需要辅助功能权限

## 安装

### 从 DMG 安装（推荐）

1. 从 [Releases](../../releases) 下载最新版本
2. 打开 DMG 文件
3. 将 `SlowQuitApps.app` 拖到 `应用程序` 文件夹
4. 打开应用并授予辅助功能权限

### 从源码构建

```bash
git clone https://github.com/yourusername/slow-quit-apps.git
cd slow-quit-apps
./build.sh
```

## 使用方法

### 首次设置

1. **授予辅助功能权限**
   - 打开应用 → 系统设置会自动打开
   - 前往：**隐私与安全性 → 辅助功能**
   - 将 **SlowQuitApps** 开关打开
   - 在设置窗口中点击 **重启应用**

2. **配置设置**
   - 右键点击菜单栏图标 → **设置**
   - 根据需要调整长按时间
   - 按需添加白名单应用

### 工作原理

| 操作 | 结果 |
|------|------|
| 短暂按下 ⌘Q | 无反应（退出已取消） |
| 长按 ⌘Q 达到设定时间 | 应用退出 |
| 提前松开 ⌘Q | 退出取消，进度重置 |
| 对白名单应用按 ⌘Q | 立即退出 |

## 配置

### 配置文件位置

配置存储在：
```
~/Library/Application Support/SlowQuitApps/config.json
```

### 可用选项

| 设置 | 说明 | 默认值 |
|------|------|--------|
| `isEnabled` | 启用/禁用功能 | `true` |
| `holdDuration` | 长按 ⌘Q 时间（秒） | `1.0` |
| `launchAtLogin` | 开机自启 | `false` |
| `showProgressAnimation` | 显示进度环 | `true` |
| `language` | 界面语言 | `en` |
| `excludedApps` | 白名单应用 | 系统默认 |

### 支持的语言

| 代码 | 语言 |
|------|------|
| `en` | English |
| `zh-CN` | 简体中文 |
| `ja` | 日本語 |
| `ru` | Русский |

## 构建

### 前置要求

- Xcode 16.0+ 或 Swift 6.0+
- macOS 15.0+

### 构建命令

```bash
# 开发构建
swift build

# 发布构建（含 DMG）
./build.sh

# 生成应用图标
swift scripts/generate-icon.swift
```

### 项目结构

```
slow-quit-apps/
├── Sources/SlowQuitApps/
│   ├── App/              # 应用入口
│   ├── Core/             # 核心功能
│   │   ├── Accessibility/  # 权限管理
│   │   └── QuitHandler/    # 退出进度 UI
│   ├── Features/         # 功能模块
│   │   └── Settings/       # 设置窗口
│   ├── Models/           # 数据模型
│   ├── State/            # 应用状态管理
│   ├── Utils/            # 工具类
│   │   └── I18n/           # 国际化
│   └── Resources/        # 语言资源文件
├── Resources/            # 应用图标、文档
└── scripts/              # 构建脚本
```

## 故障排除

### 重新构建后辅助功能权限重置

这是 ad-hoc 签名导致的问题。构建脚本包含自签名证书机制来防止此问题。运行：

```bash
./build.sh
```

首次运行会创建持久化签名证书。

### 应用无法拦截 ⌘Q

1. 检查辅助功能权限是否已授予
2. 在设置中点击 **重启应用**
3. 确保目标应用不在白名单中

## 贡献

欢迎贡献！请随时提交 issues 或 pull requests。

## 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)

---

<p align="center">
  用 ❤️ 为 macOS 打造
</p>
