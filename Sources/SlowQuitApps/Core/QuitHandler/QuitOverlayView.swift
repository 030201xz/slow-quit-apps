import SwiftUI

/// Quit progress overlay view
/// Shows a circular progress ring and app name
struct QuitOverlayView: View {
    /// Progress value (0.0 – 1.0)
    let progress: Double

    /// App name
    let appName: String

    /// Whether to animate progress changes
    let animated: Bool

    /// Key label shown in the ring ("Q" or "W")
    let keyLabel: String

    var body: some View {
        VStack(spacing: 16) {
            // Progress ring
            progressRing

            // App name
            Text(appName)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(24)
        .modifier(GlassBackgroundModifier())
    }

    /// Progress ring view
    private var progressRing: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.primary.opacity(0.15),
                    lineWidth: 5
                )

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressGradient,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(animated ? .easeOut(duration: 0.08) : .none, value: progress)

            // Key character in center
            Text(keyLabel)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(width: 56, height: 56)
    }

    /// Progress gradient color
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

// MARK: - Glass Background

/// Glass effect background
/// Uses Liquid Glass on macOS 26+, falls back to ultraThinMaterial on earlier versions
private struct GlassBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if compiler(>=6.1) && canImport(SwiftUI, _version: 7)
        if #available(macOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
        } else {
            fallbackBackground(content)
        }
        #else
        fallbackBackground(content)
        #endif
    }

    @ViewBuilder
    private func fallbackBackground(_ content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
            )
    }
}
