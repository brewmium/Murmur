import SwiftUI

struct SettingsView: View {
	var body: some View {
		TabView {
			GeneralSettingsTab()
				.tabItem { Label("General", systemImage: "gearshape") }
			TranscriptionSettingsTab()
				.tabItem { Label("Transcription", systemImage: "waveform") }
			CleanupSettingsTab()
				.tabItem { Label("Cleanup", systemImage: "wand.and.stars") }
		}
		.frame(width: 540, height: 560)
	}
}

private struct GeneralSettingsTab: View {
	@AppStorage(PrefKey.hotkey) private var hotkeyRaw = HotkeyOption.rightOption.rawValue
	@AppStorage(PrefKey.hudEnabled) private var hudEnabled = true
	@AppStorage(PrefKey.appAware) private var appAware = true
	@AppStorage(PrefKey.appendSpace) private var appendSpace = true

	var body: some View {
		Form {
			Section {
				Picker("Push-to-talk key", selection: $hotkeyRaw) {
					ForEach(HotkeyOption.allCases) { option in
						Text(option.displayName).tag(option.rawValue)
					}
				}
				Text("Hold to record, release to insert. Changes apply immediately.")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			Section {
				Toggle("Show recording HUD", isOn: $hudEnabled)
				Toggle("Code-aware formatting", isOn: $appAware)
				Toggle("Append a space after inserted text", isOn: $appendSpace)
				Text("Skips auto-capitalization and trailing periods in terminals and code editors.")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
		.formStyle(.grouped)
	}
}

private struct TranscriptionSettingsTab: View {
	@AppStorage(PrefKey.whisperModel) private var whisperModel = Prefs.defaultWhisperModel
	@ObservedObject private var state = AppState.shared

	private static let curated: [(variant: String, label: String)] = [
		("openai_whisper-tiny", "Tiny — fastest, least accurate"),
		("openai_whisper-base", "Base — good balance (default)"),
		("openai_whisper-small", "Small — more accurate, slower"),
		("openai_whisper-large-v3", "Large v3 — best accuracy, big download"),
	]

	var body: some View {
		Form {
			Section {
				Picker("Whisper model", selection: $whisperModel) {
					ForEach(Self.curated, id: \.variant) { entry in
						Text(entry.label).tag(entry.variant)
					}
					if !Self.curated.contains(where: { $0.variant == whisperModel }) {
						Text(whisperModel).tag(whisperModel)
					}
				}
				TextField("Custom variant name", text: $whisperModel)
				Text("Any variant from the argmaxinc/whisperkit-coreml collection. The model loads on next use, or load it now.")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			Section {
				LabeledContent("Status", value: modelStatus)
				HStack {
					Button("Load / Download Now") {
						Task { await AppController.shared.dictation.preloadModel() }
					}
					Button("Reveal Models Folder") {
						NSWorkspace.shared.activateFileViewerSelecting([Transcriber.modelsDirectory])
					}
				}
				Text("Models download once from Hugging Face and are cached locally. Transcription itself never touches the network.")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
		.formStyle(.grouped)
	}

	private var modelStatus: String {
		switch state.modelState {
		case .notLoaded: return "Not loaded"
		case .loading(let model): return "Loading \(AppState.shortModelName(model))…"
		case .ready(let model): return "Ready (\(AppState.shortModelName(model)))"
		case .failed(let message): return "Failed: \(message)"
		}
	}
}

private struct CleanupSettingsTab: View {
	@AppStorage(PrefKey.cleanupEnabled) private var cleanupEnabled = true
	@AppStorage(PrefKey.ollamaURL) private var ollamaURL = Prefs.defaultOllamaURL
	@AppStorage(PrefKey.ollamaModel) private var ollamaModel = Prefs.defaultOllamaModel
	@AppStorage(PrefKey.cleanupMinChars) private var minChars = 50
	@AppStorage(PrefKey.cleanupPrompt) private var prompt = Prefs.defaultCleanupPrompt

	@State private var availableModels: [String] = []
	@State private var ollamaStatus = "Not checked"

	var body: some View {
		Form {
			Section {
				Toggle("Clean up transcripts with a local LLM (Ollama)", isOn: $cleanupEnabled)
				TextField("Ollama URL", text: $ollamaURL)
				HStack {
					Picker("Model", selection: $ollamaModel) {
						ForEach(modelOptions, id: \.self) { name in
							Text(name).tag(name)
						}
					}
					Button("Refresh") { Task { await refreshModels() } }
				}
				TextField("Model (free text)", text: $ollamaModel)
				LabeledContent("Ollama status", value: ollamaStatus)
				Stepper("Skip cleanup under \(minChars) characters", value: $minChars, in: 0...400, step: 10)
				Text("Short snippets are inserted as-is to keep latency low. If Ollama is unreachable, the raw transcript is inserted and a warning is shown.")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			Section("Cleanup prompt") {
				TextEditor(text: $prompt)
					.font(.system(.body, design: .monospaced))
					.frame(minHeight: 150)
				Button("Reset to Default") { prompt = Prefs.defaultCleanupPrompt }
			}
		}
		.formStyle(.grouped)
		.task { await refreshModels() }
	}

	private var modelOptions: [String] {
		var options = availableModels
		if !options.contains(ollamaModel) { options.append(ollamaModel) }
		return options
	}

	private func refreshModels() async {
		do {
			availableModels = try await OllamaClient.listModels()
			ollamaStatus = "Connected — \(availableModels.count) model\(availableModels.count == 1 ? "" : "s")"
		} catch {
			ollamaStatus = "Unreachable at \(ollamaURL)"
		}
	}
}
