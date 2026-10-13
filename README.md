# Clipmind

A fast, private clipboard manager for macOS with smart search. Lives in the menu bar, stays out of your way.

> 🚧 Early development — stage 1 of the roadmap is done.

## Features

- **Clipboard history** — everything you copy is kept (up to 500 items), newest on top, no duplicates
- **Fuzzy search** — `gtco` finds `git checkout`, words match in any order, case- and accent-insensitive (works great with Cyrillic: `ё` = `е`)
- **Paste anywhere** — pick an item and it's pasted straight into the app you were using
- **Keyboard-first** — `⌘⇧V` to open, `↑↓` to navigate, `↵` to paste, `⌘1–9` to quick-paste, `⌘⌫` to delete
- **Private by design** — 100% local, no network. Passwords from 1Password, Bitwarden & co. are never saved ([nspasteboard.org](http://nspasteboard.org) convention)

## Build from source

Requires macOS 14+ and Xcode 16+.

```bash
git clone https://github.com/waste3d/clipmind.git
cd clipmind
open clipmind.xcodeproj
```

Press `⌘R` to run, `⌘U` to run tests.

On first paste macOS will ask for **Accessibility** permission (System Settings → Privacy & Security → Accessibility). It's needed to simulate `⌘V` in other apps. Without it, the item is just copied to the clipboard.

History is stored locally in `~/Library/Application Support/Clipmind/history.json`.

## Roadmap

- [x] **Stage 1** — menu bar app, clipboard history, fuzzy search, global hotkey, paste into active app
- [ ] **Stage 2** — smart content types: links, code, colors, emails, phones, paths — with icons, previews and filters; pinned items; SQLite storage
- [ ] **Stage 3** — images in history + OCR: search screenshots by the text in them
- [ ] **Stage 4** — semantic search: find by meaning, not just by letters (on-device embeddings)
- [ ] **Stage 5** — settings (hotkey, history size, ignored apps), launch at login, Homebrew cask

## License

MIT
