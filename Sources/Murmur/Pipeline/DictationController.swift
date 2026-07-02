import AppKit

/// Orchestrates the dictation loop: record while held → transcribe → clean → insert.
@MainActor
final class DictationController: ObservableObject {
	private let recorder = AudioRecorder()
	private let hud = HUDController()

	func preloadModel() async {
		try? await Transcriber.shared.ensureLoaded(model: Prefs.whisperModel)
	}

	func pressBegan() {
		guard AppState.shared.phase == .idle else { return }
		guard Permissions.microphoneGranted else {
			AppController.shared.showOnboarding()
			return
		}
		recorder.levelHandler = { [weak hud] level in
			Task { @MainActor in hud?.updateLevel(level) }
		}
		do {
			try recorder.start()
		} catch {
			AppState.shared.setWarning("Could not start microphone: \(error.localizedDescription)")
			return
		}
		AppState.shared.phase = .recording
		if Prefs.hudEnabled { hud.show(text: "Listening…", recording: true) }
		// Load (or keep-alive) the cleanup model while the user is still talking,
		// so a cold Ollama start overlaps with speech instead of adding latency after.
		if Prefs.cleanupEnabled {
			Task.detached { await OllamaClient.warmup() }
		}
		print("[murmur] recording started")
	}

	func pressCancelled() {
		guard AppState.shared.phase == .recording else { return }
		_ = recorder.stop()
		AppState.shared.phase = .idle
		hud.hide()
		print("[murmur] recording cancelled (modifier chord)")
	}

	func pressEnded() {
		guard AppState.shared.phase == .recording else { return }
		let samples = recorder.stop()
		let seconds = Double(samples.count) / AudioRecorder.targetFormat.sampleRate
		print("[murmur] recording stopped (\(String(format: "%.2f", seconds))s)")

		guard seconds >= 0.35 else {
			AppState.shared.phase = .idle
			hud.hide()
			return
		}

		AppState.shared.phase = .transcribing
		if Prefs.hudEnabled { hud.update(text: "Transcribing…") }
		Task { await runPipeline(samples) }
	}

	private func runPipeline(_ samples: [Float]) async {
		var pendingWarning: String?
		defer { AppState.shared.phase = .idle }

		do {
			let raw = try await Transcriber.shared.transcribe(samples)
			print("[murmur] transcript: \(raw)")
			guard !raw.isEmpty else {
				hud.flash("Nothing heard")
				return
			}

			var text = raw
			if Prefs.cleanupEnabled && raw.count > Prefs.cleanupMinChars {
				AppState.shared.phase = .cleaning
				if Prefs.hudEnabled { hud.update(text: "Cleaning up…") }
				do {
					text = try await OllamaClient.cleanup(raw)
					print("[murmur] cleaned: \(text)")
				} catch {
					pendingWarning = "Ollama unreachable — inserted raw transcript"
					AppState.shared.setWarning(pendingWarning!)
				}
			}

			text = AppAwareProcessor.adjust(text)
			AppState.shared.lastTranscript = text
			var insertionText = text
			if Prefs.appendSpace, let last = insertionText.last, !last.isWhitespace {
				insertionText += " "
			}
			AppState.shared.phase = .inserting
			if Prefs.hudEnabled { hud.update(text: "Inserting…") }
			await TextInserter.insert(insertionText)

			if let pendingWarning, Prefs.hudEnabled {
				hud.flash("⚠️ \(pendingWarning)")
			} else {
				hud.hide()
			}
		} catch {
			AppState.shared.setWarning("Transcription failed: \(error.localizedDescription)")
			hud.flash("⚠️ Transcription failed")
		}
	}
}
