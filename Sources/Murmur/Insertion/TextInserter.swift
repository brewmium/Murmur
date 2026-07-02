import AppKit
import CoreGraphics

/// Inserts text into the focused app: snapshot the pasteboard, write the text,
/// synthesize Cmd+V, then restore the snapshot.
enum TextInserter {
	@MainActor
	static func insert(_ text: String) async {
		let pasteboard = NSPasteboard.general

		guard Permissions.accessibilityGranted else {
			// Can't synthesize keystrokes — leave the text on the clipboard instead.
			pasteboard.clearContents()
			pasteboard.setString(text, forType: .string)
			AppState.shared.setWarning("Accessibility not granted — transcript copied to clipboard")
			return
		}

		let saved: [[NSPasteboard.PasteboardType: Data]] = (pasteboard.pasteboardItems ?? []).map { item in
			var snapshot: [NSPasteboard.PasteboardType: Data] = [:]
			for type in item.types {
				if let data = item.data(forType: type) { snapshot[type] = data }
			}
			return snapshot
		}

		pasteboard.clearContents()
		pasteboard.setString(text, forType: .string)

		// If the push-to-talk modifier is still physically held, Cmd+V would become
		// Cmd+Opt+V (or similar) in the target app — wait for a clean slate.
		await waitForModifierRelease()
		postCommandV()

		try? await Task.sleep(for: .milliseconds(400))

		pasteboard.clearContents()
		if !saved.isEmpty {
			let items = saved.map { snapshot -> NSPasteboardItem in
				let item = NSPasteboardItem()
				for (type, data) in snapshot { item.setData(data, forType: type) }
				return item
			}
			pasteboard.writeObjects(items)
		}
	}

	private static func waitForModifierRelease() async {
		let blocking: CGEventFlags = [.maskCommand, .maskAlternate, .maskControl, .maskShift]
		for _ in 0..<40 {
			let flags = CGEventSource.flagsState(.combinedSessionState)
			if flags.intersection(blocking).isEmpty { return }
			try? await Task.sleep(for: .milliseconds(25))
		}
	}

	private static func postCommandV() {
		guard let source = CGEventSource(stateID: .combinedSessionState) else { return }
		let vKeyCode: CGKeyCode = 9
		let down = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
		down?.flags = .maskCommand
		let up = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
		up?.flags = .maskCommand
		down?.post(tap: .cghidEventTap)
		up?.post(tap: .cghidEventTap)
	}
}
