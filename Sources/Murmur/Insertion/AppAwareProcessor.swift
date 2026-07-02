import AppKit

/// Adjusts final text based on the frontmost app: terminals and code editors get
/// no auto-capitalization and no trailing period; everything else gets a capital.
enum AppAwareProcessor {
	private static let codeApps: Set<String> = [
		"com.apple.Terminal",
		"com.googlecode.iterm2",
		"dev.warp.Warp-Stable",
		"dev.warp.Warp",
		"com.github.wez.wezterm",
		"net.kovidgoyal.kitty",
		"com.mitchellh.ghostty",
		"co.zeit.hyper",
		"com.microsoft.VSCode",
		"com.microsoft.VSCodeInsiders",
		"com.apple.dt.Xcode",
		"dev.zed.Zed",
		"com.sublimetext.4",
		"com.sublimetext.3",
		"com.panic.Nova",
		"org.vim.MacVim",
		"com.neovide.neovide",
	]
	private static let codePrefixes = ["com.jetbrains.", "com.google.android.studio"]

	static func adjust(_ text: String) -> String {
		guard Prefs.appAware else { return text }
		let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
		let isCodeTarget = codeApps.contains(bundleID)
			|| codePrefixes.contains { bundleID.hasPrefix($0) }

		var result = text
		if isCodeTarget {
			// Only lowercase a sentence-case first word; leave acronyms alone.
			if let first = result.first, first.isUppercase,
			   result.dropFirst().first?.isUppercase != true {
				result = first.lowercased() + result.dropFirst()
			}
			if result.hasSuffix("."), !result.hasSuffix("...") {
				result.removeLast()
			}
		} else {
			if let first = result.first, first.isLowercase {
				result = first.uppercased() + result.dropFirst()
			}
		}
		return result
	}
}
