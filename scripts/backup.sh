#!/usr/bin/env bash
# usage: ./backup.sh <tv-ip>   -> read-only snapshot; prints backup dir
set -u
S="$1:5555"; adb connect "$S" >/dev/null
A() { adb -s "$S" shell "$@" </dev/null | tr -d '\r'; }
B=~/tv-backup/$(date +%F_%H%M)-$(A getprop ro.product.model | tr ' /' '__'); mkdir -p "$B/apks"; cd "$B" || exit 1
A getprop > getprop.txt; A cat /proc/cpuinfo > cpuinfo.txt; A cat /proc/meminfo > meminfo.txt; A wm size > wm_size.txt
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
echo "metadata done; pulling APKs..."
cut -d: -f2 pkgs_installed.txt | while read -r p; do
  mkdir -p "apks/$p"
  A pm path "$p" | cut -d: -f2 | while read -r f; do
    adb -s "$S" pull "$f" "apks/$p/" </dev/null >/dev/null 2>&1 || echo "FAIL $p $f" >> pull_errors.txt
  done
done
shasum -a 256 apks/*/*.apk > apks.sha256
cp ~/.android/adbkey ~/.android/adbkey.pub "$B/"
echo "APKs: $(ls apks | wc -l) pkgs, $(du -sh apks | cut -f1); errors: $(wc -l < pull_errors.txt 2>/dev/null || echo 0)"
echo "$B"
