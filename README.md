# KokoroTTS

**Native macOS text-to-speech powered by Kokoro-82M.**
Choose a voice, paste text, and generate speech locally — no cloud API, no sign-in, no usage limits.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Xcode](https://img.shields.io/badge/Xcode-27.0%20Beta-blue)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Demo

<video src="https://raw.githubusercontent.com/Dennesssy/KokoroTTS/main/demo/demo.mp4" controls preload="metadata" style="max-width: 100%; border-radius: 12px;"></video>

---

## Why KokoroTTS

Most TTS tools either require cloud credits or force you into a browser tab. KokoroTTS is a standalone macOS app that calls a local Kokoro voice backend, so you get low-latency generation, offline-capable output, and full control over voice, speed, and file export.

---

## Features

- **53 Kokoro voices** across American English, British English, Spanish, French, Hindi, Italian, Japanese, Portuguese, and Mandarin
- **Speed control** — 0.5x to 2.0x
- **Chunked generation** — long text starts playing immediately instead of waiting for the full file
- **Playback controls** — Play, Pause, Resume, Stop
- **Animated timeline** — chunk-level progress with percentage
- **Save as WAV** — export the full narration as one file
- **Local only** — audio is generated on your machine via `/opt/homebrew/bin/kokoro`

---

## Quick Start

### Prerequisites

- macOS 14.0+
- Xcode 27.0 Beta or newer
- Kokoro Python package installed at `/opt/homebrew/bin/kokoro`

Install Kokoro:
```bash
pip3 install --upgrade kokoro
```

Verify:
```bash
kokoro --help
```

### Build

```bash
git clone https://github.com/Dennesssy/KokoroTTS.git
cd KokoroTTS
open KokoroTTS.xcodeproj
```

In Xcode:
1. Select your **Team** in signing settings
2. Build with `Cmd+B`
3. Run with `Cmd+R`

---

## How It Works

1. **Voice selection** — pick from 53 Kokoro voices in the menu picker
2. **Speed selection** — adjust narration speed from 0.5x to 2.0x
3. **Text input** — paste or type the script
4. **Generate** — text is split into ~400-character chunks
5. **Early playback** — chunk 1 plays as soon as it’s ready; later chunks generate in the background
6. **Save** — concatenate all chunks into a single `.wav`

### Architecture

```
KokoroTTS (SwiftUI)
  ├── Voice picker
  ├── Speed slider
  ├── Text input
  ├── Chunked generation
  │     └── /opt/homebrew/bin/kokoro per chunk
  ├── AVAudioPlayer queue
  ├── Progress timer → linear timeline
  └── WAV concatenation on save
```

---

## Troubleshooting

**Kokoro not found**
```bash
which kokoro
kokoro --help
```
If missing:
```bash
pip3 install --upgrade kokoro
```

**ModuleNotFoundError**
Reinstall Kokoro for your active Python:
```bash
pip3 install --upgrade kokoro
```

**First generation is slow**
Normal. Kokoro loads the model on first synthesis. Later chunks and subsequent app launches are faster.

**Build fails**
Make sure you’re using Xcode 27.0 Beta or newer, and that `AVFoundation` is available.

---

## Roadmap

- [ ] Per-voice pitch control
- [ ] Batch text input from file
- [ ] MP3 export
- [ ] Custom voice install flow
- [ ] System-wide voice registration via Audio Unit extension

---

## Credits

- [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M) by hexgrad
- [vicnaum/kokoro-tts-macos](https://github.com/vicnaum/kokoro-tts-macos) for system-voice integration reference

---

## License

MIT
