import CoreGraphics

/// A push-to-talk key choice. Modifier keys are tracked via flagsChanged events;
/// regular keys (F13+) via keyDown/keyUp.
enum HotkeyOption: String, CaseIterable, Identifiable {
	case rightOption
	case rightCommand
	case rightControl
	case rightShift
	case fnKey
	case f13
	case f14
	case f15
	case f16
	case f17
	case f18
	case f19

	var id: String { rawValue }

	var displayName: String {
		switch self {
		case .rightOption: return "Right Option (⌥)"
		case .rightCommand: return "Right Command (⌘)"
		case .rightControl: return "Right Control (⌃)"
		case .rightShift: return "Right Shift (⇧)"
		case .fnKey: return "Fn (Globe)"
		case .f13: return "F13"
		case .f14: return "F14"
		case .f15: return "F15"
		case .f16: return "F16"
		case .f17: return "F17"
		case .f18: return "F18"
		case .f19: return "F19"
		}
	}

	var keyCode: Int64 {
		switch self {
		case .rightOption: return 61
		case .rightCommand: return 54
		case .rightControl: return 62
		case .rightShift: return 60
		case .fnKey: return 63
		case .f13: return 105
		case .f14: return 107
		case .f15: return 113
		case .f16: return 106
		case .f17: return 64
		case .f18: return 79
		case .f19: return 80
		}
	}

	var isModifier: Bool { flagMask != nil }

	var flagMask: CGEventFlags? {
		switch self {
		case .rightOption: return .maskAlternate
		case .rightCommand: return .maskCommand
		case .rightControl: return .maskControl
		case .rightShift: return .maskShift
		case .fnKey: return .maskSecondaryFn
		default: return nil
		}
	}
}
