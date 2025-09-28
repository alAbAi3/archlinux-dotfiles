# Project Bootstrap & Debugging Log

This document chronicles the process of setting up the initial proof-of-concept for the Hyprland + QuickShell dotfiles project, detailing the issues encountered and their solutions.

## Initial Goal
The primary objective was to achieve **Phase 0** of the project roadmap: launch a minimal Hyprland session that successfully runs a basic QuickShell panel.

---

## Problem 1: Initial Hyprland Launch Failure

*   **Symptom:** When launching `hyprland` from the TTY, the screen would go black and be unresponsive. No UI elements would appear.
*   **Investigation & Solutions:**
    1.  **Incorrect `exec-once`:** The initial `hyprland.conf` was attempting to launch `waybar` and `hyprpaper`, which were not installed and were contrary to the project blueprint.
    2.  **Missing `quickshell`:** The configuration was missing the command to launch the main UI shell.
    3.  **Package Corrections:** The `hyprland.conf` was modified to launch `quickshell`. The packages `quickshell-git` and `swww` were added to `packages-aur.txt` and `packages-base.txt` respectively.
    4.  **Configuration Error:** A malformed line (`stow"swww"`) was corrected in `packages-base.txt`, and `swww` was moved to the correct AUR package list.

## Problem 2: Package Installation Conflicts

*   **Symptom:** The `bootstrap.sh` script failed with an "unresolvable package conflicts" error.
*   **Investigation:** The `yay` command was trying to install `quickshell-git`, but a conflicting `quickshell` package was already present. The non-interactive script could not answer the `[y/N]` prompt to resolve this.
*   **Solution:** The `bootstrap.sh` script was improved to automatically handle this by explicitly removing the old package before installation, using the command `sudo pacman -R --noconfirm quickshell 2>/dev/null || true`.

## Problem 3: The Silent Crash (The "No Logs" Mystery)

*   **Symptom:** Hyprland would still not launch a UI, and more confusingly, no log files were being created, even with shell redirection (`> /tmp/log.log`).
*   **Investigation & Solutions:**
    1.  **Environmental Misunderstanding:** It was discovered that my tool environment was Windows, while the target was Linux. This meant my direct attempts to read logs and run commands were invalid. The process was switched to user-guided debugging.
    2.  **Config Verification:** We confirmed the `hyprland.conf` was syntactically perfect using `hyprland --verify-config`.
    3.  **Virtual Machine Detection:** Using `lspci`, we discovered the environment was a virtual machine. The user clarified it was **Oracle VirtualBox**, not VMware as the device name misleadingly suggested.
    4.  **The Root Cause:** Using `eglinfo`, we determined the virtual GPU driver only supported **OpenGL ES 3.0**. Hyprland requires **OpenGL ES 3.2**, and this mismatch caused it to crash silently before any logs could be written.
    5.  **The Fix:** The user switched from a VM to a physical Linux laptop, which had proper graphics support.

## Problem 4: UI Components Failing to Launch

*   **Symptom:** On the laptop, Hyprland finally started (wallpaper and cursor were visible), but the QuickShell panel and the Alacritty terminal (`Super + Q`) did not appear.
*   **Investigation:** The user discovered that the log files were, in fact, being created on the laptop.
    *   `terminal.log` showed a `FontNotFound` error for the "monospace" font.
    *   `quickshell.log` showed it `Could not find "default" config directory or shell.qml`.
*   **Solutions:**
    1.  **Font Installation:** The font issue was identified as the root cause for both applications failing. The `ttf-dejavu` package was installed via `pacman` to provide the necessary base fonts. This fixed the terminal.
    2.  **QuickShell Path:** The file `modules/quickshell/panel/main.qml` was renamed to `modules/quickshell/shell.qml` to match the default path QuickShell searches for.
    3.  **Qt Platform Plugin:** The `quickshell.log` also revealed it was trying to use the X11 (`xcb`) platform plugin. The `hyprland.conf` was updated with `env = QT_QPA_PLATFORM,wayland` to force it to correctly use the Wayland plugin.

## Problem 5: Panel Misbehavior

*   **Symptom:** QuickShell finally launched, but it behaved like a normal application window (tiled, movable) instead of a static panel.
*   **Investigation:** `hyprctl clients` was used to identify the window's class name as `org.quickshell`.
*   **Solution:** A set of `windowrulev2` rules were added to `hyprland.conf` to instruct Hyprland to treat the `org.quickshell` window as a floating panel, pinning it to the top of the screen.

---

## Final Status: Phase 0 Complete

After a long and complex debugging process, all foundational issues have been resolved. The project has successfully achieved the **Phase 0** deliverable: a minimal Hyprland session that launches a custom, functional QuickShell panel.
