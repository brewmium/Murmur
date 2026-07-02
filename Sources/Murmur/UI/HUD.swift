import AppKit
import SwiftUI

@MainActor
final class HUDModel: ObservableObject {
	@Published var text = ""
	@Published var isRecording = false
	@Published var level: Float = 0
}

/// Small floating, non-activating panel shown near the bottom of the screen
/// while the dictation pipeline runs.
@MainActor
final class HUDController {
	private let model = HUDModel()
	private var panel: NSPanel?
	private var hideTask: Task<Void, Never>?

	func show(text: String, recording: Bool) {
		hideTask?.cancel()
		model.text = text
		model.isRecording = recording
		model.level = 0
		if panel == nil { panel = makePanel() }
		position()
		panel?.orderFrontRegardless()
	}

	func update(text: String) {
		if panel?.isVisible != true {
			show(text: text, recording: false)
			return
		}
		hideTask?.cancel()
		model.text = text
		model.isRecording = false
	}

	func updateLevel(_ level: Float) {
		let boosted = min(max(level * 4, 0), 1)
		model.level = max(boosted, model.level * 0.8)
	}

	func flash(_ text: String, seconds: Double = 2.5) {
		show(text: text, recording: false)
		hideTask = Task { [weak panel] in
			try? await Task.sleep(for: .seconds(seconds))
			if !Task.isCancelled { panel?.orderOut(nil) }
		}
	}

	func hide() {
		hideTask?.cancel()
		panel?.orderOut(nil)
	}

	private func makePanel() -> NSPanel {
		let panel = NSPanel(
			contentRect: NSRect(x: 0, y: 0, width: 280, height: 52),
			styleMask: [.borderless, .nonactivatingPanel],
			backing: .buffered,
			defer: false
		)
		panel.isFloatingPanel = true
		panel.level = .statusBar
		panel.backgroundColor = .clear
		panel.isOpaque = false
		panel.hasShadow = true
		panel.ignoresMouseEvents = true
		panel.hidesOnDeactivate = false
		panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
		panel.contentView = NSHostingView(rootView: HUDView(model: model))
		return panel
	}

	private func position() {
		guard let screen = NSScreen.main, let panel else { return }
		let frame = screen.visibleFrame
		panel.setFrameOrigin(NSPoint(
			x: frame.midX - panel.frame.width / 2,
			y: frame.minY + 96
		))
	}
}

struct HUDView: View {
	@ObservedObject var model: HUDModel

	var body: some View {
		HStack(spacing: 10) {
			if model.isRecording {
				LevelIndicator(level: model.level)
			} else {
				ProgressView()
					.controlSize(.small)
					.colorScheme(.dark)
			}
			Text(model.text)
				.font(.system(size: 13, weight: .medium))
				.foregroundStyle(.white)
				.lineLimit(1)
		}
		.padding(.horizontal, 16)
		.frame(width: 280, height: 52)
		.background(
			RoundedRectangle(cornerRadius: 14, style: .continuous)
				.fill(Color.black.opacity(0.8))
		)
	}
}

private struct LevelIndicator: View {
	var level: Float
	private let weights: [CGFloat] = [0.45, 0.7, 1.0, 0.7, 0.45]

	var body: some View {
		HStack(spacing: 3) {
			ForEach(0..<5, id: \.self) { index in
				Capsule()
					.fill(Color.red)
					.frame(width: 3, height: 4 + 18 * weights[index] * CGFloat(level))
			}
		}
		.frame(height: 24)
		.animation(.linear(duration: 0.08), value: level)
	}
}
