# CleanYourTV and Android TV Launcher Replacement

Research date: 2026-11-03. Repo facts come from a shallow clone of `Gathin23/cleanyourtv` at HEAD, last commit 2026-11-03, plus the GitHub API. Repo file links point at `main`.

Abbreviations: R = https://github.com/Gathin23/cleanyourtv/blob/main (repo file root).

## 1. What CleanYourTV does, how it works, what it supports, and its maintenance and problem history

### Takeaway
CleanYourTV is an MIT-licensed kit. You give a coding agent (Claude Code, Codex, Gemini CLI) `PROMPT.md`, and the agent drives network ADB to do four things: back up the TV's state, run `pm disable-user --user 0` on bloat (it never uninstalls), build and sideload a ~572 KB plain-Java launcher (`com.gathin.tvhome`), and make that launcher Home with `cmd package set-home-activity`. Home-safety guards and a recorded one-line restore are built in. It went viral on 2026-10-17 and has been under very active development since: 51K stars, 6.4K forks, and 428 per-model lists. Most reported problems are vendor-specific soft-bricks or boot loops caused by disabling load-bearing packages, not by the launcher.

### Cited Findings

**Identity and maintenance**
- The repo description is "Debloat any Android or Google TV over Wi-Fi and get an Apple TV-style home." It was created 2026-10-17, last pushed 2026-11-03, had 51,113 stars and 6,450 forks, and the API's `open_issues_count` was 200 (that count includes open PRs). Primary language is Python. — [GitHub API / repo](https://github.com/Gathin23/cleanyourtv)
- GitHub issue search counted about 495 issues in total and 120 open on 2026-11-03. — [Issues](https://github.com/Gathin23/cleanyourtv/issues)
- Dozens of PRs merged on 2026-11-03 alone, mostly device examples, docs and themes (e.g. "Merge PR #3134…", "#3126 themes: add aerial"). — [Commits](https://github.com/Gathin23/cleanyourtv/commits/main)
- Origin: on 17 Oct 2026 the author posted a before/after of his parents' TV cleaned by Claude Code, and it reached 8.6M views. The repo was called `tv-vibehack` until 19 Oct. It was GitHub's #1 trending repo for the week of 19–25 Oct. The README claims 427 TV models from 111 brands and 412 press articles (as of 30 Oct). — [R/README.md "The story"](https://github.com/Gathin23/cleanyourtv#the-story)
- Official domains are only cleanyour.tv and the repo. cleanyourtv.com and clean-your-tv.net are not run by the project (#1004), and the project "publishes no app in any app store". — [README](https://github.com/Gathin23/cleanyourtv)
- License: MIT. The launcher font is Outfit (SIL OFL). — [README Licence](https://github.com/Gathin23/cleanyourtv#licence)
- The repo also holds 31 add-ons in `addons/`, 22 themes in `themes/`, `tools/`, `tests/` (about 255 files), `docs/devices/` (about 130 per-device notes) and `SHOWCASE.md` (196 community projects). — repo tree, [R/SHOWCASE.md](https://github.com/Gathin23/cleanyourtv/blob/main/SHOWCASE.md)

**Prerequisites**
- On the TV: Settings → Device Preferences → About → press Build 7 times → Developer options → USB debugging on, plus Network/ADB debugging if the toggle exists. — [README Quick start](https://github.com/Gathin23/cleanyourtv#quick-start)
- On the computer, on the same Wi-Fi: Python 3, JDK 17–22 (JDK 23+ breaks Gradle 8.9), and Android SDK platform 34 with build-tools 34. `tools/docker-build.sh` can build in Docker instead. — [README "Doing it by hand"](https://github.com/Gathin23/cleanyourtv#doing-it-by-hand)
- The README says to clone the repo rather than only pasting the prompt, because "the assistant reuses this repo's `tools/disable.sh` and `launcher/build-and-install.sh` … that is where the backup, the Home guard and the restore record live." — [README](https://github.com/Gathin23/cleanyourtv#quick-start)

**Step by step (from PROMPT.md and the scripts)**
1. **Discovery and connect.** The agent finds the TV by hostname, ARP table or a user-supplied IP and connects to ADB on port 5555. If macOS Local Network privacy blocks the `adb` binary ("No route to host"), it uses the pure-Python `adb-shell` client (`tools/tv.py`) and pushes large files as base64 chunks verified by md5 (`tools/b64push.py`). If 5555 is closed it falls back to Wireless debugging (`adb pair` → `adb connect` → `adb tcpip 5555`, found via `_adb-tls-connect._tcp` mDNS). Some firmware uses another port (one projector used 5877). `tools/relay.py` covers agents whose sandbox has no LAN access. If the device turns out to be Tizen, webOS, Roku, VIDAA or SmartCast, the agent stops. — [R/PROMPT.md "Connect"](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
2. **Probe.** `tools/tv.py --probe` reports model, Android version and firmware. — [README](https://github.com/Gathin23/cleanyourtv#doing-it-by-hand)
3. **Back up.** The agent saves the full package list, the disabled-package list, `getprop` output and all settings, and writes a restore script. `tools/disable.sh` records the pre-change state in `~/.cleanyourtv/` before it changes anything (`tools/recovery.py` writes that record). — [PROMPT.md "Back up first"](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md), [README "Restoring"](https://github.com/Gathin23/cleanyourtv#restoring-your-tv)
4. **Classify packages.** Packages are sorted into telemetry/analytics, OEM content/ad services (PatchWall, recommendation rows), unneeded background services, preloads and streaming apps. Unclear OEM packages are inspected with `dumpsys package <name>`, never by launching them. Factory/test apps (`com.cvte.tv.fac.menu`, `mediatek.factorymenu.ui`…) must never be opened: on Haier/CVTE boards that flips a factory-mode flag that kills the Input key and CEC. — [PROMPT.md "Debloat"](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
5. **Disable.** The agent runs `pm disable-user --user 0 <pkg>`, one `pm` per shell call ("chained commands may silently stop after the first"), in small batches with screenshots between them, and checks the result with `pm list packages -d` rather than exit codes. It waits ~15 s before rebooting because Android writes package state ~10 s after a change (`WRITE_SETTINGS_DELAY`), then compares the disabled list after the reboot. Streaming apps, voice assistant, Chromecast, Miracast and the updater are disabled only if the user un-ticks them on a checklist. — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md), [R/tools/disable.sh](https://github.com/Gathin23/cleanyourtv/blob/main/tools/disable.sh)
   - `pm uninstall -k --user 0` is **not** used. PROMPT.md mentions it only as a failure mode: Fire OS 5 returns `DELETE_FAILED_INTERNAL_ERROR`, and `pm hide` "reports success while changing nothing". — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
   - A hard-coded core-package guard (`CORE_RE` in `disable.sh`) refuses lists containing `android`, `android.ext.services/shared`, `com.android.sdksandbox`, `com.android.location.fused`, systemui, shell, phone, settings, `com.android.tv.settings`, permissioncontroller, packageinstaller, modulemetadata, `com.google.android.overlay.modules*`, `com.android.providers.*` (calendar, contacts, user dictionary and blocked numbers excepted), and the TV middleware `com.cltv.mal` and `com.mediatek.(tis|tv.service|tv.agent)`. — [R/tools/disable.sh L59-73](https://github.com/Gathin23/cleanyourtv/blob/main/tools/disable.sh)
   - The agent must never disable the TV app and input services, the input/source menu, remote and Bluetooth pairing services, the on-screen keyboard, Play Store or Play Services. — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
   - Optional ad-blocking Private DNS: `settings put global private_dns_specifier dns.adguard-dns.com` and `settings put global private_dns_mode hostname`; undo with `private_dns_mode opportunistic`. It does not block YouTube ads, and it bypasses router-level Pi-hole or AdGuard rules. — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
6. **Pre-flight for the launcher.** The agent checks that the TV accepts sideloads; some China-market sets return `INSTALL_FAILED_VERIFICATION_FAILURE` or refuse any APK declaring `category.HOME` without the OEM signature. It also checks the SDK: `getprop ro.build.version.sdk` must be at least 26. — [PROMPT.md "Launcher"](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md), [R/launcher/build-and-install.sh](https://github.com/Gathin23/cleanyourtv/blob/main/launcher/build-and-install.sh)
7. **Build and install** (`launcher/build-and-install.sh`):
   - Identify the current Home owner with `cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME`. It must be one of `KNOWN_STOCK_LAUNCHERS="com.google.android.tvlauncher com.google.android.apps.tv.launcherx com.google.android.leanbacklauncher com.mitv.tvhome"`; otherwise the user must pass `STOCK_LAUNCHER=<pkg>` or `none`.
   - b64-push the APK and run `pm install -r /data/local/tmp/tvhome.apk` on its own, so a failed install can't be followed by disabling the stock launcher. On Android 14, `adb install` can hang waiting for on-screen confirmation, which is why `pm install` is used.
   - `am force-stop`, then `am start -W -a MAIN -c HOME -n com.gathin.tvhome/.MainActivity`, which must return `Status: ok` before the stock launcher is touched (#239).
   - Batch: `pm grant … ACCESS_FINE_LOCATION` (to read the Wi-Fi SSID), `cmd package compile -m speed -f com.gathin.tvhome`, `pm disable-user --user 0 <stock>`, then `cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity` **last**, because "Android drops the preference whenever the set of HOME apps changes".
   - Re-query Home. If it isn't `com.gathin.tvhome`, roll back automatically (`pm enable` the stock launcher plus `set-home-activity` back to it) and write the rescue commands to `~/cleanyourtv-handover-<ip>.txt`.
   - Source: [R/launcher/build-and-install.sh L71-200](https://github.com/Gathin23/cleanyourtv/blob/main/launcher/build-and-install.sh)
8. **Verify.** `tools/tv.py --screenshot shots/x.png DPAD_RIGHT` injects keys and pulls screenshots. Live TV, HDMI and Netflix screenshots come back as 0 bytes (DRM), so those are checked with `dumpsys activity activities | grep ResumedActivity`. The agent confirms the takeover with `dumpsys activity activities | grep mFocusedApp`, because "on some Google TV builds `set-home-activity` prints `Success` and changes nothing". — [PROMPT.md "Verify"](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
9. **Close ADB.** Turn off USB, Network and Wireless debugging and revoke authorisations, reboot, and confirm with `tools/adb-closed.py <ip>` that 5555 refuses connections. Port 5555 is plaintext, and with `ro.adb.secure=0` any LAN device gets a shell. — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md), [README FAQ](https://github.com/Gathin23/cleanyourtv#questions-people-ask)

**Backup, restore and undo**
- `tools/restore.sh <list> [stock.launcher.pkg]` replays the recorded state. Packages you had already disabled stay disabled, Home returns to the component that owned it, and animation scales are restored. On Google TV, pass `com.google.android.apps.tv.launcherx`. Without a computer, the TV's Settings → Apps can re-enable packages. The launcher itself stays installed. — [R/tools/restore.sh](https://github.com/Gathin23/cleanyourtv/blob/main/tools/restore.sh), [README Restoring](https://github.com/Gathin23/cleanyourtv#restoring-your-tv)
- After an OTA, "the listed packages come back, Home goes to the stock launcher, and new preloads appear". `tools/check.py <list>` diffs the TV against the list and `--fix` re-applies it. The updater is left on in most lists. — [README "After a firmware update"](https://github.com/Gathin23/cleanyourtv#after-a-firmware-update)
- Other tools: `tools/privacy.py` audits voice, ACR and telemetry candidates and `--write` turns them into a list; `tools/bench.py` measures key latency, jank, cold start and idle CPU/PSS; `tools/theme.sh` pushes a theme; `tools/manage.py` installs add-ons. Every script has a PowerShell twin. — [README tools table](https://github.com/Gathin23/cleanyourtv#doing-it-by-hand)

**Launcher technology**
- The launcher is plain Java, about 572 KB, "built for TVs with 1 GB of RAM. No blur, no video, no network permission, no background services". minSdk 26 (Android 8.0), targetSdk and compileSdk 34. Its only dependencies are `androidx.recyclerview:1.3.2` and `androidx.dynamicanimation:1.0.0`. It uses no Kotlin, Compose, Leanback library, WebView or Flutter: the repo has zero `.kt` files and about 74 Java classes in `com.gathin.tvhome`. — [README "The launcher"](https://github.com/Gathin23/cleanyourtv#the-launcher), [R/launcher/app/build.gradle](https://github.com/Gathin23/cleanyourtv/blob/main/launcher/app/build.gradle)
- Manifest: `MainActivity` declares `MAIN` + `HOME` + `COMMON_HOME` + `DEFAULT`, plus a `LEANBACK_LAUNCHER` filter so it also shows in the stock app row. One activity handles `com.android.tv.action.VIEW_INPUTS`. There are two AccessibilityServices (`HomeKeyService`, `InputKeyService`) for remote-key remapping. — [R/launcher/app/src/main/AndroidManifest.xml](https://github.com/Gathin23/cleanyourtv/blob/main/launcher/app/src/main/AndroidManifest.xml)
- On Android 11+ the launcher must declare `<queries>` for `LEANBACK_LAUNCHER`, or package visibility hides every app. The theme must be explicitly opaque, or the TV/HDMI picture stays visible under Home. — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
- UI: pitch-black home; a 4-tile dock (configurable 4–7); a top shelf naming the focused app with an ambient glow sampled from its banner; an app grid that slides up on Down; one "glass" focus highlight; frosted pills for Inputs (HDMI/AV/Live TV via the TV Input Framework), Wi-Fi and Settings; clock and greeting in Outfit; Clock screensaver; 31 languages; optional app library; a tile menu (Move / App info / Remove); module cards from third-party apps. — [README "What you get"](https://github.com/Gathin23/cleanyourtv#what-you-get)
- Theme `config.json` keys (pushed over Wi-Fi with no rebuild) include:
  - Wallpaper and background: `background_color`, `wallpaper`, a `wallpapers/` collection with `wallpaper_rotation_minutes` and `wallpaper_order` (`shuffle`/`sequential`), `wallpaper_dim`, `wallpaper_captions`, and `wallpaper_moods` (time-of-day groups: morning/evening/night, not emotional mood).
  - Dock and grid: `dock_opacity`, `dock_glass`, `single_row`.
  - Shelf and glow: `cinematic_home` (the focused dock app's artwork fills the top of the screen), `app_glow`, `glow_style`, `glass_style`.
  - Seasonal: `festival` (diwali/dussehra/halloween skins), `race_calendar`.
  - Boot and remote behaviour: `power_on_home`, `boot_to_live_tv`, `app_keys`.
  - Source: [R/themes/README.md](https://github.com/Gathin23/cleanyourtv/blob/main/themes/README.md)
- There is no prebuilt APK ("No prebuilt binaries"); you build it yourself. — [README FAQ](https://github.com/Gathin23/cleanyourtv#questions-people-ask)

**Supported devices and stated limitations**
- Android TV and Google TV get both the debloat and the launcher.
- Fire TV gets the debloat only ("Fire OS will not hand Home to a third-party launcher"), and on the 2015 Fire TV Box (Fire OS 5) every `pm` route is refused.
- "A few China-market TCL sets" refuse any launcher.
- Samsung Tizen, LG webOS, Roku, Vizio and VIDAA are unsupported (no ADB).
- Source: [README "Supported TVs"](https://github.com/Gathin23/cleanyourtv#supported-tvs)
- Below Android 7, `cmd package` doesn't exist, so the scripts fall back to `dumpsys activity`. Below Android 8 (SDK 26) the launcher can't install (`INSTALL_FAILED_OLDER_SDK`). — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
- On CVTE boards (any `com.cvte.*`), keep the stock `com.cvte.tv.launcher.*` enabled unless that exact board's example disables it. Set Home with `set-home-activity` and reboot before doing anything else. A JVC LT-43N7115 hung at the boot animation with ADB gone (#741). — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
- The tested-list brand counts are led by TCL 81, Sony 47, Xiaomi 42 and Philips 22. Indian brands present include Vu (3), OnePlus (4), Thomson (4), Acer (4), Nokia (3), Motorola (3), Karbonn and Jio. **No Micromax list exists**: a grep of the whole repo found zero "micromax" mentions. — [README brand table](https://github.com/Gathin23/cleanyourtv#supported-tvs), repo grep

**Issues reporting bricks and problems**
- #884: an original Mi TV Stick never booted again after a list disabled core packages. That incident is why the core guard exists. — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
- #1578: a Haier set restart-looped with `com.cltv.mal` disabled. — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
- #2516 (open): soft brick on a NOVA 32" CVTE Hi3751V350, Android 14, stuck on the boot logo after disabling `com.cvte.tv.launcher.space` followed by a power outage. — [Issue #2516](https://github.com/Gathin23/cleanyourtv/issues/2516)
- #795: a COOP COTV-0001 (rtd298x, Android 4.4.2) stuck on "INICIALIZANDO" with ADB unreachable after 17 packages were disabled. — [Issue #795](https://github.com/Gathin23/cleanyourtv/issues/795)
- #2557: a TCL G08 Google TV 14 stuck at the boot logo after `com.android.sdksandbox` was disabled; the guard was then extended. — [Issue #2557](https://github.com/Gathin23/cleanyourtv/issues/2557)
- #2803: a TCL 43S5400A boot loop led to adding `com.android.location.fused` to DO NOT DISABLE. — [Issue #2803](https://github.com/Gathin23/cleanyourtv/issues/2803)
- #62: the TV got stuck on the Google TV boot screen after a reboot with the custom launcher. — [Issue #62](https://github.com/Gathin23/cleanyourtv/issues/62)
- #1989 (open): MainActivity crashes on cold boot after disabling the stock launcher (Google TV). — [Issue #1989](https://github.com/Gathin23/cleanyourtv/issues/1989)
- #2432: the third-party "CleanTV" caused a black screen on a TCL C7L, and a factory reset was required. — [Issue #2432](https://github.com/Gathin23/cleanyourtv/issues/2432)
- #321: OnePlus TV (Android 11), where debloating OEM services broke the HDMI handshake ("No Signal"). — [Issue #321](https://github.com/Gathin23/cleanyourtv/issues/321)
- #962 (open): grey screen after the Google/TCL logo. — [Issue #962](https://github.com/Gathin23/cleanyourtv/issues/962)
- The FAQ says: "Nothing is flashed, rooted or deleted… If the TV no longer starts far enough for that, a factory reset from its recovery menu is usually the way back." — [README FAQ](https://github.com/Gathin23/cleanyourtv#questions-people-ask)
- Third-party coverage (Swedish) cautions that it does not automatically make the TV faster, does not remove all ads, and does not work on all models. — [hurbra.se](https://hurbra.se/cleanyourtv-google-tv/)

**No-laptop community apps**
- Independent apps built on the lists: Clean Your TV app (Android phone, udhaykumarbala), Tellyscope (phone), TidyTV (phone, on Google Play) and CleanMyTV (Mac/Windows). None is affiliated with the project. — [README FAQ](https://github.com/Gathin23/cleanyourtv#questions-people-ask)

### Inferences
- For a Micromax TV, CleanYourTV's own flow is the right starting point, but there is no tested list. The agent would have to do discovery itself, and if the stock launcher package isn't one of the four known ones, the install script will stop and require `STOCK_LAUNCHER=<pkg>` (or `none`).
- Many budget Indian sets use CVTE/MediaTek boards. If `pm list packages` shows `com.cvte.*` or `com.mediatek.tv.*`, the CVTE rules (keep the stock launcher enabled, reboot check) and the MediaTek middleware guard apply.
- Because the launcher is plain Java with RecyclerView and theme JSON, extending it (e.g. custom per-tile images or a "random pick" button) means writing Java in `com.gathin.tvhome`, or building a separate app that plugs in as a module card.

### Gaps
- I couldn't confirm Micromax's Android TV/AOSP status, its launcher package name, or its SoC from this source set.
- The issue count (~495, 120 open) comes from GitHub search, which may lag. I didn't read individual issue bodies beyond their titles.

## 2. How setting a default HOME launcher works on Android TV, Google TV and AOSP TVs, and what breaks when the stock launcher is disabled

### Takeaway
Android resolves Home through the `MAIN`+`HOME` intent, backed since Android 10 by RoleManager's `android.app.role.HOME`. `cmd package set-home-activity` sets the preference and AOSP-style Android TV usually honours it. Google TV fights it in three ways:
- `launcherx` silently re-takes Home while it is enabled.
- The setup wizard `setupwraith`'s `RecoveryActivity` grabs Home and can crash-loop `system_server`.
- Google features (voice results, profiles, phone casting, remote app buttons) live inside `launcherx` or `setupwraith`.

So you can disable the stock launcher, keep it and override Home with an accessibility service (Projectivy, Button Mapper), or use `set-home-activity` alone on sets that respect it. Each method has known breakages.

### Cited Findings

**Mechanics**
- The Home role is `"android.app.role.HOME"`. Apps qualify by declaring a MAIN/HOME intent filter, and `createRequestRoleIntent` asks for user consent. — [Android RoleManager docs](https://developer.android.com/reference/android/app/role/RoleManager.html), [RoleManagerCompat](https://developer.android.com/reference/androidx/core/role/RoleManagerCompat)
- AOSP changed `pm set-home-activity` to call RoleManager's `addRoleHolderAsUser` instead of PackageManagerService; since Android Q the underlying calls are asynchronous. — [AOSP commit (e/OS mirror)](https://gitlab.e.foundation/e/os/android_frameworks_base/-/commit/2b5a601f15e4709eb9e79c7fd831242e3d449531)
- CleanYourTV lists HOME claimants with `cmd package query-activities -a android.intent.action.MAIN -c android.intent.category.HOME`, reads the current owner with `cmd package resolve-activity --brief …`, and sets it with `cmd package set-home-activity --user 0 pkg/.Activity`. On Android 9, `set-home-activity` needs the full `pkg/activity` form. — [R/launcher/build-and-install.sh](https://github.com/Gathin23/cleanyourtv/blob/main/launcher/build-and-install.sh)
- `resolve-activity` answering `android` means the chooser: two launchers tie and no default is set. — [build-and-install.sh](https://github.com/Gathin23/cleanyourtv/blob/main/launcher/build-and-install.sh)
- Intent-filter priority matters on some boxes. On a Skyworth HP4416 the factory Google launcher claims HOME at priority 2 and Projectivy at 0, and after the reference launcher was installed the physical Home button still opened Google's screen. "An explicit activity launch or an injected key does not establish that the physical Home button was redirected." — [R/docs/devices/skyworth-hp4416-tvplus.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/devices/skyworth-hp4416-tvplus.md)
- The launcher's settings include a "Choose default home" entry that opens Android's home picker, and some TVs provide no home picker. — [R/docs/launcher.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/launcher.md)

**Google TV specifics (launcherx, setupwraith)**
- Known stock launcher packages: `com.google.android.tvlauncher` (Android TV), `com.google.android.apps.tv.launcherx` (Google TV), `com.google.android.leanbacklauncher` (older/AOSP Leanback) and Xiaomi `com.mitv.tvhome` (PatchWall). — [build-and-install.sh L71](https://github.com/Gathin23/cleanyourtv/blob/main/launcher/build-and-install.sh)
- While launcherx is enabled it takes Home back: "`set-home-activity` prints `Success` and changes nothing, and its home activity can't be disabled from the shell" (TCL 75C845X2, Google TV 14). — [R/docs/TROUBLESHOOTING.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/TROUBLESHOOTING.md)
- After the stock launcher is disabled, Google TV's setup wizard `com.google.android.tungsten.setupwraith` can take Home and crash-loop the system. The README says to disable it too and list it so restore brings it back. On Google TV 14 the next HOME candidate after the preference drops is `setupwraith`'s `RecoveryActivity`, "which crash-loops system_server". — [README "When something goes wrong"](https://github.com/Gathin23/cleanyourtv#when-something-goes-wrong), [build-and-install.sh](https://github.com/Gathin23/cleanyourtv/blob/main/launcher/build-and-install.sh)
- Disabling setupwraith deletes any Wi-Fi network saved during first setup, so the TV drops off Wi-Fi and ADB. Check `dumpsys wifi | grep -o 'cname=[^ ]*'` first and re-join the network in Settings. `disable.sh` skips setupwraith until you do. — [README](https://github.com/Gathin23/cleanyourtv#when-something-goes-wrong), [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
- Rescue command: `tools/tv.py 'pm enable --user 0 com.google.android.apps.tv.launcherx'`. — [README](https://github.com/Gathin23/cleanyourtv#when-something-goes-wrong)

**What breaks when the stock launcher (or setupwraith) is disabled**
- **Remote buttons:** on Google TV the stock launcher handles the remote's app buttons (Netflix, YouTube), Input and Settings/dashboard. These need remapping through the launcher's accessibility key services (`app_keys`, `input_key_keycodes`, `settings_key_keycodes`). — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md)
- **Key repeat:** on a TCL G09 (Google TV 12), any bound key-filtering accessibility service drops key repeats, so held volume becomes one step per press. Xiaomi Mi Box S on Android TV 9 showed the same trade. — [PROMPT.md](https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md), [R/docs/devices/xiaomi-mi-box-s.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/devices/xiaomi-mi-box-s.md)
- **Voice search:** "Google Assistant is having trouble processing your request" for content searches, because results render in launcherx (`.gateway.LauncherDeepLink`). App commands still work. The workaround is to keep launcherx enabled and open the custom launcher from its app row. "The Projectivy community found the same." — [TROUBLESHOOTING.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/TROUBLESHOOTING.md)
- **Accounts & profiles:** the Settings page is empty because it lives in launcherx. To switch profile you re-enable launcherx temporarily. — [TROUBLESHOOTING.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/TROUBLESHOOTING.md)
- **Phone casting:** fails with "Untrusted device" after setupwraith is disabled on Chromecast with Google TV and Google TV Streamer, because Cast factory credentials come from a content provider inside setupwraith, and its `.RecoveryActivity` component cannot be disabled alone (`SecurityException: Shell cannot change component state`). — [TROUBLESHOOTING.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/TROUBLESHOOTING.md)
- **Long-press Home:** with the system-image launcher disabled, Android sends a Home press held past 400 ms to `ACTION_ALL_APPS`, which nothing answers; the fix is the `home_long_press_home` option. — [R/themes/README.md](https://github.com/Gathin23/cleanyourtv/blob/main/themes/README.md)
- **Inputs:** on some sets (Hisense huangshan) the stock launcher is the only `VIEW_INPUTS` handler; the fix is the `handle_view_inputs` option. — [themes/README.md](https://github.com/Gathin23/cleanyourtv/blob/main/themes/README.md)
- **Boot and Home landing:** "Disable the stock launcher only after the new one is installed and running, or Home lands on a factory test app." — [README](https://github.com/Gathin23/cleanyourtv#when-something-goes-wrong)
- **OTA:** an update restores the stock launcher as Home and re-enables listed packages. Firmware updates still arrive unless the list disabled the updater. — [README](https://github.com/Gathin23/cleanyourtv#after-a-firmware-update)
- **Vendor quirks:** TCL's updater fails ("Local network or server abnormal") if `com.tcl.xian.StartandroidService` is disabled. Xiaomi China firmware Settings can crash after the debloat. — [TROUBLESHOOTING.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/TROUBLESHOOTING.md)

**Alternatives to disabling the stock launcher**
- **Projectivy "Override current launcher":** uses an Accessibility service to intercept Home presses and can be reversed by turning the override and the service off. — [Gadget Hacks guide](https://android.gadgethacks.com/how-to/best-google-tv-launcher-replacement-projectivy-setup-guide/) (via search summary; direct fetch was blocked with 403), [Galaxus](https://www.galaxus.ch/en/page/a-tv-home-screen-without-ads-projectivy-launcher-spices-up-android-and-google-tv-38294)
- CleanYourTV's device notes confirm Projectivy holds Home through `ProjectivyAccessibilityService`, which is also a key filter, while `resolve-activity` still names `com.google.android.tvlauncher`. — [R/docs/devices/xiaomi-mi-box-s.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/devices/xiaomi-mi-box-s.md)
- **Button Mapper / tvQuickActions Pro** can map the Home button to any launcher. — [BGR](https://www.bgr.com/2140758/best-smart-tv-launchers-you-can-try/)
- FLauncher's recommended method is remapping Home with Button Mapper; disabling the stock launcher over ADB is the riskier option. — [SourceForge FLauncher summary](https://sourceforge.net/app/flauncher/android/)
- Notebookcheck's Projectivy guide uses `adb shell pm disable-user --user 0 com.google.android.tvlauncher`. — [Notebookcheck (May 2025)](https://www.notebookcheck.net/The-Google-TV-launcher-is-mess-of-adverts-but-this-replacement-is-a-clean-beautiful-ad-free-alternative.1018849.0.html)
- **2026 Google TV pushback:**
  - A Google TV update broke Projectivy's override toggle: the stock home loads and Projectivy only opens manually. Android Authority said it was unclear whether this was intentional or a bug. — [Android Authority](https://www.androidauthority.com/google-tv-update-blocks-projectivy-override-3649445) (summary via search; fetch blocked)
  - Phonandroid suggests a TCL firmware update may be the cause instead. — [Phonandroid](https://www.phonandroid.com/?p=2687694)
  - The reported workaround is to reset settings and re-enable the override permissions. — [search summary of AA/Reddit](https://www.androidauthority.com/google-tv-update-blocks-projectivy-override-3649445)
  - AFTVnews reported that Google TV Streamer update UTTK.260317.003 (April 2026 patch) "deliberately uninstall[s] apps that let customers customize their streaming device, like Downloader, custom launchers like Projectivy Launcher, and ADB utilities". — [AFTVnews tag page](https://www.aftvnews.com/tag/update/)
- **CleanYourTV's own hybrid mode:** `STOCK_LAUNCHER=none` keeps the stock launcher, and `stock_home_redirect` (with `HOME_KEY_SERVICE=1`) bounces the stock home back to CleanYourTV, for firmware that re-enables its launcher (XGIMI). It does nothing on Coocaa OS, whose stock home declares no `CATEGORY_HOME` (#1351). — [themes/README.md](https://github.com/Gathin23/cleanyourtv/blob/main/themes/README.md), [Issue #1351](https://github.com/Gathin23/cleanyourtv/issues/1351)

### Inferences
- **AOSP / non-certified Android TV** (typical budget OEM sets running a vendor launcher on AOSP): no launcherx and no setupwraith, so `set-home-activity` plus disabling the vendor launcher usually works. The risks are vendor-specific instead: CVTE and MediaTek middleware, factory apps, a `FallbackHome` black screen (Xiaomi #1905).
- **Google-certified Android TV** (`tvlauncher`): generally honours `set-home-activity` once `tvlauncher` is disabled.
- **Google TV** (`launcherx` + `setupwraith`): the hardest case. Expect losses in voice results, profiles and possibly casting. The accessibility-override route is fragile, and Google may be actively hostile to it (2026 reports).
- An accessibility-based override costs key repeat on some firmware. That applies to Projectivy's service as much as to CleanYourTV's helpers.

### Gaps
- I couldn't read the Android Authority or Gadget Hacks articles directly (HTTP 403). Their claims come from search summaries.
- I found no official Android TV developer doc specific to Home/launcher replacement on TV.
- I couldn't confirm whether the 2026 override breakage was fixed.

## 3. Alternative launchers compared

### Takeaway
Projectivy is the most-used closed-source pick: free, with ~$7 premium for custom wallpapers, icons and themes, and it relies on an accessibility override that Google TV has been breaking in 2026. FLauncher (Flutter, GPLv3) is the main open-source option, with forks LTvLauncher and Arc. ATV Launcher has free and Pro tiers. Wolf is popular on Fire TV. Dispatch is a Plex-centric beta. Leanback on Fire is an open-source fork of Google's Leanback launcher. CleanYourTV's own launcher has the smallest footprint (~572 KB, no network, 1 GB-RAM target), is MIT-licensed, and has the largest fork ecosystem (196 SHOWCASE projects).

### Cited Findings
- **Projectivy Launcher** (`com.spocky.projengmenu`, dev Spocky)
  - Free, with premium at about $7 ($7.50 per Notebookcheck). Custom wallpapers and advanced icon customization need premium. You can swap icons for your own images or icon packs, add shortcuts and rename apps. Wallpaper-source plugins arrived in v4.54, themes and font customization (premium) in v4.71, and the UI adapts its colours to the wallpaper. — [search summary of Play/APKMirror listings](https://www.apkmirror.com/?p=14789445), [Notebookcheck](https://www.notebookcheck.net/The-Google-TV-launcher-is-mess-of-adverts-but-this-replacement-is-a-clean-beautiful-ad-free-alternative.1018849.0.html)
  - Notebookcheck says it is "lighter on resources than the stock launcher". — [Notebookcheck](https://www.notebookcheck.net/The-Google-TV-launcher-is-mess-of-adverts-but-this-replacement-is-a-clean-beautiful-ad-free-alternative.1018849.0.html)
  - One user reported premium features stop working when the Play Store is disabled. That matters for debloaters. — [r/Projectivy_Launcher via search summary](https://libreddit.winscloud.net/r/Projectivy_Launcher/comments/1n44qyl/projectivy_premiums_removed_when_disabling_play)
  - CleanYourTV device notes record Projectivy as Home on several TVs, e.g. staying Home across a power cycle on a Xiaomi HyperOS 3 set after Xiaomi TV Home was disabled. — [R/docs/devices/xiaomi-mitv-mftr0-hyperos3.md](https://github.com/Gathin23/cleanyourtv/blob/main/docs/devices/xiaomi-mitv-mftr0-hyperos3.md)
- **FLauncher**
  - Open source (GPLv3) and written in Flutter by Étienne Fesser; hosted at gitlab.com/etienn01/flauncher with 138 commits and 17 releases, created 2021-05-13. — [GitLab](https://gitlab.com/etienn01/flauncher)
  - Features: categories, wallpapers, row or grid layouts, uninstall, shortcuts to Settings and App info, no ads. It was "still at an early development stage and may be unstable" (2021). — [XDA, Dec 2021](https://www.xda-developers.com/flauncher-android-tv/)
  - Forks: LTvLauncher (LeanBitLab) and Arc Launcher (a fork of LTvLauncher). — [denilsonsa gist, active Nov 2026](https://gist.github.com/denilsonsa/80cbb3a14b3bf63de75e6bf81c89ee05)
- **ATV Launcher:** free and Pro tiers ($4.99 in one review, $2.99 in a 2026 listing). It is described as the "gold standard for customization" with configurable app grids and widgets. — [technicalustad](https://technicalustad.com/android-tv-launchers/), [firesticktvstream 2026](https://www.firesticktvstream.com/?p=990049)
- **Dispatch:** beta launcher with a Netflix-like Plex feed; free install with in-app purchases. — [firesticktvstream 2026](https://www.firesticktvstream.com/?p=990049)
- **Wolf Launcher:** coverage centres on Fire TV. It can replace the Fire launcher and offers app-list editing, folders and password-protected folders or apps. — [googlewatchblog](https://www.googlewatchblog.de/2023/07/amazon-fire-tv-stick-wolf-launcher-install/)
- **Leanback on Fire:** "Google Leanback Launcher on steroids". The tsynik fork has 687 stars, was last pushed 2026-02-07, and has no SPDX license in the API. — [GitHub tsynik/LeanbackLauncher](https://github.com/tsynik/LeanbackLauncher)
- **CleanYourTV launcher:** about 572 KB, plain Java, no network permission, no background services, targets 1 GB RAM; the free themes include wallpaper collections, shuffle and cinematic artwork. — [README](https://github.com/Gathin23/cleanyourtv#the-launcher), [themes/README.md](https://github.com/Gathin23/cleanyourtv/blob/main/themes/README.md)
- **Notable CleanYourTV-ecosystem launchers** relevant to custom imagery:
  - Home Deck: big glowing tiles with fan-made tile art, up to 7 favorites, a "Jump back in" row, Lite mode for slow TVs.
  - Vibe Launcher: the focused dock app fills the screen with its titles' backdrops.
  - PeachOS TV: poster shelves from Watch Next.
  - cleanyourtv-ui: TMDB Explore with "Watch on" deep links.
  - Kids World: animated worlds with a mascot and child profiles.
  - Weeb glass home: anime pictures with the focus highlight taking each picture's colour.
  - Spider-Man theme fork: rotating wallpapers.
  - KinoDock: reorderable favorites dock with Unsplash wallpapers.
  - Source: [R/SHOWCASE.md](https://github.com/Gathin23/cleanyourtv/blob/main/SHOWCASE.md)

| Launcher | Open source | Cost | Customization highlights | Home takeover | Low-RAM notes |
|---|---|---|---|---|---|
| CleanYourTV (`com.gathin.tvhome`) | Yes, MIT | Free, build it yourself | Themes over Wi-Fi, wallpaper collections, cinematic artwork, 4–7 dock, module cards | `set-home-activity` + disable stock (scripted, with rollback) | 572 KB, 1 GB target, no network |
| Projectivy | No (see gaps) | Free / ~$7 premium | Custom icons, wallpapers (premium), plugins, themes | Accessibility override or ADB disable | Reported lighter than stock |
| FLauncher (+LTv, Arc forks) | Yes, GPLv3 | Free | Categories, wallpaper, row/grid | Button Mapper or ADB disable | Flutter runtime (not measured) |
| ATV Launcher | No | Free / Pro | Grids, widgets | Not documented in sources | Not documented |
| Wolf | No | Free | Folders, passwords; Fire TV focus | Fire TV | Not documented |
| Dispatch | No | Free + IAP | Plex feed | Not documented | Not documented |
| Leanback on Fire | Source public, no license | Free | Leanback rows | Fire TV | Not documented |

Rows are cited above; "Not documented" means no source was found. The open-source status for ATV, Wolf and Dispatch rests on no source repository being found, not on an explicit statement.

### Inferences
- For a low-RAM budget TV, CleanYourTV's launcher, or a fork of it, is the best documented for performance: there is a `tools/bench.py` harness, and `glow_snap` exists because a Mali-G52 GPU dropped frames.
- Projectivy's dependence on the Play Store for premium, and on an accessibility override, makes it fragile on a heavily debloated or Google TV set.
- For a fully custom UI (custom images per app, character art), forking CleanYourTV's launcher (MIT, Java, RecyclerView) is the lowest-friction base. Home Deck, Weeb glass home and Spider-Man show the pattern.

### Gaps
- I didn't verify Projectivy's open-source status. The gist links a GitHub repo, but my understanding is that the app is closed-source with a public plugin/issue repo; this is unconfirmed.
- No measured RAM or CPU figures for Projectivy, FLauncher, ATV or Wolf were found.
- FLauncher's last-commit date couldn't be retrieved (the GitLab API and raw README requests failed).
- I found no Wolf Launcher or Dispatch current Play listing details for Android TV (as opposed to Fire TV).
- I found no source on whether any of these support a per-app background image tied to the focused tile, other than CleanYourTV's `cinematic_home` (which uses the app's own artwork) and SHOWCASE forks such as Vibe Launcher.

## 4. Is the Instagram reel concept (character lineup launcher, "My Favourites", mood-based random watch) built on CleanYourTV?

### Takeaway
I found no public source tying a "character lineup / My Favourites / mood-based random watch" launcher to CleanYourTV or any named project. CleanYourTV's ecosystem contains close building blocks: character or anime wallpapers, favorites docks, kids profiles with mascots, and TMDB "what to watch" shelves. The concept is plausibly a CleanYourTV fork or a Claude Code–built custom launcher in the same viral wave, but that is unverified.

### Cited Findings
- SHOWCASE.md lists 196 community projects. The closest matches:
  - Weeb glass home: neon-outline anime characters, the focus colour taken from each picture.
  - Kids World: "four animated worlds with a mascot, child profiles with their own allowed apps", started from this repo's launcher.
  - Home Deck: "up to seven favorites" with fan-made tile art.
  - KinoDock: "reorderable favorites dock".
  - cleanyourtv-ui and Forslag: TMDB-based Explore and "what is in your own streaming subscriptions" with deep links to Netflix, Disney+ and others.
  - kermes-tv: a recommendations hero.
  - Source: [R/SHOWCASE.md](https://github.com/Gathin23/cleanyourtv/blob/main/SHOWCASE.md)
- The built-in `weeb` theme cycles five original anime characters every 30 minutes, in sequential order (images made with Gemini). — [search summary of themes/](https://github.com/Gathin23/cleanyourtv/tree/main/themes)
- CleanYourTV's `wallpaper_moods` is time-of-day grouping (morning/evening/night), not user mood. — [themes/README.md](https://github.com/Gathin23/cleanyourtv/blob/main/themes/README.md)
- The only Instagram reel linked in SHOWCASE is for the "Bluetooth pill fork" (instagram.com/reel/DevztL0OVe_), which is unrelated to characters. — [SHOWCASE.md](https://github.com/Gathin23/cleanyourtv/blob/main/SHOWCASE.md)
- Searches for a character/favourites/mood/random launcher found nothing; results were about Instagram's own TV app (Reels on Google TV, Feb 2026). — [TechCrunch](https://techcrunch.com/2026/02/24/instagrams-tv-app-is-launching-on-google-tv-devices)
- Mentions of CleanYourTV I could find are news and blog coverage (developersdigest, hk01, hurbra.se, techno-edge, ifun.de, androidphoria), with no Reddit, YouTube or X threads surfaced by search. The author's origin post is on X. — [developersdigest](https://www.developersdigest.tech/blog/cleanyourtv-claude-code-debloat-android-tv-safe-guide-2026), [README story](https://github.com/Gathin23/cleanyourtv#the-story)

### Inferences
- Within CleanYourTV, a reel-style feature set maps onto existing pieces:
  - "My Favourites" corresponds to `dock_apps`.
  - Character lineup tiles correspond to custom tile art (as in Home Deck) or a theme's `wallpapers/` collection.
  - Mood-based random watch would need new code. The pattern exists in cleanyourtv-ui and Forslag (TMDB plus deep links), or it could be a module-card add-on (`docs/modules.md`).
- The reel was likely made during the Oct–Nov 2026 CleanYourTV wave, given the timing and the "Apple TV-style, Claude Code" framing, but there is no evidence for this.

### Gaps
- I couldn't search Instagram, X or Reddit directly (no logged-in access). The reel itself wasn't available, so its creator, device and code base are unknown.
- Asking the user for the reel URL or its creator handle would close this gap.
