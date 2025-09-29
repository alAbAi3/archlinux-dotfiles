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

---

## Problem 6: Implementing the App Launcher

This phase involved implementing the application launcher, which surfaced a complex interplay of issues involving shell scripting, QML implementation, and window manager rules.

*   **Symptom:** The application launcher, though defined in `Launcher.qml`, would not appear when triggered by its hotkey.
*   **Initial Investigation & Solutions:**
    1.  **Execution Strategy:** It was determined that the launcher needed to be a separate process. The initial approach of using `Qt.labs.process` from within QML failed due to unavailable packages on the system.
    2.  **Robust Communication:** The execution was refactored. A `toggle-launcher.sh` script now starts the QML process. The QML process, when an app is clicked, prints the desired command to standard output (`stdout`) and quits. The shell script captures this output and executes the command using `hyprctl`. This proved to be a reliable, dependency-free communication method.
    3.  **Hotkey Issues:** At one point, no logs were being created, indicating the script wasn't running at all. This was traced back to an invalid keybinding (`SUPER` key alone). Reverting to `SUPER+SPACE` fixed the trigger.
    4.  **Command-Line Arguments:** The logs revealed a `The following arguments were not expected` error. The `quickshell` executable required the `-p` flag to load a QML file, not `-qml`. The script was corrected.

*   **Sub-Problem: QML Implementation Errors**
    1.  **`qs-blackhole` Error:** After fixing the script, a cryptic `Script qrc:/qs-blackhole unavailable` error appeared. This was isolated to the JavaScript import for a fuzzy search library. The feature was temporarily removed to proceed.
    2.  **`onItemClicked` Error:** A subsequent error, `Cannot assign to non-existent property "onItemClicked"`, revealed that the click handler was incorrectly placed on the `GridView` component. The logic was correctly moved into the `AppDelegate`'s `MouseArea`.

*   **Sub-Problem: Window Rule Conflicts**
    1.  **Symptom 1:** The launcher appeared but was styled as a tiny bar in the middle of the screen.
    2.  **Symptom 2:** After a fix, the launcher appeared correctly, but the main panel broke and adopted the launcher's size.
    3.  **Investigation:** The root cause was that both the panel and the launcher shared the same window class (`org.quickshell`), causing their `windowrulev2` rules in `hyprland.conf` to conflict.
    4.  **Solution:** The definitive solution was to make both components identifiable. `shell.qml` (the panel) and `Launcher.qml` were both wrapped in `Window` elements, each with a unique `title` property (`QuickShell-Panel` and `QuickShell-Launcher`). The rules in `hyprland.conf` were then changed to target these specific, non-conflicting titles, completely isolating them.

*   **Sub-Problem: `bootstrap.sh` and Symlink Failures**
    1.  **Symptom:** Even with correct code, the launcher reported `Could not open config file`.
    2.  **Investigation:** The user's `~/.config` directory did not have the correct file structure. The `stow` command in `bootstrap.sh` was being used incorrectly, creating a mess of symlinks in the wrong locations (e.g., `~/.config/hyprland.conf` instead of `~/.config/hypr/hyprland.conf`).
    3.  **Solution:** The `stow` logic for config files in `bootstrap.sh` was replaced entirely with a more direct and reliable `ln -s` command to link the directories correctly. The user was guided to clean up the old, incorrect symlinks before re-running the corrected bootstrap script.

---

## Final Status: Phase 1 Complete

All launcher-related issues have been resolved. The project now has a functional, refactored panel and a robust, floating application launcher, successfully completing the goals of **Phase 1**.
