#!/bin/bash
# Build script for SlowQuitApps
# Produces a signed macOS .app bundle

set -e

# Configuration
APP_NAME="SlowQuitApps"
BUNDLE_ID="com.slowquitapps.app"
VERSION="1.1.0"
BUILD_DIR=".build/release"
APP_DIR="build/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔨 Building ${APP_NAME}...${NC}"

# 1. Clean previous build output
echo -e "${YELLOW}📦 Cleaning old build artifacts...${NC}"
rm -rf build/
mkdir -p build/

# 2. Compile release build
echo -e "${YELLOW}⚙️  Compiling release build...${NC}"
swift build -c release

# 3. Create .app directory structure
echo -e "${YELLOW}📁 Creating app bundle structure...${NC}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

# 4. Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${APP_DIR}/Contents/MacOS/"

# 5. Copy locale resource bundle (required for localization)
if [ -d "${BUILD_DIR}/${APP_NAME}_${APP_NAME}.bundle" ]; then
    cp -R "${BUILD_DIR}/${APP_NAME}_${APP_NAME}.bundle" "${APP_DIR}/Contents/Resources/"
    echo -e "${GREEN}✓ Locale bundle copied${NC}"
else
    echo -e "${RED}❌ Locale bundle not found: ${BUILD_DIR}/${APP_NAME}_${APP_NAME}.bundle${NC}"
    exit 1
fi

# 6. Write Info.plist
cat > "${APP_DIR}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
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
    <key>NSAccessibilityUsageDescription</key>
    <string>Slow Quit Apps needs accessibility access to intercept Cmd+Q and Cmd+W.</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>Slow Quit Apps needs to control other apps to delay quitting.</string>
</dict>
</plist>
EOF

# 7. Write PkgInfo
echo -n "APPL????" > "${APP_DIR}/Contents/PkgInfo"

# 8. Copy app icon if present
if [ -f "BuildAssets/AppIcon.icns" ]; then
    cp "BuildAssets/AppIcon.icns" "${APP_DIR}/Contents/Resources/"
    echo -e "${GREEN}✓ App icon copied${NC}"
fi

# 9. Ad-hoc code sign
echo -e "${YELLOW}🔐 Signing (ad-hoc)...${NC}"
codesign --force --deep --sign - "${APP_DIR}"

# 10. Verify signature
echo -e "${YELLOW}🔍 Verifying signature...${NC}"
codesign --verify --verbose=2 "${APP_DIR}" 2>&1 || true

# 11. Create DMG (only if create-dmg tool is installed)
if command -v create-dmg &> /dev/null; then
    echo -e "${YELLOW}📀 Creating DMG...${NC}"

    DMG_TEMP="build/dmg_temp"
    mkdir -p "${DMG_TEMP}"
    cp -R "${APP_DIR}" "${DMG_TEMP}/"
    ln -s /Applications "${DMG_TEMP}/Applications"

    DOCS_DIR="BuildAssets/Docs"
    if [ -d "${DOCS_DIR}" ]; then
        echo -e "${YELLOW}📖 Copying documentation...${NC}"
        mkdir -p "${DMG_TEMP}/Documentation"
        cp "${DOCS_DIR}/README-en.md"    "${DMG_TEMP}/Documentation/README (English).md"    2>/dev/null || true
        cp "${DOCS_DIR}/README-zh-CN.md" "${DMG_TEMP}/Documentation/README (Chinese).md"    2>/dev/null || true
        cp "${DOCS_DIR}/README-ja.md"    "${DMG_TEMP}/Documentation/README (Japanese).md"   2>/dev/null || true
        cp "${DOCS_DIR}/README-ru.md"    "${DMG_TEMP}/Documentation/README (Russian).md"    2>/dev/null || true
        echo -e "${GREEN}✓ Documentation copied${NC}"
    fi

    hdiutil create -volname "${APP_NAME}" \
        -srcfolder "${DMG_TEMP}" \
        -ov -format UDZO \
        "build/${DMG_NAME}"

    rm -rf "${DMG_TEMP}"
    echo -e "${GREEN}✓ DMG created: build/${DMG_NAME}${NC}"
fi

# 12. Summary
SIZE=$(du -sh "${APP_DIR}" | cut -f1)

echo ""
echo -e "${GREEN}✅ Build complete!${NC}"
echo -e "   App: ${APP_DIR} (${SIZE})"
if [ -f "build/${DMG_NAME}" ]; then
    DMG_SIZE=$(du -sh "build/${DMG_NAME}" | cut -f1)
    echo -e "   DMG: build/${DMG_NAME} (${DMG_SIZE})"
fi
echo ""
echo -e "${YELLOW}💡 Usage:${NC}"
echo "   • Copy ${APP_DIR} to /Applications and launch"
echo "   • Grant accessibility permission on first run"
echo "   • The app runs as a menu bar icon"
echo ""

open build/
