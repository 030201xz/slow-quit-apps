import SwiftUI

/// 退出进度覆盖窗口视图
/// 显示环形进度条和应用名称
struct QuitOverlayView: View {
    /// 进度值 (0.0 - 1.0)
    let progress: Double
    
    /// 应用名称
    let appName: String
    
    /// 是否显示动画
    let animated: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // 环形进度条
            ZStack {
                // 背景圆环
                Circle()
                    .stroke(
                        Color.gray.opacity(0.3),
                        lineWidth: 4
                    )
                
                // 进度圆环
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(animated ? .linear(duration: 0.05) : .none, value: progress)
                
                // 中心 Q 字符
                Text("Q")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(width: 50, height: 50)
            
            // 应用名称
            Text(appName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(20)
        .background(backgroundView)
    }
    
    /// 进度条颜色（根据进度变化）
    private var progressColor: Color {
        if progress < 0.5 {
            return .blue
        } else if progress < 0.8 {
            return .orange
        } else {
            return .red
        }
    }
    
    /// 背景视图
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
