# Building a Custom Character-Themed Android TV Launcher (sideloaded, low-end Indian TVs)

Research date: 2026-11-03. Scope: stack choice, launcher manifest, focus/animation, streaming deep links, perf constraints, dev loop, asset/IP note. Feature targets: (a) dock + app grid + clock, (b) "My Favourites" character lineup (grayscale unfocused / colour + scale focused, per-character background scenes, small effects), (c) mood-based random-watch screen driven by a JSON catalogue.

Confidence legend: **[official]** = developer.android.com / androidx release notes; **[OSS]** = verified open-source code; **[community]** = forum/SO/XDA; needs on-device verification; **[inference]** = my reasoning, not directly sourced.

---

## 1. Stack choice: Compose for TV vs Leanback/Views vs WebView-hosted HTML vs Flutter

### Takeaway
Google calls Compose "the recommended way to build apps for Android TV OS". `androidx.tv:tv-material` is stable at **1.1.0** and `tv-foundation` at **1.0.0** (both released May 6, 2026). Current AndroidX/Compose needs **minSdk 23**, and Android 9–11 TVs (API 28–30) are well above that. For a web developer the practical choice is Kotlin + Compose for TV. Its state-driven UI and animation APIs are the closest thing on Android to React + GSAP, and it has no WebView-version risk. A WebView shell is the fallback if you want to reuse HTML/CSS/JS skills. Flutter works (FLauncher proves it) but means learning another language and toolkit.

### Cited Findings
- "Compose is the recommended way to build apps for Android TV OS. Alongside the core Compose libraries, the Compose for TV libraries provide dedicated components designed specially for the big screen" (tv-foundation, tv-material). Leanback is still documented as an alternative toolkit. [official] — [Set up a TV project](https://developer.android.com/training/tv/get-started/create)
- Current versions: `androidx.tv:tv-material:1.1.0` and `androidx.tv:tv-foundation:1.0.0`, both released May 06, 2026. tv-material 1.0.0 (first stable) shipped Aug 21, 2024. [official] — [androidx.tv release notes](https://developer.android.com/jetpack/androidx/releases/tv)
- TV lazy layouts (`TvLazyRow`, `TvLazyColumn`, `TvLazyVerticalGrid`…) were deprecated in tv-foundation 1.0.0-alpha11 (Jul 2024) and removed in alpha12 (Jan 2025). Use the standard Compose foundation `LazyRow`/`LazyVerticalGrid` instead. [official] — [androidx.tv release notes](https://developer.android.com/jetpack/androidx/releases/tv)
- tv-material provides Surface/Card/Button with TV focus "indications": Border, Glow and Scale, "which can be used to build components that clearly highlight the focused element on the TV screen". There is also a `NavigationDrawer`, a `TabRow` and a `Carousel`. `ImmersiveList` (background changes with the focused item) was removed in 1.0.0-beta01, and Google points to [a sample](https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:tv/samples/src/main/java/androidx/tv/samples/ImmersiveListSamples.kt;drc=5920fece16ad6723107098f24a492a25937cd51a) for building it yourself. That sample is the pattern for the per-character background scenes. [official] — [androidx.tv release notes](https://developer.android.com/jetpack/androidx/releases/tv)
- "Disable glow indication for API_LEVEL below 28 as it is not supported by the OS." On Android 8 or older AOSP TVs the Glow effect silently does nothing. [official] — [androidx.tv release notes (alpha10)](https://developer.android.com/jetpack/androidx/releases/tv)
- tv-material 1.0.1 fixed "Exoplayer wasn't rendering on the Surface composables on lower Android API versions", and 1.1.0-alpha01 fixed "jittery text while scaling". Both show that low-API rendering quirks get real fixes, so use the latest version. [official] — [androidx.tv release notes](https://developer.android.com/jetpack/androidx/releases/tv)
- tv-material and tv-foundation ship baseline profiles (since alpha10). Baseline profiles cut startup and jank on cold start. [official] — [androidx.tv release notes](https://developer.android.com/jetpack/androidx/releases/tv)
- minSdk: AndroidX/Jetpack libraries have required API 23 since June 2025 [community, secondary] — [NewPipe issue #13438](https://github.153394839.workers.dev/TeamNewPipe/NewPipe/issues/13438). "Starting with Compose BOM 2025.12.00, the minimum required API level is 23" — [Zendesk SDK notice](https://support.zendesk.com/hc/en-us/articles/10934369609370-Announcing-a-new-minimum-Android-version-requirement-for-the-Zendesk-messaging-SDK). A Compose 1.10.2 upgrade failed with "minSdkVersion 21 cannot be smaller than version 23 declared in library" — [Kotlin Slack](https://slack-chats.kotlinlang.org/t/27564393/i-m-getting-this-error-why-not-support-android-21-manifest-m). Intercom SDK 18.0.0 (Mar 2026) moved to minSdk 23 "aligning with AndroidX Compose library requirements" — [newreleases.io](https://newreleases.io/project/github/intercom/intercom-android/release/18.0.0).
- The TV docs' own baseline still reads "targets Android 5.0 (API level 21) or higher". That is out of date relative to current Compose. [official] — [Set up a TV project](https://developer.android.com/training/tv/get-started/create)
- Flutter is a proven option: FLauncher, an open-source Android TV launcher, "built with Flutter" — [svrooij/flauncher](https://github.com/svrooij/flauncher); original GPL-3 project by Étienne Fesser — [gitlab.com/flauncher/flauncher](https://gitlab.com/flauncher/flauncher) [OSS]

### Inferences
- **Recommended: Kotlin + Jetpack Compose (Compose BOM + `androidx.tv:tv-material:1.1.0`), minSdk 23–28.** [inference] Why:
  - `animateFloatAsState`/`updateTransition`/`Crossfade`/`AnimatedContent` map cleanly to GSAP-style tweening driven by focus state (`onFocusChanged` / `interactionSource.collectIsFocusedAsState()`).
  - tv-material `Surface`/`Card` give scale+border on focus for free (`ClickableSurfaceDefaults.scale(focusedScale = 1.1f)`).
  - Focus traversal comes from the platform. You don't build a spatial-navigation engine as you would in a web UI.
- **WebView-hosted HTML/CSS/JS:** this reuses GSAP/React skills. The risks on cheap AOSP TVs [inference, no direct source found]:
  - Android System WebView is often an old, non-updatable build when Play Store/Play Services are missing or stripped. That can mean an old Chromium, missing CSS features, and poor GPU compositing.
  - Each WebView adds tens of MB of RAM on a 1–1.5 GB device.
  - D-pad navigation has to be hand-rolled with arrow-key listeners or a spatial-nav library.
  - You still need a native Kotlin shell for `PackageManager` queries and `startActivity`, exposed through `@JavascriptInterface`.
  - If you choose this route, keep animations to `transform`/`opacity`, avoid `filter: grayscale()` on big layers (expensive on old Mali), and pre-bake grayscale sprites instead.
- **Leanback (Views):** mature and light, but its look (BrowseSupportFragment rows) is rigid and fighting it for a custom character UI is painful. Google now steers new work to Compose. [inference based on official recommendation]
- **APK size:** a minimal Compose + tv-material release APK with R8 should be a few MB. Flutter adds its engine (~5–8 MB+ per ABI). A WebView shell is tiny, but your bundled assets dominate. No exact numbers were verified, so measure. [inference]

### Gaps
- No official benchmark of Compose for TV on 1 GB-RAM Mali-450 class devices. Real-world jank reports are anecdotal; profile on the actual TV.
- I couldn't confirm the tv-material artifact's exact declared minSdk from its POM. Treat it as 23 (the AndroidX floor) and verify when Gradle runs the manifest merge.
- The Micromax TV's WebView version and whether it can update were not verified. Check with `adb shell dumpsys webviewupdate` / `pm list packages | grep webview`.

---

## 2. Launcher manifest, listing installed apps, launching apps

### Takeaway
To work as a replaceable TV home screen, the activity needs `MAIN` + `HOME` + `DEFAULT` (plus `LEANBACK_LAUNCHER`, and optionally `LAUNCHER`/`LAUNCHER_APP`), `android:banner` 320×180, touchscreen `required=false`, and the leanback feature. On Android 11+ (targetSdk 30+) it also needs a `<queries>` block for `MAIN` intents, or `QUERY_ALL_PACKAGES` (fine for a sideloaded, non-Play app). FLauncher's manifest is a verified, working template.

### Cited Findings
- FLauncher's real manifest (verified) [OSS] — [FLauncher AndroidManifest.xml](https://gitlab.com/flauncher/flauncher/-/raw/master/android/app/src/main/AndroidManifest.xml):
  ```xml
  <uses-feature android:name="android.hardware.touchscreen" android:required="false" />
  <uses-feature android:name="android.software.leanback" android:required="true" />
  <uses-permission android:name="android.permission.REQUEST_DELETE_PACKAGES" />
  <queries>
      <intent><action android:name="android.intent.action.MAIN" /></intent>
      <intent><action android:name="android.intent.action.GET_CONTENT" /></intent>
  </queries>
  <application android:banner="@drawable/banner" android:icon="@mipmap/ic_launcher" ...>
    <activity android:name=".MainActivity" android:exported="true"
        android:launchMode="singleTask" android:screenOrientation="landscape"
        android:hardwareAccelerated="true"
        android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode" ...>
      <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.HOME" />
        <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
        <category android:name="android.intent.category.LAUNCHER_APP" />
        <category android:name="android.intent.category.LAUNCHER" />
      </intent-filter>
    </activity>
  </application>
  ```
  Takeaways from this template: `singleTask` stops the Home button from stacking new launcher instances, and the long `configChanges` list stops the activity from being recreated on HDMI/density/uiMode changes.
- "If you don't include the `CATEGORY_LEANBACK_LAUNCHER` intent filter … if your app doesn't have this filter when you use developer tools to load it onto a TV device, the app does not appear in the TV user interface." [official] — [Set up a TV project](https://developer.android.com/training/tv/get-started/create)
- Declare `<uses-feature android:name="android.software.leanback" android:required="false"/>` (true = TV-only on Play) and `<uses-feature android:name="android.hardware.touchscreen" android:required="false"/>`. [official] — [Set up a TV project](https://developer.android.com/training/tv/get-started/create)
- Banner: "use an xhdpi resource with a size of 320 x 180 px. Text must be included in the image", set via `android:banner` on `<application>` or `<activity>`. [official] — [Set up a TV project](https://developer.android.com/training/tv/get-started/create)
- Launch colour: set `android:colorPrimary` and `windowAllowReturnTransitionOverlap`/`windowAllowEnterTransitionOverlap` = true. On Android 12+ TV, custom SplashScreen API animations are not supported. [official] — [Set up a TV project](https://developer.android.com/training/tv/get-started/create)
- Package visibility on Android 11+: apps targeting API 30+ see a filtered package list. Declare `<queries>` by `<package>`, by `<intent>` (exactly one `<action>`; no path/pathPrefix/port in `<data>`), or by provider. `QUERY_ALL_PACKAGES` is "not recommended" and is subject to Play policy, but that policy only matters for Play distribution. [official] — [Declaring package visibility needs](https://developer.android.com/training/package-visibility/declaring)
- A Flutter launcher plugin's docs also state the MAIN + HOME + DEFAULT (+ LEANBACK_LAUNCHER for TV) requirement [community] — [playx_home_launcher](https://pub.dev/documentation/playx_home_launcher/latest/). A custom TV home app where the Home button never prompted for a default launcher is a known failure mode [community] — [SO 73279029 mirror](https://kiwix.lema.org/stackoverflow.com_en_all_2023-11/questions/73279029/android-tv-launcher-app-not-working-as-home-screen-app)

### Inferences
- Listing apps [inference, standard PackageManager API]:
  - `pm.queryIntentActivities(Intent(ACTION_MAIN).addCategory(CATEGORY_LEANBACK_LAUNCHER), 0)` returns TV apps. Merge with `CATEGORY_LAUNCHER` results to catch phone-only sideloads.
  - Each `ResolveInfo` gives `loadLabel()`, `activityInfo.loadBanner(pm)` (fall back to `loadIcon`), and package/class.
  - Refresh on `ACTION_PACKAGE_ADDED/REMOVED/CHANGED`, registered at runtime with a `package` data scheme.
- Launching [inference]: `pm.getLeanbackLaunchIntentForPackage(pkg) ?: pm.getLaunchIntentForPackage(pkg)`, then `startActivity(intent.addFlags(FLAG_ACTIVITY_NEW_TASK))`.
- Making it the default Home on stock Micromax/AOSP firmware [inference]:
  - After install, press Home and pick it in the chooser ("Always").
  - If the firmware hides the chooser, set it with `adb shell cmd package set-home-activity <pkg>/.MainActivity` (Android 7+), or disable the stock launcher with `adb shell pm disable-user --user 0 <stock.launcher.pkg>`. The debloat notes cover this; keep a recovery path (`pm enable`).
- Keep `QUERY_ALL_PACKAGES` *or* the `<queries><intent>MAIN</intent></queries>` block. The FLauncher-style `<queries>` is enough and less broad.
- The clock is plain composable state updated by a `LaunchedEffect` loop at the minute boundary, or `ACTION_TIME_TICK` via a runtime receiver. Don't tick every frame. [inference]

### Gaps
- LeanbackOnFire's manifest could not be fetched (404 on guessed paths), so FLauncher is the only verified OSS template here.
- I didn't verify whether Micromax firmware blocks `set-home-activity` or forces its own launcher back after reboot (some OEM TVs do). Test on device.

---

## 3. D-pad focus handling, grayscale/colour, scale, crossfade backgrounds, image memory, GPU limits, burn-in

### Takeaway
Build the character lineup as a Compose `LazyRow` of tv-material `Surface`/`Card` items.
- Focus state drives a grayscale→colour `ColorFilter` (saturation matrix) and a scale tween.
- The focused index drives a `Crossfade` of a pre-downscaled full-screen background.
- Memory is the real constraint: decode every bitmap at display size (a 1080p ARGB_8888 frame is about 8 MB) and use an image loader (Coil) with size limits.

### Cited Findings
- tv-material Surface ships focus indications (Border, Glow, Scale), and "Components' scale indications now include None to disable scaling". [official] — [androidx.tv release notes](https://developer.android.com/jetpack/androidx/releases/tv)
- Focus API changes in tv-material 1.1.0-alpha01: `FocusProperties.enter/exit` are replaced by `onEnter`/`onExit`, and `FocusEnterExitScope.cancelFocus()` is now `cancelFocusChange()`. These are what you use to restore focus to the last character when re-entering the row. [official] — [androidx.tv release notes](https://developer.android.com/jetpack/androidx/releases/tv)
- `CompositingStrategy.Offscreen` moved from Surface to Text to fix jittery scaled text. Scaling text on focus has known jitter, so prefer scaling images and keep labels unscaled. [official] — [androidx.tv release notes](https://developer.android.com/jetpack/androidx/releases/tv)
- Bitmap memory: "an image with resolution 2048x1536 that is decoded with an inSampleSize of 4 produces a bitmap of approximately 512x384. Loading this into memory uses 0.75MB rather than 12MB for the full image." Use `inJustDecodeBounds` first, then `inSampleSize` as a power of two. Google recommends Glide; Coil, Picasso and Fresco are listed as alternatives. [official] — [Loading large bitmaps efficiently](https://developer.android.com/topic/performance/graphics/load-bitmap)
- "When scrolling container gains focus, the first element does not gain focus by default" (early-alpha known issue). Set initial focus explicitly with `FocusRequester`. [official] — [androidx.tv release notes](https://developer.android.com/jetpack/androidx/releases/tv)

### Inferences
- Grayscale unfocused / colour focused [inference; standard Compose API `androidx.compose.ui.graphics.ColorMatrix.setToSaturation`]:
  ```kotlin
  val sat by animateFloatAsState(if (focused) 1f else 0f, tween(250))
  val filter = remember(sat) { ColorFilter.colorMatrix(ColorMatrix().apply { setToSaturation(sat) }) }
  Image(painter, null, colorFilter = filter, modifier = Modifier.graphicsLayer { scaleX = s; scaleY = s })
  ```
  Put scale in `graphicsLayer {}` (a draw-phase lambda) so recomposition is skipped. If animating saturation causes jank on the target GPU, snap the saturation and tween only alpha/scale, or crossfade between two pre-baked PNGs (gray + colour). The pre-baked route is cheapest.
- Background scenes [inference]:
  - Pre-render each scene at 1280×720 or 1920×1080 as WebP/JPEG (720p is often the real panel/UI resolution on budget TVs; check `adb shell wm size`).
  - Load with Coil `size(1280, 720)`, `allowHardware(true)`, and `RGB_565` where no alpha is needed (halves memory).
  - Keep only the current and next scene in memory.
  - `Crossfade(targetState = focusedCharacter)` and debounce rapid D-pad scrolling (~150 ms) so you don't decode every scene you pass.
- Small effects [inference]:
  - Prefer cheap transforms: subtle parallax translate, opacity pulses, a few dozen particles drawn in one `Canvas`.
  - Avoid `Modifier.blur` (RenderEffect needs API 31+, so it's absent on Android 9–11), full-screen alpha blending of several layers (overdraw kills Mali-400/450 fill rate), Lottie with many layers, and video backgrounds.
  - Check overdraw with Developer options → "Debug GPU overdraw" and frame times with "Profile HWUI rendering".
- Memory budget [inference]: on 1–1.5 GB TVs the per-app heap limit is often 128–256 MB (`adb shell getprop dalvik.vm.heapgrowthlimit`), and the system can kill a launcher when a streaming app starts. Keep the working set small, let state rebuild cheaply on return, and handle `onTrimMemory` by clearing the image cache.
- Burn-in avoidance [inference]: most budget TVs are LCD/LED, where burn-in risk is low. Still, avoid static high-contrast logos at full brightness, slowly drift the clock position, and dim/animate the background after N minutes idle (a custom "ambient" mode, since a home activity stays on screen).

### Gaps
- I found no authoritative source on Mali-450 / Mali-G31 fill-rate or shader limits for Compose/Skia. The overdraw and blur advice above is engineering judgement, so verify with GPU profiling on the device.
- No official Coil/Compose guidance specific to 1 GB TVs was retrieved.

---

## 4. Deep links into Netflix, YouTube, Prime Video, JioHotstar and others

### Takeaway
None of these services publish official Android TV deep-link specs. Every format below is **[community] and needs on-device verification**. Package names are well attested: Netflix TV = `com.netflix.ninja`, Prime Video TV = `com.amazon.amazonvideo.livingroom`, Disney+ Hotstar TV = `in.startv.hotstar.dplus.tv` (not the phone's `in.startv.hotstar`). YouTube for Android TV is commonly `com.google.android.youtube.tv` (unverified this session). Always fall back to launching the app's home screen.

### Cited Findings
- **Netflix (`com.netflix.ninja`)**: users report that `am start` with `-a android.intent.action.VIEW -d "https://www.netflix.com/watch/<id>"` targeted at `com.netflix.ninja/.MainActivity`, plus the LEANBACK_LAUNCHER category and an extra `source=30`, starts playback. `/title/<id>` opens the details page without autoplay. Tested on ninja 3.3.1 (old). [community] — [SO 35556634 mirror](https://kiwix.lema.org/stackoverflow.com_en_all_2023-11/questions/35556634/movie-deeplink-for-netflix-android-tv-app-com-netflix-ninja); [Home Assistant thread p5](https://community.home-assistant.io/t/android-tv-remote-app-links-deep-linking-guide/567921?page=5). `netflix://title/<id>` was also reported working, while another user could not autostart via ADB. [community] — same HA thread.
- Home Assistant's Android TV deep-link guide lists: Netflix `https://www.netflix.com/title` or `netflix://`; YouTube `https://www.youtube.com`, `vnd.youtube://`, `vnd.youtube.launch://`; Prime Video `https://app.primevideo.com`; Disney+ `https://www.disneyplus.com`; Plex `plex://`; Spotify `spotify://`. No entries for Hotstar, JioCinema, Zee5 or SonyLIV. [community] — [HA Android TV deep-linking guide](https://community.home-assistant.io/t/android-tv-remote-app-links-deep-linking-guide/567921)
- Finding deep links yourself: "If an app allows deep linking, in its manifest it will have intent-filter with data…". Use `adb shell cmd package dump PACKAGE` (or decompile the APK and grep `<data`), and check `strings.xml` for `@string/` references. [community] — [HA guide](https://community.home-assistant.io/t/android-tv-remote-app-links-deep-linking-guide/567921)
- Some TV apps only honour the VIEW intent when the component is explicit: `am start -n <pkg/activity> -a android.intent.action.VIEW -d <url>`. `-S` force-restarts the app first. YouTube TV (the US live-TV service, `com.google.android.youtube.tvunplugged`) accepts `https://tv.youtube.com/watch/<id>`. Don't confuse it with regular YouTube for Android TV. [community] — [ADBTuner thread](https://community.getchannels.com/t/adbtuner-a-channel-tuning-application-for-networked-google-tv-android-tv-devices/36822/1228)
- **Prime Video Android TV package = `com.amazon.amazonvideo.livingroom`** (APKMirror listings, e.g. 6.16.5+v14.1.0.772-armv7a, "require Android TV and can not be installed on your phone or tablet"). Freevee uses a different package, `com.imdbtv.livingroom`. [community/APK index] — [APKMirror Prime Video (Android TV)](https://apkmirror.com/apk/amazon-mobile-llc/prime-video-android-tv-android-tv/prime-video-android-tv-android-tv-6-16-5v14-1-0-772-armv7a-release/prime-video-android-tv-6-16-5v14-1-0-772-armv7a-android-apk-download)
- **Disney+ Hotstar Android TV package = `in.startv.hotstar.dplus.tv`** (APKMirror builds 24.01.29.6 through 25.03.17.8). [community/APK index] — [APKMirror Disney+ Hotstar (Android TV)](https://apkmirror.com/apk/the-walt-disney-company-southeast-asia-pte-ltd/disney-hotstar-android-tv/disney-hotstar-android-tv-25-02-24-7-release/disney-hotstar-android-tv-25-02-24-7-2-android-apk-download). A Codidact thread reports Hotstar and Prime links *not* opening from a plain VIEW intent despite declared filters (likely phone apps). [community] — [software.codidact.com/posts/287382](https://software.codidact.com/posts/287382)
- A general pattern: phone versions may support deep links while the Android TV version doesn't. [community] — [ADBTuner thread p48](https://community.getchannels.com/t/adbtuner-a-channel-tuning-application-for-networked-google-tv-android-tv-devices/36822?page=48)

### Inferences
- On-device verification recipe [inference; standard adb/am/pm tooling]:
  ```bash
  adb shell pm list packages | grep -Ei 'netflix|youtube|amazon|hotstar|jio|zee|sony'
  adb shell dumpsys package com.netflix.ninja | sed -n '/Activity Resolver Table/,/Receiver Resolver/p'   # schemes/hosts
  adb shell cmd package resolve-activity --brief -a android.intent.action.VIEW -d "https://www.netflix.com/title/80057281" com.netflix.ninja
  adb shell am start -W -a android.intent.action.VIEW -d "https://www.netflix.com/title/80057281" -p com.netflix.ninja
  adb shell am start -W -a android.intent.action.VIEW -d "vnd.youtube:dQw4w9WgXcQ" -p com.google.android.youtube.tv
  adb shell am start -W -a android.intent.action.VIEW -d "https://app.primevideo.com/detail?gti=<GTI>" -p com.amazon.amazonvideo.livingroom
  adb shell am start -W -a android.intent.action.VIEW -d "https://www.hotstar.com/in/..." -p in.startv.hotstar.dplus.tv
  adb logcat -s ActivityTaskManager:I   # see which activity actually resolved
  ```
  (Prime `detail?gti=` and Hotstar URL shapes are guesses to test, not sourced.)
- Pin the target package with `setPackage()` (or `-p`) so the browser can't intercept `https://` links. Wrap `startActivity` in try/catch for `ActivityNotFoundException` and fall back to `getLeanbackLaunchIntentForPackage(pkg)`. If the package isn't installed, show "not installed". [inference]
- JioHotstar: after the 2025 JioCinema + Disney+ Hotstar merger, the TV app may have been renamed/repackaged. Check the installed package on the Micromax TV rather than trusting the APKMirror ID. [inference; not verified]
- Mood catalogue JSON (for feature c) should store per-item `{title, mood[], app: pkg, uri, fallback: "app"}`, so a broken deep link degrades to opening the app. Ship it in `assets/` and optionally override from `/sdcard/Download/catalogue.json` so you can edit it without rebuilding. [inference]

### Gaps
- No official Netflix, Amazon, YouTube or Disney/JioStar documentation for TV deep links was found. All formats are empirical.
- YouTube for Android TV's package (`com.google.android.youtube.tv`) and its `vnd.youtube:` handling were not confirmed this session.
- I found no deep-link data for JioCinema/JioHotstar (post-merger), Zee5 (`com.graymatrix.did`?), SonyLIV, MX Player or Aha on TV. Dump the manifests on device.

---

## 5. Sideloading and dev loop on macOS

### Takeaway
Use Android Studio (or CLI Gradle) with a TV AVD first, then the real TV over USB or network ADB with `adb install -r`. Treat the emulator as functionally useful only: it says nothing about Mali-class performance.

### Cited Findings
- Physical device: Settings → Device/About → click Build several times → Developer options → USB debugging On, then Run from Android Studio. [official] — [Set up a TV project](https://developer.android.com/training/tv/get-started/create)
- Virtual device: AVD Manager → Android TV device definition. "For best performance of the TV emulator device, use the x86 emulator and enable the Use Host GPU option." [official] — [Set up a TV project](https://developer.android.com/training/tv/get-started/create)

### Inferences
- CLI loop [inference, standard tooling]:
  ```bash
  ./gradlew :app:assembleDebug
  adb connect <tv-ip>:5555          # if network ADB is enabled
  adb install -r app/build/outputs/apk/debug/app-debug.apk
  adb shell am start -n com.you.launcher/.MainActivity
  adb logcat --pid=$(adb shell pidof com.you.launcher)
  adb shell dumpsys meminfo com.you.launcher   # watch PSS under ~100 MB
  adb shell dumpsys gfxinfo com.you.launcher framestats
  ```
- On Apple Silicon Macs, use an arm64 Android TV system image, since the x86 advice in the docs predates Apple Silicon. Build `armeabi-v7a`-compatible output. Many budget TVs run 32-bit userspace (note that the Prime/Hotstar TV APKs are `armv7a`), so avoid arm64-only native libs. Pure Kotlin/Compose has no native libs, so this mostly matters for Flutter. [inference]
- Use release builds with R8 + baseline profiles when judging performance. Debug Compose builds are much slower. [inference]

### Gaps
- No source confirmed whether Micromax AOSP firmware exposes network ADB or only USB.

---

## 6. Asset / IP note (fan images of characters)

### Takeaway
Personal, non-distributed use of fan or official character images on your own TV is low-risk in practice. They remain copyrighted/trademarked, so don't publish the APK or a repo containing them.

### Cited Findings
- No authoritative legal source was retrieved in this session.

### Inferences
- [inference, not legal advice] Keep character art out of public Git (gitignore `assets/characters/`, or load from device storage at runtime). Prefer your own illustrations or AI-generated *original* art if you ever share the app. Indian copyright law has narrow fair-dealing exceptions (private/personal use is one), but that's not verified here.

### Gaps
- No Indian copyright fair-dealing citation was gathered. Consult the Copyright Act 1957 s.52 if this matters.
