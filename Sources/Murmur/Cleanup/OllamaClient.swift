import Foundation

/// Talks to a local Ollama server for the transcript cleanup pass.
enum OllamaClient {
	enum OllamaError: LocalizedError {
		case badStatus(Int)
		case emptyResponse

		var errorDescription: String? {
			switch self {
			case .badStatus(let code): return "Ollama returned HTTP \(code)"
			case .emptyResponse: return "Ollama returned an empty response"
			}
		}
	}

	private struct TagsResponse: Decodable {
		struct Model: Decodable { let name: String }
		let models: [Model]
	}

	private struct ChatResponse: Decodable {
		struct Message: Decodable { let content: String }
		let message: Message
	}

	/// Asks Ollama to load the cleanup model into memory (empty prompt = load only),
	/// so the first real dictation doesn't pay the cold-start.
	static func warmup() async {
		let url = Prefs.ollamaURL.appendingPathComponent("api/generate")
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.timeoutInterval = 120
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let body: [String: Any] = [
			"model": Prefs.ollamaModel,
			"keep_alive": "30m",
		]
		request.httpBody = try? JSONSerialization.data(withJSONObject: body)
		_ = try? await URLSession.shared.data(for: request)
	}

	static func listModels() async throws -> [String] {
		let url = Prefs.ollamaURL.appendingPathComponent("api/tags")
		var request = URLRequest(url: url)
		request.timeoutInterval = 3
		let (data, response) = try await URLSession.shared.data(for: request)
		guard (response as? HTTPURLResponse)?.statusCode == 200 else {
			throw OllamaError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
		}
		return try JSONDecoder().decode(TagsResponse.self, from: data).models.map(\.name)
	}

	static func cleanup(_ transcript: String) async throws -> String {
		let url = Prefs.ollamaURL.appendingPathComponent("api/chat")
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.timeoutInterval = 60
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let body: [String: Any] = [
			"model": Prefs.ollamaModel,
			"stream": false,
			"keep_alive": "30m",
			"options": ["temperature": 0.2],
			"messages": [
				["role": "system", "content": Prefs.cleanupPrompt],
				["role": "user", "content": transcript],
			],
		]
		request.httpBody = try JSONSerialization.data(withJSONObject: body)

		let (data, response) = try await URLSession.shared.data(for: request)
		guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
			throw OllamaError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
		}
		let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
		let cleaned = postprocess(decoded.message.content)
		guard !cleaned.isEmpty else { throw OllamaError.emptyResponse }
		return cleaned
	}

	/// LLMs occasionally wrap output in quotes, code fences, or <think> blocks
	/// despite instructions — strip those, keep everything else verbatim.
	private static func postprocess(_ content: String) -> String {
		var text = content
		text = text.replacingOccurrences(
			of: #"(?s)<think>.*?</think>"#,
			with: "",
			options: .regularExpression
		)
		text = text.trimmingCharacters(in: .whitespacesAndNewlines)
		let lines = text.components(separatedBy: "\n")
		if lines.count > 1 {
			let first = lines[0].trimmingCharacters(in: .whitespaces).lowercased()
			let preambleStarts = ["here", "sure", "okay", "certainly", "the cleaned", "cleaned"]
			if first.hasSuffix(":"), preambleStarts.contains(where: { first.hasPrefix($0) }) {
				text = lines.dropFirst().joined(separator: "\n")
					.trimmingCharacters(in: .whitespacesAndNewlines)
			}
		}
		if text.hasPrefix("```"), text.hasSuffix("```"), text.count > 6 {
			let lines = text.components(separatedBy: "\n")
			if lines.count > 2 {
				text = lines.dropFirst().dropLast().joined(separator: "\n")
			}
		}
		if text.count >= 2, text.first == "\"", text.last == "\"" {
			text = String(text.dropFirst().dropLast())
		}
		return text.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
