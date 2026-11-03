# Micromax TV — Debloat + Character Launcher: Execution Plan

Companion to `Micromax TV debloat and custom UI.md` (research report). Sources: `research_notes/Micromax TV debloat and custom UI/`. **[unverified]** = no Micromax-specific source; confirm on device.

> **Device facts (verified 2026-11-03 over ADB):** TCL-built Micromax 4K Android TV · MediaTek MT5891 (4× Cortex-A53, 32-bit) · Mali-T860 · 2 GB RAM · 4K panel, UI 1920×1080@50 Hz · Android TV 8.0 (SDK 26), certified · `tcl_eu` / `OTT1.180130.001` · not root · ADB on 5555 via firmware prop · **Path D**. Stock Home `com.google.android.tvlauncher` has **no Disable button in Settings** ⇒ Tier 2 cannot re-enable it ⇒ **Stage A only** (keep stock enabled; `set-home-activity`). Keep also: `com.tcl.xian.StartandroidService`, `com.tcl.versionUpdateApp`, all `com.tcl.tv*`/`sourcemananger`/`settings`/`inputmethod`, all `com.mediatek.*`, `mtktvapi.agent`. Recovery combo: TCL pattern (hold power while plugging AC) — test in Phase 2. Scene art: 1920×1080. Mac quirk: Warp is blocked by Local Network privacy — run the adb server from Terminal.app.
>
> **Status 2026-11-03:** G1 passed (backup 108/108 APKs, `REVERT OK`). Cold boot: ADB auto-reconnects (AC restore → standby → one Power press). Recovery: boots to "Error!" robot with no menu and auto-reboots ⇒ **no recovery-menu factory reset on this TV**. A flatmate's identical TV was bricked by self-debloat.
> **Added hard gates before ANY change:** **A** matching `V8-T658TAP` `Update.pkg` in hand · **B** reflash proven on the flatmate's bricked TV (boots, Wi-Fi, Netflix, HDMI) · **C** only then Phase 3. Phase 4 default = keep stock launcher enabled + CleanYourTV Home-key redirect (no system disables). Service centre is not an option (wall-mounted); recovery must be doable in place (side USB port + body power key).
>
> **Status 2026-11-04 (H's TV):** Phase 3 done (11 pkgs, `~/tv-backup/debloat-micromax-tcl_eu.txt`). Phase 4 done: CleanYourTV launcher built from source, stock `tvlauncher` disabled (Stage B, user's choice), Home holds across reboot; `power_on_home`, HomeKeyService on; animations 0.5×; `RUN_IN_BACKGROUND ignore` for Hotstar/FanCode/SonyLIV; HDMI-CEC on (`~/tv-backup/ps5.sh` wakes PS5); Stremio 1.10.4 sideloaded (official, signed); dock YouTube/Netflix/JioHotstar/FanCode/Stremio via `~/tv-backup/theme-h`. Chromecast verified (SonyLIV cast). Rollback: `~/tv-backup/revert-phase4.sh`, `revert.sh`. **Gate A met:** verified `Update_MMX_V8-T658TAP-LF1V372_sign.pkg` (MD5 match, `~/tv-backup/firmware/VERIFIED.txt`). M's TV (Gate B) parked. Next: Marauder's Map + Hedwig launcher (Phases 5–7), design in `hogwarts-tv-launcher/`.
>
> **Wall-mounted TV adjustment:** board/panel sticker photos are skipped. Board platform, panel config and build info are captured over ADB instead (Phase 0.4 + the extra probe below). If Tier 5 (firmware reflash) is ever needed, a repair shop will have to dismount and read the board anyway.

---

## Operating rules for Claude Code
- One `pm` command per `adb shell` call — never chained (chained commands can silently stop after the first).
- Verify state with `pm list packages -d` / `resolve-activity`, never exit codes (`set-home-activity` can print `Success` and change nothing).
- `pm disable-user --user 0` only. Never `pm uninstall` (with or without `-k`), `pm clear`, `pm hide`, or UAD-ng "Disable" (it clears data).
- Never launch factory/test apps (`com.cvte.tv.fac.menu`, `mediatek.factorymenu.ui`, …) or enter factory-menu codes. On CVTE boards this sets a factory flag that kills the Input key and CEC.
- Log every change to `changes.log` as `time|pkg|action|revert-cmd`. Human approves every disable.
- Wait 15 s after a package change before rebooting (package state is written ~10 s later).
- Unknown vendor package ⇒ KEEP.

```bash
export TV=192.168.x.y:5555
a() { adb -s "$TV" shell "$@" </dev/null | tr -d '\r'; }   # strip CRLF; </dev/null keeps loops intact
```

---

## Phase 0 — Identify & decide (1–2 h)

### 0.1 Mac prerequisites
```bash
brew install --cask android-platform-tools
# later, for Phase 5: brew install --cask temurin@17 android-studio   (JDK 17–22; JDK 23+ breaks Gradle 8.9)
```
- System Settings → Privacy & Security → **Local Network** → allow your terminal (else "No route to host"; fallback: CleanYourTV `tools/tv.py`).
- Router: DHCP reservation for the TV so the IP never changes.

### 0.2 On the TV (no tools)
- Settings → About: model, Android version, build — photograph every screen.
- Turn off **System update → Auto update**; Play Store (if present) → **Don't auto-update apps**.
- Remote: does it have Settings/gear, Input, Home keys? TV body: single power key, joystick, or vol/CH row? (decides which recovery combos are physically possible).

### 0.3 Probe ADB before touching menus
```bash
nc -vz -G 3 <tv-ip> 5555   # open with dev options untouched = ODM default ADB (note for Phase 8)
```
If closed: Settings → About → press **Build** ×7 → Developer options → **USB debugging** ON (+ **Network debugging** if present) → `adb connect $TV` → accept RSA prompt with **Always allow**. TV USB-A ports are host-only; a cable cannot give ADB.

### 0.4 Fingerprint block (replaces sticker photos)
```bash
D=~/tv-backup/$(date +%F)-phase0; mkdir -p "$D"; cd "$D"
adb connect $TV
a getprop > getprop.txt
grep -E '\[(ro\.product\.(model|brand|manufacturer|device|board)|ro\.board\.platform|ro\.hardware|ro\.build\.(fingerprint|version\.release|version\.sdk)|ro\.adb\.secure|persist\.adb\.tcp\.port|service\.adb\.tcp\.port|dalvik\.vm\.heapgrowthlimit)\]' getprop.txt
grep -iE 'mstar|cvte|mtk|mediatek|realtek|amlogic|droidlogic|hisi|odm|customer|panel|ini' getprop.txt
a id                                  # uid=0 ⇒ root adbd ⇒ full partition backup possible (see 1.5)
a cat /proc/cmdline > cmdline.txt     # often names board/panel
a ls /tvconfig /config /vendor/tvconfig > tvconfig_ls.txt 2>&1   # MStar/CVTE panel ini files
a cat /proc/cpuinfo > cpuinfo.txt; a cat /proc/meminfo | head -3; a wm size
a pm list packages > pkgs.txt
grep -E 'google\.android\.gms$|com\.android\.vending|tvlauncher|leanbacklauncher|launcherx|setupwraith|aptoide|com\.cvte|com\.mstar|com\.mediatek|com\.realtek|droidlogic|webview' pkgs.txt
a cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
a dumpsys webviewupdate | head -20
```
Read: fingerprint has `google/` + gms/vending ⇒ certified ATV. `ro.board.platform`: `mt5886`/`mt9612` ⇒ MediaTek; `m7322`/`mstar` ⇒ MStar; `rtd28xx` ⇒ Realtek.

### 0.5 Decision tree
| Fingerprint | Path | Debloat | Launcher |
|---|---|---|---|
| No ADB even after enabling dev options / non-smart set | **STOP** | — | — |
| SDK ≤ 22 (Android ≤ 5.1, 2015 KitKat sets) | **STOP** | No (4.4 needs root `pm block`; issue #795 bricked a 4.4.2 set) | Compose minSdk 23 won't install |
| SDK 24–25 (Android 7, AOSP, Aptoide, Canvas 3) | **B** | Yes | CleanYourTV launcher refuses (minSdk 26). Own Compose launcher (minSdk 23). FLauncher stopgap if it installs [unverified] |
| SDK ≥ 26, no gms (AOSP 8+ "Custom Android") | **C** | Yes | CleanYourTV with `STOCK_LAUNCHER=<pkg from resolve-activity>`, then own launcher |
| SDK ≥ 26, gms + `com.google.android.tvlauncher` (2018 4K / 2019 CAM6) | **D** | Yes; keep gms, gsf, Play, Chromecast, Assistant | CleanYourTV with `STOCK_LAUNCHER=com.google.android.tvlauncher`; expect possible Chromecast/voice loss |
| `launcherx`/`setupwraith` (Google TV) | **E** | Not expected on Micromax | Stop, or follow CleanYourTV Google TV docs and accept losses |

Modifiers: `com.cvte.*` present ⇒ keep stock CVTE launcher enabled, `STOCK_LAUNCHER=none`, reboot-check first. `com.mediatek.tv.*`/`com.cltv.mal` ⇒ never disable. Sideload refused ⇒ debloat only.

**G0:** path letter, SDK, stock HOME component, vendor stack, board/panel info captured from 0.4.

---

## Phase 1 — Backup (2–4 h; APK pull over Wi-Fi is slowest)

### 1.1 `backup.sh` — run before any change, re-run before each phase
```bash
#!/usr/bin/env bash
# usage: ./backup.sh <tv-ip>   -> prints backup dir
set -u
S="$1:5555"; adb connect "$S" >/dev/null
A() { adb -s "$S" shell "$@" </dev/null | tr -d '\r'; }
B=~/tv-backup/$(date +%F_%H%M)-$(A getprop ro.product.model | tr ' /' '__'); mkdir -p "$B/apks"; cd "$B" || exit 1
A getprop > getprop.txt; A cat /proc/cpuinfo > cpuinfo.txt; A cat /proc/meminfo > meminfo.txt; A wm size > wm_size.txt
A cat /proc/cmdline > cmdline.txt; A ls /tvconfig /config /vendor/tvconfig > tvconfig_ls.txt 2>&1
A pm list packages > pkgs_installed.txt
A pm list packages -f -u > pkgs_all_paths_incl_uninstalled.txt
for f in d e s 3; do A pm list packages -$f > pkgs_$f.txt; done
A cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME > home.txt
A cmd package query-activities -a android.intent.action.MAIN -c android.intent.category.HOME > home_candidates.txt
for t in global secure system; do A settings list $t > settings_$t.txt; done
A dumpsys package > dumpsys_package.txt
A dumpsys activity activities > dumpsys_activities.txt
A dumpsys webviewupdate > dumpsys_webview.txt
A dumpsys tv_input > dumpsys_tv_input.txt
cut -d: -f2 pkgs_installed.txt | while read -r p; do      # every APK incl. splits
  mkdir -p "apks/$p"
  A pm path "$p" | cut -d: -f2 | while read -r f; do
    adb -s "$S" pull "$f" "apks/$p/" </dev/null >/dev/null || echo "FAIL $p $f" >> pull_errors.txt
  done
done
shasum -a 256 apks/*/*.apk > apks.sha256
cp ~/.android/adbkey ~/.android/adbkey.pub "$B/"          # the key this TV trusts
echo "$B"
```
Keep `~/tv-backup` out of iCloud/Dropbox/git (contains the ADB private key).

### 1.2 Photos scripts can't capture
Picture, sound, input, network settings screens; channel list (restore = rescan); Settings → Apps → stock launcher info page — confirm an **Enable/Disable** button exists (Tier 2 path).

### 1.3 Firmware sourcing (search, don't flash)
- Search board platform + model + "Micromax <model> software"; leads: Elektroda, local repair shops (dipelectronicslab is offline). Record file, source, match evidence, sha256 in `firmware.md`.
- Unofficial dumps can carry another unit's MAC/Widevine/HDCP keys — DRM apps may break.
- Micromax care 0129-488 3999, IVR option 1 (third-party listing).
- **Not finding firmware does not block**: user-0 changes are undone by factory reset — which makes the Phase 2 recovery test mandatory.

### 1.4 `revert.sh` — one command back to baseline
```bash
#!/usr/bin/env bash
# usage: ./revert.sh <tv-ip> <backup-dir>
set -u
S="$1:5555"; B="$2"; adb connect "$S" >/dev/null
A()  { adb -s "$S" shell "$@" </dev/null | tr -d '\r'; }
pk() { cut -d: -f2 | tr -d '\r' | sort; }
HOME_C=$(tail -1 "$B/home.txt")
# 1) re-enable everything disabled since baseline
comm -13 <(pk < "$B/pkgs_d.txt") <(A pm list packages -d | pk) | while read -r p; do A pm enable "$p"; done
# 2) restore anything uninstalled for user 0 since baseline (should be empty)
comm -23 <(pk < "$B/pkgs_installed.txt") <(A pm list packages | pk) | while read -r p; do A pm install-existing "$p"; done
# 3) restore Home (skip if baseline was the chooser)
case "$HOME_C" in android/*) ;; *) A cmd package set-home-activity "$HOME_C" ;; esac
A input keyevent KEYCODE_HOME
# 4) self-check
diff <(pk < "$B/pkgs_d.txt") <(A pm list packages -d | pk) \
 && [ "$(A cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1)" = "$HOME_C" ] \
 && echo "REVERT OK" || { echo "REVERT INCOMPLETE"; exit 1; }
```
Dry-run now with nothing changed — must print `REVERT OK`. If using CleanYourTV `tools/disable.sh`, its `tools/restore.sh` is primary; `revert.sh` is the tool-independent fallback.

### 1.5 Only if `adb shell id` shows `uid=0` (root adbd)
Dump partitions — a firmware backup from your own TV beats any download:
```bash
a ls -l /dev/block/by-name /dev/block/platform/*/by-name 2>/dev/null > partitions.txt
for p in boot recovery system vendor tvconfig; do                        # only names that exist in partitions.txt
  adb -s $TV exec-out "dd if=/dev/block/by-name/$p 2>/dev/null" > "$p.img"
done
shasum -a 256 *.img > images.sha256
```
Skip userdata (huge, personal). Read-only operation; never `dd` *to* a block device.

**G1:** backup folder complete, `pull_errors.txt` empty or explained, `REVERT OK` dry run, `firmware.md` written (even if "not found").

---

## Phase 2 — ADB persistence gate (~1 h). Nothing changes until this passes.
1. **Cold power-cycle:** AC off 60 s, power on, don't touch the remote.
   ```bash
   adb disconnect; sleep 90; adb connect $TV && a getprop sys.boot_completed   # expect 1
   ```
2. **Recovery entry test** (remove all USB sticks first — some boards auto-apply updates from USB):
   `adb -s $TV reboot recovery` → choose **Reboot system now**. Then try the physical combo (Tier 4) and note which keys navigate.
3. **Remote Settings path:** with a streaming app open, press Settings/gear — Settings must open without the launcher; reach Developer options and toggle USB debugging.
4. Optional: test safe mode (Tier 3).

| Result | Action |
|---|---|
| PASS | Proceed |
| PARTIAL (reconnects only after toggling USB debugging) | Proceed only if step 3 passed; never disable stock launcher (Stage A only) |
| FAIL, or step 3 fails | No launcher swap; at most debloat apps re-enable-able from Settings → Apps |
| Recovery unreachable + no firmware | User-facing preloads only; no vendor packages; Stage A only |

**G2:** cold-boot reconnect passes twice; recovery entry confirmed; remote Settings path works.

---

## Phase 3 — Conservative debloat (1–2 evenings + 48 h soak)

### Never-touch list
- **Core:** `android`, `android.ext.*`, `com.android.sdksandbox`, `com.android.location.fused`, `com.android.systemui`, `com.android.shell`, `com.android.phone`, `com.android.settings`, `com.android.tv.settings` + any OEM TV Settings, permissioncontroller, packageinstaller, modulemetadata, `com.google.android.overlay.modules*`, `com.android.providers.*`.
- **Input/UI:** `com.android.inputmethod.*`, `com.google.android.leanback.ime` (no keyboard ⇒ no Wi-Fi password ⇒ no ADB), WebView, setup wizard.
- **TV stack:** `com.android.tv`/`com.google.android.tv`, TV source/HDMI-CEC app; MStar `com.mstar.*`; CVTE `com.cvte.tv.*` (incl. its launcher); MediaTek `com.mediatek.tv*`, `com.mediatek.wwtv.*`, `com.mediatek.twoworlds.*`, `com.cltv.mal`; Realtek `com.realtek.*`; Amlogic droidlogic.
- **Remote/connectivity:** `com.android.bluetooth`, `com.google.android.tv.remote.service`, remote pairing services.
- **Path D:** gms, gsf, vending (+ Chromecast/Assistant unless you choose otherwise).
- **OTA/updater** (may back "Upgrade from USB"). **The only working launcher.** **Factory/test apps.**
- Can't name a package's purpose from `dumpsys package` ⇒ it stays.

### Candidates (safest first)
Social apps, Aptoide (`cm.aptoide.pt`/`cm.aptoide.tv`) once you have another install route, partner content, ad/recommendation clients, unused eShare/AirPlay/TV Guide; Path D: `com.google.android.tvrecommendations`. CleanYourTV `tools/privacy.py` can audit telemetry candidates.

### Per-package loop
```bash
P=cm.aptoide.tv
a dumpsys package $P | grep -E 'versionName|codePath|enabled=|Activity|Service' | head -40   # inspect, never launch
echo "$(date +%T)|$P|disable-user|pm enable $P" >> "$B/changes.log"
a pm disable-user --user 0 $P
a pm list packages -d | grep -x "package:$P"
sleep 15; adb -s $TV reboot
# after boot:
adb connect $TV; a getprop sys.boot_completed; a pm list packages -d | grep -x "package:$P"
```
**Smoke test after every reboot (~5 min):** ADB reconnects · every HDMI/AV/tuner input shows picture via Input key · Home/Back/Input/Settings keys work, held volume repeats · Wi-Fi up · one streaming app plays 30 s with sound · Settings opens · on-screen keyboard appears · Path D: casting works.
**On failure:** `a pm enable $P`, reboot, mark KEEP. Only plainly user-facing third-party preloads may be batched (max 3 per reboot).

### Per-model list
Keep `lists/micromax-<model>.txt` + `docs/devices/micromax-<model>.md` in CleanYourTV format. After 7 stable days, open an upstream PR (repo has zero Micromax mentions).

**G3:** every disable survived reboot + smoke test; `changes.log` complete; 48 h soak incl. one AC-off night; `revert.sh` prints `REVERT OK`, then re-apply (fire drill).

---

## Phase 4 — Launcher swap (2–3 h + 24 h soak). Run `backup.sh` first.

**Paths C/D — CleanYourTV interim launcher:**
```bash
git clone https://github.com/Gathin23/cleanyourtv && cd cleanyourtv && git rev-parse HEAD >> "$B/notes.txt"
# read script usage first; it installs, verifies Status: ok, disables stock, set-home LAST, re-queries, auto-rolls-back
STOCK_LAUNCHER=<pkg from home.txt> ./launcher/build-and-install.sh ...          # Path C
STOCK_LAUNCHER=com.google.android.tvlauncher ./launcher/build-and-install.sh ... # Path D
STOCK_LAUNCHER=none ./launcher/build-and-install.sh ...                          # any CVTE board; reboot right after
```
**Path B / own launcher later — two stages, Stage B only if A doesn't hold:**
```bash
adb -s $TV install -r app-release.apk
a am start -W -a android.intent.action.MAIN -c android.intent.category.HOME -n com.you.tvhome/.MainActivity   # Status: ok
# Stage A: set Home, stock stays ENABLED
a cmd package set-home-activity com.you.tvhome/.MainActivity
a cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
a dumpsys activity activities | grep -E 'mFocusedApp|ResumedActivity'
# Stage B (only if stock re-asserts after cold boot / physical Home; never on CVTE):
a pm disable-user --user 0 <stock.launcher>
a cmd package set-home-activity com.you.tvhome/.MainActivity   # again; Android drops the pref when HOME set changes
```
**Verify:** press the **physical** Home key · 3 AC cold boots land on new Home · Input key switches HDMI with picture · Settings key + tile work · long-press Home OK · Path D: Chromecast/voice (if broken and you care, re-enable tvlauncher, stay Stage A). Screenshots: `adb exec-out screencap -p > x.png` (HDMI/DRM return blank — use `ResumedActivity`).
**Fire drill:** `revert.sh` → stock Home back → re-apply.
**No-go:** Home won't hold ⇒ debloat-only, or accessibility Home redirect (CleanYourTV `HOME_KEY_SERVICE`/`stock_home_redirect`, Projectivy override; may cost key repeat).

**G4:** all checks + fire drill pass; 24 h soak incl. AC-off night.

---

## Phases 5–7 — Custom UI

### Stack: Kotlin + Jetpack Compose for TV, standalone app
| | Compose for TV (chosen) | Fork CleanYourTV Java launcher |
|---|---|---|
| Path B (Android 7) | Yes (minSdk 23) | No (minSdk 26) |
| Fit for React/GSAP dev | State-driven, `animateFloatAsState`/`Crossfade` | Imperative Views/RecyclerView |
| Your features | Greenfield anyway | Same new code inside 74 foreign classes |
| Upstream churn | None | Dozens of PRs/day |
| Perf on 1 GB / Mali-470 | **Unknown — spike first (5.2)** | Tuned for 1 GB |

Reuse CleanYourTV for operations (`restore.sh`, `disable.sh` guard, `tv.py`, `bench.py`, `adb-closed.py`) and as MIT reference code (opaque theme, `<queries>`, `VIEW_INPUTS`, `HomeKeyService`).
**Fallback if 5.2 fails:** C/D ⇒ CleanYourTV launcher with character `wallpapers/` + `dock_apps` (zero code); B ⇒ pre-baked static art, no animation.

### Phase 5 — Foundation (2–3 days)
**5.1 Skeleton (emulator).** minSdk 23, target/compile 34; Compose BOM + `androidx.tv:tv-material:1.1.0`; standard `LazyRow`/`LazyVerticalGrid` (TvLazy* removed). arm64 Android TV AVD, lowest API available.
```xml
<uses-feature android:name="android.software.leanback" android:required="false"/>
<uses-feature android:name="android.hardware.touchscreen" android:required="false"/>
<queries><intent><action android:name="android.intent.action.MAIN"/></intent></queries>
<application android:banner="@drawable/banner" ...>   <!-- 320x180 with text -->
  <activity android:name=".MainActivity" android:exported="true" android:launchMode="singleTask"
      android:theme="@style/OpaqueTheme"
      android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode">
    <intent-filter>
      <action android:name="android.intent.action.MAIN"/>
      <category android:name="android.intent.category.HOME"/>
      <category android:name="android.intent.category.DEFAULT"/>
      <category android:name="android.intent.category.LEANBACK_LAUNCHER"/>
      <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
  </activity>
```
App list: `queryIntentActivities` for `LEANBACK_LAUNCHER` + `LAUNCHER`, merged; refresh on `PACKAGE_ADDED/REMOVED/CHANGED`. Launch: `getLeanbackLaunchIntentForPackage ?: getLaunchIntentForPackage`. Clock ticks per minute.
✅ Emulator: set-home works, grid lists/launches apps, clock runs.

**5.2 Perf spike on the real TV — go/no-go for the stack.** Install as normal app (not Home); release build with R8; 20-banner grid + 720p background crossfade.
```bash
a dumpsys gfxinfo com.you.tvhome framestats; a dumpsys meminfo com.you.tvhome   # PSS < ~100 MB
a getprop dalvik.vm.heapgrowthlimit
```
✅ Smooth D-pad scrolling, PSS < ~100 MB. ❌ ⇒ fallback.

**5.3 Dock + grid + clock + Inputs/Settings tiles.** Settings: `Settings.ACTION_SETTINGS`. Inputs: launch vendor TV/source package from Phase 0. Initial focus via `FocusRequester`. Path B: now run the Phase 4 swap.

### Phase 6 — My Favourites lineup (2–4 days + art prep)
`favourites.json` bundled in `assets/`, overridable via `adb push favourites.json /sdcard/Android/data/com.you.tvhome/files/`:
```json
[{"id":"char1","label":"Name","pkg":"com.netflix.ninja","uri":null,
  "art":"char1.webp","art_gray":"char1_gray.webp","scene":"char1_scene.webp","effect":null}]
```
- **6.1 Lineup:** `LazyRow` of tv-material `Surface`; focus drives scale via `graphicsLayer {}`; grey→colour = crossfade of **pre-baked** grey/colour sprites (live `setToSaturation` only if 5.2 showed headroom); labels unscaled; restore focus with `onEnter`.
- **6.2 Scenes:** `Crossfade(focusedId)`; pre-render at `wm size` (usually 1280×720) WebP; decode `RGB_565`; keep current + next only; debounce D-pad ~150 ms; clear cache in `onTrimMemory`.
- **6.3 Effects (config-driven `effect` field):** parallax translate, opacity pulse, a few particles in one `Canvas`. No `Modifier.blur` (API 31+), no video, no heavy Lottie; Glow silently no-ops below API 28. Drift clock / dim after idle (burn-in).
- Character art gitignored; APK not published — personal use only.
✅ Each slice: emulator → TV within 5.2 budget → cold boot.

### Phase 7 — Deep links + mood random-watch (1–2 days)
**7.1 Verify on the TV** (all formats community-sourced; Prime/Hotstar are guesses):
```bash
a pm list packages | grep -Ei 'netflix|youtube|amazon|hotstar|jio|zee|sony'
a dumpsys package com.netflix.ninja | sed -n '/Activity Resolver Table/,/Receiver Resolver/p'
a am start -W -a android.intent.action.VIEW -d "https://www.netflix.com/title/80057281" -p com.netflix.ninja
a am start -W -a android.intent.action.VIEW -d "vnd.youtube:dQw4w9WgXcQ" -p com.google.android.youtube.tv
a am start -W -a android.intent.action.VIEW -d "https://app.primevideo.com/detail?gti=<GTI>" -p com.amazon.amazonvideo.livingroom
a am start -W -a android.intent.action.VIEW -d "https://www.hotstar.com/in/..." -p in.startv.hotstar.dplus.tv
adb -s $TV logcat -s ActivityTaskManager:I
```
Record `deeplinks.md`: pkg | version | uri pattern | result (plays / details / app-home / fail). Read JioHotstar's real package name from the TV. Netflix may need explicit component + `source=30`.

**7.2 `catalogue.json`:**
```json
[{"title":"...","mood":["comfort_sitcom"],"pkg":"com.netflix.ninja","uri":"https://www.netflix.com/title/80057281","fallback":"app"}]
```
**7.3 Mood screen:** pick mood → `pick()` filters by mood + installed packages, random choice → Left/Back skips, OK accepts → `Intent(VIEW, uri).setPackage(pkg)` → on `ActivityNotFoundException` open the app → not installed ⇒ "not installed". One JVM unit test for `pick()` + fallback (empty mood, app missing, seeded random). Skipped: no-repeat history — add if repeats annoy you.
✅ Every entry deep-links or degrades to opening the app; nothing crashes.

---

## Phase 8 — Harden (30 min)
Closing ADB removes Tier 1 — only after Phase 4 is stable; reopen from Settings when developing.
1. Developer options → USB debugging OFF, Network debugging OFF, **Revoke USB debugging authorizations** → reboot.
2. From the Mac:
   ```bash
   adb disconnect
   nc -vz -G 3 <tv-ip> 5555      # expect refused/timeout
   adb connect <tv-ip>:5555      # expect failure
   python3 cleanyourtv/tools/adb-closed.py <tv-ip>
   ```
3. If 5555 stays open (ODM default): `ro.adb.secure=1` ⇒ RSA-gated, accept; `=0` ⇒ anyone on LAN gets a shell ⇒ move TV to guest network/VLAN.

---

## Rollback ladder
| Tier | When | How |
|---|---|---|
| **1. ADB restore** | ADB alive | `./revert.sh <ip> <backup>` or `tools/restore.sh <list> <stock.pkg>` |
| **2. Remote Settings** | ADB dead, Settings reachable | Settings/gear or Input key → Apps → show system apps → stock launcher → **Enable**. Toggle USB debugging off→on to reopen ADB → Tier 1 |
| **3. Safe mode** [unverified] | Third-party launcher broken | Hold power 3–5 s → reboot → hold **Vol-down** through boot animation. Uninstall your launcher in Settings → Apps. Black screen possible if stock launcher was disabled |
| **4. Recovery factory reset** [unverified combo] | No usable UI, boots to recovery | `adb reboot recovery`, or **power + Vol-down until logo**, or **hold physical power while plugging in AC**. Volume keys navigate, power selects → **Wipe data/factory reset**. Undoes every user-0 change; wipes Wi-Fi, accounts, ADB keys, channels, picture settings |
| **5. USB reflash** | Recovery unreachable / bootloop | **Exact board + panel + RAM/eMMC match only**; rule out backlight/PSU first. MStar: `MstarUpgrade.bin` on FAT32 ≤16 GB, hold power/CH+ while plugging AC, ~15 min, never cut power. Amlogic: USB Burning Tool / `aml_upgrade_package.img` + `aml_sdc_burn.ini`, reset button at power-on (Windows-only tools; never tick "Overwrite key"). Realtek: `install.img` on FAT32. Or your own `.img` dumps from 1.5 |
| **6. Service** | All else failed | Micromax care 0129-488 3999, or local repair shop with RT809H programmer + board-matched dump |

Tier 1 commands:
```bash
a pm enable <stock.launcher>
a cmd package set-home-activity <pkg/.Activity from home.txt>
a input keyevent KEYCODE_HOME
a pm install-existing <pkg>      # only if something was uninstalled
a am start -a android.settings.SETTINGS
a am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS
```

---

## Gates
| Gate | Must be true |
|---|---|
| G0 | Path chosen, not STOP; board/panel info captured via ADB |
| G1 | Backup complete; `revert.sh` dry run `REVERT OK` |
| G2 | Cold-boot reconnect ×2, recovery entry, remote Settings path (partial ⇒ restricted mode) |
| G3 | 48 h soak clean; revert fire drill passes |
| G4 | Physical Home + 3 cold boots land on new Home; inputs/Settings reachable; fire drill passes |
| G5.2 | Perf spike within budget, else fallback |
| G8 | 5555 closed, or residual risk documented |

## Time
P0 1–2 h · P1 2–4 h + 1–2 h firmware search · P2 1 h · P3 1–2 evenings + 48 h soak · P4 2–3 h + 24 h soak · P5 2–3 days · P6 2–4 days · P7 1–2 days · P8 30 min. **≈ 2–3 weeks of evenings.**

## Top risks
| Risk | Likelihood | Impact | Mitigation | Recovers at |
|---|---|---|---|---|
| ADB gone after reboot into broken UI | Med | High | Phase 2 gate; Stage A; remote Settings verified | T2 |
| Disabling vendor middleware ⇒ bootloop / no HDMI | Med | High | Never-touch list; one pkg per reboot; unknown ⇒ keep | T1/T4 |
| CVTE stock launcher disabled + power cut ⇒ stuck at logo | Med on CVTE | High | `STOCK_LAUNCHER=none` | T4 |
| Recovery combo absent (single-button TV) | Med | High | Tested in Phase 2; if absent, restricted debloat | T5/T6 |
| Wrong firmware flashed | Low | Brick | Exact match; rule out hardware first | T6 |
| Firmware unobtainable | High | Med | Not needed for user-0 changes; root dump if possible | — |
| Physical Home not redirected | Med | Low | Verify physical key; Stage B or accessibility redirect | T1 |
| Compose jank/OOM on 1 GB | Med | Med | 5.2 spike; pre-baked assets; RGB_565 | Fallback |
| Deep links fail on TV builds | High | Low | Per-app verify; open app fallback | — |
| Plaintext ADB left open on LAN | Med | Med | Phase 8; guest network/VLAN | — |
| macOS Local Network blocks adb | Med | Low | Grant permission; `tv.py` fallback | — |
| Agent runs chained/unverified commands | Low | High | Rules above; human approves each disable | T1 |
| OTA reverts packages/Home | Low | Low | `tools/check.py <list> --fix`; redo Phase 4 checks | — |
