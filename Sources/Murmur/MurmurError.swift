import Foundation

enum MurmurError: LocalizedError {
	case modelNotReady
	case noAudioInput
	case transcriptionFailed(String)

	var errorDescription: String? {
		switch self {
		case .modelNotReady:
			return "Whisper model is not loaded yet"
		case .noAudioInput:
			return "No audio input device available"
		case .transcriptionFailed(let detail):
			return "Transcription failed: \(detail)"
		}
	}
}
