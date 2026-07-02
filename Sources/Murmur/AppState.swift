import SwiftUI

enum FlowPhase: Equatable {
	case idle
	case recording
	case transcribing
	case cleaning
	case inserting
}

@MainActor
final class AppState: ObservableObject {
	static let shared = AppState()

	enum ModelState: Equatable {
		case notLoaded
		case loading(String)
		case ready(String)
		case failed(String)
	}

	@Published var phase: FlowPhase = .idle
	@Published var modelState: ModelState = .notLoaded
	@Published var lastTranscript: String = ""
	@Published var warning: String?

	private var warningClearTask: Task<Void, Never>?

	var menuSymbol: String {
		switch phase {
		case .recording:
			return "mic.fill"
		case .transcribing, .cleaning, .inserting:
			return "waveform.circle"
		case .idle:
			return warning == nil ? "waveform" : "waveform.badge.exclamationmark"
		}
	}

	var statusLine: String {
		if case .loading(let model) = modelState {
			return "Loading model \(Self.shortModelName(model))…"
		}
		if case .failed(let message) = modelState {
			return "Model failed: \(message)"
		}
		switch phase {
		case .idle:
			return "Ready — hold \(Prefs.hotkeyOption.displayName) to dictate"
		case .recording:
			return "Recording…"
		case .transcribing:
			return "Transcribing…"
		case .cleaning:
			return "Cleaning up…"
		case .inserting:
			return "Inserting…"
		}
	}

	func setWarning(_ message: String) {
		warning = message
		warningClearTask?.cancel()
		warningClearTask = Task {
			try? await Task.sleep(for: .seconds(10))
			if !Task.isCancelled { self.warning = nil }
		}
	}

	static func shortModelName(_ variant: String) -> String {
		variant.replacingOccurrences(of: "openai_whisper-", with: "")
	}
}
