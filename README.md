# Micromax (TCL) Android TV: safe debloat, clean launcher, Hogwarts UI

A worked, rollback-first log of cleaning up a **Micromax 4K Android TV** (TCL-built: `tcl_eu`, MediaTek MT5891,
Android TV 8.0, firmware `V8-T658TAP-LF1V372`) without root, then replacing its home screen.

Built on [CleanYourTV](https://github.com/Gathin23/cleanyourtv): its launcher and tools do the heavy lifting.

## TV specs (read over ADB)
Read with `getprop`, `/proc/cpuinfo`, `/proc/meminfo`, `df`, `wm`, `dumpsys` (SurfaceFlinger, tv_input, display)
and the TV's own update request. Device-unique values (serial, MAC, IP) are left out.

| | |
|---|---|
| Brand / model | MICROMAX / "MICROMAX TV" (likely the 2018 `xxTA7000UHD` 4K Android TV line) |
| Built by | **TCL Multimedia** (ODM build `tcl_eu`, `ro.build.company=TCL Multimedia`) |
| Fingerprint | `MICROMAX/tcl_eu/tcl_eu:8.0.0/OTT1.180130.001/hefang08142127:user/release-keys` |
| OS | **Android TV 8.0 Oreo**, SDK 26, Google-certified (Play Store, Play Services, Chromecast built-in, Assistant) |
| Security patch | 2018-06-05 |
| Kernel | 3.10.79, built 2018-10-20 |
| Firmware | `V8-T658TAP-LF1V372` (TCL T658 platform, Asia-Pacific variant) |
| TCL client type / project ID | `SCBC-AP-MT5658-0000A` / `207` (from the TV's update request) |
| SoC | **MediaTek MT5891** (`ro.board.platform=mt5891`; TCL MT5658 family) |
| CPU | 4× ARM **Cortex-A53** (part 0xd03), running 32-bit ARMv7 with NEON and VFPv4 |
| GPU | **ARM Mali-T860**, OpenGL ES 3.2, driver r19p0 |
| RAM | 2 GB (1.93 GB visible to Android), 192 MB per-app heap limit, 100 MB swap |
| Storage | ~16 GB eMMC: `/data` 10 GB, `/system` 1.9 GB (87% used, read-only), `/cache` 114 MB |
| Panel | **3840×2160 (4K)** (`sys.display-size`) |
| UI | 1920×1080 at 320 dpi, 50 Hz |
| HDR / DRM | HDR10 in Netflix (`ro.nrdp.hdr10.revision=1`); Widevine HAL running |
| Inputs | 4 HDMI registrations (3 sockets on the side panel), AV composite, component, VGA, DVB tuner (TCL TV input + passthrough services) |
| Connectivity | MediaTek dual-band Wi-Fi (5 GHz works), MediaTek Bluetooth, Ethernet, USB-A (host only) |
| HDMI-CEC | "HDMI Link"; sees a PS5 as logical address 4 on port 1 |
| ADB | `ro.adb.secure=1` (RSA prompt), `service.adb.tcp.port=5555` preset by the vendor, so network ADB survives reboots |
| Recovery | Boots to the "Error!" robot with no menu and auto-reboots: there is no remote-driven factory reset |
| Stock launcher | `com.google.android.tvlauncher` 7.7.15 (no Disable button in Settings); Settings has `FallbackHome` |
| Notable vendor packages | `com.tcl.tv`, `com.tcl.tvinput`, `com.tcl.tvpassthrough`, `com.tcl.sourcemananger`, `com.tcl.settings`, `com.mediatek.*`, `mtktvapi.agent` (all kept) |

## What's here
| Path | What |
|---|---|
| `docs/research-report.md` | Deep-research report: platform, debloat safety, launchers, recovery ladder |
| `docs/execution-plan.md` | The phased plan with gates and the live status of what was done |
| `docs/research/` | Source notes (platform/ADB, CleanYourTV, backup & recovery, launcher build, firmware, TCL updater) |
| `config/debloat-micromax-tcl_eu.txt` | The 11 packages disabled (all `pm disable-user --user 0`, never uninstalled) |
| `config/launcher-theme.json` | CleanYourTV theme overlay (dock order) |
| `scripts/` | `backup.sh`, `revert.sh`, `step.sh` (one package per reboot, never-touch guard), `revert-phase4.sh`, `ps5.sh` |

## Use
```bash
export TV_HOST=<tv ip>
./scripts/backup.sh $TV_HOST                         # read-only snapshot, prints a folder
BACKUP_DIR=<that folder> ./scripts/step.sh <package>  # disable one package, reboot, verify
./scripts/revert.sh $TV_HOST <that folder>            # back to the snapshot
```
On macOS, if `adb` says "No route to host", start the adb server from Terminal.app (Local Network privacy).

## Safety rules followed
- Disable only, never uninstall; one package per reboot; core/TV/vendor packages are on a refuse list.
- ADB must survive a cold boot before anything changes. On this firmware the stock launcher has no
  Disable/Enable button in Settings, so ADB is the way back.
- A matching signed USB firmware was located and checksum-verified as a last resort (not included here).
- Never use the factory menu's NVM reset (erases Wi-Fi MAC, Widevine and Netflix keys).

## Not included, on purpose
Backups, ADB keys, firmware files, device serials, MAC/IP addresses, and any Harry Potter artwork
(Warner Bros. property; supply your own for personal use).
