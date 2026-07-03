# Murmur

Local, privacy-first push-to-talk dictation for macOS — a Wispr Flow-style loop that
runs entirely on-device. Hold a key anywhere, speak, release: Murmur transcribes with
WhisperKit (CoreML / Neural Engine), cleans the text with a local LLM via Ollama, and
pastes the result into whatever app has focus. Nothing leaves the machine.

## Requirements

- macOS 14+ (Apple Silicon recommended)
- Xcode toolchain (`swift build` must work)
- [Ollama](https://ollama.com) running locally with a model pulled
  (default: `llama3.1:8b`) — optional; without it, raw transcripts are inserted

## Build & run

```sh
make app        # swift build -c release + assemble build/Murmur.app + codesign
make run        # build and open the app
```

Dev loop: `make app CONFIG=debug` builds faster.

## First run

1. Murmur appears as a waveform icon in the menu bar and opens the setup window.
2. Grant the three permissions (buttons deep-link to System Settings):
   - **Microphone** — records while the key is held
   - **Input Monitoring** — the global push-to-talk key (CGEventTap)
   - **Accessibility** — synthesizes Cmd+V to paste the transcript
3. macOS usually requires relaunching the app after granting Input Monitoring or
   Accessibility.
4. On first use Murmur downloads the Whisper `base` model (~150 MB, one time) from
   Hugging Face into `~/Library/Application Support/Murmur/Models`. Bigger models
   are selectable in Settings → Transcription.

Then hold **Right Option**, speak, release. The hotkey, Whisper model, Ollama model,
and cleanup prompt are all configurable in Settings.

If Ollama isn't running the first time cleanup would be used, Murmur asks once
whether to stay in plain-dictation mode or set Ollama up — so it works out of the
box as a pure speech-to-text tool with no local LLM required.

## How it works

hold key → AVAudioEngine (16 kHz mono Float32) → WhisperKit → sanitize →
(if > 50 chars) Ollama cleanup pass → app-aware formatting → save clipboard →
paste via synthetic Cmd+V → restore clipboard

- Transcripts under ~50 chars (configurable) skip the LLM pass for low latency.
- If Ollama is down, the raw transcript is inserted and a non-blocking warning shows.
- In terminals and code editors (Terminal, iTerm2, Warp, VS Code, Xcode, Zed,
  JetBrains, …) auto-capitalization and trailing periods are skipped.
- If Accessibility isn't granted, the transcript is left on the clipboard instead.

## Headless pipeline test

```sh
say -o /tmp/t.aiff "um so basically I think we should meet on Tuesday"
afconvert -f WAVE -d LEI16@16000 -c 1 /tmp/t.aiff /tmp/t.wav
.build/debug/Murmur --test-file /tmp/t.wav
```

Prints the raw Whisper transcript and the Ollama-cleaned version, then exits.

## Signing / permissions caveat

`scripts/build-app.sh` signs with the first Apple Development / Developer ID
identity it finds so the TCC identity stays stable across rebuilds. With only an
ad-hoc signature, macOS drops granted permissions on every rebuild (the checkbox
stays on but silently stops working — toggle it off and on, or re-add the app).
