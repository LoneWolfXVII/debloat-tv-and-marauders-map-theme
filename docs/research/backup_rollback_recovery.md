# Backup, Rollback and Unbrick/Recovery for Android TVs (non-root ADB debloat + launcher swap)

Scope: Android TV / Google TV and AOSP-based smart TVs (e.g., Micromax) on budget Indian boards (MStar/MediaTek, Realtek, Amlogic, CVTE). No root. Researched Nov 2026.

## Q1. Non-root backup options: what can be captured and what is worth capturing?

### Takeaway
Without root you can capture package state and APK files, but not most app data. Before touching anything, record: the full package list with paths, including uninstalled and disabled packages (`pm list packages -f -u`, `-d`, `-s`, `-3`); `pm path` output and `adb pull` of every APK, including splits, for anything you might want back; the current HOME resolution; and settings tables. `adb backup` is effectively useless for app data on Android 12+.

### Cited Findings
- `pm list packages [options] filter` flags (official): `-f` shows the associated APK file, `-d` shows only disabled packages, `-e` only enabled, `-s` only system, `-3` only third-party, `-i` shows the installer, `-u` includes uninstalled packages, and `--user user_id` sets the user to query. — [Android Developers: adb](https://developer.android.com/tools/adb)
- `pm path package` prints the path to a package's APK(s). — [Android Developers: adb](https://developer.android.com/tools/adb)
- For split APKs, `pm path` lists `base.apk` plus `split_config.*.apk` files under `/data/app/`, and each one must be pulled. Older backup scripts that pull only base.apk miss the splits. — [APK extractor guide](https://mintlify.com/KilzaNiko/apk-extractor-adb/guides/extracting-apks); [AnatomicJC gist](https://gist.github.com/AnatomicJC/e773dd55ae60ab0b2d6dd2351eb977c1)
- The same gist shows `adb backup -apk -all -nosystem` as the separate (legacy) data-backup mechanism. — [AnatomicJC gist](https://gist.github.com/AnatomicJC/e773dd55ae60ab0b2d6dd2351eb977c1)
- Android 12 changed `adb backup` so app data is excluded from backups unless the app is `android:debuggable=true`. — [Android Developers: backup-leaks (MASVS-STORAGE)](https://developer.android.com/privacy-and-security/risks/backup-leaks); [Medium: Android 12 restricts adb backup](https://medium.com/swlh/android-12-changelog-google-finally-restricts-the-power-of-adb-backup-44f2216c219)
- On Android 12+, `allowBackup="false"` restricts cloud and ADB backups (device-to-device migration still allowed), and `allowBackup` is deprecated in favor of `dataExtractionRules`. — [Android Developers: backup-leaks](https://developer.android.com/privacy-and-security/risks/backup-leaks)
- UAD-ng has no backup feature. It writes logs of its actions to the user cache directory (an "About" button locates them), which works as an action history. — [UAD-ng FAQ](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/wiki/FAQ)
- `cmd package resolve-activity` with the HOME category shows which activity currently wins the HOME intent. A Mi TV debugging write-up used it to diagnose a black-screen loop. — [search summary of Gathin23/cleanyourtv discussion & related](https://github.com/Gathin23/cleanyourtv/discussions/741) (secondary, community)
- The Mi TV launcher-replacement write-up used `pm list packages -f` and `pm list packages | grep ...` to inventory packages before making changes. — [bhupixb: minimal MiTV launcher](https://bhupixb.github.io/blog/11-minimal-mitv-launcher/)

### Inferences
- Recommended snapshot set, saved to a dated folder on the PC:
  1. `adb shell getprop > getprop.txt` (gives model, board, firmware build and Android version, which you need later to find matching firmware).
  2. `adb shell pm list packages -f -u > pkgs_all.txt`, plus `-d`, `-s`, `-3` and `-e` variants.
  3. `adb shell dumpsys package > dumpsys_package.txt` (versionCodes, enabled state, preferred activities).
  4. `adb shell cmd package resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME` (the current default home).
  5. `adb shell settings list global|secure|system > settings_*.txt`.
  6. `adb pull` of each APK that `pm path` reports for packages you might remove, or at least for any updated system apps whose updates live in /data/app.
  7. Photos of the picture/sound/source/network settings screens (these usually live in vendor-specific stores that `settings list` does not show).
- Pulling APKs mainly protects *updated* versions and third-party apps. The factory version of a system app stays in /system or /vendor anyway, so `install-existing` can restore it without a backup.
- Budget AOSP TVs (Micromax and similar) often run Android 9–11, so `adb backup` may still partly work there. Android TV 12+ devices should be treated as having no app-data backup without root.
- Vendor TV settings (picture modes, channel lists, tuner/ATV/DTV databases) are usually in vendor DBs under /data/vendor or app-private storage, which cannot be read without root. A channel scan is the realistic "restore" for those.

### Gaps
- No primary source found that confirms `settings list` coverage on TV OEM builds, or that the `dumpsys package` output format stays stable across Android 9–14 TV builds. These are standard shell tools, but how well they work on Micromax firmware is unverified.
- No source documents where MStar/CVTE TV builds store picture/channel settings.

## Q2. Reversibility of each method (disable-user, uninstall --user 0, hide, clear) and factory reset

### Takeaway
`pm disable-user --user 0` is the safest change and is undone with `pm enable`. `pm uninstall [-k] --user 0` removes the app only for user 0; the APK stays on /system, so `cmd package install-existing` undoes it. A factory reset wipes /data, where these per-user states are stored, so it restores every debloated system app. `pm clear` irreversibly deletes app data. OTAs can bring removed packages back.

### Cited Findings
- `pm uninstall [options] package`: `-k` keeps data/cache dirs, and `--user user_id` removes only for that user. By default the package is removed for all users. — [Android Developers: adb](https://developer.android.com/tools/adb)
- `pm clear package` deletes all data associated with a package (irreversible without a backup). — [Android Developers: adb](https://developer.android.com/tools/adb)
- `pm enable` / `pm disable` / `pm disable-user --user` act on a package or component (`package/class`). — [Android Developers: adb](https://developer.android.com/tools/adb)
- The basic uninstall/restore pair is `pm uninstall -k --user 0 <pkg>` and `pm install-existing <pkg>`. — [Red-Eyed gist](https://gist.github.com/Red-Eyed/a6d8a64f904109a2b505c672766f09f5)
- A per-user uninstall leaves the APK on the system partition, so a restore re-adds the app for the user, and `-k` keeps its data. — [sysapps.bayton.org](https://sysapps.bayton.org/packages/com.android.backup)
- UAD-ng calls Uninstall (`pm uninstall --user <u>`) "Unsafe… more likely to trigger instability". It can also remove the app's updates. It calls Disable (`pm disable-user --user <u>`, then force-stop and clear) "Safest". UAD-ng recommends disabling rather than uninstalling for anything outside the "Recommended" list. — [UAD-ng FAQ](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/wiki/FAQ)
- Note: UAD-ng's Disable action also runs **clear**, so it wipes the app's data. Re-enabling restores the app but not its old data. — [UAD-ng FAQ](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/wiki/FAQ)
- UAD-ng's restore commands are `cmd package install-existing` for uninstalled packages and `pm enable` for disabled ones. — [UAD-ng FAQ](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/wiki/FAQ)
- Factory reset: "A factory reset will restore all the debloated packages!" Removals are stored in /data, which the reset wipes. — [UAD-ng FAQ](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/wiki/FAQ)
- A system/OTA update can bring removed packages back, and disabling keeps updates installed. — [UAD-ng FAQ](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/wiki/FAQ)
- Android-version mechanics per UAD-ng: Android 6+ uses `pm uninstall`/`pm disable-user`; Android 5.x uses `pm hide`/`pm unhide`; Android 4.4 and older uses `pm block`/`pm unblock`; before 6.x, disable needs root. Issues filed for Android 17 report restrictions on uninstalling system apps on the read-only partition. — [UAD-ng FAQ](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/wiki/FAQ)
- Caveat: on GrapheneOS, `install-existing` worked for system apps whose APK remains on /system, but a user reported that the Play Store did not restore that way in their setup. — [GrapheneOS forum](https://discuss.grapheneos.org/d/24872-how-to-reinstall-google-play-store-after-it-was-uninstalled-via-adb)
- `set-home-activity` may not promote a *disabled* package to default on some builds, so re-enable the package first. — [shield_optimizer PR #18](https://github.com/bryanroscoe/shield_optimizer/pull/18) (community)

### Inferences
- Reversibility ranking: disable-user (fully reversible, and keeps data unless a tool also clears it) > uninstall -k --user 0 (reversible via install-existing; data kept) > uninstall --user 0 without -k (reversible, but data is lost) > pm clear (data irreversibly gone) > anything needing root (not applicable).
- For TVs, prefer `disable-user` for anything you are unsure of. Use `uninstall -k --user 0` only for clearly user-facing bloat (preinstalled streaming apps, ad/recommendation services).
- If an app was uninstalled *without* `-k` and later restored, its updates in /data/app are gone, and it reverts to the factory /system version. Keep the pulled APKs to reinstall the update.
- `pm hide` on Android 6+ generally needs MANAGE_USERS/device-owner privileges, which the shell user does not have on most builds. Treat it as unavailable without root. (No primary source found; verify on device.)
- Never touch these (they will cause boot or UI failure, or lock you out): SystemUI, Settings / TV Settings (`com.android.tv.settings` or the OEM equivalent), the package installer and permission controller, the setup wizard / provisioning (this can loop "device not provisioned"), the input method (keyboard; without one you cannot type Wi-Fi passwords), the TV input framework / tuner / HDMI-CEC / OEM "tvserver" or MStar/MTK middleware services, WebView (many launchers and settings pages depend on it), `com.android.shell`, `com.android.providers.*`, the remote/Bluetooth pairing service, and the only launcher before a replacement is set as default.

### Gaps
- No primary source found on whether TV OEM factory-reset paths (some MStar/CVTE "factory reset" options in the service menu wipe only vendor settings) wipe /data the same way as an AOSP recovery wipe.
- I did not verify that `pm hide` fails as a shell user on Android TV 9–14.

## Q3. Failure modes when the launcher or a critical package is disabled; recovery via ADB, safe mode and recovery mode

### Takeaway
If ADB debugging and the device's RSA key authorization are still in place, almost any package-level mistake can be fixed from a PC: `pm enable`, `cmd package install-existing`, `cmd package set-home-activity`, `am start`. The main risk is wireless ADB. `adb tcpip 5555` does not persist across reboots without root, so after a reboot into a broken UI you may lose your way back in. Android 11+ wireless debugging also needs re-enabling via the on-screen UI. Stepping down from there: Android safe mode (on some brands), then recovery-mode factory reset (power-button-on-plug or a vendor key combo), which restores all user-0 removals.

### Cited Findings
- Disabling the stock home app before an alternative is in place leaves a black screen (example: Google TV's `com.google.android.apps.tv.launcherx`). — [tv-fresh wiki](https://github.com/wangrongding/tv-fresh/wiki); [tv-vibehack wiki](https://github.com/ToomRamcharan/tv-vibehack/wiki) (community)
- Recovery sequence over ADB: `pm enable <launcher>`, then `cmd package install-existing --user 0 <pkg>` for removed packages, then `cmd package set-home-activity <pkg>/<activity>`, then `input keyevent HOME`. Some builds silently ignore set-home-activity, so re-query the result afterwards. — [shield_optimizer PR #18](https://github.com/bryanroscoe/shield_optimizer/pull/18); [bhupixb Mi TV](https://bhupixb.github.io/blog/11-minimal-mitv-launcher/)
- In one Mi TV case, the system's fallback home won the HOME lookup and looped on a black screen, retrying every ~20 s whenever the resolved activity was not the expected launcher. It was diagnosed with `cmd package resolve-activity` on the HOME category. — [Gathin23/cleanyourtv discussion #741](https://github.com/Gathin23/cleanyourtv/discussions/741) (community; via search summary)
- A worked Mi TV (Android 9, `MiTV4I`) launcher swap: the author disabled `com.google.android.tvlauncher` and the recommendations packages, deliberately kept SystemUI, TV settings, `com.android.tv`, the Droidlogic tuner/Live TV packages, Play Services and GSF, and set the custom launcher via `cmd package set-home-activity`. The rollback was `pm enable com.google.android.tvlauncher`, `cmd package set-home-activity com.google.android.tvlauncher/.MainActivity`, uninstalling the custom launcher, and `install-existing --user 0` for each removed package. The work was done over ADB at port 5555. — [bhupixb Mi TV](https://bhupixb.github.io/blog/11-minimal-mitv-launcher/)
- The same build warned "This app was built for an older version of Android" until the launcher declared targetSdk 28. — [bhupixb Mi TV](https://bhupixb.github.io/blog/11-minimal-mitv-launcher/)
- `adb tcpip 5555` is the documented way to switch adbd to TCP for Android 10 and lower. Android 11+ uses Wireless debugging with pairing (pair once; it stays paired until "Forget"). — [Android Developers: adb](https://developer.android.com/tools/adb)
- The TCP mode set by `adb tcpip` is not persistent: `service.adb.tcp.port` is lost on reboot, and making it permanent needs `setprop persist.adb.tcp.port 5555`, which requires root. — [knightli: adb tcpip persistent (root)](https://knightli.com/en/2020/12/28/adb-tcpip-persistent/); [Datalogic forum](https://discussion.datalogic.com/t/adb-over-tcp-ip/341); [OmniROM gerrit commit](https://gerrit.omnirom.org/plugins/gitiles/android_system_core/+/8e2ceaeacf9fa1eb5ac41e4d3498836a6e2c7c97%5E%21)
- A non-root workaround: toggling USB debugging off and back on re-enables network debugging after a reboot. This needs a working on-screen UI. — [Home Assistant community](https://community.home-assistant.io/t/is-this-the-perfect-standalone-tablet-for-ha/658422/206)
- Shizuku (used by Canta) must be restarted after every reboot when started via wireless debugging or a PC ("due to system limitations"). Shizuku's setup guide does not mention Android TV. — [Shizuku setup guide](https://shizuku.rikka.app/guide/setup/)
- Android TV safe mode (Sony): hold the remote power button about 3 s (newer models: 5 s), then hold volume-down during the boot animation. "Safe mode" appears bottom-left, and third-party apps are temporarily disabled. — [Sony support 00127645](https://www.sony.ca/en/electronics/support/televisions-projectors/articles/00127645)
- Entering recovery on TCL Google TV: unplug, hold the physical power button, plug back in, and release when the recovery screen appears. The options are "Reboot system now", "Wipe data/factory reset" and "Apply update from USB" (use the last only with model-exact firmware). The remote may not work in recovery, so use the volume keys to navigate and power to select. — [TCL support](https://support.tcl.com/en_US/how-to-troubleshoot-a-tcl-google-tv-in-recovery-mode)
- Micromax Android TV (50K2330UHD) reset via buttons when stuck or in a reboot loop: hold power + volume-down until the logo appears. The menu path is Settings > Storage & reset > Factory data reset. — [tvsfaq Micromax 50K2330UHD](https://www.tvsfaq.com/en/reset/micromax-50k2330uhd) (third-party aggregator; unverified); [tvsfaq Micromax 42C0050UHD](https://www.tvsfaq.com/en/reset/micromax-42c0050uhd)
- Sony also documents a "forced factory reset" for TVs stuck on the logo or not responding to the remote or buttons. — [Sony AU support 00206447](https://www.sony.com.au/electronics/support/televisions-projectors/articles/00206447)

### Inferences
- Failure modes by package:
  - Only launcher disabled: black screen, or a "Fallback Home"/boot-complete hang. The rest of the system runs and ADB works if it was enabled.
  - SystemUI disabled: no system dialogs, volume or notification overlays. It may crash-loop.
  - Settings disabled: you cannot reach Developer options, so you cannot re-toggle debugging.
  - Setup wizard or provisioning disabled before provisioning completed: a home-key-dead state or a setup loop.
  - Package installer disabled: APK installs fail, though `adb install` normally still works through system_server.
  - Keyboard disabled: you cannot type Wi-Fi passwords, so wireless ADB cannot be re-established after a network change.
  - TV input / tvserver disabled: no HDMI/tuner picture, and vendor middleware may crash at boot (higher bootloop risk on MStar/MTK AOSP TVs).
- ADB persistence across reboots: the USB/"ADB debugging" toggle (`adb_enabled`) and the authorized host keys persist across reboots, because both live in /data and settings. A factory reset clears both. What does *not* persist is the `adb tcpip` TCP port. Many TV OEM builds expose a "Network debugging" toggle, or listen on 5555 by default, which would survive reboots; check whether `adb connect <ip>:5555` works after a cold reboot *before* you start debloating. This is common on TVs, but no primary source confirms it for Micromax.
- Most TVs have USB-A host ports, not device ports, so USB ADB is usually impossible. Wireless ADB is therefore the only ADB path, which makes the persistence check above critical.
- Recovery shortcuts that need no launcher: from ADB, `am start -a android.settings.SETTINGS`, `am start -n com.android.tv.settings/.MainSettings` (exact component varies by OEM), `am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS`, `input keyevent KEYCODE_SETTINGS`. Many TV remotes also have a Settings/gear or "Input" key that launches system Settings independently of the launcher.
- Recovery ladder (tiered):
  1. **Launcher missing, ADB alive:** `pm enable` the old launcher, or `install-existing` it, then `set-home-activity`, then `input keyevent HOME`.
  2. **Launcher missing, ADB dead but Settings reachable** (remote Settings key, or a long-press Home quick-settings panel): re-enable Network debugging or install a launcher APK via USB stick and a file manager. If that fails, use Apps > show system apps > Enable.
  3. **No UI path:** try safe mode (if the OEM supports it) to bypass a broken third-party launcher, then uninstall that launcher.
  4. **Still stuck:** use recovery mode (hold power while plugging in AC, or power + vol-down on Micromax per tvsfaq) and choose "Wipe data/factory reset". This restores all user-0 removals, but you must set up the TV and rescan channels again.
  5. **Bootloop / no recovery:** firmware reflash by USB stick or chip tool (Q4), then the service centre.

### Gaps
- No primary source confirms whether Micromax/CVTE AOSP TVs keep adbd listening on 5555 after a reboot, or expose a persistent "network debugging" toggle.
- No source confirms that safe mode exists on Micromax or other AOSP (non-Google-certified) TVs. It is an AOSP feature, but OEM key handling varies.
- The Micromax power+vol-down recovery combo comes from only an aggregator site (tvsfaq). Many budget TVs have just one physical button (a joystick or single power key), so the combo may not apply.

## Q4. Soft-brick / bootloop recovery by firmware reflash for budget TV boards (MStar/MTK, CVTE, Amlogic, Realtek); obtaining correct firmware; Micromax service

### Takeaway
Each SoC family has a USB-stick recovery path. MStar/MTK and CVTE use `MstarUpgrade.bin`/`CtvUpgrade.bin` on a FAT32 stick plus a power-button-at-plug-in or factory-menu "Upgrade Main". Amlogic uses the USB Burning Tool or an `aml_upgrade_package.img` + `aml_sdc_burn.ini` card with the reset button. Realtek uses `install.img` on a FAT32 stick. The serious risk is mismatched firmware: CVTE/MStar boards such as CV338H are shared across many brands and panels, and a wrong panel build gives a black screen, wrong colours or a dead board. A user-level debloat almost never requires a reflash, because a factory reset fixes it.

### Cited Findings
- MStar: a file named `MstarUpgrade.bin` goes in the root of a FAT32 USB stick. The standard route is the factory menu (a model-specific key sequence, e.g., Input then 2580 on ViewSonic) > "Upgrade Main". — [ViewSonic SOP](https://support.viewsonic.com/en/support/solutions/articles/33000233952-cde6502-and-e-poster-f-w-update-sop); [ViewSonic EP5520](https://support.viewsonic.com/support/solutions/articles/33000211652-how-to-upgrade-firmware-on-ep5520-ep5520t-)
- Forced USB recovery on a bootlooping MStar board: unplug AC, copy the renamed file to a FAT32 stick of 16 GB or less, insert it, then hold the front power (or CH+) button while applying power. The button differs by board. — [Elektroda MS08GP guide](https://www.elektroda.com/qa,40-ms08gp-mab2hg-firmware-guide.html) (Elektroda Q&A; partly AI-generated summaries on this site)
- An upgrade can take about 15 min. Do not cut power. If the power-up logo appears quickly, the upgrade failed. Some boards first upgrade mboot (the bootloader) by holding "volume −" for about 10 s. — [RCA 55AN3D manual p.27](https://www.manualslib.com/manual/1954450/Rca-55an3d.html?page=27); [p.28](https://www.manualslib.com/manual/1954450/Rca-55an3d.html?page=28)
- Firmware is usually brand-specific. A file for one TV may not work on another, even with the same MStar chip. — [Elektroda topic4178421](https://www.elektroda.com/rtvforum/topic4178421.html)
- CVTE CV338H boards are used across brands (Graetz/Akai, Smarttech, etc.). A board revived with another brand's firmware had "incorrect colours/bit rate due to different screen". A CV338H-T50 bricked after a firmware upgrade. — [badcaps: Graetz/Akai CV338H-T50 bricked](https://www.badcaps.net/forum/troubleshooting-hardware-devices-and-electronics-theory/troubleshooting-tvs-and-video-sources/3235735-graetz-akai-cv338h-t50-bricked-after-firmware-upgrade?p=3236102); [badcaps: CV338H-T42 firmware issue](https://www.badcaps.net/forum/troubleshooting-hardware-devices-and-electronics-theory/troubleshooting-tvs-and-video-sources/92281-43-inch-tv-firmware-issue-the-board-is-cv338h-t42)
- Third-party Indian repair sites host Micromax model- and board-specific dumps (e.g., Micromax 40C3420MHD, 43T7200MHD, 3MSV56LT5AP-01, CV338H-A50). These are unofficial and their provenance is unverified. — [dipelectronicslab 40C3420MHD](https://dipelectronicslab.com/micromax-40c3420mhd-software/); [43T7200MHD](https://dipelectronicslab.com/micromax-43t7200mhd-software/); [3MSV56LT5AP-01](https://www.dipelectronicslab.com/micromax-3msv56lt5ap-01-software/); [CV338H-A50](https://dipelectronicslab.com/cv338h-a50-software-download-for-free/)
- Black-screen symptoms can be hardware (weak LED backlight, PSU, loose backlight connector). Rule these out before reflashing. — [electronics-tricks blog](https://electronics-tricks.blogspot.com/2023/11/lcd-tv-screen-repairing-classes.html)
- Amlogic: the USB Burning Tool is the recommended way to update firmware or unbrick, and it can repair a corrupted bootloader. To enter burn mode, hold the reset button (sometimes inside the AV jack, pressed with a toothpick) while powering on, and release at the logo. Load the image via File > Import image. — [Armbian quick guide](https://forum.armbian.com/topic/32632-quick-guide-amlogic-tv-boxes/); [CoreELEC wiki: Amlogic USB Burning Tool](https://wiki.coreelec.org/coreelec:aml_usb_tool)
- Amlogic card/USB route: put `aml_sdc_burn.ini` (extractable from the .img) and the firmware renamed to `aml_upgrade_package.img` on the card, then hold reset while powering on. Burn Card Maker is Windows-only. Never tick "Reset after success" or "Overwrite key", because doing so can wipe keys or the MAC address. — [CoreELEC wiki: Burn Card Maker](https://wiki.coreelec.org/coreelec:aml_burncard); [androidpctv Amlogic guide](https://androidpctv.com/firmware-update-guide-for-tv-box-with-soc-amlogic-s802-s805-s812-s905-s905x-s912/)
- Realtek TV boards (e.g., HK.T.RT2851, TPD.RT2841): `install.img` goes in the root of a FAT32 USB stick. Some packages are USB-upgrade files, while others are eMMC/programmer dumps that cannot be flashed by stick. Owners of bricked boards struggle to obtain a valid install.img. — [Elektroda RT2851 thread](https://www.elektroda.pl/rtvforum/topic4133903.html); [Elektroda RT2841 Q&A](https://www.elektroda.com/qa,acer-tpdrt2841apb782-32-hd-firmware.html); [CNX: Realtek RTD1195 flashing](https://www.cnx-software.com/2014/11/03/how-to-flash-firmware-to-realtek-rtd1195-media-players/)
- Recovery menu "Apply update from USB" should be used only with software for the exact model. — [TCL support](https://support.tcl.com/en_US/how-to-troubleshoot-a-tcl-google-tv-in-recovery-mode)
- Micromax service (India): a third-party listing gives the TV customer care line as 0129-488 3999 (IVR option 1 for service centres). Reports say support lines are hard to reach and service quality is mixed. The standard TV warranty is reportedly 1 year (from a low-quality blog). — [indiacustomercare](https://www.indiacustomercare.com/micromax-tv-customer-care-number); [TelecomTalk](https://telecomtalk.info/impossible-to-reach-micromax-customer-support/118911); [boonbac blog](https://boonbac.com/read-blog/20251_is-warranty-repair-available-at-the-micromax-tv-service-center.html)

### Inferences
- Before debloating, record the information needed to find matching firmware: the exact model from the rear label, the main board silkscreen ID (e.g., CV338H-A42, TP.MS338.PB801, HK.T.RT2851, or an MTK/MStar part number), the panel part number (on the panel's rear sticker), and `getprop ro.build.fingerprint` / `ro.product.board` / panel resolution. A panel mismatch (resolution, LVDS vs. V-by-One, bit depth, mirror/flip) gives a black, garbled or wrong-colour image even when the board boots. Some MStar/CVTE service menus let you change panel ID afterwards, but only if the image appears at all.
- `CtvUpgrade.bin` is the CVTE naming variant of MStar-style USB upgrades. No source in this research explicitly documented it, so treat the filename as needing per-board verification (see Gaps).
- Unofficial dumps from repair sites often contain another unit's MAC address, keys (Widevine/Netflix ESN, HDCP) and settings. Flashing one can break DRM apps even when the TV boots.
- For Micromax specifically, official firmware downloads are not publicly available. The practical routes are (a) a factory reset via recovery, (b) the service centre or local TV repair shops that use board-ID-matched dumps and SPI/eMMC programmers (e.g., RT809H), and (c) self-flashing an exact board+panel-matched MstarUpgrade.bin, at your own risk.
- A user-0 debloat cannot corrupt /system, so if recovery mode is reachable, a factory reset always undoes it. A reflash should be needed only when recovery itself is unreachable (rare from debloating alone; more likely after a failed OTA or a vendor-service crash at boot).

### Gaps
- No primary or manufacturer source found for the `CtvUpgrade.bin` filename or procedure on CVTE boards. Badcaps pages returned 403, and details came only from search summaries.
- No official Micromax TV firmware portal or official service-centre locator was found. Contact details come from third-party sites.
- No source maps specific Micromax Android TV models to SoC/board vendors. Most appear to be CVTE/MStar or Realtek builds from ODMs, but this needs per-model confirmation from board silkscreen or `getprop`.

## Q5. Best-practice safe workflow and existing tools with undo

### Takeaway
Change one package at a time and reboot-test after each. Keep a generated revert script. Install and verify a second, known-good launcher *before* touching the stock one. Confirm that wireless ADB still connects after a cold reboot. Prefer disable over uninstall. UAD-ng (desktop, ADB) and Canta (on-device via Shizuku) both provide undo lists. Neither is TV-specific, and Shizuku needs restarting after every reboot.

### Cited Findings
- UAD-ng is a desktop GUI that debloats non-rooted devices over ADB. It uses a community package list (`uad_lists.json`) and can also be used through other projects. It collects no data and only makes GET requests to GitHub. — [UAD-ng README](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation)
- UAD-ng warns that the "Recommended" list "IS NOT ACTUALLY RECOMMENDED", provides an "unsafe" category, says it "can't brick" but can't guarantee no bootloops, and advises trying the other method if one fails. — [UAD-ng FAQ](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/wiki/FAQ)
- Canta + Shizuku: uninstalls system apps without root or a PC, labels apps Recommended/Advanced/Expert/System/Unsafe from community lists, and has a "See uninstalled" tab to restore them. It uninstalls per user, so the base package remains. — [Canta GitHub](https://github.com/samolego/Canta); [Android Authority](https://androidauthority.com/debloat-android-phone-shizuku-canta-3465600); [awesome-android-root guide](https://awesome-android-root.pages.dev/general-guides/android-apps-debloating)
- Restoring removals one at a time and testing after each is advised when something breaks. Bootloops from removing critical apps are possible but rare. — [awesome-android-root guide](https://awesome-android-root.pages.dev/general-guides/android-apps-debloating); [kil0bit blog](https://kil0bit.blogspot.com/2023/11/how-to-debloat-android-without-pc-or.html)
- Shizuku on Android 11+ uses wireless debugging, and on Android 10 and below it needs a PC `adb shell sh .../start.sh`. Either way it must be restarted after each reboot, and OEM modifications can break it. — [Shizuku setup guide](https://shizuku.rikka.app/guide/setup/)
- TV-specific community projects exist: cleanyourtv, tv-fresh and tv-vibehack (GitHub), and shield_optimizer for Nvidia Shield. Shield_optimizer re-queries the active launcher after `set-home-activity` instead of trusting the command output. — [shield_optimizer PR #18](https://github.com/bryanroscoe/shield_optimizer/pull/18); [cleanyourtv](https://github.com/Gathin23/cleanyourtv/discussions/741); [tv-fresh](https://github.com/wangrongding/tv-fresh/wiki); [tv-vibehack](https://github.com/ToomRamcharan/tv-vibehack/wiki)
- The Mi TV author kept the rollback commands ready, reconnected over ADB if the custom launcher broke, and then ran `adb disconnect` and turned off network debugging for security. — [bhupixb Mi TV](https://bhupixb.github.io/blog/11-minimal-mitv-launcher/)

### Inferences
- Safe workflow:
  1. Take the snapshot (Q1) and record board/panel IDs (Q4).
  2. Confirm that ADB reconnects after a **cold** AC power-cycle. If it does not, decide whether you can live with re-enabling it via the UI every time.
  3. Install the custom launcher plus a second fallback launcher (or a simple app-drawer app) and a file manager. Test that Settings is reachable from each.
  4. Set the default home with `cmd package set-home-activity` and verify it with `resolve-activity`, *before* disabling the stock launcher. Disable the stock launcher (never uninstall it) only as the last step.
  5. For each package, log the line `pkg | action | revert cmd` to a text file, run it, reboot, and test picture, inputs (HDMI/tuner), the remote, Wi-Fi, a streaming app and Settings.
  6. Generate `revert.sh` from the log in reverse order: `pm enable <pkg>` or `cmd package install-existing --user 0 <pkg>`.
  7. Avoid `pm clear` and avoid any tool option that clears data (UAD-ng's Disable does this).
  8. Re-check after every OTA, because OTAs can restore packages or change component names.
- Avoid disabling OEM OTA/updater packages blindly. They can stop updates that would restore packages, which you may want, but on some MStar/CVTE builds they are tied to the "Upgrade from USB" settings entry used for recovery.
- Since the TV is a single-user device, `--user 0` is the right target. Never omit `--user 0` on `pm uninstall`, because the default removes the package for all users.

### Gaps
- I found no maintained TV-specific tool (e.g., an app named "TV Debloater" or "Launcher Manager") with verified undo functionality. The TV GitHub projects above are small community scripts, and I did not review their quality.
- UAD-ng's list coverage of Micromax/CVTE/MStar-specific packages (e.g., `com.cvte.*`, `com.mstar.*`, `com.mediatek.wwtv.*`, `com.realtek.*`) is unverified.
- No source confirms that Canta/Shizuku run on Android TV builds without a touchscreen. Wireless debugging pairing UIs are often missing from TV Developer options.
