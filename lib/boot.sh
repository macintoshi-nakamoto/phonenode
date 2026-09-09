#!/usr/bin/env bash
base="$HOME/.phonenode"
mkdir -p "$base/run"
[ "${1:-}" = manual ] || date +%s >"$base/run/booted"
if command -v termux-wake-lock >/dev/null 2>&1; then
  timeout 10 termux-wake-lock >/dev/null 2>&1 && date +%s >"$base/run/wakelock"
fi
if command -v sshd >/dev/null 2>&1 && ! pgrep -x sshd >/dev/null 2>&1; then
  sshd >/dev/null 2>&1
fi
for f in "$base"/enabled/*; do
  [ -e "$f" ] || continue
  "$base/bin/pn" start "$(basename "$f")" >/dev/null 2>&1
done
