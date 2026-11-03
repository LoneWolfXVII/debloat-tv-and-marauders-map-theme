#!/usr/bin/env bash
# usage: ./step.sh <pkg>   -> log, disable-user, verify, wait 15s, reboot, reconnect, verify again
set -u
S="${TV_HOST:?set TV_HOST=<tv ip>}:5555"; B="${BACKUP_DIR:?set BACKUP_DIR=<backup folder from backup.sh>}"; P="$1"
a() { adb -s "$S" shell "$@" </dev/null | tr -d '\r'; }
case "$P" in com.tcl.tv*|com.tcl.sourcemananger|com.tcl.settings|com.tcl.autopair|com.tcl.inputmethod*|com.tcl.factory*|com.mediatek.*|mtktvapi.*|com.google.android.gms|com.google.android.gsf*|com.android.vending|com.google.android.tvlauncher|*setupwraith|*webview|*mediashell|com.android.*|android|com.tcl.versionUpdateApp|com.tcl.xian.StartandroidService)
  echo "REFUSED: $P is on the never-touch list"; exit 2;; esac
grep -qx "package:$P" <(a pm list packages) || { echo "not installed: $P"; exit 3; }
echo "$(date '+%F %T')|$P|disable-user|pm enable $P" >> "$B/changes.log"
a pm disable-user --user 0 "$P"
a pm list packages -d | grep -qx "package:$P" && echo "VERIFIED disabled" || { echo "DISABLE FAILED"; exit 1; }
sleep 15; adb -s $S reboot; sleep 25
for i in $(seq 1 20); do case "$(adb connect $S 2>&1)" in *connected*) break;; esac; sleep 6; done
for i in $(seq 1 20); do [ "$(a getprop sys.boot_completed)" = 1 ] && break; sleep 3; done
echo "boot_completed=$(a getprop sys.boot_completed)"
a pm list packages -d | grep -qx "package:$P" && echo "still disabled after reboot" || echo "WARNING: state changed after reboot"
echo "HOME: $(a cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1)"
a cat /proc/meminfo | grep MemFree
