#!/usr/bin/env bash
set -u

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found. Install Android platform-tools and put adb in PATH." >&2
  exit 1
fi

adb=(adb)
[ $# -gt 0 ] && adb=(adb -s "$1")

state=$("${adb[@]}" get-state 2>/dev/null | tr -d '\r' || true)
if [ "$state" != device ]; then
  echo "no device. On the phone: Settings > About > tap Build number 7 times, then Developer options > USB debugging. Plug it in, accept the prompt, run again." >&2
  "${adb[@]}" devices
  exit 1
fi

run() {
  printf '  %s\n' "$*"
  "${adb[@]}" shell "$@" 2>&1 | tr -d '\r' | sed 's/^/      /'
}

installed=$("${adb[@]}" shell pm list packages 2>/dev/null | tr -d '\r')
for p in com.termux com.termux.boot com.termux.api; do
  if printf '%s\n' "$installed" | grep -qx "package:$p"; then
    echo "$p"
    run dumpsys deviceidle whitelist "+$p"
    run cmd appops set "$p" RUN_IN_BACKGROUND allow
    run cmd appops set "$p" RUN_ANY_IN_BACKGROUND allow
  else
    echo "$p is not installed, skipping it"
  fi
done

if printf '%s\n' "$installed" | grep -qx "package:com.termux.boot"; then
  echo "opening Termux:Boot once, Android refuses to run it at boot until that happened"
  run monkey -p com.termux.boot -c android.intent.category.LAUNCHER 1
fi

echo "keeping Wi-Fi on while the screen is off"
run settings put global wifi_sleep_policy 2

echo
echo "done. Vendors keep their own kill lists on top of this, run pn doctor on the phone for the ones that apply to it."
