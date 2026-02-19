import SwiftUI

/// App entry point
/// A macOS tool that prevents accidental ⌘Q / ⌘W
@main
struct SlowQuitAppsApp: App {
    /// App delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar app, no main window needed
        Settings {
            SettingsWindowView()
        }
    }
}
