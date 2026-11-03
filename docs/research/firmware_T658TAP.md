# Micromax (TCL-built) MT5658 Android TV: USB firmware for V8-T658TAP

Researched 2026-11-04. No files were downloaded. Confidence tags: **[V]** verified on the device or in a primary/official source, **[F]** forum anecdote (one or more users), **[I]** my inference.

Device (from ADB): `ro.software.version_id=V8-T658TAP-LF1V372`, fingerprint `MICROMAX/tcl_eu/tcl_eu:8.0.0/OTT1.180130.001/hefang08142127`, build 14 Aug 2018, `mt5891`, armv7, 4K, about 2 GB RAM visible.

## Bottom line

1. **No public copy of any `V8-T658TAP-*` firmware was found.** Exact-string searches for `V8-T658TAP`, `T658TAP`, `T658TAP-LF1V` and `LF1V372` return nothing on XDA, Elektroda, HiFiVision, Whirlpool, Lowyat, computerbase, firmware-mirror sites or the TCL Telegram docs. Every public T658 file uses the `T658T01` stream. [V: negative search result]
2. **TCL sold its own India sets on T01 firmware.** The India iFFALCON 55K2A (MT5658, client type `TCL-AP-MT58K-S1`, Project ID 157) ran `V8-T658T01-LF1R549` and other T01 builds. So `TAP` is not simply "TCL India". It looks like a separate customer stream for the Micromax OEM build. [F for the 55K2A strings; I for what TAP means]
3. **Flashing T01 onto a TAP set is unproven and risky.** No report of a TAP-to-T01 cross-flash was found. The real risk is the Project ID / panel whitelist, more than the region. Details in Q2.
4. **Best lead for a genuine TAP image: the TV's own updater.** TCL's OTA CDN uses the path `…-update.cedock.com/apps/resource2/V8<platform>/V8-<platform>-LF1V<nnn>/…`. If `V8T658TAP` exists there, the TV's update service will show the URL in logcat when you run System Update. Details in Q1. [I, based on a [V] URL pattern]

## Q1. Where can V8-T658TAP firmware be found?

### Findings
- **Exact-string searches came up empty:** "V8-T658TAP", "T658TAP", "T658TAP-LF1V", "LF1V372" and "MICROMAX/tcl_eu". [V: negative]
- **TCL's OTA CDN uses a fixed path pattern** (all T01 examples):
  - `http://eu-update.cedock.com/apps/resource2/V8T658T01/V8-T658T01-LF1V568/FOTA-OTA/V8-T658T01-LF1V568.zip`, posted on Whirlpool and XDA. [F: URL quoted in a search snippet of the Whirlpool "TCL 2019 Android TVs" thread]
  - Hosts are `eu-`, `na-` and `as-update.cedock.com`. `as-` is the Asia-Pacific mirror. — [FaserF tclupdate.sh](https://github.com/FaserF/bash_scripts/blob/main/tclupdate.sh), [TCL Discussion firmwares](https://faserf.github.io/TCL-Discussion-Telegram/firmwares/) [V: in community tooling]
  - The FaserF script treats an HTTP 403 on `V8<plat>/V8-<plat>-LF1V<nnn>/` as "this build exists" (the zip name carries a numeric suffix such as `.341571.zip`). [V: script logic]
  - **I could not test this.** From this machine every cedock host timed out (HTTP 000), even though DNS resolved (`as-update.cedock.com` → 103.235.236.100). The CDN may be geo-restricted or may only answer TV clients. [V: my test]
- **India T658 firmware that is public** (all T01, iFFALCON):
  - Files: `Update_V8-T658T01-LF1V535_sign.pkg`, `…LF1V546_sign.pkg`, `…LF1R549_sign.pkg`, plus V544, V551 ("K2A only"), V519 and V528.
  - Hosts: Dropbox and Google Drive links in [HiFiVision iFFALCON thread p.34](https://www.hifivision.com/threads/iffalcon-tvs-owners-thread.70169/page-34) and the [XDA "iFFalcon TV (India) ROM Links"](https://xdaforums.com/t/iffalcon-tv-india-rom-links.3892518/) thread.
  - The links date from 2019 and many are dead. [F]
- **Other T01 files in circulation:**
  - V534/V574/V575/V602 (XDA [C6 downgrade thread](https://xdaforums.com/t/downgrade-file-for-tcl-c6-current-version-v8-t658t01-lf1v534.4122589/) and the ["Android TV 8.0 flash file for all TCL"](https://xdaforums.com/t/android-tv-8-0-flash-file-for-all-tcl-android-tv.3926570/) thread).
  - `MT58_Android O_V551.zip` / `MT58_Android O_V574.zip` ([computerbase](https://www.computerbase.de/forum/threads/tcl-thomson-software-update-chassis-ms6586-anleitung-linux.1886036/)).
  - `TCL 55DP660 V8-T658T01-LF1V575.zip` ([filewale](https://filewale.com/files/tcl-55dp660-v8-t658t01-lf1v575zip/54219)). [F]
- **Sizes:**
  - CleanYourTV measured the V602 Update.pkg at about 1.37 GB.
  - An XDA user reports a full PKG of 1.27 GB (C6 thread).
  - filewale lists the V575 zip at 1.03 GB.
  - Sources: [V for the CleanYourTV figure], [F for the others]
- **Checksums:** none published for any T658 file. The TCL Telegram tracker publishes MD5/SHA-256 only for newer platforms, for example `V8-0014T01-LF1V001.zip`. [V]
- **Official India portal:** none found. tcl.com/in has no firmware downloads. The Hong Kong and Gulf FAQs say to use the online updater or contact after-sales. — [TCL HK FAQ](https://www.tcl.com/hk/en/support/faq/2800), [TCL Gulf FAQ](https://tcl.com/gulf/en/support/faq/4462) [V]
- **XDA and Elektroda pages** returned 403 or timed out to direct fetches. The thread contents above come from search snippets, so treat any exact wording as paraphrase.

### Actionable lead: capture the TAP OTA URL from the TV itself [I]
1. Run `adb logcat -c`.
2. Open Settings > System update and press Check. Then run `adb logcat -d | grep -iE 'cedock|resource2|FOTA|\.zip|\.pkg'`.
3. Look for an `as-update.cedock.com/apps/resource2/V8T658TAP/...` URL.
   - If the updater offers a newer LF1V build, the URL is a genuine TAP package. It will probably be an OTA zip, not a full PKG.
   - "No new version" still tells you the client type and project ID it sends.
4. Also grep `getprop` for the client type, project ID and panel: `getprop | grep -iE 'client|project|panel|tcl'`. Write them down before any flash.
5. Do not disable `com.tcl.xian.StartandroidService`. CleanYourTV's TROUBLESHOOTING says TCL's updater fails with "Local network or server abnormal" without it.

## Q2. Is the EU T01 firmware safe on the AP (TAP) variant?

### Findings
- **No report found of anyone flashing T01 onto a TAP set, or the reverse.** [V: negative]
- **Region-labelled boards do run T01.** TCL's own Asia-Pacific/India iFFALCON sets (client type `TCL-AP-MT58K-S1`) ran T01, and EU, AU and NZ sets all ran T01. Region is therefore not encoded in the T01/TAP suffix for TCL's own brands. [F]
- **Project ID ties the firmware to the panel and board.** Per the [TCL Discussion FAQ](https://faserf.github.io/TCL-Discussion-Telegram/faq/):
  - The Project ID "maps the TV motherboard firmware to your specific panel type, tuner region, and backlight configuration".
  - You get a black screen when "the installed firmware lacks your specific TV's Project ID in its internal whitelist".
  - [F: community docs, consistent with TCL service manuals that set Project ID in the service menu]
- **Elektroda Q&A pages** say firmware carries panel timing and LVDS mapping, and that a mismatch gives no picture, wrong colours or a boot failure. One of them treats a different platform code (T65B vs T658) as non-booting. These are AI-written summaries, so give them low weight. [F, low]
- **Assessment:**
  - TAP was built from the `tcl_eu` product tree on the same OTT1.180130.001 base, so the bootloader and partition layout are very likely the same. [I, medium]
  - What could break: the Micromax panel's Project ID may be missing from the T01 whitelist (black screen with sound, or blank). You would also lose Micromax branding and boot logo, and pick up EU tuner and app defaults.
  - The signature check could reject T01 outright if TAP uses different signing keys, which would be the safe failure mode. [I]
  - Recovery from a black-screen result needs either a TAP image or a blind Project ID entry, and the TCL docs give no exact key sequence for it. [F]
- **Recommendation:**
  - Treat T01 as a last resort for a set that is already bricked, never as a refresh.
  - Before trying it, record the Project ID from the factory menu or About > Product information, and photograph the mainboard and panel stickers. Mainboard names to look for: MT58xx, `40-MT58xx-MAx4HG`.

## Q3. Which Micromax/TCL models are on T658TAP?

### Findings
- **Micromax's only 2018 Google-certified Android TVs are a 49-inch and a 55-inch 4K set.**
  - Specs: Android Oreo, quad-core Cortex-A53, 2.5 GB DDR3, 16 GB eMMC, HDR10, Chromecast. Launched November 2018 at Rs 51,990 and Rs 61,990.
  - Sources: [ElectronicsForU](https://ace.electronicsforu.com/?p=68943), [Digit](https://www.digit.in/?p=76502), [IBTimes India](https://ibtimes.co.in/micromax-launches-49-55-inch-4k-smart-tvs-starting-rs-51990-all-you-need-know-784697) [V: several sources agree]
- **Retail models:** listings name them **49TA7000UHD** (also L49TA7000UHD) and **55TA7000UHD** (2018, 2.5 GB RAM, 16 GB, 3 HDMI, 2 USB, Wi-Fi ac, Play Store).
  - Sources: [Gizbot 55TA7000UHD](https://www.gizbot.com/smart-tv/micromax-4k-uhd-led-smart-android-tv-55ta7000uhd-139cm-55-inch-uhd-157), [Gizbot 49TA7000UHD](https://www.gizbot.com/smart-tv/micromax-4k-uhd-led-smart-android-tv-49ta7000uhd-124cm-49-inch-uhd-156), [Bajaj L49TA7000UHD](https://www.bajajfinserv.in/bmall/micromax-124-cm-49-inch-4k-ultra-hd-led-black-l49ta7000uhd/p/29185) [V for the listings]
  - The link between those model numbers and the Oreo launch is not stated in any source. [I, medium-high]
- **The device matches this generation.** MT5658 is a quad-core A53. About 2 GB visible out of 2.5 GB fits memory reserved for video. The build date (Aug 2018) falls just before the Nov 2018 launch. [I, high]
- **No source names TCL as Micromax's ODM.** The device's own fingerprint (`MICROMAX/tcl_eu`, `hefang` builder, `com.tcl.*` stack, `V8-T658` ID) is the evidence that TCL built it. [V: device]
- **TCL India 2018 sets on MT5658:** C6, P6/P8 (2018) and iFFALCON K2A. Their firmware is T01, not TAP. The 2019 P8/P8S moved to Android 9 on other platforms. [F for P8 Android 9]

## Q4. USB flash procedure for TCL T658 / MT5658

### Official (TCL service manual, sister MT58 model U65S9906)
- Source: [manualslib, Appendix 2](https://www.manualslib.com/manual/1782072/Tcl-U65s9906.html?page=21), quoted in search snippets because the page returned 403. [V]
- Copy the main SW image `V8-T658T01.pkg` to the root of the USB stick and delete any other `.pkg` files.
- Power-button method: "Power on TV by AC, at the same time press 'power on' key for 10s, TV will update SW automatically." About 4 minutes, then reboot.
- Menu method: Settings > Support > Software update > By USB. The TV finds the version and you choose Update.
- After flashing: Factory menu > Reset ALL, then Reset Shop.

### Community consensus for MT5658 Android 8 [F, several independent sources]
- **File:** the Update `.pkg` from the zip, at the root of the stick. Seen named `Update.pkg`, `Update_V8-T658T01-LF1Vxxx_sign.pkg` and `V8-T658T01.pkg`. Keep only one `.pkg` on the stick. The manual does not show the boot-time scan requiring a fixed name.
- **Stick:** FAT32 with an MBR partition table, 8–32 GB, USB 2.0. Format on Windows or Linux if you can (TCL Discussion guide).
- **Port:** a USB 2.0 port. On the iFFALCON 55K2A the top black USB 2.0 port is called the "service port".
- **Button:** the physical power key on the TV body, not the remote.
- **Sequence:**
  1. Unplug the TV from mains.
  2. Hold the body power key.
  3. Plug mains back in while still holding the key.
  4. Keep holding about 10–15 s, until the blue/upgrade "Software Update" screen appears, then release.
- **Duration and LED:**
  - Stage 1 takes about 5–10 min and stage 2 about 10–15 min, with the LED blinking at 1 s intervals.
  - Another user reports 20–25 min in total until the Google welcome screen.
  - Do not unplug the TV or press anything during the flash.
  - Sources: HiFiVision 55K2A, [TCL Discussion guides](https://faserf.github.io/TCL-Discussion-Telegram/guides/)
- **Data:** this wipes /data, so apps and accounts are gone. Channel lists sometimes survive.
- **Afterwards:** factory reset, or Reset Shop from the factory menu.

### When it fails [F]
- **The TV logo shows and the TV boots normally, with no progress bar** (L49C2US V189 on [XDA](https://xdaforums.com/t/tcl-l49c2us-v8-t658t01-lf1v189-cannot-flash-firmware-via-usb.4792961/), tried V373/V387/V575). Try in this order:
  1. A different stick: 8–16 GB, USB 2.0, MBR FAT32.
  2. The other USB port.
  3. Holding the key from before mains is applied.
  4. Renaming to `Update.img` (one XDA reply; untested here).
  5. Signature rejection of a foreign stream would look like this too. [I]
- **"No file found" or "Validation failed":** reformat the stick, put the file at the root, and use a different stick.
- **Stuck on the updating screen after V602** (Whirlpool): the user re-flashed the PKG and that worked.
- **OTA zips cannot rescue a bootloop or downgrade.** Use a full PKG.
- **Never flash an image older than the set's factory release:** its Project ID whitelist can be missing, giving a black screen.

### Settings > System update > Local update [F/I]
- On TCL Android TVs, "Local update" takes the OTA `.zip` copied as-is. It keeps data and only installs a newer build of the same stream.
- The full `.pkg` is for the power-button or "By USB" route.
- This is documented for RT51M ([TCL_Guide](https://github.com/mojothemonkey2/TCL_Guide)) and repeated in T658 threads. It is not verified on TAP.
- Expect Local update to refuse a T01 zip on a TAP set, because the stream or fingerprint will not match. [I]

## Q5. Do Widevine, Netflix ESN and MAC survive a flash?

- **CleanYourTV, measured on a 50DP660 with T01 V602** (`docs/devices/tcl-50dp660.txt` lines 58–70) [V: one real set]:
  - The NVM reset wipes the Wi-Fi MAC (02:00:00:00:00:00), the Widevine keybox (`/factory/wv.keys` missing, falls back to L3) and the Netflix ESN.
  - A full USB reflash brought back the MAC and Netflix.
  - Widevine stayed at L3.
- **What this means for an ordinary reflash with no NVM reset** [I, medium]:
  - The device-unique data most likely sits outside the PKG, in NVM/factory storage. A PKG flash re-provisions some of it from NVM (MAC, ESN), so a reflash alone should normally keep MAC and Netflix.
  - The L3 result after the NVM-reset-plus-reflash case shows that the Widevine keybox is not in the PKG. Once lost, it cannot be restored from a public image.
- **Before any flash:**
  - Record the Widevine level (`dumpsys media.drm` or a DRM-info app) and the MAC.
  - Never run the factory-menu NVM reset.
- No source found on whether a TAP Micromax unit's keys live in a separate `/factory` partition. On the 50DP660, `/factory` was not even mounted.
- Third-party dumps from repair sites can carry another unit's MAC and keys (existing note `backup_rollback_recovery.md`).

## Q6. Official route

- **TCL:** no public firmware download for India. The official TCL route is the online updater, or after-sales/hotline. TCL Australia's service-provider software page (`support.tclelectronics.com.au/software-version/`, connection refused from here) is restricted to approved service providers. [V/F]
- **Micromax:** no official TV firmware portal or service-centre firmware download found (consistent with `backup_rollback_recovery.md`). The realistic route is a Micromax or TCL authorised service centre in India. They may hold the TAP image as a service file. [I]
- **TCL Telegram firmware bot / group** (`t.me/FirmwareTCLbot`, `t.me/tclupdates_discussion`) can look up a full firmware string. This is worth trying with `V8-T658TAP-LF1V372`. Untested. [F]

## Suggested order before anyone flashes
1. Back up: `getprop`, the Project ID, the panel ID, the MAC, the Widevine level, and photos of the mainboard and panel stickers.
2. Run the TV's own System update with logcat capture to find a genuine `V8T658TAP` URL.
3. Ask the Telegram bot or group about `V8-T658TAP`. Ask a Micromax or TCL India service centre for the service PKG.
4. Use the T01 V602 PKG only as a last resort on an already-bricked set, accepting the Project ID / panel risk.

## Round 2 (projectid 207 / SCBC-AP-MT5658)

Researched 2026-11-04 using the identifiers the TV's updater logged (`devmodel SCBC-AP-MT5658-0000A`, `projectid 207`, `appid V8T658TAP`, see `tcl_updater_protocol.md`). No firmware was downloaded. Only HTML landing pages and the seller's product photos were fetched.

### Verdict
**(a) A matching file exists and can be downloaded free today.** It is the exact build the TV already runs: `Update_MMX_V8-T658TAP-LF1V372_sign.pkg`, hosted by the Pakistani repair-firmware site Kazmi Elecom and split into two RAR parts on up-4ever. No checksum is published anywhere. It is a same-version factory image, useful for recovery and not an upgrade. Whether project ID 207 is in its whitelist is not stated, but the file is the TAP stream at the TV's own version, so a match is very likely [I, high].

### Leads
| # | Lead | Source | Conf. |
|---|---|---|---|
| 1 | **Micromax 50TA7000UHD page (live links).** "Firmware Type: USB Update / Firmware Name: `Update_MMX_V8-T658TAP-LF1V372_sign.pkg` / Firmware Version: `V8-T658TAP-LF1V372`". Published 2020-03-31, modified 2025-08-26. Two files:<br>• `Micromax 50TA7000UHD Software.part1.rar`: **800.0 MB**, uploaded 2024-05-10, <https://www.up-4ever.net/rzmjhmatkxtw> (HTTP 200)<br>• `Micromax 50TA7000UHD Software.part2.rar`: **439.7 MB**, uploaded 2024-05-10, <https://www.up-4ever.net/brnkwn7br8y3> (HTTP 200)<br>The total of about 1.24 GB fits the 1.27–1.37 GB T658 full PKGs. Free tier with a wait timer and ads. A Premium tier also exists. No MD5 or SHA on either page. | <https://www.kazmielecom.tech/micromax-50ta7000uhd-software/> | V (page text and file-host metadata); file contents unverified |
| 2 | **Micromax L55TA7000UHD page (dead links).** Same file name and version. Three RAR parts (`Micromax 55TA7000UHD Software.part1/2/3`) at up-4ever `30vhzb6i7rh8`, `3cnru0dz13x0`, `o6wtm7f5q3l4`: all **404 File Not Found** on 2026-11-04. Published 2020-05-03, modified 2024-05-11. A 2021 commenter asked for this file and got the link. A 2023 commenter asked for 49TA7000UHD firmware and Kazmi replied "No". The Wayback Machine was offline, so the dead parts could not be checked for archived copies. | <https://www.kazmielecom.tech/micromax-l55ta7000uhd-software/> | V |
| 3 | **The 43TA7000UHD is a different platform.** Kazmi lists `install.img`, `V8-T851T01-LF1V080` (Realtek/MStar T851, not MT5658). Do not use it. | <https://www.kazmielecom.tech/micromax-43ta7000uhd-software/> | V |
| 4 | **Mainboard identity, from a seller photo of a used 55TA7000UHD board** (Great Bharat Electronics, Hyderabad, ₹5,999, 30-day warranty):<br>• Silkscreen: **`MT58AP` / `40-MT58AP-MAA4HG` / `2018-01-08`**<br>• Sticker: `M6-1MT6526-MA200A`, `M3-1MT6507-MA…`, `IDGTC33297`, `80203485MA0011`, `…1MT6526-MA200AA  V8-T658TAP-LF1V372`<br>So the Micromax sets use TCL chassis **MT58AP** with the TAP software flashed at the factory. TCL's own T01 sets use other MT58 chassis (MT58CU `40-MT58CU-MAB4HG/MAD4HG` for Thomson and TCL; MT58DU `40-MT58DU-MAB4HG` for the iFFALCON 55K2A). The "AP" in the chassis name and the "TAP" in the stream name are probably the same AP (Asia-Pacific/customer) board variant. | Photo: <https://greatbharatspares.com/products/micromax-55-inches-led-tv-motherboard-for-model-55ta7000uhd> (image `…-16152.jpg`) | V (read from the photo) for the strings; I for what "AP" means |
| 5 | **Exact-string web searches still return nothing** outside Kazmi: `SCBC-AP-MT5658`, `SCBC-AP`, `MT5658-0000A`, `T658TAP`, `V8-T658TAP`, `40-MT58AP-MAA4HG`, `MT58AP`, `Update_MMX_V8-T658TAP…`, `49TA7000UHD` firmware, `50TA7000UHD` firmware. GitHub code search found nothing for `T658TAP` or `MT58AP` either. No other SCBC ODM brand (Thomson, Nordmende, Aiwa, Akai, Kodak, JVC and others) was found reporting an `SCBC-AP-MT5658` client type. All public TCL client types seen are `TCL-xx-…` (for example `TCL-AU-MT5658-S1`, `TCL-EU-MT58K-S1`, `TCL-AP-MT58K-S1`) or `SEM-LA-…`. `SCBC-` is evidently the OEM/ODM prefix, and Micromax is the only SCBC-AP T658 customer seen. | search engines, GitHub | V (negative) |
| 6 | **Other Kazmi T658 pages, for contrast (all T01).** Thomson 55UD6406 (40-MT58CU-MAD4HG, MT5658MGEJ, panel LVU550NDEL, EMMC dump); 40-MT58CU-MAD4HG `Update_V8-T658T01-LF1V575_sign.pkg`; iFFALCON 55K2A (40-MT58DU-MAB4HG, panel ST54, `Update.pkg`); TCL V8-S65AT01 MT58CU page with T01 V549/V551/V495 parts on upload-4ever. | kazmielecom.tech | V |
| 7 | **Paid or repair-shop channels.** Not needed now that #1 exists. A used genuine board (#4) comes with the TAP software installed and is the hardware fallback if the eMMC dies. Telegram (`t.me/FirmwareTCLbot`, `t.me/tclupdates_discussion`) is still untested. | — | — |

### Before trusting the file (if it is downloaded)
- Expect a RAR whose extracted folder holds `Update_MMX_V8-T658TAP-LF1V372_sign.pkg`, about 1.2–1.4 GB.
- The file passed through a third-party, ad-funded host, so treat it as untrusted. Extract it in its own empty folder and run nothing from it.
- Check that the version string `V8-T658TAP` appears in cleartext near the start of the PKG (`xxd file | head -200 | grep -i t658`), and record its SHA-256. No reference hash exists to compare against.
- The `_sign` suffix and the secure loader (below) mean a tampered PKG should fail signature verification. That protects against a modified file. It does not protect against a genuine TCL file built for other hardware (next section).

### Is a mismatched T01 Update.pkg refused by the TV (fail-safe) or accepted (dangerous)?
**Probably accepted. Treat it as dangerous.**
- **Direct precedent [F]:** XDA "Help!!! TCL android TV C8US Bricked" (<https://xdaforums.com/t/help-help-help-tcl-android-tv-c8us-bricked.4536435/>, read through search snippets because XDA returns 403). A T01 set was flashed by mistake with `V8-T658T04-LF1V373` (a sibling T658 stream). The power-key USB flash **ran and finished**, and afterwards the TV had **no logo and no sound** and switched itself off. Re-flashing the correct T01 PKG from other USB ports did nothing, and the thread shows no fix. So the boot-time flasher **did not refuse a same-platform, different-stream package**, and the result was not recoverable by USB.
- **Same signing domain [I, medium]:** the MT5658 service manual's blank-board procedure uses one loader, `tcl_m1v1_eu_secure_emmcboot.bin`, with the `V8-T658T01.pkg`. TAP was built from the same `tcl_eu` tree, so TAP and T01 are very likely signed with the same TCL keys. A signature check would then pass a T01 PKG on a TAP board.
- **The hardware check is on the Android side [V, from `tcl_updater_protocol.md`]:** the string `Dialog_HardWareUnequal_Local` ("The local hardware version does not match update file") belongs to `com.tcl.versionUpdateApp`'s **Settings > Local update** path. It compares a header field with something like `ro.hardware.version_id=MT5658`, which is the **same** on T01 and TAP sets. So even this check would probably pass a T01 file. The power-key path bypasses Android entirely, and no evidence was found that it checks the stream or project ID.
- **What would actually break [F/I]:** the TCL Discussion FAQ and guides say a PKG without the set's project ID in its whitelist gives a black screen. Micromax project 207 on board MT58AP is very unlikely to be in the T01 whitelist, because T01 targets the CU/DU/XU chassis.
- **Conclusion:** do **not** flash T01 on this TV. Use the TAP file from lead #1. If you ever have to experiment, try it only through Settings > Local update (which can show the hardware-mismatch dialog), never through the power-key route.

### Service-manual facts useful for recovery
Source: TCL Service Manual MT5658-EU, "Test and Alignment Specification for MT58 Series", via yoreparo. Board family `40-MT58XU-MAA4HG`. [V]
- **Factory menu:** Menu > Picture > Advanced setting > Contrast, then press `9 7 3 5`. The menu shows Project ID, Name, Panel, Region and Client Type under "Other".
- **Set the Project ID blind with IR codes:** `062598` + `MENU` + `xxx` (three digits, so `207` here). The TV restarts if it works. This is the blind-entry method `firmware_T658TAP.md` Q2 said was missing. Write down **207** now.
- **Project ID controls everything else:** "different IDs stored into the eMMC depending on Panels settings and Models features, but there's only one key branching ProjectID that includes all", and "Reset ALL" restores NVM defaults "according to selected Project ID". After a TAP reflash, run Reset ALL and then Reset Shop, but never the NVM reset discussed in Q5.
- **USB flash (power key):** put the PKG at the stick root with no other `.pkg` files, then hold the power key while applying AC for about 10 s. The TV reboots by itself after about 4 minutes. Kazmi's TAP procedure matches this: the red LED blinks slowly while flashing (15–20 min) and fast when done. Then pull AC and remove the stick.
- **Blank or dead eMMC:** UART with FlashTool 7.0.0.1 and `tcl_m1v1_eu_secure_emmcboot.bin`, then the PKG over USB while holding MENU/STB on the keypad. Not tested on MT58AP.
