import SwiftUI

/// About tab view
struct AboutView: View {
    @State private var i18n = I18n.shared

    var body: some View {
        // Access currentLanguage to trigger refresh on language change
        let _ = i18n.currentLanguage

        VStack(spacing: 20) {
            // App icon
            Image(systemName: "hand.raised.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            // App name and version
            VStack(spacing: 4) {
                Text(t("app.name"))
                    .font(.title2)
                    .fontWeight(.bold)

                Text("\(t("settings.about.version")) \(Constants.App.version)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // App description
            Text(t("app.description"))
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Divider()
                .padding(.horizontal, 40)

            // Feature list
            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "keyboard", text: t("settings.about.features.monitor"))
                FeatureRow(icon: "timer", text: t("settings.about.features.longPress"))
                FeatureRow(icon: "list.bullet", text: t("settings.about.features.whitelist"))
                FeatureRow(icon: "gearshape", text: t("settings.about.features.customize"))
            }

            // Copyright
            Text(t("settings.about.copyright"))
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
        }
        .padding()
    }
}

/// Feature row
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
