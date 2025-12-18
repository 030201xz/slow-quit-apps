#!/usr/bin/env swift
// SlowQuitApps 图标生成脚本
// 生成带有 Q 字母和圆形进度条的简洁图标

import Cocoa
import Foundation

// 图标尺寸列表（macOS icns 需要的所有尺寸）
let sizes: [(size: Int, scale: Int, suffix: String)] = [
    (16, 1, "16x16"),
    (16, 2, "16x16@2x"),
    (32, 1, "32x32"),
    (32, 2, "32x32@2x"),
    (128, 1, "128x128"),
    (128, 2, "128x128@2x"),
    (256, 1, "256x256"),
    (256, 2, "256x256@2x"),
    (512, 1, "512x512"),
    (512, 2, "512x512@2x")
]

/// 生成单个尺寸的图标
/// 设计理念：Apple 风格 - 简洁、扁平、高辨识度
func generateIcon(size: Int, scale: Int) -> NSImage {
    let pixelSize = size * scale
    let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let rect = CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize)
    let padding = CGFloat(pixelSize) * 0.08
    let mainRect = rect.insetBy(dx: padding, dy: padding)
    
    // 背景 - 圆角矩形，macOS 系统蓝色
    let cornerRadius = CGFloat(pixelSize) * 0.22
    let bgPath = NSBezierPath(roundedRect: mainRect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    // 纯净的系统蓝色背景（Apple 标准蓝）
    let systemBlue = NSColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
    systemBlue.setFill()
    bgPath.fill()
    
    // 中心圆环背景
    let center = CGPoint(x: CGFloat(pixelSize) / 2, y: CGFloat(pixelSize) / 2)
    let ringRadius = CGFloat(pixelSize) * 0.28
    let ringWidth = CGFloat(pixelSize) * 0.05
    
    // 圆环背景（半透明白色轨道）
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.25).cgColor)
    context.setLineWidth(ringWidth)
    context.addArc(center: center, radius: ringRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    context.strokePath()
    
    // 进度圆弧（75% 白色）
    context.setStrokeColor(NSColor.white.cgColor)
    context.setLineWidth(ringWidth)
    context.setLineCap(.round)
    let startAngle = CGFloat.pi / 2  // 从顶部开始
    let endAngle = startAngle - CGFloat.pi * 1.5  // 顺时针 75%
    context.addArc(center: center, radius: ringRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    context.strokePath()
    
    // 中心 Q 字母（SF Pro 风格）
    let fontSize = CGFloat(pixelSize) * 0.30
    let font = NSFont.systemFont(ofSize: fontSize, weight: .semibold)
    let qText = "Q" as NSString
    
    let textAttributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white
    ]
    
    let textSize = qText.size(withAttributes: textAttributes)
    let textRect = CGRect(
        x: center.x - textSize.width / 2,
        y: center.y - textSize.height / 2,
        width: textSize.width,
        height: textSize.height
    )
    qText.draw(in: textRect, withAttributes: textAttributes)
    
    image.unlockFocus()
    return image
}

/// 将 NSImage 保存为 PNG
func savePNG(image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("❌ 无法生成 PNG: \(path)")
        return
    }
    
    do {
        try pngData.write(to: URL(fileURLWithPath: path))
    } catch {
        print("❌ 保存失败: \(error)")
    }
}

// 主程序
print("🎨 开始生成 SlowQuitApps 图标...")

// 创建临时图标集目录
let iconsetDir = "AppIcon.iconset"
try? FileManager.default.removeItem(atPath: iconsetDir)
try? FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

// 生成各尺寸图标
for (size, scale, suffix) in sizes {
    let image = generateIcon(size: size, scale: scale)
    let filename = "\(iconsetDir)/icon_\(suffix).png"
    savePNG(image: image, to: filename)
    print("✓ 生成 \(suffix)")
}

// 使用 iconutil 转换为 icns
print("📦 转换为 icns 格式...")
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetDir, "-o", "BuildAssets/AppIcon.icns"]

do {
    try process.run()
    process.waitUntilExit()
    
    if process.terminationStatus == 0 {
        print("✅ 图标已生成: BuildAssets/AppIcon.icns")
    } else {
        print("❌ iconutil 失败")
    }
} catch {
    print("❌ 执行失败: \(error)")
}

// 清理临时文件
try? FileManager.default.removeItem(atPath: iconsetDir)
print("🧹 已清理临时文件")
