#!/usr/bin/env bash
# usage: ./revert.sh <tv-ip> <backup-dir>   -> restore package states + Home to that backup
set -u
S="$1:5555"; B="$2"; adb connect "$S" >/dev/null
A()  { adb -s "$S" shell "$@" </dev/null | tr -d '\r'; }
pk() { cut -d: -f2 | tr -d '\r' | sort; }
HOME_C=$(tail -1 "$B/home.txt")
comm -13 <(pk < "$B/pkgs_d.txt") <(A pm list packages -d | pk) | while read -r p; do echo "enable $p"; A pm enable "$p"; done
comm -23 <(pk < "$B/pkgs_installed.txt") <(A pm list packages | pk) | while read -r p; do echo "install-existing $p"; A cmd package install-existing "$p"; done
case "$HOME_C" in android/*) ;; *) A cmd package set-home-activity "$HOME_C" >/dev/null ;; esac
A input keyevent KEYCODE_HOME
diff <(pk < "$B/pkgs_d.txt") <(A pm list packages -d | pk) \
 && [ "$(A cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1)" = "$HOME_C" ] \
 && echo "REVERT OK" || { echo "REVERT INCOMPLETE"; exit 1; }
