import AppKit
import SwiftUI

@MainActor
final class AppController {
	static let shared = AppController()

	let dictation = DictationController()
	private let hotkey = HotkeyManager()
	private var onboardingWindow: NSWindow?
	private var settingsWindow: NSWindow?

	func start() {
		hotkey.onKeyDown = {
			Task { @MainActor in AppController.shared.dictation.pressBegan() }
		}
		hotkey.onKeyUp = {
			Task { @MainActor in AppController.shared.dictation.pressEnded() }
		}
		hotkey.onCancel = {
			Task { @MainActor in AppController.shared.dictation.pressCancelled() }
		}
		startHotkeyIfPermitted()
		if !Prefs.hasCompletedOnboarding || !Permissions.allGranted {
			showOnboarding()
		}
		Task { await dictation.preloadModel() }
		if Prefs.cleanupEnabled {
			Task { await OllamaClient.warmup() }
		}
	}

	func startHotkeyIfPermitted() {
		guard Permissions.inputMonitoringGranted, !hotkey.isRunning else { return }
		if hotkey.start() {
			print("[murmur] hotkey listener active (\(Prefs.hotkeyOption.displayName))")
		} else {
			AppState.shared.setWarning("Could not start hotkey listener — check Input Monitoring")
		}
	}

	func showOnboarding() {
		if onboardingWindow == nil {
			let window = NSWindow(
				contentRect: .zero,
				styleMask: [.titled, .closable],
				backing: .buffered,
				defer: false
			)
			window.title = "Murmur Setup"
			window.contentViewController = NSHostingController(rootView: OnboardingView())
			window.isReleasedWhenClosed = false
			window.center()
			onboardingWindow = window
		}
		NSApp.activate(ignoringOtherApps: true)
		onboardingWindow?.makeKeyAndOrderFront(nil)
	}

	func closeOnboarding() {
		onboardingWindow?.orderOut(nil)
	}

	func showSettings() {
		if settingsWindow == nil {
			let window = NSWindow(
				contentRect: .zero,
				styleMask: [.titled, .closable, .miniaturizable],
				backing: .buffered,
				defer: false
			)
			window.title = "Murmur Settings"
			window.contentViewController = NSHostingController(rootView: SettingsView())
			window.isReleasedWhenClosed = false
			window.center()
			settingsWindow = window
		}
		NSApp.activate(ignoringOtherApps: true)
		settingsWindow?.makeKeyAndOrderFront(nil)
	}
}
