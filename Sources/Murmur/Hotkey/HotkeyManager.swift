import AppKit
import CoreGraphics

/// Listen-only CGEventTap that turns the configured key into press/release callbacks.
/// The hotkey is read from Prefs on every event, so changing it in Settings needs no restart.
final class HotkeyManager {
	var onKeyDown: (() -> Void)?
	var onKeyUp: (() -> Void)?
	/// Fired instead of onKeyUp when another modifier joins mid-hold (a chord,
	/// not dictation) — the recording should be discarded, not transcribed.
	var onCancel: (() -> Void)?

	private var tap: CFMachPort?
	private var runLoopSource: CFRunLoopSource?
	private var isHeld = false

	var isRunning: Bool { tap != nil }

	@discardableResult
	func start() -> Bool {
		guard tap == nil else { return true }

		let mask: CGEventMask =
			(1 << CGEventType.keyDown.rawValue) |
			(1 << CGEventType.keyUp.rawValue) |
			(1 << CGEventType.flagsChanged.rawValue)

		let callback: CGEventTapCallBack = { _, type, event, refcon in
			if let refcon {
				let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon).takeUnretainedValue()
				manager.handle(type: type, event: event)
			}
			return Unmanaged.passUnretained(event)
		}

		guard let tap = CGEvent.tapCreate(
			tap: .cgSessionEventTap,
			place: .headInsertEventTap,
			options: .listenOnly,
			eventsOfInterest: mask,
			callback: callback,
			userInfo: Unmanaged.passUnretained(self).toOpaque()
		) else {
			NSLog("HotkeyManager: event tap creation failed (Input Monitoring missing?)")
			return false
		}

		self.tap = tap
		runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
		CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
		CGEvent.tapEnable(tap: tap, enable: true)
		return true
	}

	func stop() {
		if let tap { CGEvent.tapEnable(tap: tap, enable: false) }
		if let runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes) }
		tap = nil
		runLoopSource = nil
		isHeld = false
	}

	private func handle(type: CGEventType, event: CGEvent) {
		if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
			if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
			return
		}

		let hotkey = Prefs.hotkeyOption
		let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
		let allModifiers: CGEventFlags = [.maskCommand, .maskControl, .maskShift, .maskAlternate, .maskSecondaryFn]
		let otherModifiers = event.flags.intersection(allModifiers.subtracting(hotkey.flagMask ?? []))

		if let flagMask = hotkey.flagMask {
			guard type == .flagsChanged else { return }
			if isHeld {
				if !event.flags.contains(flagMask) {
					transition(pressed: false)
				} else if !otherModifiers.isEmpty {
					cancelHold()
				}
			} else {
				// Only start when the hotkey is the sole modifier down, so
				// shortcuts like Cmd+Opt+… don't trigger phantom recordings.
				guard keyCode == hotkey.keyCode,
					  event.flags.contains(flagMask),
					  otherModifiers.isEmpty else { return }
				transition(pressed: true)
			}
		} else {
			switch type {
			case .keyDown:
				guard keyCode == hotkey.keyCode,
					  event.getIntegerValueField(.keyboardEventAutorepeat) == 0,
					  otherModifiers.isEmpty else { return }
				transition(pressed: true)
			case .keyUp:
				guard keyCode == hotkey.keyCode else { return }
				transition(pressed: false)
			case .flagsChanged:
				if isHeld, !otherModifiers.isEmpty { cancelHold() }
			default:
				break
			}
		}
	}

	private func cancelHold() {
		guard isHeld else { return }
		isHeld = false
		onCancel?()
	}

	private func transition(pressed: Bool) {
		if pressed && !isHeld {
			isHeld = true
			onKeyDown?()
		} else if !pressed && isHeld {
			isHeld = false
			onKeyUp?()
		}
	}
}
