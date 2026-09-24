# Specification: macOS Dotfiles Suite

## 1. Overview & Goal
Transform the local configuration workspace into a clean, modern, modular macOS dotfiles repository (`dotfiles`), fully debugged and portable so any other Mac user (Apple Silicon or Intel) can install and use it. Once verified, initialize and push as a new public repository `RazerZS-oss/dotfiles` on GitHub.

## 2. Repository Layout & Architecture
The repository will follow a clean, standardized structure:

```plaintext
dotfiles/
├── .zshrc                          # Lightweight loader sourcing ~/.zshrc.d/*.zsh
├── zshrc.d/                        # Modular Zsh configurations
│   ├── 10-env.zsh                  # Portable brew paths, PATH, default editor
│   ├── 20-completion.zsh           # Fast compinit (24h cache) & vivid snazzy LS_COLORS
│   ├── 30-fzf.zsh                  # fzf-tab plugin & interactive preview styles
│   ├── 40-aliases.zsh              # eza, bat, zed, yazi, and ghostty shortcuts
│   ├── 50-plugins.zsh              # Syntax highlighting & autosuggestions
│   ├── 60-vim-keybindings.zsh      # Vim mode, block/beam cursor, prefix history search
│   ├── 70-functions.zsh            # Custom functions & hooks
│   └── 80-prompt.zsh               # Two-line clean prompt with Vim mode status
├── config/                         # Standard XDG ~/.config mirrors
│   ├── borders/
│   │   └── bordersrc               # JankyBorders configuration
│   ├── fastfetch/
│   │   └── config.jsonc            # Fastfetch system info layout
│   ├── ghostty/
│   │   ├── config                  # Ghostty terminal config
│   │   ├── config-manager.sh       # Ghostty config switcher
│   │   ├── theme-picker.sh         # Ghostty theme picker
│   │   └── themes/                 # Ghostty theme files
│   ├── paneru/
│   │   └── paneru.toml             # Paneru tiling window manager config
│   └── sketchybar/
│       ├── sketchybarrc            # Sketchybar status bar config
│       └── plugins/
│           ├── battery.sh
│           ├── date.sh
│           ├── volume.sh
│           └── windows.sh
├── scripts/
│   ├── macos_speedup.sh            # Animation & keyboard repeat optimizations
│   └── reset_windows.sh            # Emergency window rescue script
├── assets/
│   └── wallpaper.jpg               # Desktop wallpaper
├── Brewfile                        # Declarative list of Homebrew formulae & casks
├── install.sh                      # Universal installer script
├── LICENSE                         # MIT License
└── README.md                       # Comprehensive guide, badges, setup, keybindings
```

`pdf-converter/` and its previous task planning docs will be safely moved out of the dotfiles repository to preserve them independently without bloating the dotfiles.

## 3. Portability & Configuration Fixes
Each module in `zshrc.d/` will be debugged for multi-machine portability:
- **`10-env.zsh`**:
  - Dynamically detect Homebrew on Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`).
  - Replace hardcoded `/Users/roy/.local/bin` with `"$HOME/.local/bin"`.
  - Set `EDITOR` (fallback to `nano`/`vim` if `micro` is missing).
- **`20-completion.zsh`**:
  - Safe caching of `compinit` (24h invalidation) and byte-compilation (`.zwc`).
  - Safe checking of `vivid` command existence before generating/sourcing colors.
- **`30-fzf.zsh`**:
  - Check existence of `~/.zsh/fzf-tab/fzf-tab.plugin.zsh` before sourcing.
  - Fall back gracefully to `ls`/`head` if `eza`/`bat` are not installed.
- **`40-aliases.zsh`**:
  - Make aliases conditional on binary availability (`eza`, `bat`, `yazi`, `mpv`).
- **`50-plugins.zsh`**:
  - Check plugin paths under `${HOMEBREW_PREFIX}/share/...` dynamically.
- **`60-vim-keybindings.zsh`**:
  - Clean cursor mode switching and prefix history navigation.
- **`70-functions.zsh` & `80-prompt.zsh`**:
  - Clean hook management and prompt definition.

## 4. Automated Installer (`install.sh`)
The installer will:
1. Validate macOS environment.
2. Check for Homebrew; provide prompt to install or run `brew bundle --file=Brewfile`.
3. Create a timestamped backup directory at `~/.dotfiles_backup/<timestamp>/` and move existing configs safely before linking.
4. Create symlinks:
   - `~/.zshrc` -> `<repo>/.zshrc`
   - `~/.zshrc.d` -> `<repo>/zshrc.d`
   - `~/.config/borders` -> `<repo>/config/borders`
   - `~/.config/fastfetch` -> `<repo>/config/fastfetch`
   - `~/.config/ghostty` -> `<repo>/config/ghostty`
   - `~/.config/paneru` -> `<repo>/config/paneru`
   - `~/.config/sketchybar` -> `<repo>/config/sketchybar`
5. Clone `fzf-tab` to `~/.zsh/fzf-tab` if missing.
6. Provide an option to apply macOS UI speedups (`scripts/macos_speedup.sh`).

## 5. Documentation & GitHub Push
- Create a complete `README.md` with features, prerequisites, one-liner and manual install steps, keybindings cheatsheet, and uninstallation guide.
- Initialize/reconfigure git remote to point to `https://github.com/RazerZS-oss/dotfiles.git`.
- Create public repository on GitHub using `gh repo create RazerZS-oss/dotfiles --public --source=. --remote=origin --push`.
