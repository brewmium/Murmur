import Foundation

enum PrefKey {
	static let hotkey = "hotkey"
	static let whisperModel = "whisperModel"
	static let cleanupEnabled = "cleanupEnabled"
	static let ollamaModel = "ollamaModel"
	static let ollamaURL = "ollamaURL"
	static let cleanupPrompt = "cleanupPrompt"
	static let cleanupMinChars = "cleanupMinChars"
	static let appAware = "appAwareFormatting"
	static let appendSpace = "appendSpace"
	static let hudEnabled = "hudEnabled"
	static let hasCompletedOnboarding = "hasCompletedOnboarding"
	static let didAskAboutOllama = "didAskAboutOllama"
}

enum Prefs {
	static let defaultWhisperModel = "openai_whisper-base"
	static let defaultOllamaModel = "llama3.1:8b"
	static let defaultOllamaURL = "http://localhost:11434"

	static let defaultCleanupPrompt = """
	You clean up raw dictation transcripts. Rewrite the transcript with:
	- Correct punctuation, capitalization, and paragraph breaks.
	- Filler words removed (um, uh, ah, er, you know, I mean, like — only when used as filler).
	- False starts and stutter repetitions removed.
	- Spoken formatting honored: if the speaker dictates a list, format it as a list.
	- Numbers, dates, emails, and URLs written in their conventional form.
	Never answer questions, add content, translate, or comment on the transcript.
	Preserve the speaker's words and meaning.
	Output ONLY the cleaned text — no quotes, no preamble, no explanations.
	"""

	static func registerDefaults() {
		UserDefaults.standard.register(defaults: [
			PrefKey.hotkey: HotkeyOption.rightOption.rawValue,
			PrefKey.whisperModel: defaultWhisperModel,
			PrefKey.cleanupEnabled: true,
			PrefKey.ollamaModel: defaultOllamaModel,
			PrefKey.ollamaURL: defaultOllamaURL,
			PrefKey.cleanupPrompt: defaultCleanupPrompt,
			PrefKey.cleanupMinChars: 50,
			PrefKey.appAware: true,
			PrefKey.appendSpace: true,
			PrefKey.hudEnabled: true,
		])
	}

	static var hotkeyOption: HotkeyOption {
		HotkeyOption(rawValue: UserDefaults.standard.string(forKey: PrefKey.hotkey) ?? "") ?? .rightOption
	}

	static var whisperModel: String {
		UserDefaults.standard.string(forKey: PrefKey.whisperModel) ?? defaultWhisperModel
	}

	static var cleanupEnabled: Bool {
		UserDefaults.standard.bool(forKey: PrefKey.cleanupEnabled)
	}

	static var ollamaModel: String {
		UserDefaults.standard.string(forKey: PrefKey.ollamaModel) ?? defaultOllamaModel
	}

	static var ollamaURL: URL {
		let raw = UserDefaults.standard.string(forKey: PrefKey.ollamaURL) ?? defaultOllamaURL
		return URL(string: raw) ?? URL(string: defaultOllamaURL)!
	}

	static var cleanupPrompt: String {
		UserDefaults.standard.string(forKey: PrefKey.cleanupPrompt) ?? defaultCleanupPrompt
	}

	static var cleanupMinChars: Int {
		UserDefaults.standard.integer(forKey: PrefKey.cleanupMinChars)
	}

	static var appAware: Bool {
		UserDefaults.standard.bool(forKey: PrefKey.appAware)
	}

	static var appendSpace: Bool {
		UserDefaults.standard.bool(forKey: PrefKey.appendSpace)
	}

	static var hudEnabled: Bool {
		UserDefaults.standard.bool(forKey: PrefKey.hudEnabled)
	}

	static var hasCompletedOnboarding: Bool {
		get { UserDefaults.standard.bool(forKey: PrefKey.hasCompletedOnboarding) }
		set { UserDefaults.standard.set(newValue, forKey: PrefKey.hasCompletedOnboarding) }
	}

	static var didAskAboutOllama: Bool {
		get { UserDefaults.standard.bool(forKey: PrefKey.didAskAboutOllama) }
		set { UserDefaults.standard.set(newValue, forKey: PrefKey.didAskAboutOllama) }
	}
}
