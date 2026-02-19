import SwiftUI
import UniformTypeIdentifiers

/// General settings view
struct GeneralSettingsView: View {
    @Bindable var appState = AppState.shared

    /// Triggers UI refresh on language change
    @State private var i18n = I18n.shared

    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var importError: String?

    /// Whether running inside a valid .app bundle
    private var isValidAppBundle: Bool {
        Bundle.main.bundleIdentifier != nil && Bundle.main.bundleURL.pathExtension == "app"
    }

    var body: some View {
        // Access currentLanguage to trigger refresh on language change
        let _ = i18n.currentLanguage

        Form {
            // Accessibility status (top)
            Section {
                AccessibilityStatusRow()
            }

            // Language
            Section {
                Picker(t("settings.language.title"), selection: $appState.language) {
                    ForEach(Language.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
            }

            // Feature toggles
            Section {
                Toggle(t("settings.general.enableLongPress"), isOn: $appState.quitOnLongPress)

                Toggle(t("settings.general.closeWindowOnLongPress"), isOn: $appState.closeWindowOnLongPress)

                VStack(alignment: .leading, spacing: 4) {
                    Toggle(t("settings.general.launchAtLogin"), isOn: $appState.launchAtLogin)
                        .disabled(!isValidAppBundle)

                    if !isValidAppBundle {
                        Text(t("settings.general.launchAtLoginDisabled"))
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                Toggle(t("settings.general.showProgressAnimation"), isOn: $appState.showProgressAnimation)
            }

            // Hold duration
            Section {
                LabeledContent(t("settings.general.holdDuration")) {
                    Text(String(format: "%.1f \(t("settings.general.seconds"))", appState.holdDuration))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: $appState.holdDuration,
                    in: Constants.Progress.minHoldDuration...Constants.Progress.maxHoldDuration,
                    step: 0.1
                )
            }

            // Config management
            Section(t("settings.general.configManagement")) {
                HStack {
                    Button(t("settings.general.export")) { showingExporter = true }
                    Divider().frame(height: 16)
                    Button(t("settings.general.import")) { showingImporter = true }
                }

                Button(t("settings.general.resetDefaults"), role: .destructive) {
                    appState.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .fileExporter(
            isPresented: $showingExporter,
            document: ConfigDocument(),
            contentType: .json,
            defaultFilename: "slow-quit-apps-config"
        ) { result in
            if case .failure(let error) = result {
                print("Export failed: \(error)")
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case .success(let url):
                do {
                    _ = url.startAccessingSecurityScopedResource()
                    defer { url.stopAccessingSecurityScopedResource() }
                    try appState.importConfig(from: url)
                } catch {
                    importError = error.localizedDescription
                }
            case .failure(let error):
                importError = error.localizedDescription
            }
        }
        .alert(t("settings.general.importFailed"), isPresented: .constant(importError != nil)) {
            Button(t("settings.general.ok")) { importError = nil }
        } message: {
            Text(importError ?? "")
        }
    }
}

// MARK: - Config Document (for export)

struct ConfigDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    init() {}

    init(configuration: ReadConfiguration) throws {
        // Reading from file is not needed
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let config = ConfigManager.shared.load()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Accessibility Status

struct AccessibilityStatusRow: View {
    @State private var isEnabled = AccessibilityManager.shared.isAccessibilityEnabled
    @State private var i18n = I18n.shared

    var body: some View {
        let _ = i18n.currentLanguage

        LabeledContent {
            if isEnabled {
                Text(t("accessibility.granted"))
                    .foregroundStyle(.green)
            } else {
                HStack(spacing: 8) {
                    Button(t("accessibility.openSettings")) {
                        AccessibilityManager.shared.openAccessibilitySettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button(t("accessibility.restartApp")) {
                        restartApplication()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        } label: {
            Label(
                t("settings.general.accessibilityStatus"),
                systemImage: isEnabled ? "checkmark.shield.fill" : "exclamationmark.shield"
            )
        }
        .foregroundStyle(isEnabled ? Color.primary : Color.orange)
        .onAppear {
            isEnabled = AccessibilityManager.shared.isAccessibilityEnabled
        }
    }

    /// Restart the app
    private func restartApplication() {
        guard let bundleURL = Bundle.main.bundleURL as URL? else { return }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-n", bundleURL.path]

        try? task.run()

        // Terminate current instance after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApplication.shared.terminate(nil)
        }
    }
}
