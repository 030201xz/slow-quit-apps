# Slow Quit Apps

<p align="center">
  <img src="BuildAssets/AppIcon.png" width="128" height="128" alt="Slow Quit Apps 图标">
</p>

<p align="center">
  <strong>通过长按 ⌘Q / ⌘W，防止意外退出应用或关闭窗口</strong>
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

- 🛡️ **防止误退出** — 长按 ⌘Q 才能退出应用，短按无效
- 🪟 **防止误关窗口** — 长按 ⌘W 才能关闭窗口，短按无效
- ⏱️ **可调节时长** — 长按时间可在 0.3 秒到 3.0 秒之间调节
- 📋 **应用排除列表** — 指定无需长按即可直接退出/关闭的应用
- 🌐 **多语言支持** — 英语、简体中文、日语、俄语
- 🎨 **原生 macOS 设计** — 进度环与系统 UI 无缝融合
- 💾 **配置持久化** — 设置保存到 JSON 文件

## 系统要求

- macOS 14.0 (Sonoma) 或更高版本
- 需要辅助功能权限

## 安装

### 从 DMG 安装（推荐）

1. 从 [Releases](../../releases) 下载最新版本
2. 打开 DMG 文件
3. 将 `SlowQuitApps.app` 拖到「应用程序」文件夹
4. 打开应用并按提示授予辅助功能权限

### 从源码构建

```bash
git clone https://github.com/030201xz/slow-quit-apps.git
cd slow-quit-apps
./build.sh
```

## 使用方法

### 首次设置

1. **授予辅助功能权限**
   - 打开应用 → 系统设置会自动弹出
   - 前往：**隐私与安全性 → 辅助功能**
   - 将 **SlowQuitApps** 开关打开
   - 在设置窗口中点击**重启应用**

2. **通过菜单栏图标配置**
   - 点击菜单栏图标
   - **启用 ⌘Q** / **禁用 ⌘Q** — 控制长按退出功能
   - **启用 ⌘W** / **禁用 ⌘W** — 控制长按关闭窗口功能
   - **设置…** — 调整长按时间、排除列表、语言

### 工作原理

| 操作 | 结果 |
|------|------|
| 短暂按下 ⌘Q | 无反应（退出已取消） |
| 长按 ⌘Q 达到设定时间 | 应用退出 |
| 提前松开 ⌘Q | 退出取消，进度重置 |
| 对排除列表中的应用按 ⌘Q | 立即退出 |
| 短暂按下 ⌘W | 无反应（关闭已取消） |
| 长按 ⌘W 达到设定时间 | 窗口关闭 |
| 提前松开 ⌘W | 关闭取消，进度重置 |
| 对排除列表中的应用按 ⌘W | 立即关闭 |

## 配置

### 配置文件位置

```
~/Library/Application Support/SlowQuitApps/config.json
```

### 可用选项

| 键 | 说明 | 默认值 |
|----|------|--------|
| `quitOnLongPress` | 启用 ⌘Q 长按退出 | `true` |
| `closeWindowOnLongPress` | 启用 ⌘W 长按关闭窗口 | `true` |
| `holdDuration` | 长按时间（秒） | `1.0` |
| `launchAtLogin` | 开机自启 | `false` |
| `showProgressAnimation` | 显示进度环 | `true` |
| `language` | 界面语言 | `en` |
| `excludedApps` | 排除的应用列表 | Finder、终端 |

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
- macOS 14.0+

### 构建命令

```bash
# 开发构建
swift build

# 发布 .app 包（ad-hoc 签名）
./build.sh
```

## 故障排除

### 重新构建后辅助功能权限重置

ad-hoc 签名的应用在二进制文件发生变化后会失去辅助功能信任。每次重新构建后，请前往**系统设置 → 隐私与安全性 → 辅助功能**，移除 SlowQuitApps 后重新添加，再重启应用。

### 应用无法拦截 ⌘Q 或 ⌘W

1. 确认辅助功能权限已授予
2. 在设置中点击**重启应用**
3. 确保目标应用不在排除列表中
4. 检查菜单栏中对应的开关（⌘Q 或 ⌘W）是否已启用

## 贡献

欢迎贡献！请随时提交 issue 或 pull request。

## 许可证

MIT 许可证 — 详见 [LICENSE](LICENSE)

---

<p align="center">
  用 ❤️ 为 macOS 打造
</p>
