#!/usr/bin/env bash
# Wake the PS5 via HDMI-CEC by switching the TV to HDMI1 (requires HDMI Link on; adb server running in Terminal.app)
S="${TV_HOST:?set TV_HOST=<tv ip>}:5555"; adb connect $S >/dev/null
adb -s $S shell settings put global hdmi_control_enabled 1
adb -s $S shell am start -a android.intent.action.VIEW -d "content://android.media.tv/passthrough/com.tcl.tvpassthrough%2F.TvPassThroughService%2FHW1413744128" >/dev/null && echo "switched to HDMI1 (PS5)"
