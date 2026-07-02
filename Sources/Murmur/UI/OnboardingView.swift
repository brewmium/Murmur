import SwiftUI

struct OnboardingView: View {
	@State private var microphone = Permissions.microphoneGranted
	@State private var inputMonitoring = Permissions.inputMonitoringGranted
	@State private var accessibility = Permissions.accessibilityGranted

	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	private var allGranted: Bool { microphone && inputMonitoring && accessibility }

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Welcome to Murmur")
				.font(.title.bold())
			Text("Hold **\(Prefs.hotkeyOption.displayName)** anywhere, speak, release — your words are typed into the focused app. Everything runs on this Mac; nothing leaves it.")
				.fixedSize(horizontal: false, vertical: true)

			PermissionRow(
				title: "Microphone",
				detail: "Records your voice while the key is held.",
				granted: microphone,
				request: { Task { _ = await Permissions.requestMicrophone() } },
				openPane: { Permissions.openSystemSettings(.microphone) }
			)
			PermissionRow(
				title: "Input Monitoring",
				detail: "Detects the push-to-talk key in any app.",
				granted: inputMonitoring,
				request: { Permissions.requestInputMonitoring() },
				openPane: { Permissions.openSystemSettings(.inputMonitoring) }
			)
			PermissionRow(
				title: "Accessibility",
				detail: "Pastes the transcript into the app you're using.",
				granted: accessibility,
				request: { Permissions.requestAccessibility() },
				openPane: { Permissions.openSystemSettings(.accessibility) }
			)

			Text("macOS may require relaunching Murmur after granting Input Monitoring or Accessibility.")
				.font(.caption)
				.foregroundStyle(.secondary)

			HStack {
				Spacer()
				Button(allGranted ? "Done" : "Skip for Now") { finish() }
					.keyboardShortcut(.defaultAction)
			}
		}
		.padding(24)
		.frame(width: 480)
		.onReceive(timer) { _ in refresh() }
	}

	private func refresh() {
		microphone = Permissions.microphoneGranted
		inputMonitoring = Permissions.inputMonitoringGranted
		accessibility = Permissions.accessibilityGranted
	}

	private func finish() {
		Prefs.hasCompletedOnboarding = true
		AppController.shared.startHotkeyIfPermitted()
		AppController.shared.closeOnboarding()
	}
}

private struct PermissionRow: View {
	let title: String
	let detail: String
	let granted: Bool
	let request: () -> Void
	let openPane: () -> Void

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: granted ? "checkmark.circle.fill" : "circle")
				.foregroundStyle(granted ? .green : .secondary)
				.font(.title3)
			VStack(alignment: .leading, spacing: 2) {
				Text(title).font(.headline)
				Text(detail).font(.caption).foregroundStyle(.secondary)
			}
			Spacer()
			if !granted {
				Button("Grant", action: request)
				Button("Open Settings", action: openPane)
			}
		}
		.padding(10)
		.background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.05)))
	}
}
