#!/usr/bin/env bash
# usage: ./revert-phase4.sh   -> remove the new launcher + its key helpers, give Home back to the stock launcher.
# Keeps the Phase 3 debloat. Safe to run any number of times.
set -u
S="${TV_HOST:?set TV_HOST=<tv ip>}:5555"; adb connect "$S" >/dev/null
A() { adb -s "$S" shell "$@" </dev/null | tr -d '\r'; }
A am force-stop com.gathin.tvhome
A settings delete secure enabled_accessibility_services
A pm enable com.google.android.tvlauncher >/dev/null           # no-op if already enabled
A cmd package set-home-activity com.google.android.tvlauncher/.MainActivity >/dev/null
A pm uninstall com.gathin.tvhome                                # our own sideloaded app only
for p in in.startv.hotstar com.fancode.tv com.sonyliv; do A cmd appops set $p RUN_IN_BACKGROUND allow; done
A input keyevent KEYCODE_HOME
H=$(A cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1)
[ "$H" = "com.google.android.tvlauncher/.MainActivity" ] && ! A pm list packages | grep -q gathin && echo "PHASE4 REVERT OK" || { echo "REVERT INCOMPLETE: home=$H"; exit 1; }
