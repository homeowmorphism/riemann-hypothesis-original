#!/usr/bin/env bash
# Compare this checkout with the archive published at alpo.ge on 2026-11-20.
#
#   scripts/check-archive.sh               download the 14 parts and compare
#   scripts/check-archive.sh lean.tar.gz   compare with a copy you already have
#
# Set RH_ARCHIVE_URL to download the parts from somewhere other than https://alpo.ge.
set -euo pipefail

SHA256=9631b4f020199e580ba86178cb56c6e9b09f690c2369a80dc4334aa93f49c7fc
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
T="$(mktemp -d)"
trap 'rm -rf -- "$T"' EXIT

fail() { echo "DIFFERENT: $*" >&2; exit 1; }

if [[ "$#" == 1 ]]; then
  archive="$1"
else
  base="${RH_ARCHIVE_URL:-https://alpo.ge}"
  echo "Downloading 14 parts from $base ..."
  for i in $(seq -w 1 14); do
    curl -fsSL --retry 3 -o "$T/part$i" "$base/lean.tar.gz.part$i"
  done
  cat "$T"/part* > "$T/lean.tar.gz"
  archive="$T/lean.tar.gz"
fi

# The server answers 200 for any path, so the checksum is the only test of the download.
if command -v sha256sum >/dev/null; then
  sum="$(sha256sum "$archive" | cut -d' ' -f1)"
else
  sum="$(shasum -a 256 "$archive" | cut -d' ' -f1)"
fi
[[ "$sum" == "$SHA256" ]] || fail "the archive's sha256 is $sum, expected $SHA256"

mkdir "$T/x"
tar xzf "$archive" -C "$T/x"

# The archive holds one folder, lean/, with the source and three configuration files.
[[ "$(ls -A "$T/x")" == lean ]] || fail "the archive has more than the lean/ folder"
[[ "$(ls -A "$T/x/lean" | sort | tr '\n' ' ')" == "lake-manifest.json lakefile.toml lean-toolchain src " ]] ||
  fail "lean/ in the archive has unexpected entries"

# src/ differs only by the added Challenge.lean.
d="$(diff -r "$T/x/lean/src" src || true)"
[[ "$d" == "Only in src: Challenge.lean" ]] || { echo "$d" | head -20 >&2; fail "src/ differs from the archive"; }
cmp "$T/x/lean/lean-toolchain" lean-toolchain || fail "lean-toolchain differs"
cmp "$T/x/lean/lake-manifest.json" lake-manifest.json || fail "lake-manifest.json differs"

# lakefile.toml is the original, byte for byte, after a three-line prefix and before a marked block.
printf '# Cache infrastructure; the original submission starts below this block.\nplatformIndependent = true\n\n' > "$T/prefix"
head -n 3 lakefile.toml | cmp - "$T/prefix" || fail "lakefile.toml does not start with the three added lines"
tail -n +4 lakefile.toml > "$T/rest"
n=$(( $(wc -c < "$T/x/lean/lakefile.toml") ))
head -c "$n" "$T/rest" | cmp - "$T/x/lean/lakefile.toml" || fail "lakefile.toml does not contain the original"
tail -c +"$((n + 1))" "$T/rest" | head -n 1 | grep -q '^# --- Everything below this line was added' ||
  fail "lakefile.toml has unmarked text after the original"

echo "Identical: $(find "$T/x/lean" -type f | wc -l | tr -d ' ') files, archive sha256 $SHA256."
