# Micromax Smart TVs (India): Platform, ADB Access, and Bloatware

Researched 2026-11-03. Almost every Micromax-specific source found dates from 2015–2019. No Micromax TV launches after about 2020 turned up, and current Flipkart listings would not load (error E002). Treat all model data as old. Micromax-specific debloat and ADB documentation is close to nonexistent online. Many points below are therefore marked as inference from generic Android or Android TV behaviour.

## 1. Which Micromax TV lines shipped, and which are certified Android TV vs. AOSP "Android-based"

### Takeaway
Micromax has shipped at least four software generations. Two of them are certified:
- **2015:** 4K sets on AOSP Android 4.2 / 4.4.
- **2018:** "Canvas 3" Smart TVs on AOSP Android 7.0 with the Aptoide store and no Google Play. These are not certified.
- **2018:** 49/55-inch 4K Google-certified Android TVs.
- **July 2019:** 32/40/43-inch Google-certified Android TVs with Play Store and Chromecast.

Many cheaper sets are listed only as "Android Based" or "Custom Android". These are likely AOSP builds with an OEM launcher. The only reliable way to tell is to check on the TV itself.

### Cited Findings
- **2015, first 4K Android TVs.** The 42-inch model ran Android 4.2 Jelly Bean and the 49-inch ran Android 4.4.2 KitKat. Pricing started around US$640. — [Ubergizmo](https://www.ubergizmo.com/2015/03/micromax-unveils-android-powered-4k-tvs-in-india-starting-from-640/amp/); [GizChina](https://www.gizchina.com/news/micromax-enters-the-smart-tv-market-with-4k-model-from-640); [SoyaCincau](https://soyacincau.com/2015/03/14/micromax-introduces-its-own-4k-resolution-smart-tv/) (multiple sources agree)
- **2015 model 42C0050UHD.** A buyer review says it shipped with KitKat and no YouTube app. A listing names YouTube, Twitter and Facebook as built-in apps. — [91mobiles](https://91mobiles.com/micromax-42c0050uhd-42-inch-4k-led-tv-price-in-india-74315) (conflicting single-source user review vs. listing)
- **4K UHD Android line, preloaded apps.** Reportedly ships with Facebook, Twitter and Gmail, with Play Store access. — [tvsfaq / crazyengineers result snippet](https://www.crazyengineers.com/news/micromax-4k-uhd-tvs-running-android-launched-in-india-via-flipkart.79524/) (the article URL now returns 404, so this is unverified)
- **Canvas 3 Smart TV range** (32 HD, 40 FHD, 50 FHD):
  - Software: Android 7.0 Nougat with the **Aptoide** store. Some apps are preinstalled and others can be downloaded from Aptoide.
  - Hardware: quad-core CPU, dual-core GPU, 1 GB RAM, 5.5 GB storage, 3× HDMI, 2× USB, Ethernet. AirPlay / media sharing is supported.
  - Pricing and sales: Rs 13,999 for the 32-inch and Rs 19,999 for the 40-inch, sold only on Flipkart.
  - Sources: [FoneArena](https://www.fonearena.com/blog/263265/micromax-canvas-3-smart-tv-price-india.html); [Gizbot](https://www.gizbot.com/home-entertainment/news/micromax-launches-canvas-3-led-smart-tv-with-android-7-0-nougat-053845.html); [The Mobile Indian](https://themobileindian.com/news/micromax-announces-canvas-3-smart-tv-with-android-70-aptoide-store-23692) (multiple sources agree)
- **Canvas 3 launch date.** The Mobile Indian dates it to 12 September 2018. — [The Mobile Indian](https://themobileindian.com/news/micromax-announces-canvas-3-smart-tv-with-android-70-aptoide-store-23692). A search-engine summary placed it in 2017, but I found no primary source for that date.
- **Canvas 3 model names.** The 32-inch is "32 Canvas 3" and the 40-inch is "40 Canvas 3". — [Flipkart](https://dl.flipkart.com/dl/micromax-canvas-81cm-32-inch-hd-ready-led-smart-tv/p/itmf7g9xq8gpfgw7); [Gizbot 40 Canvas 3](https://www.gizbot.com/smart-tv/micromax-canvas-smart-tv-40-canvas-3-102cm-40-inch-fhd-159/)
- **Earlier Canvas TV models exist** (no OS details found): "40 Canvas1Pro" and "Canvas S-40". — [tvsfaq Micromax brand page](https://tvsfaq.com/en/brand/micromax)
- **2018, first Google-certified Android TVs.** The 49-inch and 55-inch 4K models have a quad-core Cortex-A53 CPU, 2.5 GB DDR3 RAM and 16 GB storage. Prices were Rs 51,990 and Rs 61,990. — [ElectronicsForU](https://ace.electronicsforu.com/?p=68943); [NewsBytes](https://www.newsbytesapp.com/news/science/micromax-launches-google-certified-android-tvs-in-india/story)
- **July 2019, 32/40/43-inch "Google Certified Android TV".** Features include Play Store, built-in Chromecast and Google Assistant.
  - 32-inch: HD, 1.5 GB RAM, 8 GB storage, Rs 13,999.
  - 40-inch and 43-inch: 2.5 GB RAM, 16 GB storage.
  - Sold on Flipkart from 11 July 2019.
  - Sources: [Digit](https://www.digit.in/news/tvs/micromax-launches-32-inch-40-inch-and-43-inch-android-smart-tvs-starting-at-rs-13999-49074.html); [Beebom](https://beebom.com/micromax-android-tv-launched-india); [TelecomTalk](https://telecomtalk.info/?p=202736) (multiple sources agree)
- **2019 model numbers** seen on spec sites:
  - 32CAM6SHD: quad-core, Mali-470 MP3 GPU, 1 GB RAM, 8 GB storage, 2 HDMI + 1 USB, Play Store, YouTube and Netflix. — [Gizbot](https://www.gizbot.com/smart-tv/micromax-led-smart-android-tv-32cam6shd-81cm-32-inch-hd-ready-153/)
  - 40CAM6SFHD: quad-core. — [Gizbot](https://www.gizbot.com/smart-tv/micromax-full-hd-led-smart-android-tv-40cam6sfhd-102cm-40-inch-fhd-154)
  - Conflict: Gizbot lists 1 GB RAM for 32CAM6SHD, but Digit reports 1.5 GB for the 2019 32-inch Android TV.
- **Sets listed only as "Custom Android" or "Android Based"** (version and chipset not stated):
  - 32TA6445HD — [Smartprix](https://smartprix.com/tvs/micromax-32ta6445hd-32-inch-hd-ready-smart-ppd14458kbxy)
  - 40V1107HD (38.5-inch) — [Flipkart](https://dl.flipkart.com/dl/micromax-smart-led-tv-98-cm-38-5-inch-hd-ready-android-based/p/itm54a9466f29f92)
  - A 43-inch FHD "Android Based" set (search snippet calls it 43V2000FHD, with JioHotstar and Netflix) — [Flipkart](https://flipkart.com/micromax-smart-led-tv-109-cm-43-inch-full-hd-android-based/p/itmb5d46d714938f) (the page returned an error when fetched, so the snippet is unverified)
- **Non-smart LED sets** also form a large part of the catalogue. Examples: L32P8361HD, 43T6950FHD, 43T7200MHD, 40C3420MHD, 22A8100HD. — [MySmartPrice](https://www.mysmartprice.com/electronics/micromax-l32p8361hd-32-inch-hd-ready-led-tv-msf559994); [91mobiles](https://www.91mobiles.com/tv/compare/micromax/43t6950fhd-89920/vs/micromax/43x6300mhd-89925.html); [dipelectronicslab (search listing)](https://dipelectronicslab.com/micromax-43t7200mhd-software/)
- **Older precedent:** Micromax sold an Android USB "smart stick" alongside its LED TVs. — [TechEnclave](https://techenclave.com/threads/micromax-launches-led-tvs-home-theater-systems-android-usb-smart-stick.139807)

### Inferences
- **Decision rule:**
  - A set with a Google Play Store and Chromecast built in is certified Android TV (2018 4K, 2019 CAM6 series). It probably runs Android TV 8/9 with `com.google.android.tvlauncher`.
  - A set with Aptoide or a vendor app store and no Play Store is AOSP (Canvas 3 / Android 7, 2015 KitKat sets, and probably the "Custom Android" / "Android Based" listings).
- **Naming pattern:** The "CAM6" series looks like the certified 2019 line. The "TA" and "V" series look like budget "Custom Android" builds. This rests on listing wording only.
- **What launcher replacement means:**
  - On AOSP sets it is usually straightforward: set a new Home app and disable the stock one.
  - On certified ATV it is harder, because the stock launcher re-asserts itself and the Home button is bound to it.
- **Who builds the sets:** Micromax likely sourced them from ODMs. The "MediaTek processor" claim (Beebom), the Mali-470 GPU, and Aptoide plus AirPlay on Canvas 3 are typical of MStar/MediaTek and CVTE reference software. This is not confirmed.

### Gaps
- I found no official Micromax TV support or spec pages. The micromaxinfo.com TV section was not found or indexed.
- I found no models launched after 2019–2020, and I could not confirm whether Micromax still sells TVs in late 2026.
- No exact Android versions were found for the 2019 certified sets.
- No Google TV (as opposed to Android TV) Micromax model was found.

## 2. SoC and board platforms (for firmware recovery)

### Takeaway
SoC vendors are almost never named in public specs. The one named vendor is "MediaTek processors" for the 2019 certified line (single source), plus Cortex-A53 and Mali-470 MP3 clues. Repair and firmware sites list Micromax firmware by model number. One board code turned up (3MS553LT5AP.01 / 3MSV56LT5AP.01, an MStar-family naming pattern). No CVTE board (CV338 / TP.MS338 etc.) was tied to Micromax in any source I found.

### Cited Findings
- The 2019 Google-certified Micromax Android TVs use "MediaTek processors" (model not given). — [Beebom](https://beebom.com/micromax-android-tv-launched-india) (single source)
- The 2018 4K certified sets use a quad-core Cortex-A53 CPU. — [ElectronicsForU](https://ace.electronicsforu.com/?p=68943)
- 32CAM6SHD lists a Mali-470 MP3 GPU. — [Gizbot](https://www.gizbot.com/smart-tv/micromax-led-smart-android-tv-32cam6shd-81cm-32-inch-hd-ready-153/)
- One page links a Micromax 32-inch to board name 3MS553LT5AP.01, though its model naming is inconsistent. A firmware page titled "micromax 3msv56lt5ap 01 software" exists. — [search result](https://www.mysmartprice.com/electronics/micromax-l32ips100hd-32-inch-hd-ready-smart-led-tv-msf588161); [dipelectronicslab](https://www.dipelectronicslab.com/micromax-3msv56lt5ap-01-software/) (the site now shows a "Coming Soon" placeholder, so the content is unverifiable)
- Dipelectronicslab also hosted per-model Micromax firmware pages, all now offline: 43T7200MHD, 43T8100MHD, 22A8100HD, 40C3420MHD. These were delivered as a .bin inside a zip. — [43T7200MHD](https://dipelectronicslab.com/micromax-43t7200mhd-software/); [43T8100MHD](https://dipelectronicslab.com/micromax-43t8100mhd-software/); [22A8100HD](https://dipelectronicslab.com/micromax-22a8100hd-firmware/); [40C3420MHD](https://dipelectronicslab.com/micromax-40c3420mhd-software/)
- **Generic CVTE / MStar board recovery** (shown on a Telefunken CV338 example, not Micromax): flash an eMMC dump, then run a USB update with `CtvUpgrade.bin` via the MStar console. — [kenotrontv.ru](https://kenotrontv.ru/files/file/7528-telefunken-tf-led42s62t2s-cv338-t42-cx420dleddm-klm8g)
- **MSD338 board variants** (512M vs 1G/4G) need different packages. Low-trust source. — [edx.ipeindia.org](https://edx.ipeindia.org/hollow-nook/cvte-msd338-512m-update-2021) (unverified, keyword-spam site)
- Hovatek keeps a Micromax stock-ROM thread, but it is phone-focused. — [Hovatek](https://www.hovatek.com/forum/thread-938.html)

### Inferences
- The "3MS553LT5AP" / "3MSV56LT5AP" strings resemble MStar-based ODM board naming ("MS553", "MSV56"). Combined with Aptoide and AirPlay on Canvas 3, this suggests some AOSP Micromax sets run on MStar boards. That makes the `CtvUpgrade.bin` / MstarUpgrade.bin USB-update and RT809H eMMC-dump recovery workflows potentially relevant. Not confirmed for any specific Micromax model.
- **Do this before any debloat.** Photograph the mainboard sticker (requires opening the back cover) and the rear model label, and save `getprop` output. Firmware is matched by board code + panel + RAM/eMMC size, not by retail model alone.

### Gaps
- No source names a specific SoC for any Micromax TV. That covers MediaTek MT58xx/MT9xxx, MStar MSD338/MSD6683, Realtek RTD28xx/RTD2841, Amlogic T962 and so on.
- No Micromax-specific CVTE board was found.
- The main Micromax TV firmware host (dipelectronicslab) is offline, so recovery images may be hard to obtain.

## 3. Enabling Developer Options, USB debugging, and network ADB

### Takeaway
I found no Micromax-specific instructions, so use the standard Android TV procedure:
1. Open Settings > Device Preferences/System > About.
2. Click **Build** 7 times.
3. Developer options > enable USB debugging, and "Network debugging" if present.
4. Run `adb connect <TV-IP>:5555` and accept the RSA prompt on the TV.

On AOSP Micromax sets (Android 4.4 / 7), Settings may be a vendor "TV Settings" app. Use "About > Build number" if it exists. Otherwise open stock Android Settings via a launcher's app drawer or the "Settings" icon. Wireless-debugging pairing (Android 11+) almost certainly does not exist, because no Micromax TV on Android 11+ was found.

### Cited Findings
- **Generic Android TV / Google TV path:** Settings > System (Device Preferences) > About > Android TV OS build, pressed about 7 times with the centre button. Then connect with `adb connect <IP>:5555`; the TV asks you to approve the connection. — [anexplorer devmode/Android TV](https://anexplorer.io/devmode/android/tv); [DroiX KB](https://droix.net/knowledge-base/article/how-to-enable-developer-options-on-your-android-powered-smart-tv-box/); [Home Assistant Android TV integration](https://www.home-assistant.io/integrations/androidtv/) (multiple generic sources agree)
- **Wi-Fi only on some devices:** some Android TV devices accept the first ADB connection only over the Wi-Fi interface. — search summary of [Home Assistant docs](https://home-assistant.io/integrations/androidtv/) (generic, single source)
- **Comparable Indian-market brand:** Xiaomi documents enabling developer options and ADB debugging on Mi TV in an official support article. It is a useful template for a budget MediaTek ATV. — [Mi support KA-06513](https://www.mi.com/global/support/article/KA-06513/)
- **Android's official adb docs** cover `adb tcpip 5555` for switching a USB-connected device to TCP, and "Wireless debugging" pairing (`adb pair`) for Android 11+. — [Android Developers: adb](https://developer.android.com/tools/adb)

### Inferences
- **Certified Micromax ATV (2018/2019, Android 8/9 likely).** Developer Options should be under Settings > Device Preferences > About > Build. Many ATV 8/9 builds expose "Network debugging" or accept ADB on port 5555 once USB debugging is on. If port 5555 is closed, the fallback `adb tcpip 5555` needs a USB connection first, which is a problem on TVs (see next point).
- **USB-A ports on TVs are host-only.** They usually cannot act as an ADB device port, so a PC-to-TV USB-A cable will not give ADB. This is general hardware knowledge; I found no Micromax-specific confirmation either way. Some MStar boards expose a service/debug UART or a "USB upgrade" port, but these are not ADB.
- **AOSP Canvas 3 / KitKat sets.** These often ship with ADB enabled over Ethernet/Wi-Fi on port 5555 by default. Factory ODM builds commonly set `persist.adb.tcp.port` / `service.adb.tcp.port`, and some even run adbd as root. Check by running `nmap -p 5555 <TV-IP>` or `adb connect <TV-IP>:5555` before touching menus. This is anecdotal knowledge about MStar/CVTE builds, not verified for Micromax.
- **No "Wireless debugging" (pairing-code) UI is expected.** It arrived only in Android 11, and no Micromax TV on Android 11+ was found.
- **Factory/service menus:** MStar and CVTE sets typically hide a factory menu behind Settings + a code such as 1147, 0000 or 2580. Some expose ADB/UART toggles there. Specific codes for Micromax were not found.

### Gaps
- No Micromax-specific screenshots or guide for the About > Build path.
- I could not verify whether ADB on port 5555 is open by default on any Micromax model.
- No factory-menu code was confirmed for Micromax TVs.

## 4. Stock launcher and bloatware package names; critical packages

### Takeaway
No public source lists Micromax TV package names. The only confirmed software facts are:
- Canvas 3 ships Aptoide plus unnamed preloaded apps.
- 2015/2018 4K sets preloaded Facebook, Twitter and Gmail (unverified).
- Later sets list YouTube, Netflix and JioHotstar.
- Certified sets have Google Play, Chromecast and Assistant.

Package lists must be pulled from the device (`adb shell pm list packages -f`). The critical-package list below is generic Android TV / MStar knowledge, not Micromax-verified.

### Cited Findings
- Canvas 3 includes the Aptoide store and preinstalled apps (not named). — [The Mobile Indian](https://themobileindian.com/news/micromax-announces-canvas-3-smart-tv-with-android-70-aptoide-store-23692); [FoneArena](https://www.fonearena.com/blog/263265/micromax-canvas-3-smart-tv-price-india.html)
- 32CAM6SHD apps: YouTube and Netflix, plus Google Play Store. — [Gizbot](https://www.gizbot.com/smart-tv/micromax-led-smart-android-tv-32cam6shd-81cm-32-inch-hd-ready-153/)
- Micromax phones historically bundled partner apps (Spuul, Hike on Canvas 4). This shows a content-partner bundling habit, but it is a phone, not a TV. — [MediaNama](https://www.medianama.com/2013/07/223-micromax-spuul-hike-canvas-4)
- **Generic warning from Chromecast with Google TV:** disabling the stock Google TV launcher loses features such as casting. Commenters suggest keeping the stock launcher and using Projectivy's accessibility-based Home-button override instead. — [r/AndroidTV via redlib](https://redlib.ssps.io/r/AndroidTV/comments/1k9gfpx/release_android_tv_debloat_toolkit_clean_safe/mpsfflp/?context=3) (single anecdote, different device)
- Generic ATV debloat tooling over ADB exists, for example cleanyourtv. — [HelloGitHub: cleanyourtv](https://hellogithub.com/en/repository/Gathin23/cleanyourtv). Sony Bravia debloat guide: [r/bravia guide](https://lr.in.psf.lt/r/bravia/comments/czuo7q/guide_android_tv_debloat_and_customization)
- PCWorld warns against blindly following AI-generated TV debloat commands. — [PCWorld](https://www.pcworld.com/article/3266473/please-dont-use-ai-hacks-to-debloat-your-tv.html)
- Third-party launchers commonly used on ATV: Projectivy, Kyu, AT4K. — [BGR](https://www.bgr.com/2140758/best-smart-tv-launchers-you-can-try/)

### Inferences
These lists are generic and must be validated against your own `pm list packages`.

- **Do not remove** (TV input, tuner, settings, system):
  - Android core: `android`, `com.android.systemui`, `com.android.settings`, `com.android.tv.settings` (ATV settings), `com.android.providers.*`, `com.android.packageinstaller` / `com.google.android.packageinstaller`, `com.android.inputmethod.*` / `com.google.android.leanback.ime` (on-screen keyboard)
  - TV input framework: `com.android.tv` / `com.google.android.tv` (Live Channels / TIF)
  - Vendor TV and input services (names vary by vendor): MStar `com.mstar.android.tv.*`, `com.mstar.tv.service`, `com.mstar.tv.tvplayer.ui`, `com.mstar.android.tvapi`; CVTE `com.cvte.tv.*`; MediaTek `com.mediatek.tv*`, `com.mediatek.wwtv.*`, `com.mediatek.twoworlds.*`; Realtek `com.realtek.*`
  - Remote / Bluetooth pairing: e.g. `com.google.android.tv.remote.service`, `com.android.bluetooth`, `com.google.android.tvrecommendations` on some builds
  - Google services, which certified ATV setup and Play depend on: `com.google.android.gms`, `com.google.android.gsf`
  - The TV "source" / HDMI-CEC app. On AOSP MStar sets this often *is* the tvplayer app, and removing it kills HDMI/antenna input.
- **Usually safe to disable** with `pm disable-user --user 0` (preferred over `pm uninstall --user 0`):
  - Partner content apps and recommendation/ad clients
  - App stores such as Aptoide (`cm.aptoide.pt` / `cm.aptoide.tv`) once you have an alternative
  - Social apps (Facebook, Twitter)
  - Vendor "eShare" / AirPlay / "TV Guide" apps if unused
  - On certified ATV: `com.google.android.tvrecommendations` and `com.google.android.leanbacklauncher.recommendations` (the specific package depends on the build)
- **Launcher swap:**
  - AOSP: install the new launcher, set it as Home, then disable the stock one. Keep `adb` ready so the stock launcher can be re-enabled if the Home intent breaks.
  - Certified ATV 8/9: disabling `com.google.android.tvlauncher` / `com.google.android.leanbacklauncher` is possible but can break Chromecast and setup. Prefer a Home-button remapper.

### Gaps
- No Micromax TV package dump was found on XDA, Reddit, YouTube or forums. Names like "Hungama", "Eros" and "eShare" could not be confirmed as Micromax TV preloads.
- The stock launcher package of Canvas 3 or the "Custom Android" sets is unknown.

## 5. Community reports of debloating or launcher replacement on Micromax TVs (bricks, problems)

### Takeaway
I found no Micromax-TV-specific debloat, launcher-replacement or brick reports on Reddit, XDA or web search. Community evidence is all for other brands (Xiaomi Mi TV/Box, TCL, Sony, Chromecast). The user should expect to be pioneering on this hardware.

### Cited Findings
- **Generic and other-brand reports:**
  - An r/MiBox user used ADB with Projectivy to uninstall stock YouTube, YouTube Music and Google gaming. — [r/MiBox](https://reddit.birdcat.cafe/r/MiBox/comments/1ivxcns/mi_box_with_projectivy_launcher/mece3s1/?context=3)
  - An Android TV debloat toolkit release thread (r/AndroidTV, April 2025). — [redlib](https://redlib.ssps.io/r/AndroidTV/comments/1k9gfpx/release_android_tv_debloat_toolkit_clean_safe/mpg1npq/?context=3)
  - A Samsung Community thread on removing preinstalled apps on Android TV. — [Samsung Community](https://r2.community.samsung.com/t5/Tech-Talk/Remove-Pre-installed-Apps-on-Android-TV/td-p/12168630)
- A 2026 report describes people using AI coding agents to strip ads from Xiaomi and TCL TVs over ADB. PCWorld warns that blindly running AI-generated debloat commands risks breaking TVs. — [AI Weekly (FR)](https://aiweekly.co/fr/alerts/claude-code-sert-vider-les-smart-tv-xiaomi-et-tcl-de-leurs-pubs); [PCWorld](https://www.pcworld.com/article/3266473/please-dont-use-ai-hacks-to-debloat-your-tv.html)

### Inferences
- **Brick risk** on budget MStar/CVTE AOSP sets mainly comes from:
  - disabling the tvplayer/source app or the system launcher with no fallback Home, which leaves a black screen with ADB still reachable;
  - `pm uninstall` of system packages followed by a factory reset that fails;
  - flashing the wrong board firmware, the most serious.
- Using `pm disable-user` with a working network ADB connection keeps everything reversible (`pm enable` / `cmd package install-existing`).

### Gaps
- No Micromax-specific threads, videos or brick reports were found. A YouTube search in Hindi ("Micromax smart TV launcher change") was not done within the tool budget.

## 6. Identifying the exact model and board

### Takeaway
Combine four sources: the rear sticker (retail model such as 32CAM6SHD or 40V1107HD), Settings > About, `getprop` over ADB, and the mainboard sticker inside the TV. Firmware recovery needs the board code, which only the last source reliably gives.

### Cited Findings
- Micromax retail models follow codes like 32CAM6SHD, 40CAM6SFHD, 32TA6445HD, 40V1107HD, 43T7200MHD and L32P8361HD. — [Gizbot](https://www.gizbot.com/smart-tv/micromax-led-smart-android-tv-32cam6shd-81cm-32-inch-hd-ready-153/); [Smartprix](https://smartprix.com/tvs/micromax-32ta6445hd-32-inch-hd-ready-smart-ppd14458kbxy); [Flipkart](https://dl.flipkart.com/dl/micromax-smart-led-tv-98-cm-38-5-inch-hd-ready-android-based/p/itm54a9466f29f92); [MySmartPrice](https://www.mysmartprice.com/electronics/micromax-l32p8361hd-32-inch-hd-ready-led-tv-msf559994)
- Firmware is matched to the board part number (e.g. CV338H-T42 vs CV338H-A50 vs T50; MSD338 512M vs 1G). Repair forums advise reading the board sticker before flashing. — [elektroda](https://www.elektroda.pl/rtvforum/topic3750962.html); [elektroda MSD338STV5.0 Q&A](https://www.elektroda.com/qa,vs-s358a3-2-firmware-msd338stv5-0.html)

### Inferences
Commands to run once ADB is connected. These are standard Android properties.

```
adb shell getprop ro.product.model
adb shell getprop ro.product.brand
adb shell getprop ro.product.manufacturer
adb shell getprop ro.product.device
adb shell getprop ro.product.board
adb shell getprop ro.board.platform        # e.g. mt58xx / m7322 / mtk / realtek / amlogic
adb shell getprop ro.hardware
adb shell getprop ro.build.fingerprint
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
adb shell getprop | grep -iE "mstar|cvte|mtk|mediatek|realtek|amlogic|hisi|odm|customer"
adb shell cat /proc/cpuinfo
adb shell pm list packages -f > packages.txt   # back this up before any change
adb shell cmd package resolve-activity -c android.intent.category.HOME -a android.intent.action.MAIN   # current Home
```

- **Reading the results:**
  - A fingerprint containing `google/` with Play services present means certified ATV.
  - `ro.board.platform` values like `mt5886` or `mt9612` mean MediaTek TV SoC; `m7322` or `mstar` means MStar (now MediaTek); `rtd28xx` means Realtek.
  - The vendor packages in `pm list` (mstar / cvte / mediatek) confirm the ODM stack.
- **Physical identification:** check the rear-panel label (model, serial, manufacture month). Then check the mainboard silkscreen or sticker, such as "TP.MSxxxx.PBxxx", "CVxxxH-xxx" or "3MSxxxxx" (the last is seen in one Micromax-linked listing).

### Gaps
- No Micromax-specific mapping from `ro.board.platform` values to retail models was found.
