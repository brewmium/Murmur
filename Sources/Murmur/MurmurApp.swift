import SwiftUI

@main
struct MurmurApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

	// The menu bar item is an AppKit NSStatusItem owned by AppController; this
	// app hosts no windows of its own, so the scene is an empty Settings stub.
	var body: some Scene {
		Settings { EmptyView() }
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
