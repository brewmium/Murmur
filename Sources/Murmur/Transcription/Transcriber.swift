import Foundation
import WhisperKit

/// Owns the WhisperKit pipeline. Loads (and downloads, on first use) the configured
/// model; reloads lazily when the setting changes.
actor Transcriber {
	static let shared = Transcriber()

	static let modelsDirectory: URL = {
		let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
			.appendingPathComponent("Murmur/Models", isDirectory: true)
		try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
		return base
	}()

	private var whisperKit: WhisperKit?
	private var loadedModel: String?

	func ensureLoaded(model: String) async throws {
		if loadedModel == model, whisperKit != nil { return }
		whisperKit = nil
		loadedModel = nil
		await MainActor.run { AppState.shared.modelState = .loading(model) }
		do {
			let config = WhisperKitConfig(
				model: model,
				downloadBase: Self.modelsDirectory,
				verbose: false,
				logLevel: .error
			)
			whisperKit = try await WhisperKit(config)
			loadedModel = model
			await MainActor.run { AppState.shared.modelState = .ready(model) }
		} catch {
			let message = error.localizedDescription
			await MainActor.run { AppState.shared.modelState = .failed(message) }
			throw error
		}
	}

	func transcribe(_ samples: [Float]) async throws -> String {
		try await ensureLoaded(model: Prefs.whisperModel)
		guard let whisperKit else { throw MurmurError.modelNotReady }
		let results = try await whisperKit.transcribe(audioArray: samples)
		let text = results.map(\.text).joined(separator: " ")
		return TranscriptSanitizer.clean(text)
	}
}
