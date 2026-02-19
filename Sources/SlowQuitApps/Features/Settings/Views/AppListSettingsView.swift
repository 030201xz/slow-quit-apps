import SwiftUI

/// App list settings view
/// Manages the excluded apps list
struct AppListSettingsView: View {
    @Bindable var appState = AppState.shared
    @State private var i18n = I18n.shared
    @State private var showingAppPicker = false

    var body: some View {
        // Access currentLanguage to trigger refresh on language change
        let _ = i18n.currentLanguage

        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(t("settings.appList.title"))
                        .font(.headline)
                    Text(t("settings.appList.description"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showingAppPicker = true
                } label: {
                    Label(t("settings.appList.add"), systemImage: "plus")
                }
            }
            .padding()

            Divider()

            // App list
            if appState.excludedApps.isEmpty {
                emptyStateView
            } else {
                appListView
            }
        }
        .sheet(isPresented: $showingAppPicker) {
            InstalledAppPicker { app in
                appState.addExcludedApp(app)
                showingAppPicker = false
            } onCancel: {
                showingAppPicker = false
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            t("settings.appList.empty"),
            systemImage: "app.badge.checkmark",
            description: Text(t("settings.appList.emptyDescription"))
        )
    }

    private var appListView: some View {
        List {
            ForEach(appState.excludedApps) { app in
                HStack(spacing: 12) {
                    // Load icon the same way as InstalledAppRow
                    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleIdentifier) {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                            .resizable()
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "app.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.name)
                            .font(.system(size: 13, weight: .medium))

                        Text(app.bundleIdentifier)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(role: .destructive) {
                        appState.removeExcludedApp(app)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.inset)
    }
}

// MARK: - App List Row

struct AppListRow: View {
    let app: ManagedApp
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AppIconView(bundleIdentifier: app.bundleIdentifier)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 13, weight: .medium))

                Text(app.bundleIdentifier)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - App Icon View

struct AppIconView: View {
    let bundleIdentifier: String

    var body: some View {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                .resizable()
        } else {
            Image(systemName: "app.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Installed App Picker

struct InstalledAppPicker: View {
    let onSelect: (ManagedApp) -> Void
    let onCancel: () -> Void

    @State private var i18n = I18n.shared
    @State private var searchText = ""
    @State private var installedApps: [AppInfo] = []
    @State private var isLoading = true

    var body: some View {
        let _ = i18n.currentLanguage

        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text(t("settings.appList.selectApp"))
                    .font(.headline)
                Spacer()
                Button(t("settings.appList.cancel"), action: onCancel)
            }
            .padding()

            // Search field
            TextField(t("settings.appList.search"), text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Divider()
                .padding(.top, 8)

            // App list
            if isLoading {
                ProgressView(t("settings.appList.loading"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredApps, id: \.bundleIdentifier) { app in
                    Button {
                        selectApp(app)
                    } label: {
                        InstalledAppRow(app: app)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.inset)
            }
        }
        .frame(width: 400, height: 500)
        .onAppear {
            loadInstalledApps()
        }
    }

    private var filteredApps: [AppInfo] {
        guard !searchText.isEmpty else { return installedApps }
        let query = searchText.lowercased()
        return installedApps.filter {
            $0.name.lowercased().contains(query) ||
            $0.bundleIdentifier.lowercased().contains(query)
        }
    }

    private func selectApp(_ app: AppInfo) {
        let managedApp = ManagedApp(
            bundleIdentifier: app.bundleIdentifier,
            name: app.name,
            iconPath: nil,
            isExcluded: true
        )
        onSelect(managedApp)
    }

    /// Load installed apps
    private func loadInstalledApps() {
        isLoading = true

        // Scan apps on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let appURLs = findInstalledApplications()

            var apps: [AppInfo] = []
            for url in appURLs {
                guard let bundle = Bundle(url: url),
                      let bundleId = bundle.bundleIdentifier else { continue }

                let name = bundle.infoDictionary?["CFBundleName"] as? String
                    ?? bundle.infoDictionary?["CFBundleDisplayName"] as? String
                    ?? url.deletingPathExtension().lastPathComponent

                apps.append(AppInfo(bundleIdentifier: bundleId, name: name, url: url))
            }

            // Sort by name
            apps.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

            // Update UI on main thread
            DispatchQueue.main.async {
                self.installedApps = apps
                self.isLoading = false
            }
        }
    }
}

// MARK: - App Scanner

/// Scan installed applications (thread-safe)
private func findInstalledApplications() -> [URL] {
    var urls: [URL] = []

    let searchPaths = [
        "/Applications",
        "/System/Applications",
        NSHomeDirectory() + "/Applications"
    ]

    let fileManager = FileManager.default

    for path in searchPaths {
        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.isApplicationKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { continue }

        for case let url as URL in enumerator {
            if url.pathExtension == "app" {
                urls.append(url)
            }
        }
    }

    return urls
}

// MARK: - App Info

struct AppInfo: Identifiable {
    let bundleIdentifier: String
    let name: String
    let url: URL

    var id: String { bundleIdentifier }
}

// MARK: - Installed App Row

struct InstalledAppRow: View {
    let app: AppInfo

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: app.url.path))
                .resizable()
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 13, weight: .medium))

                Text(app.bundleIdentifier)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
