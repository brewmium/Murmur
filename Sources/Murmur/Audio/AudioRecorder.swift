import AVFoundation

/// Captures the default input device and accumulates 16 kHz mono Float32 samples.
final class AudioRecorder {
	static let targetFormat = AVAudioFormat(
		commonFormat: .pcmFormatFloat32,
		sampleRate: 16_000,
		channels: 1,
		interleaved: false
	)!

	private let engine = AVAudioEngine()
	private var converter: AVAudioConverter?
	private var samples: [Float] = []
	private let lock = NSLock()

	/// Called on the audio thread with a rough RMS level (0…1-ish).
	var levelHandler: ((Float) -> Void)?

	var isRunning: Bool { engine.isRunning }

	func start() throws {
		lock.lock()
		samples.removeAll(keepingCapacity: true)
		lock.unlock()

		let input = engine.inputNode
		let inputFormat = input.outputFormat(forBus: 0)
		guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0 else {
			throw MurmurError.noAudioInput
		}
		converter = AVAudioConverter(from: inputFormat, to: Self.targetFormat)

		input.removeTap(onBus: 0)
		input.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
			self?.process(buffer)
		}
		engine.prepare()
		try engine.start()
	}

	func stop() -> [Float] {
		engine.inputNode.removeTap(onBus: 0)
		engine.stop()
		converter = nil
		lock.lock()
		defer { lock.unlock() }
		return samples
	}

	private func process(_ buffer: AVAudioPCMBuffer) {
		guard let converter else { return }
		let ratio = Self.targetFormat.sampleRate / buffer.format.sampleRate
		let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 16
		guard let out = AVAudioPCMBuffer(pcmFormat: Self.targetFormat, frameCapacity: capacity) else { return }

		var consumed = false
		var error: NSError?
		converter.convert(to: out, error: &error) { _, outStatus in
			if consumed {
				outStatus.pointee = .noDataNow
				return nil
			}
			consumed = true
			outStatus.pointee = .haveData
			return buffer
		}
		if error != nil { return }

		guard let channel = out.floatChannelData?[0] else { return }
		let count = Int(out.frameLength)
		guard count > 0 else { return }

		lock.lock()
		samples.append(contentsOf: UnsafeBufferPointer(start: channel, count: count))
		lock.unlock()

		var sum: Float = 0
		for i in 0..<count { sum += channel[i] * channel[i] }
		levelHandler?(sqrt(sum / Float(count)))
	}
}
