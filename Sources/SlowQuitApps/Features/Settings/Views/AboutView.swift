import SwiftUI

/// 关于页面视图
struct AboutView: View {
    @State private var i18n = I18n.shared
    
    var body: some View {
        // 通过访问 currentLanguage 确保语言变化时视图刷新
        let _ = i18n.currentLanguage
        
        VStack(spacing: 20) {
            // 应用图标
            Image(systemName: "hand.raised.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            // 应用名称和版本
            VStack(spacing: 4) {
                Text(t("app.name"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(t("settings.about.version")) \(Constants.App.version)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // 应用描述
            Text(t("app.description"))
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
                .padding(.horizontal, 40)
            
            // 功能说明
            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "keyboard", text: t("settings.about.features.monitor"))
                FeatureRow(icon: "timer", text: t("settings.about.features.longPress"))
                FeatureRow(icon: "list.bullet", text: t("settings.about.features.whitelist"))
                FeatureRow(icon: "gearshape", text: t("settings.about.features.customize"))
            }
            
            // 版权信息
            Text(t("settings.about.copyright"))
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
        }
        .padding()
    }
}

/// 功能行
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 13))
        }
    }
}

