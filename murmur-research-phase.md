/deep-research I want to come up with a plan to clone Whisperflow. I want you to do some deep resarch on how whisperflow works, and what we coul ddo to recreate it's base functinoallity on my local mac. Does this need inference? if so, i want it to be a local model running on ollama or some other local inference runner that essentially does what whiserflow does.
I'll run the deep-research workflow on this. The question is specific enough to research directly — you want to understand how Wispr Flow (the dictation app) works and how to rebuild its core functionality locally on your Mac with local inference. Kicking it off now.

Workflow
IN
{
  "name": "deep-research",
  "args": "How does Wispr Flow (also spelled \"Whisperflow\") work, and how could I recreate its base functionality locally on a Mac using local inference? Wispr Flow is a voice-to-text dictation app for Mac/Windows that lets you dictate anywhere with a hotkey, transcribes speech in real time, and cleans up / formats the text (removing filler words, applying context/commands) before inserting it into whatever app has focus. I want to understand: (1) its architecture — audio capture, hotkey/push-to-talk, speech-to-text engine, LLM-based text cleanup/formatting, and system-wide text insertion; (2) whether it uses cloud or on-device inference and what models; (3) the specific components I'd need to recreate the base functionality — real-time dictation, transcription, AI cleanup, and paste-into-focused-app — entirely locally on macOS. For the local rebuild, transcription should run on a local speech-to-text model (e.g. whisper.cpp / faster-whisper / MacWhisper-style) and any text cleanup should run on a local LLM via Ollama or a similar local inference runner. Cover: best local STT models/runners for real-time low-latency dictation on Apple Silicon, how to do global hotkey + system-wide text insertion on macOS (accessibility APIs, CGEvent, pasteboard), how to pipe transcription through a local Ollama model for cleanup, and existing open-source projects that already do some/all of this (so I can build on them rather than from scratch)."
}
OUT
Workflow launched in background. Task ID: winv2quge
Summary: Deep research harness — fan-out web searches, fetch sources, adversarially verify claims, synthesize a cited report.
Transcript dir: /Users/eric/.claude/projects/-Users-eric-projects/ee7776fb-e341-4f9c-9a7b-095e7ebd7a8a/subagents/workflows/wf_3476a940-71a
Script file: /Users/eric/.claude/projects/-Users-eric-projects/ee7776fb-e341-4f9c-9a7b-095e7ebd7a8a/workflows/scripts/deep-research-wf_3476a940-71a.js
(Edit this file with Write/Edit and re-invoke Workflow with {scriptPath: "/Users/eric/.claude/projects/-Users-eric-projects/ee7776fb-e341-4f9c-9a7b-095e7ebd7a8a/workflows/scripts/deep-research-wf_3476a940-71a.js"} to iterate without resending the script.)
Run ID: wf_3476a940-71a
To resume after editing the script: Workflow({scriptPath: "/Users/eric/.claude/projects/-Users-eric-projects/ee7776fb-e341-4f9c-9a7b-095e7ebd7a8a/workflows/scripts/deep-research-wf_3476a940-71a.js", resumeFromRunId: "wf_3476a940-71a"}) — completed agents return cached results.

You will be notified when it completes. Use /workflows to watch live progress.
The deep-research workflow is running in the background. It'll fan out web searches across five angles (Wispr Flow architecture, local STT models, macOS hotkey/text-insertion APIs, Ollama cleanup pipelines, existing open-source projects), fetch and adversarially verify sources, then synthesize a cited report.

I'll let you know when it completes — you can watch live progress with /workflows in the meantime.

<task-notification>
<task-id>winv2quge</task-id>
<tool-use-id>toolu_0122YFSdKyYXYi8UYBoiEKZt</tool-use-id>
<output-file>/private/tmp/claude-501/-Users-eric-projects/ee7776fb-e341-4f9c-9a7b-095e7ebd7a8a/tasks/winv2quge.output</output-file>
<status>completed</status>
<summary>Dynamic workflow "Deep research harness — fan-out web searches, fetch sources, adversarially verify claims, synthesize a cited report." completed</summary>
<result>{"question":"How does Wispr Flow (also spelled \"Whisperflow\") work, and how could I recreate its base functionality locally on a Mac using local inference? Wispr Flow is a voice-to-text dictation app for Mac/Windows that lets you dictate anywhere with a hotkey, transcribes speech in real time, and cleans up / formats the text (removing filler words, applying context/commands) before inserting it into whatever app has focus. I want to understand: (1) its architecture — audio capture, hotkey/push-to-talk, speech-to-text engine, LLM-based text cleanup/formatting, and system-wide text insertion; (2) whether it uses cloud or on-device inference and what models; (3) the specific components I'd need to recreate the base functionality — real-time dictation, transcription, AI cleanup, and paste-into-focused-app — entirely locally on macOS. For the local rebuild, transcription should run on a local speech-to-text model (e.g. whisper.cpp / faster-whisper / MacWhisper-style) and any text cleanup should run on a local LLM via Ollama or a similar local inference runner. Cover: best local STT models/runners for real-time low-latency dictation on Apple Silicon, how to do global hotkey + system-wide text insertion on macOS (accessibility APIs, CGEvent, pasteboard), how to pipe transcription through a local Ollama model for cleanup, and existing open-source projects that already do some/all of this (so I can build on them rather than from scratch).","summary":"Wispr Flow is a cloud-based voice-dictation app: a single hotkey triggers audio capture in any app, streams speech to cloud speech-recognition models, then pipes the raw transcript through fine-tuned Meta Llama models (hosted on Baseten atop AWS, dedicated infra) for cleanup (filler removal, punctuation, formatting) before inserting text into the focused app — the entire STT-to-Llama pipeline runs server-side in under 700ms, with no on-device/offline mode. The base functionality is fully recreatable locally on Apple Silicon: run STT on a local Whisper-family model (whisper.cpp with Metal/Core ML, WhisperKit via CoreML+ANE, or NVIDIA Parakeet TDT v3 via CoreML/ANE), stream it with a LocalAgreement policy (whisper_streaming) for low latency, and pipe the transcript through a local LLM via Ollama for cleanup. The macOS system integration is a well-trodden pattern: a global push-to-talk hotkey via CGEventTap (Apple DTS-recommended; requires the Input Monitoring TCC privilege) or the KeyboardShortcuts Swift package, and system-wide text insertion via the pasteboard + simulated Cmd+V. Several open-source projects already implement the full local pipeline end-to-end — parakey, vocamac, local-whisper, and OpenWhisper — so a rebuild can start from these rather than from scratch. All 24 claims passed adversarial verification (23 unanimously) against primary sources, so confidence is high throughout.","findings":[{"claim":"Wispr Flow is fully cloud-based: a single hotkey in any app captures speech, cloud speech-recognition models transcribe it, and fine-tuned Meta Llama models (hosted on Baseten atop AWS, dedicated infra) clean up the transcript — the whole multi-step STT-to-Llama pipeline runs server-side in under 700ms with no on-device/offline mode.","confidence":"high","sources":["https://www.baseten.co/resources/customers/wispr-flow/","wisprflow.ai official docs"],"evidence":"Baseten's first-party case study (Wispr's actual inference vendor) states Flow's 'entire pipeline, from speech recognition models to Llama-based transcript enhancement, runs end-to-end in under 700 milliseconds,' uses a 'Chains framework for multi-step inference' plus 'TensorRT-LLM engine builder for fine-tuned Llama models,' and runs on 'private, dedicated deployments' on 'AWS workload planes.' Co-founder Sahaj Garg: 'Llama is controllable and customizable, which lets us focus on the output.' The team 'chose Llama... as the base for their real-time transcript cleanup step' and 'fine-tuned these LLMs to precisely solve user tasks based on the users' context and preferences.' Wispr's own docs confirm 'transcription always occurs on the cloud'; Privacy Mode affects only retention, not transmission. User-facing framing: 'press one button in any application, speak naturally, and Flow writes what you would've written.' Merges claims [0], [1], [2].","vote":"3-0 (all three merged claims unanimous)"},{"claim":"For local STT on Apple Silicon, whisper.cpp is a first-class option: it is optimized via ARM NEON, Accelerate, Metal and Core ML, runs inference fully on the GPU via Metal, and its Core ML encoder path on the Apple Neural Engine yields &gt;3x speedup over CPU-only, aiding low-latency dictation. It ships a naive real-time streaming example (whisper-stream) that samples audio every half second and transcribes continuously (requires SDL2).","confidence":"high","sources":["https://github.com/ggml-org/whisper.cpp"],"evidence":"Official README: 'Apple Silicon first-class citizen - optimized via ARM NEON, Accelerate framework, Metal and Core ML'; 'the inference runs fully on the GPU via Metal.' Core ML encoder on ANE: 'This can result in significant speed-up - more than x3 faster compared with CPU-only execution' (Discussion #548 reports up to 6x real-world). Streaming: 'This is a naive example of performing real-time inference on audio from your microphone. The stream tool samples the audio every half a second and runs the transcription continuously'; 'You will need to have sdl2 installed.' Caveat: the &gt;3x figure is encoder-only (decoder still runs on CPU/Metal). Merges claims [5], [6], [7].","vote":"3-0 (all three merged claims unanimous)"},{"claim":"For low-latency real-time streaming, whisper_streaming supports multiple local backends — faster-whisper (GPU-recommended), whisper-timestamped, and MLX-Whisper (optimized for Apple Silicon M1/M2) — plus an optional OpenAI cloud API. Its LocalAgreement policy confirms a prefix transcript only when consecutive updates on new audio chunks agree, emits text confirmed by 2 iterations, and scrolls the buffer on a confirmed complete sentence.","confidence":"high","sources":["https://github.com/ufal/whisper_streaming"],"evidence":"README: 'The most recommended one is faster-whisper with GPU support'; MLX-Whisper is 'Optimized specifically for Apple Silicon' for M1/M2; whisper-timestamped ('less restrictive, but slower') and the OpenAI API are optional selectable backends. Streaming algorithm: 'if n consecutive updates, each with a newly available audio stream chunk, agree on a prefix transcript, it is confirmed'; 'we consecutively process new audio chunks, emit the transcripts that are confirmed by 2 iterations, and scroll the audio processing buffer on a timestamp of a confirmed complete sentence.' This is the UFAL academic repo behind the technique. Merges claims [3], [4].","vote":"3-0 (both merged claims unanimous)"},{"claim":"Global push-to-talk hotkey capture on macOS is best done via CGEventTap (Apple DTS-recommended over RegisterEventHotKey and NSEvent global monitors, chiefly for clean TCC integration), which requires the Input Monitoring privilege and exposes CGPreflightListenEventAccess (check) and CGRequestListenEventAccess (request). Alternatively, the KeyboardShortcuts Swift package (macOS 10.15+) adds user-customizable global hotkeys with onKeyDown/onKeyUp handlers ideal for wiring push-to-talk start/stop.","confidence":"high","sources":["https://developer.apple.com/forums/thread/735223","https://github.com/sindresorhus/KeyboardShortcuts"],"evidence":"Apple DTS engineer Quinn: 'Of the remaining options, I prefer CGEventTap because of its interactions with TCC'; 'To listen for keyboard events you'll need the Input Monitoring privilege'; CGEventTap 'is clearly associated with the APIs to determine whether you have that privilege (CGPreflightListenEventAccess) and to request that privilege (CGRequestListenEventAccess),' and is App Sandbox-compatible since 10.15. (Nuance: RegisterEventHotKey is ex
... (truncated 14116 chars, full result in /private/tmp/claude-501/-Users-eric-projects/ee7776fb-e341-4f9c-9a7b-095e7ebd7a8a/tasks/winv2quge.output)</result>
<usage><agent_count>104</agent_count><subagent_tokens>1762136</subagent_tokens><tool_uses>425</tool_uses><duration_ms>348961</duration_ms></usage>
</task-notification>
The research completed. Let me read the full report.

Read winv2quge.output
The research is done — 22 sources, 24 verified claims, one refuted. Here's the synthesis.

Cloning Wispr Flow locally on your Mac
How Wispr Flow actually works
It's fully cloud-based — this is the key thing to internalize before planning a clone. The pipeline is:

Single global hotkey captures speech in whatever app has focus
Audio streams to cloud speech-recognition models for transcription
Raw transcript is piped through fine-tuned Meta Llama models (hosted on Baseten, running on AWS with dedicated/private deployments) that do the cleanup — filler removal, punctuation, formatting, context/commands
Cleaned text is inserted into the focused app
The whole STT→Llama pipeline runs server-side in under 700ms. There is no on-device/offline mode — even "Privacy Mode" only affects retention, not whether audio is transmitted. Their own docs confirm "transcription always occurs on the cloud."

So: it does need inference (both STT and an LLM cleanup step), and Wispr does all of it remotely. Your instinct to run it locally is a genuine re-architecture, not a port — but the good news is the entire thing is recreatable locally on Apple Silicon, and several open-source projects already do it end-to-end.

The four components you need to recreate
Wispr does (cloud)	You do (local)
Cloud STT model	Local Whisper-family model on Apple Silicon
Fine-tuned Llama cleanup	Local LLM via Ollama
Global hotkey capture	CGEventTap (or KeyboardShortcuts Swift pkg)
Insert into focused app	Pasteboard + simulated Cmd+V
1. Local speech-to-text (real-time, low-latency)
Three viable runners on Apple Silicon, in rough order of "native feel":

WhisperKit — OpenAI Whisper reimplemented in CoreML, runs on the Apple Neural Engine. Swift-native, purpose-built for on-device real-time ASR (there's even an arXiv paper on it). Easiest path if you build a native Swift app.
Parakeet TDT v3 (NVIDIA, via CoreML/ANE using the FluidAudio SDK) — multilingual, also ANE-accelerated. This is what the leading OSS clone uses.
whisper.cpp — "first-class" Apple Silicon support (Metal GPU + Core ML encoder on ANE, >3× encoder speedup). Its bundled whisper-stream real-time example is explicitly labeled "naive" by its own maintainers.
For real streaming (partial results as you speak, low latency), the serious approach is the whisper_streaming project's LocalAgreement policy — it only commits transcript text once consecutive audio chunks agree (confirmed by 2 iterations), which avoids flickering rewrites. It drives faster-whisper or MLX-Whisper (MLX is Apple-Silicon-optimized). ⚠️ Note: faster-whisper is CPU/CUDA only — no Metal, so on a Mac you'd lean on MLX-Whisper or whisper.cpp instead.

2. Global hotkey (push-to-talk)
Two clean options:

CGEventTap — Apple DTS explicitly recommends this over the legacy Carbon RegisterEventHotKey and NSEvent monitors, mainly for clean TCC integration. Requires the Input Monitoring privilege; check/request via CGPreflightListenEventAccess / CGRequestListenEventAccess.
KeyboardShortcuts (sindresorhus Swift package, macOS 10.15+) — gives you user-customizable hotkeys with separate onKeyDown/onKeyUp callbacks, which are exactly the push-to-talk primitive (hold = record, release = stop).
3. Local LLM cleanup via Ollama
Write the raw transcript to a local Ollama model with a cleanup prompt (fix punctuation, strip fillers, format lists). Proven working combos from the sources:

gemma3:4b — small, fast, "good at text cleanup" (local-whisper's default)
Qwen 2.5 7B — used by the "Murmur" clone
llama3.2 — used in the MacWhisper+Ollama writeup
Smart pattern worth stealing: only run cleanup on transcripts longer than ~50 chars — short dictations get inserted as-is, saving latency. And consider inserting the raw transcript first, then refining, so perceived latency stays low.

4. System-wide text insertion
The universal pattern across every project: save clipboard → write text to pasteboard → simulate Cmd+V → restore clipboard. Accessibility permission is needed only to synthesize the keystroke, not to set text. Nice touch from local-whisper: app-aware post-processing via bundle-ID detection — skip auto-capitalization in terminals (Terminal/iTerm2/Warp) and code editors (VS Code/Xcode/Zed), capitalize everywhere else.

Don't build from scratch — fork one of these
The strongest match to what you want, ranked:

VoiceInk (Beingpax/VoiceInk) — the closest OSS analog to Wispr Flow. Native macOS Swift, ~3.7k stars, GPLv3. whisper.cpp for STT (Parakeet/FluidAudio as an alternative) plus Ollama AI cleanup already built in. This is likely your best starting fork.
local-whisper (luisalima/local-whisper) — the clearest reference for the whisper.cpp + Ollama combo end-to-end. Hold-to-talk (Hammerspoon), optional gemma3:4b refinement, app-aware insertion. Simplest to read and learn from.
parakey (rcourtman/parakey) — native Swift, on-device Parakeet TDT v3 on ANE, CGEventTap hotkey, clipboard paste. Great CGEventTap reference.
vocamac (jatinkrmalik/vocamac) — WhisperKit + AVAudioEngine + CGEventTap + clipboard injection. Clean WhisperKit reference (beta).
OpenWhisper / OpenSuperWhisper — WhisperKit-based, MIT-licensed, offline; good if you want a permissive license.
⚠️ One correction from verification: a claim that parakey hits ~100ms key-release-to-paste latency was refuted — don't anchor on any specific local-latency number. Real-time feel depends on model size, chunk cadence, and ANE availability; you'll need to measure on your own hardware.

My recommended path
Given you want native, local, and low-effort: fork VoiceInk (it already has the whole architecture you described — local Whisper/Parakeet STT + Ollama cleanup + hotkey + insertion) and tune it to your taste, or read local-whisper first if you'd rather understand the whole pipeline in a small codebase before committing to a native Swift app.

Open questions the research couldn't close
Wispr's exact cloud STT model is never named publicly (only that it's cloud + feeds Llama).
The exact Llama size/quantization Wispr fine-tunes is undocumented — so whether a local 4B–8B model matches its cleanup quality is something you'd validate empirically.
No verified local end-to-end latency figure survived; measure it yourself per STT path.
Want me to turn this into a task file with a concrete build plan (e.g. "fork VoiceInk, wire gemma3:4b via Ollama, tune the cleanup prompt"), or dig deeper into any one component first?

it sounds like there are built in tts i can make use of like WhisperKit? i think we use that to build a native swift app! maybe llama3.1:8b, maybe we play with different models once it's built, make it support the choice of model. lets write up a prompt to do this for me to start in a Fable5 session
Quick clarifications before the prompt, so the Fable session starts on solid footing:

STT, not TTS — WhisperKit is speech-to-text (transcription). That's what you want; just flagging the acronym.
WhisperKit isn't an OS built-in — it's a third-party Swift package (argmaxinc/WhisperKit) you add via SPM. But it is native Swift, runs Whisper on CoreML + the Neural Engine, and is purpose-built for on-device real-time ASR — so it's the right choice for a native app. (macOS does ship SFSpeechRecognizer in the Speech framework, but it's weaker and less controllable — WhisperKit is the better call.)
Here's a self-contained kickoff prompt. I wrote it to stand alone since a fresh Fable 5 session won't have this research in context.


Build me a native macOS app in Swift — a local, privacy-first clone of Wispr Flow's
core dictation loop. Everything runs on-device; nothing goes to the cloud.

## What it does
Press-and-hold a global hotkey anywhere in macOS → speak → release → the app
transcribes my speech locally, cleans up the text with a local LLM (fix punctuation,
remove filler words like "um"/"uh", format lists), and pastes the result into
whatever app currently has focus.

## Stack (decided)
- **Language/UI:** Swift + SwiftUI, menu-bar app (LSUIElement, no dock icon).
  Target macOS 14+. Use Swift Package Manager.
- **Speech-to-text:** WhisperKit (github.com/argmaxinc/WhisperKit) — runs Whisper
  on CoreML + Apple Neural Engine. Bundle a small model (e.g. base/small) and allow
  downloading larger ones on first use, cached locally.
- **Audio capture:** AVAudioEngine, 16kHz mono Float32, fed to WhisperKit.
- **Text cleanup:** local LLM via Ollama's HTTP API (http://localhost:11434).
  Default model **llama3.1:8b**, but make the model a user-configurable setting
  (dropdown populated from Ollama's /api/tags, plus a free-text field). Send the
  raw transcript with a cleanup system prompt; the prompt should also be editable
  in settings. Only run cleanup on transcripts longer than ~50 chars — insert
  shorter ones as-is to keep latency low. If Ollama is unreachable, fall back to
  inserting the raw transcript and surface a non-blocking warning.
- **Global hotkey:** push-to-talk (hold to record, release to stop). Use either
  CGEventTap or the KeyboardShortcuts Swift package (sindresorhus/KeyboardShortcuts)
  with separate onKeyDown/onKeyUp handlers. Make the hotkey user-configurable;
  default to a modifier like Right Option.
- **Text insertion:** save the current clipboard → write cleaned text to
  NSPasteboard → simulate Cmd+V via CGEvent → restore the original clipboard.

## Permissions (handle explicitly with a first-run onboarding screen)
- **Input Monitoring** (for the global hotkey via CGEventTap) — check with
  CGPreflightListenEventAccess, request with CGRequestListenEventAccess.
- **Accessibility** (to synthesize the Cmd+V keystroke).
- **Microphone** (AVAudioEngine).
Detect missing permissions and guide the user to System Settings.

## Nice-to-haves (do after the core loop works)
- App-aware post-processing: skip auto-capitalization in terminals (Terminal,
  iTerm2, Warp) and code editors (VS Code, Xcode, Zed) via frontmost-app bundle-ID
  detection; capitalize elsewhere.
- A small HUD/indicator while recording.
- Settings persisted via UserDefaults.

## Reference implementations to study (do NOT copy license-incompatible code;
## read them for architecture, then write your own):
- Beingpax/VoiceInk — closest full analog (Swift, whisper.cpp/Parakeet + Ollama cleanup)
- jatinkrmalik/vocamac — WhisperKit + AVAudioEngine + CGEventTap + clipboard injection
- rcourtman/parakey — CGEventTap hotkey + on-device STT + clipboard paste
- luisalima/local-whisper — clean whisper.cpp + Ollama cleanup reference

## Build order
1. Menu-bar app skeleton + permissions onboarding.
2. Global push-to-talk hotkey → logs "recording started/stopped."
3. AVAudioEngine capture → WhisperKit transcription → print transcript.
4. Pasteboard + Cmd+V insertion of raw transcript into the focused app.
5. Ollama cleanup pass with configurable model (default llama3.1:8b) + editable prompt.
6. Settings UI (hotkey, model, prompt, toggles) + the nice-to-haves.

Verify each step runs before moving on. Assume Ollama is already installed and
llama3.1:8b is pulled. Ask me before making any architectural decision that
locks out later flexibility (e.g. model choice, hotkey config).
Want me to save this as a task file in a project (which ecosystem/repo should it live under — or a standalone folder?), and should I note the refined stack decisions to memory so a future session has the context?