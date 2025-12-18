#!/bin/bash
# SlowQuitApps 构建脚本
# 用于构建签名的 macOS .app 包

set -e

# 配置
APP_NAME="SlowQuitApps"
BUNDLE_ID="com.slowquitapps.app"
VERSION="1.0.0"
BUILD_DIR=".build/release"
APP_DIR="build/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔨 开始构建 ${APP_NAME}...${NC}"

# 1. 清理之前的构建
echo -e "${YELLOW}📦 清理旧的构建产物...${NC}"
rm -rf build/
mkdir -p build/

# 2. Release 模式构建
echo -e "${YELLOW}⚙️  编译 Release 版本...${NC}"
swift build -c release

# 3. 创建 .app 目录结构
echo -e "${YELLOW}📁 创建应用包结构...${NC}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

# 4. 复制可执行文件
cp "${BUILD_DIR}/${APP_NAME}" "${APP_DIR}/Contents/MacOS/"

# 5. 创建 Info.plist（关键：正确配置 GUI 应用）
cat > "${APP_DIR}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>Slow Quit Apps</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>Slow Quit Apps 需要控制其他应用以实现延迟退出功能。</string>
</dict>
</plist>
EOF

# 6. 创建 PkgInfo
echo -n "APPL????" > "${APP_DIR}/Contents/PkgInfo"

# 7. 如果存在图标，复制图标
if [ -f "BuildAssets/AppIcon.icns" ]; then
    cp "BuildAssets/AppIcon.icns" "${APP_DIR}/Contents/Resources/"
    echo -e "${GREEN}✓ 已复制应用图标${NC}"
fi

# 8. Ad-hoc 签名（本地开发使用）
echo -e "${YELLOW}🔐 进行 ad-hoc 签名...${NC}"
codesign --force --deep --sign - "${APP_DIR}"

# 9. 验证签名
echo -e "${YELLOW}🔍 验证签名...${NC}"
codesign --verify --verbose=2 "${APP_DIR}" 2>&1 || true

# 10. 创建 DMG 安装包（可选）
if command -v create-dmg &> /dev/null || command -v hdiutil &> /dev/null; then
    echo -e "${YELLOW}📀 创建 DMG 安装包...${NC}"
    
    # 创建临时目录
    DMG_TEMP="build/dmg_temp"
    mkdir -p "${DMG_TEMP}"
    cp -R "${APP_DIR}" "${DMG_TEMP}/"
    
    # 创建指向 Applications 的符号链接
    ln -s /Applications "${DMG_TEMP}/Applications"
    
    # 复制多语言安装文档
    DOCS_DIR="BuildAssets/Docs"
    if [ -d "${DOCS_DIR}" ]; then
        echo -e "${YELLOW}📖 复制安装文档...${NC}"
        mkdir -p "${DMG_TEMP}/Documentation"
        cp "${DOCS_DIR}/README-en.md" "${DMG_TEMP}/Documentation/README (English).md" 2>/dev/null || true
        cp "${DOCS_DIR}/README-zh-CN.md" "${DMG_TEMP}/Documentation/安装指南 (中文).md" 2>/dev/null || true
        cp "${DOCS_DIR}/README-ja.md" "${DMG_TEMP}/Documentation/インストールガイド (日本語).md" 2>/dev/null || true
        cp "${DOCS_DIR}/README-ru.md" "${DMG_TEMP}/Documentation/Руководство (Русский).md" 2>/dev/null || true
        echo -e "${GREEN}✓ 已复制多语言文档${NC}"
    fi
    
    # 使用 hdiutil 创建 DMG
    hdiutil create -volname "${APP_NAME}" \
        -srcfolder "${DMG_TEMP}" \
        -ov -format UDZO \
        "build/${DMG_NAME}"
    
    # 清理临时目录
    rm -rf "${DMG_TEMP}"
    
    echo -e "${GREEN}✓ DMG 已创建: build/${DMG_NAME}${NC}"
fi

# 11. 获取最终文件大小
SIZE=$(du -sh "${APP_DIR}" | cut -f1)

echo ""
echo -e "${GREEN}✅ 构建完成！${NC}"
echo -e "   应用位置: ${APP_DIR}"
echo -e "   应用大小: ${SIZE}"
if [ -f "build/${DMG_NAME}" ]; then
    DMG_SIZE=$(du -sh "build/${DMG_NAME}" | cut -f1)
    echo -e "   DMG 位置: build/${DMG_NAME}"
    echo -e "   DMG 大小: ${DMG_SIZE}"
fi
echo ""
echo -e "${YELLOW}💡 使用说明:${NC}"
echo "   • 双击 ${APP_DIR} 或 DMG 安装后运行"
echo "   • 首次运行需要授予辅助功能权限"
echo "   • 应用会在菜单栏显示图标"
echo ""

# 打开构建目录
open build/
