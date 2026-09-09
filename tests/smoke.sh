#!/usr/bin/env bash
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
export HOME
HOME=$(mktemp -d)
export PHONENODE_SRC="$here"
unset PREFIX

pn="$HOME/.phonenode/bin/pn"
base="$HOME/.phonenode"
cleanup() {
  [ -x "$pn" ] && "$pn" stop >/dev/null 2>&1
  rm -rf "$HOME"
}
trap cleanup EXIT

bash "$here/install.sh"

"$pn" add demo 'while :; do echo tick; sleep 1; done'
"$pn" start demo
sleep 2
"$pn" status | grep -E '^demo +running'
grep -q tick "$base/logs/demo.log"

kill "$(cat "$base/run/demo.child")"
sleep 8
"$pn" status | grep -E '^demo +running'
[ "$(cat "$base/run/demo.restarts")" = 1 ]

"$pn" stop demo
sleep 1
"$pn" status | grep -E '^demo +stopped'
if pgrep -f "supervise.sh demo" >/dev/null; then echo "supervisor still alive"; exit 1; fi

"$pn" add crashy 'exit 3' --delay 1
"$pn" start crashy
sleep 4
grep -q 'exited with code 3, restarting in 1s' "$base/logs/crashy.log"
grep -q 'restarting in 2s' "$base/logs/crashy.log"
"$pn" stop crashy

"$pn" add cwd 'pwd; sleep 30' --dir /tmp
"$pn" start cwd
sleep 1
grep -qx /tmp "$base/logs/cwd.log"
"$pn" remove cwd
[ ! -f "$base/services/cwd.conf" ]

"$pn" heartbeat http://127.0.0.1:9/ 1
sleep 1
"$pn" status | grep -E '^heartbeat +running'
"$pn" heartbeat off

"$pn" doctor || true
"$pn" uninstall --yes
[ ! -d "$base" ]
echo "smoke ok"
