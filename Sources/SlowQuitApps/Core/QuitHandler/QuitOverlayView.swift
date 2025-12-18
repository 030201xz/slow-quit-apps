import SwiftUI

/// 退出进度覆盖窗口视图
/// 显示环形进度条和应用名称，使用 Liquid Glass 效果
struct QuitOverlayView: View {
    /// 进度值 (0.0 - 1.0)
    let progress: Double
    
    /// 应用名称
    let appName: String
    
    /// 是否显示动画
    let animated: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // 环形进度条
            progressRing
            
            // 应用名称
            Text(appName)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(24)
        .modifier(GlassBackgroundModifier())
    }
    
    /// 环形进度条视图
    private var progressRing: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(
                    Color.primary.opacity(0.15),
                    lineWidth: 5
                )
            
            // 进度圆环
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressGradient,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(animated ? .easeOut(duration: 0.08) : .none, value: progress)
            
            // 中心 Q 字符
            Text("Q")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(width: 56, height: 56)
    }
    
    /// 进度条渐变色
    private var progressGradient: AngularGradient {
        let colors: [Color] = switch progress {
        case ..<0.5:
            [.blue, .cyan]
        case ..<0.8:
            [.orange, .yellow]
        default:
            [.red, .pink]
        }
        
        return AngularGradient(
            colors: colors,
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * progress)
        )
    }
}

// MARK: - Liquid Glass 背景修饰器

/// 根据系统版本选择合适的玻璃效果
private struct GlassBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            // macOS 26+ 使用 Liquid Glass
            content
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
        } else {
            // 低版本使用 Material 效果
            content
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                )
        }
    }
}

