# macOS Dotfiles Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the configuration workspace into an organized, modular macOS dotfiles repository with an automated backup/installer script (`install.sh`), debugged portable Zsh modules, Homebrew `Brewfile`, comprehensive documentation, and push to a new public GitHub repository `RazerZS-oss/dotfiles`.

**Architecture:** Standardized modular dotfiles layout separating shell configurations (`.zshrc`, `zshrc.d/`), application configs (`config/borders`, `config/fastfetch`, `config/ghostty`, `config/paneru`, `config/sketchybar`), helper scripts (`scripts/`), desktop assets (`assets/`), and system packages (`Brewfile`), orchestrated by an idempotent `install.sh` that safely creates backups before linking.

**Tech Stack:** Bash, Zsh, Homebrew (`brew bundle`), JankyBorders, Paneru, Sketchybar, Fastfetch, Ghostty, GitHub CLI (`gh`).

**Spec:** `docs/superpowers/specs/2026-09-24-dotfiles-design.md`

## Global Constraints
- Target platform: macOS (Apple Silicon ARM64 and Intel x86_64).
- Safe backup first: Never overwrite any user configuration file without a timestamped backup.
- Dynamic paths: Do NOT hardcode `/Users/roy` or static `/opt/homebrew` without checking fallback to `/usr/local`.
- Zero broken dependencies: All modules must handle missing commands gracefully without spamming stderr on startup.
- Repository visibility: Public on GitHub (`RazerZS-oss/dotfiles`).

---

### Task 1: Preserve pdf-converter & Workspace Directory Scaffolding

**Files:**
- Move: `pdf-converter` -> `/Users/roy/project/pdf-converter` (preserving the standalone tool outside dotfiles)
- Create directories:
  - `zshrc.d/`
  - `config/borders/`
  - `config/fastfetch/`
  - `config/ghostty/`
  - `config/paneru/`
  - `config/sketchybar/`
  - `scripts/`
  - `assets/`

**Interfaces:**
- Consumes: Existing files in `/Users/roy/project/config`
- Produces: Clean base directories for the dotfiles hierarchy

- [ ] **Step 1: Safely copy pdf-converter to standalone location outside dotfiles**

```bash
mkdir -p /Users/roy/project/pdf-converter
cp -R /Users/roy/project/config/pdf-converter/* /Users/roy/project/pdf-converter/
```

- [ ] **Step 2: Remove pdf-converter from dotfiles repository workspace**

```bash
rm -rf /Users/roy/project/config/pdf-converter
```

- [ ] **Step 3: Create target directory structure**

```bash
mkdir -p zshrc.d config/borders config/fastfetch config/ghostty config/paneru config/sketchybar scripts assets
```

- [ ] **Step 4: Commit clean directory scaffolding**

```bash
git rm -rf --cached . 2>/dev/null || true
git add .
git commit -m "chore: scaffold dotfiles directory structure"
```

---

### Task 2: Port and Debug Modular Zsh Configuration Suite

**Files:**
- Create/Move:
  - `.zshrc` (entry loader)
  - `zshrc.d/10-env.zsh`
  - `zshrc.d/20-completion.zsh`
  - `zshrc.d/30-fzf.zsh`
  - `zshrc.d/40-aliases.zsh`
  - `zshrc.d/50-plugins.zsh`
  - `zshrc.d/60-vim-keybindings.zsh`
  - `zshrc.d/70-functions.zsh`
  - `zshrc.d/80-prompt.zsh`

**Interfaces:**
- Consumes: Existing modules from `~/.zshrc.d/` and local repo
- Produces: Fully portable, standalone Zsh module suite without hardcoded user directories

- [ ] **Step 1: Write `.zshrc` root loader**

```zsh
# ~/.zshrc - Modular Zsh Configuration Loader
# Loads all *.zsh configuration files from ~/.zshrc.d in alphanumeric order.

if [[ -d "$HOME/.zshrc.d" ]]; then
  for module in "$HOME/.zshrc.d/"*.zsh(N); do
    source "$module"
  done
  unset module
fi
```

- [ ] **Step 2: Write portable `zshrc.d/10-env.zsh`**

```zsh
# 10-env.zsh - Environment Variables & Dynamic Homebrew PATH

# Dynamically discover Homebrew prefix for Apple Silicon (/opt/homebrew) or Intel (/usr/local)
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv zsh)"
  fi
fi

# User Local Binaries
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Tool Defaults
export BAT_THEME="Dracula"
export CLICOLOR=1

# Default Editor: micro -> nano -> vim
if (( $+commands[micro] )); then
  export EDITOR='micro'
elif (( $+commands[nano] )); then
  export EDITOR='nano'
else
  export EDITOR='vim'
fi
```

- [ ] **Step 3: Write `zshrc.d/20-completion.zsh` with cached compinit**

```zsh
# 20-completion.zsh - High-Performance Completion & LS_COLORS Caching
autoload -Uz compinit

# Fast compinit: only re-index completions once every 24 hours
_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -s "$_zcompdump" && $(($(date +%s) - $(stat -f %m "$_zcompdump" 2>/dev/null || echo 0))) -lt 86400 ]]; then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
  { zcompile "$_zcompdump" } 2>/dev/null &!
fi

# Cache LS_COLORS from vivid (snazzy theme)
_lscache="${XDG_CACHE_HOME:-$HOME/.cache}/ls_colors_snazzy"
if [[ ! -s "$_lscache" ]] && (( $+commands[vivid] )); then
  mkdir -p "${_lscache:h}"
  vivid generate snazzy > "$_lscache" 2>/dev/null
fi

if [[ -s "$_lscache" ]]; then
  export LS_COLORS="$(<"$_lscache")"
elif (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate snazzy 2>/dev/null)"
fi

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format $'\e[1;38;5;212m✦ [ %d ]\e[0m'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select

unset _zcompdump _lscache
```

- [ ] **Step 4: Write `zshrc.d/30-fzf.zsh` with fallback handling**

```zsh
# 30-fzf.zsh - FZF-tab & Interactive Search Styling
if [[ -f "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"
fi

# FZF Dracula & Snazzy Palette
zstyle ':fzf-tab:*' fzf-flags \
   --color=bg+:#282a36,fg+:#f8f8f2,hl:#ff79c6,hl+:#50fa7b \
   --color=info:#bd93f9,prompt:#8be9fd,pointer:#00f5d4,marker:#ff79c6,header:#8be9fd,border:#6272a4 \
   --preview-window=right:55%:wrap \
   --border=rounded

# Previews with safe tool fallbacks
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range :50 $realpath 2>/dev/null || head -n 50 $realpath'
```

- [ ] **Step 5: Write `zshrc.d/40-aliases.zsh` with command checks**

```zsh
# 40-aliases.zsh - Aliases with safe binary detection

# Modern CLI replacements
if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first'
fi

if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
fi

if (( $+commands[micro] )); then
  alias edit='micro'
  alias nano='micro'
fi

# GUI & Media Tools
alias z="open -a Zed"
alias zed="open -a Zed"
alias gsc='git status | pbcopy'

if (( $+commands[mpv] )); then
  alias mpv='mpv'
elif [[ -x /opt/homebrew/bin/mpv ]]; then
  alias mpv='/opt/homebrew/bin/mpv'
fi

if (( $+commands[yazi] )); then
  alias yy='yazi'
elif [[ -x /opt/homebrew/bin/yazi ]]; then
  alias yy='/opt/homebrew/bin/yazi'
fi

# Ghostty config shortcuts (if ghostty scripts exist)
if [[ -f "$HOME/.config/ghostty/config-manager.sh" ]]; then
  alias conf='source ~/.config/ghostty/config-manager.sh'
  alias cfg='source ~/.config/ghostty/config-manager.sh'
fi
if [[ -f "$HOME/.config/ghostty/theme-picker.sh" ]]; then
  alias theme='source ~/.config/ghostty/theme-picker.sh'
fi
```

- [ ] **Step 6: Write `zshrc.d/50-plugins.zsh`, `60-vim-keybindings.zsh`, `70-functions.zsh`, `80-prompt.zsh`**

Implement dynamic plugin detection using `${HOMEBREW_PREFIX:-/opt/homebrew}/share/...`, clean vim mode handling, and 2-line prompt.

- [ ] **Step 7: Test syntax of all `.zsh` files**

Run: `zsh -n .zshrc && for f in zshrc.d/*.zsh; do zsh -n "$f"; done`
Expected: Return 0 (no syntax errors)

- [ ] **Step 8: Commit modular Zsh configs**

```bash
git add .zshrc zshrc.d/
git commit -m "feat(zsh): port and debug all modular zshrc.d configurations"
```

---

### Task 3: Organize XDG `config/`, `scripts/`, `assets/`, and Create `Brewfile`

**Files:**
- Move:
  - `bordersrc` -> `config/borders/bordersrc`
  - `fastfetch/config.jsonc` -> `config/fastfetch/config.jsonc`
  - `paneru.toml` -> `config/paneru/paneru.toml`
  - `sketchybar/*` -> `config/sketchybar/`
  - `macos_speedup.sh` -> `scripts/macos_speedup.sh`
  - `reset_windows.sh` -> `scripts/reset_windows.sh`
  - `wallpaper.jpg` -> `assets/wallpaper.jpg`
- Copy:
  - `~/.config/ghostty/*` -> `config/ghostty/`
- Create:
  - `Brewfile`

**Interfaces:**
- Consumes: System configs from `~/.config/ghostty` and existing repo files
- Produces: Clean, standard XDG directory structure and Homebrew package manifest

- [ ] **Step 1: Move and organize application configs into `config/`**

```bash
mv bordersrc config/borders/bordersrc
mv fastfetch config/fastfetch/ 2>/dev/null || true
mv paneru.toml config/paneru/paneru.toml
mv sketchybar config/sketchybar/ 2>/dev/null || true
cp -R ~/.config/ghostty/* config/ghostty/
```

- [ ] **Step 2: Move helper scripts to `scripts/` and wallpaper to `assets/`**

```bash
mv macos_speedup.sh scripts/macos_speedup.sh
mv reset_windows.sh scripts/reset_windows.sh
mv wallpaper.jpg assets/wallpaper.jpg
rm -f apply_zsh.sh 10-env.zsh 20-completion.zsh
```

- [ ] **Step 3: Create declarative `Brewfile`**

```ruby
# Taps
tap "FelixKratz/formulae"

# CLI Tools
brew "bat"
brew "eza"
brew "fastfetch"
brew "fzf"
brew "micro"
brew "vivid"
brew "yazi"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# macOS Desktop & Tiling Window Manager Suite
brew "FelixKratz/formulae/borders"
brew "FelixKratz/formulae/sketchybar"

# Applications / Casks
cask "ghostty"
cask "zed"
cask "font-hack-nerd-font"
cask "font-jetbrains-mono-nerd-font"
```

- [ ] **Step 4: Verify permissions on scripts and config files**

```bash
chmod +x scripts/*.sh config/sketchybar/sketchybarrc config/sketchybar/plugins/*.sh config/ghostty/*.sh config/borders/bordersrc
```

- [ ] **Step 5: Commit XDG configuration layout and Brewfile**

```bash
git add config/ scripts/ assets/ Brewfile
git commit -m "feat(config): organize xdg configs, scripts, assets, and Brewfile"
```

---

### Task 4: Develop Universal Automated Installer (`install.sh`)

**Files:**
- Create: `install.sh`

**Interfaces:**
- Consumes: Repository files in `.`, `config/`, `zshrc.d/`, `Brewfile`
- Produces: Safe, backup-preserving installation onto any target Mac

- [ ] **Step 1: Implement `install.sh`**

The installer must:
1. Verify macOS running on ARM64 or x86_64.
2. Provide non-destructive backup mechanism to `~/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)`.
3. Support unattended/silent mode via flags (`--non-interactive` / `-y`).
4. Optionally run `brew bundle --file=Brewfile` if Homebrew is available.
5. Create symlinks for:
   - `~/.zshrc` -> `${DOTFILES_DIR}/.zshrc`
   - `~/.zshrc.d` -> `${DOTFILES_DIR}/zshrc.d`
   - `~/.config/borders` -> `${DOTFILES_DIR}/config/borders`
   - `~/.config/fastfetch` -> `${DOTFILES_DIR}/config/fastfetch`
   - `~/.config/ghostty` -> `${DOTFILES_DIR}/config/ghostty`
   - `~/.config/paneru` -> `${DOTFILES_DIR}/config/paneru`
   - `~/.config/sketchybar` -> `${DOTFILES_DIR}/config/sketchybar`
6. Clone `fzf-tab` to `~/.zsh/fzf-tab` if missing.
7. Offer to run `scripts/macos_speedup.sh`.

- [ ] **Step 2: Test `install.sh` syntax and execution flags**

Run: `bash -n install.sh`
Expected: Exit code 0

- [ ] **Step 3: Commit `install.sh`**

```bash
chmod +x install.sh
git add install.sh
git commit -m "feat: add universal automated installer script"
```

---

### Task 5: Testing & Dry-Run Verification

**Files:**
- Test target paths in simulated home directory (`/tmp/dotfiles_test_home`)

- [ ] **Step 1: Execute installer in a simulated `$HOME` environment**

```bash
TEST_HOME="$(mktemp -d /tmp/dotfiles_test.XXXXXX)"
HOME="$TEST_HOME" ./install.sh --skip-brew --skip-speedup -y
```

- [ ] **Step 2: Verify symlinks in simulated `$HOME`**

```bash
ls -la "$TEST_HOME/.zshrc"
ls -la "$TEST_HOME/.zshrc.d"
ls -la "$TEST_HOME/.config/paneru"
ls -la "$TEST_HOME/.config/sketchybar"
ls -la "$TEST_HOME/.config/borders"
ls -la "$TEST_HOME/.config/ghostty"
```
Expected: All symlinks point accurately to the repository path.

- [ ] **Step 3: Test loading `.zshrc` in simulated environment**

```bash
HOME="$TEST_HOME" zsh -i -c 'echo "Zsh loaded cleanly: exit status $?"'
```
Expected: Prints clean load with code 0.

- [ ] **Step 4: Clean up test directory**

```bash
rm -rf "$TEST_HOME"
```

---

### Task 6: Comprehensive README & Documentation

**Files:**
- Create: `README.md`
- Preserve: `LICENSE` (MIT)

**Interfaces:**
- Consumes: Features from all modules and configs
- Produces: Professional open-source documentation for GitHub

- [ ] **Step 1: Draft modern `README.md`**
  - Title, badge row (macOS Apple Silicon & Intel, Zsh, Paneru, Ghostty, MIT License).
  - Clean overview of the workstation aesthetics (Niri-style Paneru ribbon tiling, Sketchybar dynamic status bar, JankyBorders, Ghostty, Fastfetch, snazzy vivid LS_COLORS, Vim-mode prompt).
  - 1-line installation command:
    ```bash
    git clone https://github.com/RazerZS-oss/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./install.sh
    ```
  - Keyboard shortcuts table for Paneru window navigation and Zsh Vim mode.
  - Directory structure explanation.
  - Safe uninstallation / revert steps.

- [ ] **Step 2: Commit `README.md`**

```bash
git add README.md LICENSE
git commit -m "docs: add comprehensive dotfiles documentation and setup guide"
```

---

### Task 7: GitHub Setup & Push to `RazerZS-oss/dotfiles`

**Files:**
- Git remotes and GitHub repository `RazerZS-oss/dotfiles`

- [ ] **Step 1: Remove old planning docs from git tracking**

```bash
rm -rf docs/superpowers/plans/2026-09-23-docker-pdf-converter.md docs/superpowers/specs/2026-09-23-docker-pdf-converter-design.md
git add -u docs/
git commit -m "chore: clean up legacy pdf converter planning documents"
```

- [ ] **Step 2: Create new public GitHub repository `RazerZS-oss/dotfiles`**

```bash
gh repo create RazerZS-oss/dotfiles --public --source=. --remote=origin --push
```

- [ ] **Step 3: Verify GitHub repository URL and status**

```bash
gh repo view RazerZS-oss/dotfiles --web || gh repo view RazerZS-oss/dotfiles
```

- [ ] **Step 4: Final verification of clean status**

```bash
git status
```
Expected: Clean working tree, on branch `main`, tracking `origin/main`.
