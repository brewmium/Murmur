import SwiftUI

@main
struct MurmurApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	@ObservedObject private var state = AppState.shared

	var body: some Scene {
		MenuBarExtra {
			MenuView()
		} label: {
			Image(systemName: state.menuSymbol)
		}
	}
}

final class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		Prefs.registerDefaults()
		if let path = TestMode.fileArgument() {
			TestMode.run(path: path)
			return
		}
		NSApp.setActivationPolicy(.accessory)
		AppController.shared.start()
	}
}
