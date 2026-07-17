# KokoroTTS

**Native macOS text-to-speech app powered by Kokoro-82M.**

Select a voice, paste text, and generate natural speech locally — no cloud API required.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Xcode](https://img.shields.io/badge/Xcode-27.0%20Beta-blue)

---

## Demo

![KokoroTTS Demo](demo/demo.mp4)

*Voice picker → speed control → chunked generation → play/pause → save.*

---

## Features

- **53 Kokoro voices** — American English, British English, Spanish, French, Hindi, Italian, Japanese, Portuguese, and Mandarin
- **Speed control** — 0.5x to 2.0x via slider
- **Chunked generation** — long text starts playing immediately; no waiting for full synthesis
- **Playback controls** — Play, Pause, Resume, Stop
- **Animated timeline** — linear progress bar shows chunk progress and percentage
- **Save** — export full narration as a single `.wav`
- **Local only** — all synthesis happens on-device via `/opt/homebrew/bin/kokoro`

---

## Architecture

```
KokoroTTS (SwiftUI)
  ├── Voice picker (53 voices)
  ├── Speed slider (0.5x–2.0x)
  ├── Text paste area
  ├── Generate → chunks text into ~400-char pieces
  │     └── calls `/opt/homebrew/bin/kokoro` per chunk
  ├── Playback queue
  │     ├── plays chunk 1 immediately
  │     ├── generates chunk 2 in background
  │     └── chains chunks via AVAudioPlayerDelegate
  ├── Progress timer (10Hz) → linear progress bar
  └── Save → strips WAV headers and concatenates PCM
```

---

## Requirements

- macOS 14.0+
- Xcode 27.0 Beta (or Xcode 15+)
- [Kokoro Python package](https://github.com/hexgrad/Kokoro) installed at `/opt/homebrew/bin/kokoro`
  - Install: `pip3 install kokoro`
  - Requires Python 3.12 with `scipy`, `transformers`, `torch`

---

## Build

```bash
git clone https://github.com/<your-username>/KokoroTTS.git
cd KokoroTTS
open KokoroTTS.xcodeproj
```

In Xcode:
1. Select your **Team** for signing
2. Product → Build (or Cmd+B)
3. Product → Run (or Cmd+R)

The app launches from the DerivedData folder, or you can find it in the Xcode build products.

---

## How It Works

### Voice Selection
All 53 voices from `hexgrad/Kokoro-82M` are listed in the menu picker, grouped by language.

### Chunking
Long text is split on word boundaries into ~400-character chunks. Each chunk is sent to Kokoro as a separate synthesis job.

### Early Playback
Chunk 1 begins playing as soon as it finishes generating. Chunk 2+ generate in the background while earlier chunks play.

### Progress
A `Timer` fires at 10Hz and updates `playbackProgress` based on:
```
current_chunk_index * chunk_weight + (current_time / duration) * chunk_weight
```

### Save
`concatWavFiles()` strips the 44-byte WAV header from each chunk after the first and concatenates the raw PCM into a single valid WAV file.

---

## Troubleshooting

**Kokoro not found**
Ensure `/opt/homebrew/bin/kokoro` exists and is executable:
```bash
which kokoro
kokoro --help
```

**Import errors**
If you see `ModuleNotFoundError: No module named 'kokoro'`, reinstall for your Python version:
```bash
pip3 install --upgrade kokoro
```

**Build fails on AVFoundation**
Add `import AVFoundation` to `ContentView.swift`. Already included in this project.

**First generation is slow**
Normal — Kokoro loads the ~600MB model on first run. Subsequent generations are much faster.

---

## Credits

- [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M) by hexgrad
- [vicnaum/kokoro-tts-macos](https://github.com/vicnaum/kokoro-tts-macos) for system-voice integration reference
- Built with Xcode 27.0 Beta on Apple Silicon

---

## License

MIT
