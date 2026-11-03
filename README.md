# Micromax (TCL) Android TV: safe debloat, clean launcher, Hogwarts UI

A worked, rollback-first log of cleaning up a **Micromax 4K Android TV** (TCL-built: `tcl_eu`, MediaTek MT5891,
Android TV 8.0, firmware `V8-T658TAP-LF1V372`) without root, then replacing its home screen.

Built on [CleanYourTV](https://github.com/Gathin23/cleanyourtv): its launcher and tools do the heavy lifting.

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
