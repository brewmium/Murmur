import AppKit
import AVFoundation
import ApplicationServices
import CoreGraphics

enum Permissions {
	enum Pane: String {
		case microphone = "Privacy_Microphone"
		case inputMonitoring = "Privacy_ListenEvent"
		case accessibility = "Privacy_Accessibility"
	}

	static var microphoneGranted: Bool {
		AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
	}

	static var inputMonitoringGranted: Bool {
		CGPreflightListenEventAccess()
	}

	static var accessibilityGranted: Bool {
		AXIsProcessTrusted() || CGPreflightPostEventAccess()
	}

	static var allGranted: Bool {
		microphoneGranted && inputMonitoringGranted && accessibilityGranted
	}

	static func requestMicrophone() async -> Bool {
		await AVCaptureDevice.requestAccess(for: .audio)
	}

	static func requestInputMonitoring() {
		CGRequestListenEventAccess()
	}

	static func requestAccessibility() {
		let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
		AXIsProcessTrustedWithOptions(options)
	}

	static func openSystemSettings(_ pane: Pane) {
		let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(pane.rawValue)")!
		NSWorkspace.shared.open(url)
	}
}
