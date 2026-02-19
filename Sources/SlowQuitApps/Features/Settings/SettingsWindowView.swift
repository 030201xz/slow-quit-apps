import SwiftUI

/// Settings window root view
/// Uses Apple's recommended TabView pattern for settings
struct SettingsWindowView: View {
    @State private var i18n = I18n.shared

    var body: some View {
        // Access currentLanguage to trigger refresh on language change
        let _ = i18n.currentLanguage

        settingsContent
            .scenePadding()
    }

    // MARK: - Adaptive TabView

    @ViewBuilder
    private var settingsContent: some View {
        if #available(macOS 15.0, *) {
            // macOS 15+: new Tab API
            TabView {
                Tab(t("settings.tabs.general"), systemImage: "gearshape") {
                    GeneralSettingsView()
                        .fixedSize()
                }

                Tab(t("settings.tabs.appList"), systemImage: "app.badge.checkmark") {
                    AppListSettingsView()
                        .frame(minWidth: 450, minHeight: 300)
                }

                Tab(t("settings.tabs.about"), systemImage: "info.circle") {
                    AboutView()
                        .fixedSize()
                }
            }
        } else {
            // macOS 14: legacy tabItem API
            TabView {
                GeneralSettingsView()
                    .fixedSize()
                    .tabItem {
                        Label(t("settings.tabs.general"), systemImage: "gearshape")
                    }

                AppListSettingsView()
                    .frame(minWidth: 450, minHeight: 300)
                    .tabItem {
                        Label(t("settings.tabs.appList"), systemImage: "app.badge.checkmark")
                    }

                AboutView()
                    .fixedSize()
                    .tabItem {
                        Label(t("settings.tabs.about"), systemImage: "info.circle")
                    }
            }
        }
    }
}
