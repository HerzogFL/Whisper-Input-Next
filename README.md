# Whisper-Input-Next - Enhanced Voice Transcription Tool

<p align="center">
  <img src="docs/whisper_claudecode.png" alt="Project Poster" />
</p>

<p align="center">
  <a href="./VERSION">
    <img src="https://img.shields.io/badge/version-3.3.0-blue.svg" alt="Version" />
  </a>
  <a href="https://www.python.org/">
    <img src="https://img.shields.io/badge/python-3.12+-green.svg" alt="Python" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License" />
  </a>
  <a href="docs/README_zh-CN.md">
    <img src="https://img.shields.io/badge/docs-中文文档-red.svg" alt="Chinese Documentation" />
  </a>
</p>

An intelligent voice transcription input tool supporting multiple transcription services and high-quality speech recognition features.

> 🐧 **Linux users:** Linux desktop support lives on the [`linux` branch](https://github.com/Mor-Li/Whisper-Input-Next/tree/linux), kindly contributed and maintained by [@MiaoDX](https://github.com/MiaoDX) — many thanks! I'm on macOS and don't personally test/maintain the branch, so it may lag behind `main`. Track or contribute there.

## 💰 Why Pay $12/Month? Use Open Source Instead!

**Typeless charges $12/month** for their voice keyboard, but you know what? This open-source project does the same thing for **FREE** - you only pay for the underlying API costs (Doubao ASR or OpenAI GPT-4o transcribe), which is incredibly cheap compared to Typeless's subscription.

- Typeless: $144/year subscription + you don't own the service
- **Whisper-Input-Next**: $0 + only pay for what you use (Doubao streaming ASR is super cheap!)

Stop renting your tools. Own them.

## 🚀 Project Background

This project is based on [ErlichLiu/Whisper-Input](https://github.com/ErlichLiu/Whisper-Input) for secondary development. The original project has been inactive for months, so we have made extensive feature expansions and architectural optimizations, adding important features like OpenAI GPT-4o transcribe integration, audio archiving, local whisper support, and more. [Why use this project?](./docs/[V3.0.0]_知乎blog.md)

## ✨ Key Features

### 🔥 NEW in v3.3.0: Two-Pass Recognition & Accuracy Boost
- **Two-Pass Recognition**: Enables `enable_nonstream` for sentence-level re-recognition using the higher-accuracy nostream model during speech pauses, significantly improving transcription quality
- **Deferred Text Output**: All text stays in floating preview during recording; final text is pasted only after recording stops, allowing full ASR context optimization
- **DJI Wireless Mic Support**: Auto-detects and prioritizes DJI Wireless Microphone as input device

### Doubao Streaming ASR (since v3.2.0)
- **Real-time Streaming Transcription**: Powered by ByteDance's Doubao Seed ASR 2.0, transcription appears as you speak
- **Floating Preview Window**: Shows pending text in real-time near your input field, like an IME
- **Now Default for Ctrl+F**: The best voice input experience, set as default (configurable)
- 👉 [How to get your API keys](#how-to-get-doubao-api-keys)

### 🎯 Core Functions
- **Multi-platform Transcription Services**: Doubao Streaming ASR (default), OpenAI GPT-4o transcribe, local whisper.cpp
- **Smart Hotkeys**: Ctrl+F (Doubao streaming, default) / Ctrl+I (local cost-saving mode)
- **Audio Archive**: Automatically save all recordings, support history playback
- **Failure Retry**: Intelligent error handling and retry mechanism

### 🔧 Technical Features
- **Dual Processor Architecture**: Streaming + Batch processors working simultaneously
- **180s Long Audio Support**: Support up to 3 minutes of continuous recording
- **Smart Status Indicators**: Simple numeric status display (0, 1, !)
- **Cache System**: Audio archive with transcription result caching

### 🌟 User Experience
- **No Clipboard Pollution**: Clean status display without interfering with system clipboard
- **One-click Retry**: Failed transcriptions can be retried without re-recording
- **Real-time Input**: Transcription results appear directly at cursor position
- **Privacy Protection**: Local processing option, data not uploaded

## 📦 Quick Start

### ⚡ One-command setup (macOS / Apple Silicon)

```bash
git clone https://github.com/HerzogFL/Whisper-Input-Next.git
cd Whisper-Input-Next
brew install cmake          # skip if you already have cmake
./setup.sh                  # venv + deps + build whisper.cpp + download model + generate .env
```

`setup.sh` does everything mechanical: creates the venv, installs deps, clones & builds whisper.cpp with Metal, downloads the `large-v3-turbo` model (~1.5GB), and writes a ready `.env` with local paths pre-filled. Two things it **can't** do for you:

1. **Doubao keys** (only if you want the real-time `Ctrl+F` streaming mode) — edit `.env` and set `DOUBAO_APP_KEY` / `DOUBAO_ACCESS_KEY`. Local `Ctrl+I` mode needs no keys.
2. **Launch + grant macOS permissions**:
   ```bash
   source .venv/bin/activate
   python main.py
   ```
   On first run, grant **Accessibility** + **Microphone** to your terminal (System Settings → Privacy & Security), then quit and relaunch the terminal once.

Then: **`Ctrl+F`** = Doubao real-time streaming · **`Ctrl+I`** = local offline (free).

> The manual step-by-step install is below if you prefer to do it yourself.

### Environment Requirements
- Python 3.12+
- macOS/Linux (Windows support in development)
- Network connection (only required for cloud services)
- **Local whisper.cpp** (required when using local transcription features)

### Installation Steps

1. **Clone Project**
```bash
git clone https://github.com/Mor-Li/Whisper-Input-Next.git
cd Whisper-Input-Next
```

2. **Create Virtual Environment**
```bash
python -m venv .venv
source .venv/bin/activate  # macOS/Linux
# or .venv\\Scripts\\activate  # Windows
```

3. **Install Dependencies**
```bash
pip install -r requirements.txt
```

4. **Install Local whisper.cpp (Optional — required only for the local `Ctrl+I` mode)**

   Modern whisper.cpp builds with **CMake** (the old `make` is deprecated). On macOS install CMake first (`brew install cmake`), then:
```bash
# Clone into the project folder (it is git-ignored, won't be committed)
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp

# Build with Metal acceleration (Apple Silicon)
cmake -B build -DGGML_METAL=ON
cmake --build build -j --config Release

# Download a model. large-v3-turbo is recommended: near large-v3 accuracy,
# 3-5x faster, ~1.5GB — ideal for an interactive voice-input tool.
bash ./models/download-ggml-model.sh large-v3-turbo

# Note the CLI path for your .env (WHISPER_CLI_PATH)
echo "Whisper CLI Path: $(pwd)/build/bin/whisper-cli"
cd ..
```

5. **Configure Environment Variables**
```bash
cp env.example .env
```
   Edit `.env` (the template has every option with comments). Minimum to get going:
   - **Doubao streaming (recommended, `Ctrl+F`)**: set `DOUBAO_APP_KEY` + `DOUBAO_ACCESS_KEY` (from the Volcengine *Speech* console — see "How to get Doubao API keys" below).
   - **Local whisper (`Ctrl+I`)**: set `WHISPER_CLI_PATH` (absolute) + `WHISPER_MODEL_PATH` (relative to the whisper.cpp root, e.g. `models/ggml-large-v3-turbo.bin`).
   - **Placeholder keys (required to boot)**: the app constructs OpenAI/Symbol/Kimi objects at startup, so `OFFICIAL_OPENAI_API_KEY`, `GROQ_API_KEY`, `KIMI_API_KEY` must be **non-empty** even if you only use Doubao/local. Any placeholder value works (the template ships with safe placeholders); replace `OFFICIAL_OPENAI_API_KEY` with a real key only if you actually use OpenAI transcription/translation.

6. **Run Program**
```bash
python main.py
# or use the startup script
chmod +x start.sh
./start.sh
```
   On first run, macOS will ask for **Accessibility** and **Microphone** permissions for your terminal app (System Settings → Privacy & Security). Grant both, then fully quit and relaunch the terminal — global hotkeys and text injection won't work until the app is "trusted".

### ⚠️ Important Notes

- **`DOUBAO_APP_KEY` / `DOUBAO_ACCESS_KEY`**: from the Volcengine **Speech** console (streaming ASR large model). This is *not* the Volcengine Ark (方舟) API key and *not* a Coze token.
- **`WHISPER_CLI_PATH`**: absolute path to the compiled `whisper-cli`.
- **`WHISPER_MODEL_PATH`**: model path relative to the whisper.cpp root directory (e.g. `models/ggml-large-v3-turbo.bin`).
- **Placeholder keys**: `OFFICIAL_OPENAI_API_KEY` / `GROQ_API_KEY` / `KIMI_API_KEY` must be non-empty for the app to start (placeholders are fine if unused).
- `whisper.cpp/` and `tools/` are git-ignored — each user compiles whisper.cpp and downloads the model locally; the large files are never committed.

## ⚙️ Configuration Guide

### Environment Variable Configuration

Configure the following parameters in the `.env` file:

```bash
# ============ Doubao Streaming ASR (Recommended, Default) ============
# Get your API keys from Volcengine Console (see screenshot below)
DOUBAO_APP_KEY=your_app_id_here        # APP ID from console
DOUBAO_ACCESS_KEY=your_access_token_here  # Access Token from console

# Transcription service selection: "doubao" (default, streaming) or "openai" (batch)
TRANSCRIPTION_SERVICE=doubao

# ============ OpenAI Configuration (Optional, for batch mode) ============
OFFICIAL_OPENAI_API_KEY=sk-proj-xxx

# ============ Local whisper.cpp (Optional, for Ctrl+I) ============
WHISPER_CLI_PATH=/path/to/whisper.cpp/build/bin/whisper-cli
WHISPER_MODEL_PATH=models/ggml-large-v3.bin

# ============ Keyboard & System Configuration ============
TRANSCRIPTIONS_BUTTON=f   # Ctrl+F: Doubao/OpenAI
LOCAL_BUTTON=i            # Ctrl+I: local whisper.cpp (customizable)
TRANSLATIONS_BUTTON=ctrl
SYSTEM_PLATFORM=mac  # mac/win

# Feature switches
ENABLE_AUDIO_ARCHIVE=false  # save recordings to audio_archive/ (default off)
CONVERT_TO_SIMPLIFIED=false
ADD_SYMBOL=false
OPTIMIZE_RESULT=false
```

<a id="how-to-get-doubao-api-keys"></a>
**How to get Doubao API keys**:

1. Go to [Volcengine Console - Speech Recognition](https://console.volcengine.com/ark/region:ark+cn-beijing/tts/speechRecognition)
2. Find your **APP ID** and **Access Token** in the "服务接口认证信息" section (see screenshot below)

<p align="center">
  <img src="assets/images/volcengine_doubao_api_keys.png" alt="Volcengine Doubao API Keys" width="800" />
</p>

**Important Notes**:
- **Doubao Streaming ASR** is now the default and recommended transcription service
- Set `TRANSCRIPTION_SERVICE=openai` to use OpenAI batch mode instead

### Quick Start with Aliases (Recommended)

Add these aliases to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
alias whisper_input='cd /path/to/Whisper-Input-Next && ./start.sh'
alias whisper_input_off='tmux kill-session -t whisper-input'
```

Replace `/path/to/Whisper-Input-Next` with your actual project path.

### Hotkey Instructions

| Hotkey | Function | Service | Features |
|--------|----------|---------|-----------|
| `Ctrl+F` | **Real-time streaming transcription** | Doubao Seed ASR 2.0 (default) | Ultra-low latency, floating preview, text appears as you speak |
| `Ctrl+I` | Local transcription | whisper.cpp | Offline processing, privacy protection |

> **Note**: Set `TRANSCRIPTION_SERVICE=openai` in `.env` to use OpenAI GPT-4o transcribe instead of Doubao for Ctrl+F.

### Status Indicators

The program displays concise status indicators at the cursor position during runtime:

| Status | Meaning | Action |
|--------|---------|--------|
| `0` | Recording | Press hotkey again to stop recording |
| `1` | Transcribing | Please wait for transcription to complete |
| `!` | Transcription failed/error | Press `Ctrl+F` again to retry (audio saved) |

**Design Optimizations**:
- Use concise numeric status, avoid complex emoji symbols
- No system clipboard pollution, display only at cursor position
- Clear and intuitive status, easy to quickly identify

**Retry Mechanism Instructions**:
- When transcription fails, the system saves the recording and displays `!` status
- No need to re-record, simply press `Ctrl+F` to retry
- Retry uses previously saved audio until transcription succeeds

## 📚 Feature Documentation

- [🔊 Audio Archive Feature](./docs/[V3.0.0]_AUDIO_ARCHIVE_FEATURE.md) - *Introduced in v3.0.0*
- [🤖 Kimi Polish Integration](./docs/[DEPRECATED]_KIMI_USAGE.md) - *Deprecated*
- [📊 Status Display Improvements](./docs/[V3.0.0]_STATUS_DISPLAY_IMPROVEMENTS.md) - *Introduced in v3.0.0*
- [🔄 Branch Differences Comparison](./docs/[V3.0.0]_BRANCH_DIFFERENCES.md) - *Introduced in v3.0.0*
- [📋 Version Control Documentation](./docs/[V3.0.0]_VERSION_CONTROL.md) - *Established in v3.0.0*

## 🛠️ Development Status

### ✅ Completed Features
- [x] **Two-pass recognition for higher accuracy** *(NEW in v3.3.0)*
- [x] **Deferred text output with full-context optimization** *(NEW in v3.3.0)*
- [x] **DJI Wireless Mic auto-detection** *(NEW in v3.3.0)*
- [x] **Doubao Streaming ASR integration** *(v3.2.0)*
- [x] **Floating preview window for real-time feedback** *(v3.2.0)*
- [x] OpenAI GPT-4o transcribe integration
- [x] Audio archive system
- [x] Local whisper support
- [x] Dual processor architecture
- [x] Smart retry mechanism
- [x] Project documentation improvement
- [x] 10-minute recording limit protection
- [x] Status indicator delay optimization
- [x] Audio format conversion support (m4a to wav)
- [x] Bilingual documentation system
- [x] GPT-4o terminology standardization

### 🚧 In Development  
*No features currently in development*

### 📋 Planned Features
*No features currently planned*

### 🧪 Experimental Features History

#### iOS Keyboard Extension Experiment (August 14, 2025)
**Status**: ❌ Discontinued due to Apple's restrictions  
Attempted to create iOS keyboard extension but discovered that even Sogou Input Method cannot directly record audio in keyboard extensions due to Apple's system limitations. iOS voice input is currently not feasible as a seamless keyboard extension.

## 🤝 Contributing Guidelines

We welcome all forms of contributions! Whether it's:

- 🐛 **Bug Reports**: Found an issue? [Create an Issue](https://github.com/Mor-Li/Whisper-Input-Next/issues)
- 💡 **Feature Suggestions**: Have great ideas? [Start a Discussion](https://github.com/Mor-Li/Whisper-Input-Next/discussions)
- 📝 **Code Contributions**: Submit Pull Requests
- 📚 **Documentation Improvements**: Help improve documentation
- 🌍 **Translations**: Help translate to more languages

### Development Environment Setup

```bash
# Clone repository
git clone https://github.com/Mor-Li/Whisper-Input-Next.git
cd Whisper-Input-Next

# Create development environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start development
python main.py
```

## 🙏 Acknowledgments

- Thanks to [ErlichLiu/Whisper-Input](https://github.com/ErlichLiu/Whisper-Input) for the original project foundation
- Thanks to [ByteDance/Volcengine](https://www.volcengine.com/) for the excellent Doubao Seed ASR 2.0 streaming API
- Thanks to OpenAI for providing excellent transcription API services
- Thanks to [whisper.cpp](https://github.com/ggerganov/whisper.cpp) community for local processing support
- Thanks to all contributors and users for their support

## 📞 Contact Information

- **Project Address**: https://github.com/Mor-Li/Whisper-Input-Next  
- **Issue Reports**: [Issues](https://github.com/Mor-Li/Whisper-Input-Next/issues)
- **Feature Suggestions**: [Discussions](https://github.com/Mor-Li/Whisper-Input-Next/discussions)

## 📋 Changelog

### Stability fixes (deadlock-free on macOS + Python 3.13)
- **Persistent audio stream**: The audio stream is now opened once and kept alive; recording start/stop only toggles a capture flag instead of tearing down the stream each time. This eliminates an intermittent PortAudio↔CoreAudio teardown deadlock (`AudioOutputUnitStop` ↔ `HALB_Mutex`) that could freeze the app after a while (symptom: gray mic icon, hotkey stops responding).
- **Off-thread recording toggle**: Start/stop work is dispatched off the pynput keyboard-event-tap thread, so a slow audio op can never block the global keyboard input pipeline.
- **Accessibility caret query timeout**: `AXUIElementSetMessagingTimeout(1.0)` on caret-position lookups prevents an unresponsive foreground app from hanging the main thread.
- **Python 3.13 fix**: Bump `pynput` to ≥1.8.2 (1.7.7 crashed the keyboard listener on Python 3.13 via `_thread._ThreadHandle`).
- **Chinese macOS mic detection**: Add `麦克风` keywords so the built-in mic ("MacBook Pro麦克风") is recognized on Chinese systems.
- **New options**: `LOCAL_BUTTON` (customize the local-whisper hotkey, default `i`), `ENABLE_AUDIO_ARCHIVE` (default `false`, recordings no longer saved to disk by default).

### v3.3.0 (2026-03-11)
- **Two-pass recognition**: Enable `enable_nonstream` for sentence-level re-recognition with nostream model, significantly improving accuracy (e.g. "广告位" → "光标位置")
- **Deferred text output**: All text stays in floating preview during recording; final text pasted only after stop, allowing full ASR context optimization
- **DJI Wireless Mic support**: Auto-detect and prioritize DJI Wireless Microphone as highest priority input device
- **Lower latency**: Reduce streaming chunk size from 200ms to 100ms
- **Faster streaming**: Remove artificial delays in audio packet sending

### v3.2.0 (2025-07-27)
- **Doubao Streaming ASR**: Real-time streaming transcription powered by ByteDance Seed ASR 2.0
- **Floating preview window**: Shows pending text in real-time near input field
- **Auto audio device switching**: Priority-based microphone selection

### v3.0.0
- OpenAI GPT-4o transcribe integration
- Audio archive system
- Local whisper.cpp support
- Dual processor architecture

---

**⭐ If this project helps you, please give it a Star for support!**