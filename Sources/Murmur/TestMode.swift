import Foundation
import WhisperKit

/// Headless pipeline check: `Murmur --test-file path/to/audio.wav` transcribes the
/// file, runs the Ollama cleanup pass, prints both, and exits. No mic, no hotkey,
/// no pasteboard — used to verify the STT + cleanup stages end to end.
enum TestMode {
	static func fileArgument() -> String? {
		let args = CommandLine.arguments
		guard let index = args.firstIndex(of: "--test-file"), index + 1 < args.count else {
			return nil
		}
		return args[index + 1]
	}

	static func run(path: String) {
		Task {
			do {
				let buffer = try AudioProcessor.loadAudio(fromPath: path)
				let samples = AudioProcessor.convertBufferToArray(buffer: buffer)
				print("[test] loaded \(samples.count) samples (\(String(format: "%.2f", Double(samples.count) / 16_000))s)")

				let raw = try await Transcriber.shared.transcribe(samples)
				print("[test] raw transcript: \(raw)")

				if Prefs.cleanupEnabled && raw.count > Prefs.cleanupMinChars {
					do {
						let cleaned = try await OllamaClient.cleanup(raw)
						print("[test] cleaned (\(Prefs.ollamaModel)): \(cleaned)")
					} catch {
						print("[test] ollama cleanup failed: \(error.localizedDescription)")
					}
				} else {
					print("[test] cleanup skipped (disabled or under \(Prefs.cleanupMinChars) chars)")
				}
				exit(0)
			} catch {
				print("[test] FAILED: \(error.localizedDescription)")
				exit(1)
			}
		}
	}
}
