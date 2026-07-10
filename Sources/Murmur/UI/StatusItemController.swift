import AppKit
import Combine

/// AppKit-backed menu bar item. Replaces SwiftUI `MenuBarExtra`, whose view-graph
/// churn on every @Published change drove intermittent menu-bar rendering crashes
/// (EXC_BAD_ACCESS in DesignLibrary's HStack update) during multi-day sessions.
///
/// The icon is updated imperatively from `phase`/`warning`; the menu is rebuilt
/// lazily each time it opens, so nothing observes the frequently-changing state.
@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
	private let statusItem: NSStatusItem
	private let state = AppState.shared
	private var cancellables: Set<AnyCancellable> = []

	override init() {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		super.init()

		statusItem.button?.imagePosition = .imageOnly
		refreshIcon()

		let menu = NSMenu()
		menu.delegate = self
		statusItem.menu = menu

		// Only `phase` and `warning` feed `menuSymbol`; observe just those so the
		// icon reflects state live without pulling the rest of AppState in.
		state.$phase.combineLatest(state.$warning)
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in self?.refreshIcon() }
			.store(in: &cancellables)
	}

	private func refreshIcon() {
		let image = NSImage(systemSymbolName: state.menuSymbol, accessibilityDescription: "Murmur")
		image?.isTemplate = true
		statusItem.button?.image = image
	}

	// MARK: NSMenuDelegate — rebuild fresh on open so status/transcript are current.

	func menuNeedsUpdate(_ menu: NSMenu) {
		menu.removeAllItems()

		menu.addItem(infoItem(state.statusLine))
		if let warning = state.warning {
			menu.addItem(infoItem("⚠️ \(warning)"))
		}
		menu.addItem(.separator())

		if !state.lastTranscript.isEmpty {
			menu.addItem(infoItem(truncatedTranscript))
			menu.addItem(actionItem("Copy Last Transcript", #selector(copyTranscript)))
			menu.addItem(.separator())
		}

		menu.addItem(actionItem("Settings…", #selector(openSettings)))
		menu.addItem(actionItem("Permissions & Setup…", #selector(openOnboarding)))
		menu.addItem(.separator())
		menu.addItem(actionItem("Quit Murmur", #selector(quit), key: "q"))
	}

	private func infoItem(_ title: String) -> NSMenuItem {
		// nil action → auto-disabled (grayed) by NSMenu, matching the SwiftUI Text rows.
		NSMenuItem(title: title, action: nil, keyEquivalent: "")
	}

	private func actionItem(_ title: String, _ action: Selector, key: String = "") -> NSMenuItem {
		let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
		item.target = self
		return item
	}

	private var truncatedTranscript: String {
		let text = state.lastTranscript
		return text.count > 48 ? "Last: \(text.prefix(48))…" : "Last: \(text)"
	}

	@objc private func copyTranscript() {
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(state.lastTranscript, forType: .string)
	}

	@objc private func openSettings() { AppController.shared.showSettings() }
	@objc private func openOnboarding() { AppController.shared.showOnboarding() }
	@objc private func quit() { NSApp.terminate(nil) }
}
