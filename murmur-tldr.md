with a fresh session of Opus 4.8 (max effort, not the highest effort called untracode, i don't use that at all ever), i prompted this: 

```/deep-research I want to come up with a plan to clone Whisperflow. I want you to do some deep resarch on how whisperflow works, and what we coul ddo to recreate it's base functinoallity on my local mac. Does this need inference? if so, i want it to be a local model running on ollama or some other local inference runner that essentially does what whiserflow does.
```

then after the research was done, i prompted it this: 

```it sounds like there are built in tts i can make use of like WhisperKit? i think we use that to build a native swift app! maybe llama3.1:8b, maybe we play with different models once it's built, make it support the choice of model. lets write up a prompt to do this for me to start in a Fable5 session
```

Opus generated this prompt for me:

```
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
```


-----------------------------------------------------

I then started a fresh session and set it to fable (set effort to extra high, 2 from highest) and fed it that prompt ^

I then did just a few refinement prompts:

```can you launch it?```

I prompted this (generated with Murmur):
```it appears you were able to get VoiceOver to work by holding down the Option key while speaking (it ended up taking a long time to clean up the face paint) <- oh my goodness```

```the llama's cold load happened for the first time and it was quite lengthy. This occurred afterwards```

```what if we don't run it thru the model? would we get just straight text to speach? it seems to be messing with what i am saying too much```

```this is the text we'll clean up and turn it off. much, much better, the best part is I can just stop talking when I'm going to say umthat's not what I meant. What I meant was I can let go of the option key which shows me one thing We need to put a space after the text that gets inserted because that way they're not all running together when I pause```

----------

Then i downgraded the fable impl session to Opus (could have probably gone lower, but i don't ever use the other 2) to get it into the repo i just shared with you:

```lets commit this work```


