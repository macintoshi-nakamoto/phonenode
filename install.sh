#!/usr/bin/env bash
set -eu

src="${PHONENODE_SRC:-}"
raw="${PHONENODE_RAW:-https://raw.githubusercontent.com/macintoshi-nakamoto/phonenode/main}"
base="$HOME/.phonenode"

termux=0
case "${PREFIX:-}" in */com.termux/*) termux=1 ;; esac
if [ "$termux" = 1 ]; then
  bindir="$PREFIX/bin"
  shell="$PREFIX/bin/bash"
else
  bindir="$HOME/.local/bin"
  shell=$(command -v bash)
fi

say() { printf '%s\n' "$*"; }

get() {
  if [ -n "$src" ]; then
    cp "$src/$1" "$2"
  else
    curl -fsSL "$raw/$1" -o "$2"
  fi
}

if [ "$termux" = 1 ]; then
  say "installing termux-api, openssh and procps"
  pkg install -y termux-api openssh procps >/dev/null 2>&1 || pkg install -y termux-api openssh procps
fi

mkdir -p "$base/bin" "$base/lib" "$base/services" "$base/enabled" "$base/logs" "$base/run" "$bindir"

for f in bin/pn lib/supervise.sh lib/boot.sh; do
  get "$f" "$base/$f.new"
  sed -i "1s|^#!.*|#!$shell|" "$base/$f.new"
  chmod 0755 "$base/$f.new"
  mv -f "$base/$f.new" "$base/$f"
done
ln -sf "$base/bin/pn" "$bindir/pn"

if [ "$termux" = 1 ]; then
  mkdir -p "$HOME/.termux/boot"
  cp "$base/lib/boot.sh" "$HOME/.termux/boot/phonenode.sh.new"
  chmod 0755 "$HOME/.termux/boot/phonenode.sh.new"
  mv -f "$HOME/.termux/boot/phonenode.sh.new" "$HOME/.termux/boot/phonenode.sh"
  line="[ -x \"\$HOME/.termux/boot/phonenode.sh\" ] && \"\$HOME/.termux/boot/phonenode.sh\" manual >/dev/null 2>&1"
  grep -qF 'phonenode.sh' "$HOME/.bashrc" 2>/dev/null || printf '\n%s\n' "$line" >>"$HOME/.bashrc"
  "$HOME/.termux/boot/phonenode.sh" manual || true
fi

say "phonenode $("$base/bin/pn" version) installed as $bindir/pn"
case ":$PATH:" in
  *":$bindir:"*) ;;
  *) say "$bindir is not in your PATH yet, add it or call $base/bin/pn" ;;
esac
say ""
"$base/bin/pn" doctor || true
say ""
say "next:  pn add <name> '<command>'   then   pn start <name>"
