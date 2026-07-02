import Foundation

/// Strips Whisper's non-speech artifacts ("[BLANK_AUDIO]", "(typing)", …) and
/// normalizes whitespace. Only known artifact tokens are removed so dictated
/// brackets survive.
enum TranscriptSanitizer {
	static func clean(_ raw: String) -> String {
		var text = raw
		text = text.replacingOccurrences(
			of: #"\[(?i:blank_audio|music|inaudible|silence|noise|applause|laughter)\]"#,
			with: " ",
			options: .regularExpression
		)
		text = text.replacingOccurrences(
			of: #"\((?i:typing|silence|music|noise|laughs?|laughter|coughs?|clears throat)\)"#,
			with: " ",
			options: .regularExpression
		)
		text = text.replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
		return text.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
