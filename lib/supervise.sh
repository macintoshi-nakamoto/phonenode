#!/usr/bin/env bash
set -u

name=${1:?service name}
base="$HOME/.phonenode"
conf="$base/services/$name.conf"
log="$base/logs/$name.log"
run="$base/run"
[ -f "$conf" ] || exit 1

cmd=; dir="$HOME"; delay=5
. "$conf"

echo $$ >"$run/$name.pid"
child=

finish() {
  [ -n "$child" ] && kill -TERM "$child" 2>/dev/null
  rm -f "$run/$name.pid" "$run/$name.child" "$run/$name.since"
  exit 0
}
trap finish TERM INT HUP

stamp() { date '+%Y-%m-%d %H:%M:%S'; }

rotate() {
  if [ -f "$log" ] && [ "$(stat -c %s "$log" 2>/dev/null || echo 0)" -gt 5242880 ]; then
    mv -f "$log" "$log.1"
  fi
}

backoff=$delay
restarts=0
echo 0 >"$run/$name.restarts"

while [ -e "$base/enabled/$name" ]; do
  rotate
  started=$(date +%s)
  echo "$started" >"$run/$name.since"
  printf '%s phonenode: starting %s\n' "$(stamp)" "$name" >>"$log"
  (
    cd "$dir" 2>/dev/null || cd "$HOME" || exit 1
    exec bash -c "$cmd"
  ) >>"$log" 2>&1 &
  child=$!
  echo "$child" >"$run/$name.child"
  wait "$child"
  rc=$?
  child=
  [ -e "$base/enabled/$name" ] || break
  quick=0
  if [ $(( $(date +%s) - started )) -ge 60 ]; then backoff=$delay; else quick=1; fi
  restarts=$((restarts + 1))
  echo "$restarts" >"$run/$name.restarts"
  printf '%s phonenode: %s exited with code %s, restarting in %ss\n' "$(stamp)" "$name" "$rc" "$backoff" >>"$log"
  sleep "$backoff" &
  wait $!
  if [ "$quick" = 1 ]; then
    backoff=$((backoff * 2))
    [ "$backoff" -gt 300 ] && backoff=300
  fi
done

rm -f "$run/$name.pid" "$run/$name.child" "$run/$name.since"
