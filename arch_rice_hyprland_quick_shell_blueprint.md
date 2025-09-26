# MVP Dotfiles — Hyprland + QuickShell (scalable blueprint)

> Focus: a clean, minimal **MVP** for your personal rice — Hyprland as the compositor, QuickShell as the single UI surface. Ship a reliable 8-desktop workflow (Windows-like virtual desktops), deterministic app placement, live theming from wallpaper, a QuickShell-only panel/launcher/overview, and a small set of robust helper scripts. Design everything to scale later without redoing the foundations.

---

## High-level goals

**MVP scope (must-haves):**
- A Wayland session using Hyprland and QuickShell only for the UI. No external bars unless they become necessary later.  
- 8 default workspaces (numbered 1–8, optionally named) with quick hotkey switching and moving windows between them.  
- Deterministic app placement: rules or launcher scripts that reliably open apps in target workspaces.  
- QuickShell-based topbar/panel showing workspaces, basic status (clock, battery, network), and a launcher/app-grid.  
- Wallpaper-driven theming pipeline: pick wallpaper → generate palette → QuickShell updates colors.  
- Small robust scripts: `workspace-launcher`, `ws-listener` (socket2→JSON), `apply-theme`.  
- Idempotent `bootstrap.sh` to reproduce the environment (packages + dotfiles symlinks).

**MVP non-goals (deferred):**
- Heavy integrations like AI panels or cloud-synced stores.  
- Complete app catalog wiring for every corner case — aim for a working, extensible baseline.

**Scalability goals (post-MVP):**
- Per-machine overlays (e.g., laptop vs. desktop) via profile overlays.  
- Plugin-style QuickShell modules (small, hot-loadable QML components).  
- CI checks, package snapshots, and a contributor-friendly README.

---

## Assumptions & prerequisites

- You’re running Arch Linux (or Arch-based) with Wayland-ready GPU drivers.  
- Comfortable with `git`, the terminal, `pacman`, and building packages from AUR if needed.  
- You want a single dotfiles repo to reproduce the rice across machines.

---

## Technology choices (MVP)

- **Compositor:** Hyprland (tiling, event-driven, `hyprctl` IPC).  
- **UI shell:** QuickShell (QML-based shell; handles panels, launcher, overview).  
- **Wallpaper daemon:** `swww` or `hyprpaper` (MVP: `swww` for scriptability).  
- **Palette generator:** `pywal` (extracts a color scheme from wallpaper).  
- **Screenshot & selection:** `grim` + `slurp`.  
- **Terminal:** `foot` or `alacritty` (pick one Wayland-native if you want fewer oddities).  
- **Clipboard:** `wl-clipboard`.  
- **Recording / streaming:** optional: `wf-recorder` / `obs`.  

All UI and status elements come from QuickShell QML modules; avoid external bars in MVP.

---

## Core UX model: workspaces = first-class

- Create 8 persistent workspaces by default. Each workspace can be:
  - **Named** (e.g., `1:sys`, `2:web`) or just `1`–`8`.
  - **Bound** to keys `SUPER+1..8` (switch) and `SUPER+SHIFT+1..8` (move focused window).
  - **Associated** with an autostart list or a window rule so specified apps land there automatically.

Three reliable methods for placement:
1. **Window rules (preferred):** use `windowrulev2` in Hyprland to match `app.class`/`title` and assign a workspace — stable for most apps.  
2. **Dispatch-based executor:** `hyprctl dispatch exec [workspace <id> silent] <cmd>` where supported.  
3. **Launcher script with fallbacks:** spawn the app then wait for its window and move it to the target workspace (useful for fragile XWayland apps).

Keep the rules readable and limited: prefer a handful of explicit matches rather than an explosion of heuristics.

---

## Repo layout (recommended)

```
rice-dotfiles/
├─ README.md
├─ packages/                 # pacman + AUR package lists
│  ├─ packages-base.txt
│  └─ packages-aur.txt
├─ modules/                  # modular configs to be stowed
│  ├─ hypr/                  # hyprland.conf (bindings, rules, exec-once), hypr fragments
│  ├─ quickshell/            # QML modules (panel/, launcher/, overview/, theme/)
│  ├─ scripts/               # workspace-launcher.sh, ws-listener.sh, apply-theme.sh
│  └─ wallpapers/            # curated wallpapers, metadata.json
├─ profiles/                 # machine-specific overlays (laptop, desktop)
├─ scripts/
│  └─ bootstrap.sh           # idempotent setup script
└─ docs/
   └─ cheatsheet.md
```

- Use `stow` (or `dotbot`) to manage symlinks from `modules/*` into `~/.config` for easy activation.
- Keep `packages/` for reproducing the environment across machines.

---

## QuickShell architecture (QML modules)

Design QuickShell as small composable QML modules:
- `panel/` — topbar with workspace buttons, system indicators (clock, battery, net), and a quick settings menu.  
- `workspace/` — renders an array of 8 workspace buttons, shows active/urgent states, and supports click/hotkey actions.  
- `launcher/` — app-grid, fuzzy search, and a small command palette; hotkey to open (`SUPER+SPACE`).  
- `overview/` — an exposé showing thumbnails of each workspace (optional for MVP but very useful).  
- `theme/` — a QML or JS color module generated by `apply-theme.sh` and imported by other modules.

Keep modules minimal and config-driven. Each module exposes a small API (properties + signals) to simplify hooking them together.

---

## Theming pipeline (source of truth: wallpaper)

Flow:
1. Choose wallpaper (`modules/wallpapers/` or user-provided).  
2. Run `pywal -i <wall>` to generate color variables (stored in `$HOME/.cache/wal/`).  
3. `apply-theme.sh` converts the palette into a QuickShell consumable (e.g., `colors.qml` or `colors.js`) and writes it to the QuickShell `theme/` folder.  
4. `apply-theme.sh` tells QuickShell to reload or emits a small event file (e.g., `$XDG_RUNTIME_DIR/rice/theme.json`) that QuickShell watches.  
5. Also call `swww img <wall>` to set wallpaper.

Implementation notes:
- Store generated themes in `$HOME/.cache/rice/themes/<wallname>/` for easy reloading.  
- Keep templates for QML color variables in `modules/quickshell/theme/templates/` and render them using `envsubst` or `jq`.

---

## Important scripts (MVP implementations)

### `workspace-launcher.sh` (purpose)
Spawn an app into a specific workspace reliably. Strategy:
1. If Hyprland supports `dispatch exec workspace <id>`, use it.  
2. Otherwise: switch to the target workspace, run the command, wait for a window with a matching class/title for up to N seconds, then move it to the target workspace if needed and restore focus.

Key properties: idempotent-ish, quiet on success, verbose on failure for debugging.

### `ws-listener.sh` (purpose)
Listen to Hyprland's socket2/event stream and emit a small JSON or Unix socket events QuickShell consumes to update the panel (active workspace, number of windows, urgency). Keeps QuickShell and Hyprland in perfect sync.

### `apply-theme.sh` (purpose)
Run `pywal`, render `colors.qml`, set wallpaper with `swww`, and signal QuickShell to reload.

(Complete skeleton scripts live in `modules/scripts/` so you can refine them.)

---

## Hyprland config notes (what lives in `hypr/hyprland.conf`)
- **Bindings:** `SUPER+1..8` -> `dispatch workspace N`; `SUPER+SHIFT+1..8` -> `dispatch movetoworkspace N` (or `move` dispatcher).  
- **Autostart:** `exec-once =` entries for essential background services (e.g., `ws-listener.sh`, `workspace-launcher` for pinned apps).  
- **Window rules:** `windowrulev2 = class:Firefox workspace:2` (use conservative matching).  
- **Scratchpad:** configure a dedicated scratchpad workspace or use `specialworkspace` behavior for toggling terminals.

Keep the file short and comment the important intent lines so later-you remembers why each rule exists.

---

## Reliability & edge-cases

- **XWayland apps** sometimes report their class/title late — use the launcher script fallback with a small `sleep` + `poll` loop for matching windows.  
- **Race conditions** on startup: avoid spawning heavyweight apps immediately on session start; use short delays or systemd user units for ordering.  
- **Testing on a VM** is useful but GPU/Wayland behavior varies; test core workflows on your real machine early.

---

## Keybindings & UX suggestions (defaults)
- `SUPER + 1..8`: switch to workspace N.  
- `SUPER + SHIFT + 1..8`: move focused window to workspace N.  
- `SUPER + SPACE`: open launcher.  
- `SUPER + TAB`: toggle previous workspace.  
- `SUPER + SHIFT + S`: toggle scratchpad.  
- `SUPER + O`: toggle overview.  

These are sensible defaults — keep them editable in `hypr/hyprland.conf`.

---

## Roadmap (phased milestones for MVP → 1.0)

**Phase 0 — Proof-of-concept (0.5–1 day)**
- Minimal Hyprland session that launches QuickShell and shows a panel with 3 workspaces.  
- Deliverable: `hypr/hyprland.conf` (bindings) + QuickShell panel QML showing workspace buttons.

**Phase 1 — MVP baseline (1–3 days)**
- Full 8-workspace flow, `workspace-launcher.sh`, window rules for 3 core apps (terminal, browser, editor), launcher open/close.  
- Deliverable: working session you can use daily; basic README and cheatsheet.

**Phase 2 — Theming + polish (1–2 days)**
- `apply-theme.sh`, 5 sample wallpapers, QuickShell reload on theme changes, polished panel indicators.  
- Deliverable: consistent theming across panel/launcher and sample themes.

**Phase 3 — UX niceties (2–4 days)**
- Overview/exposé, scratchpad, multi-monitor behavior tuning, systemd user service for autostart.  
- Deliverable: documented workflows for multi-monitor and gaming setups.

**Phase 4 — Packaging & infra (1–2 days)**
- `bootstrap.sh`, `packages-*.txt`, a small CI that runs shellcheck/lint on scripts.  
- Deliverable: one-command repro of the dotfiles on a clean Arch install (with caveats documented).

**Phase 5 — Pluginization & community (ongoing)**
- Convert QuickShell modules into small plugin packages, create contribution guide, publish examples.

---

## Testing & validation

- Maintain a `test/` folder with scripts that simulate: switching workspaces, launching apps with the launcher, and applying themes.  
- Use logging in `ws-listener.sh` and `workspace-launcher.sh` during development; keep logs small and optional.

---

## CI & reproducibility

- Add a GitHub Actions workflow that:
  - runs `shellcheck` on scripts,  
  - checks `pywal` template generation (basic smoke test),  
  - validates that `hyprland.conf` parses (dry check).  
- Keep `packages-base.txt` up to date; provide an `export-packages.sh` that snapshots `pacman -Qqe`.

---

## Docs & user onboarding

- `docs/cheatsheet.md` with hotkeys, install steps, typical debugging steps (how to move a stuck window, how to reapply theme).  
- `README.md` with one-liner bootstrap instructions and a small list of hard-known caveats (XWayland, GPU drivers, Hyprland version).

---

## Deliverables for the first iteration (concrete)

- `hypr/hyprland.conf` with binds and a few window rules.  
- `modules/quickshell/panel/` minimal QML that shows workspace buttons, clock, and a launcher hotkey.  
- `modules/scripts/{workspace-launcher.sh,ws-listener.sh,apply-theme.sh}` skeletons.  
- `scripts/bootstrap.sh` to install packages and stow configs.  
- `docs/cheatsheet.md` and `packages/packages-base.txt`.

--