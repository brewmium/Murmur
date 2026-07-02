# Murmur

Native macOS menu-bar dictation app (SwiftUI + SPM, no Xcode project). Push-to-talk →
WhisperKit on-device STT → Ollama cleanup → paste into focused app. Posture: Active
Development.

- Build: `make app` (release) or `make app CONFIG=debug`; run with `make run`.
- The .app bundle is assembled by `scripts/build-app.sh` (Info.plist in `Support/`);
  running the bare `.build/*/Murmur` binary misattributes TCC permissions — always
  test via the bundle.
- Headless STT+cleanup check: `.build/debug/Murmur --test-file foo.wav` (see README).
- Rebuilds can invalidate granted TCC permissions unless signed with a real identity;
  the build script auto-picks one if present.
