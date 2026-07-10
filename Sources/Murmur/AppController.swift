import AppKit
import SwiftUI

@MainActor
final class AppController {
	static let shared = AppController()

	let dictation = DictationController()
	private let hotkey = HotkeyManager()
	private var statusItem: StatusItemController?
	private var onboardingWindow: NSWindow?
	private var settingsWindow: NSWindow?

	func start() {
		statusItem = StatusItemController()
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
		Task { await checkOllamaFirstRun() }
	}

	/// First launch after onboarding, exactly once: if cleanup is on but Ollama
	/// isn't reachable, offer to switch to plain dictation or set Ollama up.
	private func checkOllamaFirstRun() async {
		guard Prefs.hasCompletedOnboarding,
			  Prefs.cleanupEnabled,
			  !Prefs.didAskAboutOllama else { return }
		let reachable = await OllamaClient.isReachable()
		guard !reachable else { return }
		presentOllamaFirstRunPrompt()
	}

	private func presentOllamaFirstRunPrompt() {
		Prefs.didAskAboutOllama = true
		let alert = NSAlert()
		alert.messageText = "Set up local cleanup?"
		alert.informativeText = """
		Murmur can polish your dictation with a local LLM through Ollama - dropping \
		filler words like "um," fixing punctuation, and formatting lists. Ollama \
		isn't running right now.

		Murmur still works great without it: your speech is transcribed and inserted \
		exactly as spoken. You can turn cleanup on any time in Settings.
		"""
		alert.addButton(withTitle: "Use Plain Dictation")
		alert.addButton(withTitle: "Set Up Ollama…")
		NSApp.activate(ignoringOtherApps: true)
		if alert.runModal() == .alertFirstButtonReturn {
			UserDefaults.standard.set(false, forKey: PrefKey.cleanupEnabled)
		} else if let url = URL(string: "https://ollama.com/download") {
			NSWorkspace.shared.open(url)
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
