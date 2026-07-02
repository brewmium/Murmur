import SwiftUI

struct MenuView: View {
	@ObservedObject private var state = AppState.shared

	var body: some View {
		Text(state.statusLine)
		if let warning = state.warning {
			Text("⚠️ \(warning)")
		}
		Divider()
		if !state.lastTranscript.isEmpty {
			Text(truncatedTranscript)
			Button("Copy Last Transcript") {
				let pasteboard = NSPasteboard.general
				pasteboard.clearContents()
				pasteboard.setString(state.lastTranscript, forType: .string)
			}
			Divider()
		}
		Button("Settings…") { AppController.shared.showSettings() }
		Button("Permissions & Setup…") { AppController.shared.showOnboarding() }
		Divider()
		Button("Quit Murmur") { NSApp.terminate(nil) }
			.keyboardShortcut("q")
	}

	private var truncatedTranscript: String {
		let text = state.lastTranscript
		return text.count > 48 ? "Last: \(text.prefix(48))…" : "Last: \(text)"
	}
}
