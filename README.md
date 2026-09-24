# ⚡ macOS Apple Silicon & Intel Modular Dotfiles Suite

<p align="center">
  <img src="https://img.shields.io/badge/macOS-Apple%20Silicon%20%26%20Intel-black?style=for-the-badge&logo=apple" alt="macOS" />
  <img src="https://img.shields.io/badge/Shell-Zsh%20(Modular)-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Zsh" />
  <img src="https://img.shields.io/badge/Window%20Manager-Paneru%20(Niri--Style)-purple?style=for-the-badge" alt="Paneru" />
  <img src="https://img.shields.io/badge/Status%20Bar-Sketchybar-blue?style=for-the-badge" alt="Sketchybar" />
  <img src="https://img.shields.io/badge/Terminal-Ghostty-orange?style=for-the-badge" alt="Ghostty" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

A blazingly fast, aesthetically curated, and completely modular dotfiles suite for **macOS (Apple Silicon M1/M2/M3/M4 & Intel)**. 

Engineered for keyboard-driven efficiency, instantaneous shell startup, buttery smooth window navigation, and zero-latency macOS UI interactions.

---

## 📑 Table of Contents

- [✨ Highlights](#-highlights)
- [📦 Repository Architecture](#-repository-architecture)
- [🚀 Quick Start Installation](#-quick-start-installation)
  - [Prerequisites](#prerequisites)
  - [Automated 1-Step Setup](#automated-1-step-setup)
  - [Installer Flags](#installer-flags)
- [🧩 Detailed Breakdown of Components](#-detailed-breakdown-of-components)
  - [1. Modular Zsh Suite (`~/.zshrc.d/`)](#1-modular-zsh-suite-zshrcd)
  - [2. Niri-Style Sliding Window Manager (`paneru`)](#2-niri-style-sliding-window-manager-paneru)
  - [3. Dynamic Status Bar & Borders (`sketchybar` & `borders`)](#3-dynamic-status-bar--borders-sketchybar--borders)
  - [4. High-Performance Terminal (`ghostty`)](#4-high-performance-terminal-ghostty)
  - [5. macOS Latency Elimination (`macos_speedup.sh`)](#5-macos-latency-elimination-macos_speedupsh)
- [⌨️ Keybindings Cheat Sheet](#%EF%B8%8F-keybindings-cheat-sheet)
  - [Paneru Window Management](#paneru-window-management)
  - [Zsh Vim Navigation](#zsh-vim-navigation)
- [🔄 Safe Backup & Rollback](#-safe-backup--rollback)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Highlights

- 🏎️ **Sub-15ms Zsh Startup**: High-efficiency shell loader using 24-hour cached `compinit` bytecode (`.zwc`) and pre-cached `vivid` syntax colors (`LS_COLORS`).
- ⌨️ **Vim-Mode Terminal with Dynamic Cursor**: Auto-switches between a Solid Block (`█`) in Vim command mode and a Pipe (`|`) in Insert mode, paired with instant typed-prefix history search.
- 🪟 **Sliding Ribbon Window Management**: Smooth scrolling window ribbons powered by `paneru` (inspired by Linux's Niri) with left-aligned eager snapping, multi-touch trackpad gestures, and zero auto-centering lag.
- 🎨 **Unified Aesthetic Palette**: Dracula & Cyberpunk Snazzy styling across Ghostty, Sketchybar, JankyBorders, FZF-tab, and Fastfetch.
- 🛡️ **Non-Destructive & Safe Installer**: Automatically creates timestamped backups in `~/.dotfiles_backup/` before linking any configuration file.
- ⚡ **Zero-Delay macOS UI**: Optional system optimizations to strip artificial Dock hover delays and set an ultra-fast 15ms keyboard repeat rate.

---

## 📦 Repository Architecture

All configurations adhere strictly to the standard XDG directory layout and modular shell design:

```plaintext
dotfiles/
├── .zshrc                          # Lightweight root loader sourcing ~/.zshrc.d/*.zsh
├── zshrc.d/                        # Cleanly separated, numbered Zsh modules
│   ├── 10-env.zsh                  # Portable brew paths, PATH, default editor
│   ├── 20-completion.zsh           # Fast compinit (24h cache) & vivid snazzy LS_COLORS
│   ├── 30-fzf.zsh                  # fzf-tab & Dracula/Snazzy interactive preview styles
│   ├── 40-aliases.zsh              # eza, bat, zed, yazi, and ghostty shortcuts
│   ├── 50-plugins.zsh              # Dynamic syntax highlighting & autosuggestions
│   ├── 60-vim-keybindings.zsh      # Vim mode, block/beam cursor, prefix history search
│   ├── 70-functions.zsh            # Custom functions & hooks (suppresses cd noise)
│   └── 80-prompt.zsh               # Clean 2-line minimal prompt with realtime Vim status
├── config/                         # Mirrors ~/.config/
│   ├── borders/                    # JankyBorders window outline styling
│   │   └── bordersrc
│   ├── fastfetch/                  # Fastfetch system specification layout
│   │   └── config.jsonc
│   ├── ghostty/                    # Ghostty terminal config, themes & manager scripts
│   │   ├── config
│   │   ├── config-manager.sh
│   │   ├── theme-picker.sh
│   │   └── themes/
│   ├── paneru/                     # Niri-style sliding window manager
│   │   └── paneru.toml
│   └── sketchybar/                 # Dynamic status bar and event-driven plugins
│       ├── sketchybarrc
│       └── plugins/
│           ├── battery.sh
│           ├── date.sh
│           ├── volume.sh
│           └── windows.sh
├── scripts/
│   ├── macos_speedup.sh            # Animation & keyboard repeat optimizations
│   └── reset_windows.sh            # Emergency window rescue script
├── assets/
│   └── wallpaper.jpg               # Curated desktop wallpaper
├── Brewfile                        # Declarative list of Homebrew formulae & casks
├── install.sh                      # Universal automated installer
├── LICENSE                         # MIT License
└── README.md                       # Documentation & setup guide
```

---

## 🚀 Quick Start Installation

### Prerequisites

- macOS running on **Apple Silicon (M1/M2/M3/M4)** or **Intel (x86_64)**.
- [Homebrew](https://brew.sh) package manager.
- Git (comes with macOS Developer Tools: `xcode-select --install`).

### Automated 1-Step Setup

Clone the repository to `~/.dotfiles` and launch the automated installer:

```bash
git clone https://github.com/RazerZS-oss/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer will:
1. Detect your hardware architecture (Apple Silicon vs Intel).
2. Prompt to install all required packages via `brew bundle` (`Brewfile`).
3. Safely back up existing configurations to `~/.dotfiles_backup/<timestamp>/`.
4. Create atomic symlinks to `~/.zshrc`, `~/.zshrc.d`, and `~/.config/*`.
5. Install the `fzf-tab` plugin for interactive completion dropdowns.
6. Offer to apply macOS UI speedups.

Once complete, simply reload your terminal:
```bash
source ~/.zshrc
```

### Installer Flags

For automated or unattended setups:
```bash
./install.sh --yes              # Auto-confirm all prompts
./install.sh --skip-brew        # Skip Homebrew package bundling
./install.sh --skip-speedup     # Skip macOS UI latency optimizations
./install.sh --help             # Display help options
```

---

## 🧩 Detailed Breakdown of Components

### 1. Modular Zsh Suite (`~/.zshrc.d/`)
Rather than maintaining a bloated, unmaintainable single `.zshrc` file, the shell configuration is partitioned into structured, isolated modules loaded in numerical sequence:
- **`10-env.zsh`**: Dynamically detects the correct Homebrew environment (`/opt/homebrew` on Apple Silicon or `/usr/local` on Intel), exports `$HOME/.local/bin` to `PATH`, sets `BAT_THEME="Dracula"`, and detects the default editor (`micro` $\rightarrow$ `nano` $\rightarrow$ `vim`).
- **`20-completion.zsh`**: Checks file modification timestamps on `.zcompdump` to ensure expensive re-indexing only happens once per day. Spawns background byte-compilation (`zcompile &!`) and reads pre-cached vivid `LS_COLORS`.
- **`30-fzf.zsh`**: Configures `fzf-tab` dropdown completions with real-time directory listing via `eza` and file syntax preview via `bat`.
- **`40-aliases.zsh`**: Ergonomic shortcuts (`ls` $\rightarrow$ `eza`, `cat` $\rightarrow$ `bat`, `edit` $\rightarrow$ `micro`, `z`/`zed` $\rightarrow$ Zed editor, `yy` $\rightarrow$ Yazi).
- **`50-plugins.zsh`**: Integrates syntax highlighting and command autosuggestions directly from Homebrew without third-party framework overhead.
- **`60-vim-keybindings.zsh`**: Complete Vim editing engine:
  - Instant transition between Insert and Command mode (`Esc` / `i`).
  - Terminal cursor shape morphing: **Pipe** (`|`) in Insert mode, **Block** (`█`) in Command mode.
  - Native typed-prefix history lookup via `Up`/`Down` and `k`/`j`.
  - Pressing `Ctrl + C` instantly cancels the line and resets status to `[ INSERT ]`.
- **`70-functions.zsh`**: Cleans up shell output by silencing automatic directory listings on `cd`.
- **`80-prompt.zsh`**: Minimalist 2-line prompt with path, colored symbol, and dynamic right-aligned Vim status indicator.

---

### 2. Niri-Style Sliding Window Manager (`paneru`)
Configured in `config/paneru/paneru.toml`:
- **Ribbon Layout**: Windows arrange horizontally along an infinite desktop ribbon, smoothly scrolling as focus moves.
- **Eager Left Alignment**: Windows snap flush to the left edge of the screen rather than being forced into the center.
- **Multi-Touch Gestures**: Seamless 3-finger swipe navigation to scroll between active windows.
- **Preset Column Widths**: Effortlessly toggle between `1/3`, `1/2`, `2/3`, and full screen (`1.0`).
- **Emergency Window Reset**: If a display disconnects or windows ever drift off-screen, run `./scripts/reset_windows.sh` to immediately snap all windows back to the primary display.

---

### 3. Dynamic Status Bar & Borders (`sketchybar` & `borders`)
- **JankyBorders (`config/borders/bordersrc`)**: Clean, rounded window borders highlighting the active focused window.
- **SketchyBar (`config/sketchybar/sketchybarrc`)**: Minimalist status bar displaying workspace indicators, active window titles, volume levels, battery charge, and time with dynamic event hooks.

To start services:
```bash
brew services start borders
brew services start sketchybar
```

---

### 4. High-Performance Terminal (`ghostty`)
Located in `config/ghostty/`:
- Native macOS vibrancy, blur radius (`70`), and semi-transparency (`0.50`).
- Built-in theme picker script (`theme`) and config manager (`conf`).
- Option key mapped cleanly as `Alt` for instant 2-key window management shortcuts.

---

### 5. macOS Latency Elimination (`macos_speedup.sh`)
macOS introduces built-in animation delays that make fast machines feel sluggish. `scripts/macos_speedup.sh` strips this overhead:
- **Instant Dock**: Eliminates the 0.5s auto-hide hover pause (`autohide-delay = 0`) and sets a crisp 0.12s slide animation.
- **Lightning Key Repeat**: Lowers initial key repeat delay to `10` (150ms) and repeat rate to `1` (15ms)—essential for smooth Vim navigation.
- **Quick-Look & Window Snappiness**: Disables window resize and dialog slide delays.

*To revert macOS animations back to factory defaults at any time:*
```bash
./scripts/macos_speedup.sh --revert
```

---

## ⌨️ Keybindings Cheat Sheet

### Paneru Window Management

| Shortcut | Action |
| :--- | :--- |
| `Option + H` | Focus window to the left (West) |
| `Option + L` | Focus window to the right (East) |
| `Option + J` | Swap / move window left |
| `Option + K` | Swap / move window right |
| `Option + R` / `Option + =` | Expand window column width |
| `Option + -` | Shrink window column width |
| `Option + F` | Toggle full-width window (Ribbon fullscreen) |
| `Option + S` | Snap window flush to display edge |
| `Option + C` | Center window manually |
| `Option + T` / `Option + M` | Toggle window between Tile and Float |
| `Option + Q` | Quit Paneru daemon |

### Zsh Vim Navigation

| Mode | Keybinding | Action |
| :--- | :--- | :--- |
| **Insert** | `Esc` | Enter Vim Command Mode (Cursor becomes `█`) |
| **Insert** | `Ctrl + K` / `▲` | Search history upward matching typed prefix |
| **Insert** | `Ctrl + J` / `▼` | Search history downward matching typed prefix |
| **Vim (Cmd)** | `i` / `a` | Enter Insert Mode (Cursor becomes `\|`) |
| **Vim (Cmd)** | `k` / `j` | Search history by typed prefix |
| **Vim (Cmd)** | `v` / `V` | Visual / Visual Line selection mode |
| **Vim (Cmd)** | `x` / `Backspace` | Delete character |
| **Global** | `Ctrl + C` | Cancel line & reset status to `[ INSERT ]` |

---

## 🔄 Safe Backup & Rollback

Before linking any configuration, `install.sh` saves your previous files in:
```plaintext
~/.dotfiles_backup/YYYYMMDD_HHMMSS/
```

To restore an old configuration, simply copy the backed-up directory back to `$HOME`:
```bash
cp -R ~/.dotfiles_backup/<timestamp>/.zshrc ~/.zshrc
cp -R ~/.dotfiles_backup/<timestamp>/.config/* ~/.config/
```

---

## 🤝 Contributing

Contributions, issues, and suggestions are welcome! Feel free to open an issue or pull request on GitHub.

---

## 📄 License

This repository is licensed under the [MIT License](LICENSE).
Created with 💜 by [RazerZS-oss](https://github.com/RazerZS-oss).
