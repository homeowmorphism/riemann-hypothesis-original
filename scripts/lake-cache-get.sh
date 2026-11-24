#!/usr/bin/env bash
# Fetch Mathlib's compiled files and this project's, and unpack both.
# The project's files are one fixed set, pinned in scripts/restore-cache.py.
set -euo pipefail

if [[ "$#" != 1 || "$1" != get ]]; then
  echo 'Usage: lake exe cache get' >&2
  exit 2
fi

RH_CACHE_ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RH_CACHE_ROOT"

# scripts/restore-cache.py needs Python 3.11 for hashlib.file_digest. Say so before downloading anything.
if ! python3 -c 'import sys; sys.exit(sys.version_info < (3, 11))'; then
  RH_CACHE_PYTHON="$(command -v python3 >/dev/null && python3 --version 2>&1 || echo none)"
  echo "lake exe cache get needs Python 3.11 or newer as python3; found: $RH_CACHE_PYTHON" >&2
  exit 1
fi

# Mathlib's parallel unpacker and our 500 parallel downloads exceed the usual 1024-file soft limit.
# Best effort: macOS may refuse values above kern.maxfilesperproc even when the hard limit is unlimited.
RH_CACHE_FD_HARD="$(ulimit -Hn)"
RH_CACHE_FD_WANT=65536
if [[ "$RH_CACHE_FD_HARD" != unlimited && "$RH_CACHE_FD_HARD" -lt "$RH_CACHE_FD_WANT" ]]; then
  RH_CACHE_FD_WANT="$RH_CACHE_FD_HARD"
fi
if ! ulimit -Sn "$RH_CACHE_FD_WANT" 2>/dev/null; then
  RH_CACHE_FD_MAX="$(sysctl -n kern.maxfilesperproc 2>/dev/null || true)"
  if ! { [[ -n "$RH_CACHE_FD_MAX" ]] && ulimit -Sn "$RH_CACHE_FD_MAX" 2>/dev/null; }; then
    echo "warning: could not raise the open-file limit above $(ulimit -Sn); downloads may fail" >&2
  fi
fi

# Qualify Mathlib's executable because this package also supplies a cache target.
printf 'Fetching Mathlib cache...\n'
MATHLIB_CACHE_GET_URL="${MATHLIB_CACHE_GET_URL:-https://cache.mathlib.org/mathlib4}" \
  lake exe mathlib/cache get

# Cache URLs live in lakefile.toml; users need no separate configuration file.
export LAKE_CACHE_DIR="$RH_CACHE_ROOT/.lake/cache"
source scripts/cache-env.sh

# Download the archives in the pinned list, 500 at a time, and check each one's SHA-256.
# Archives already in the cache are checked too, so a rerun repairs an interrupted download.
printf 'Fetching project cache (4.94 GB)...\n'
python3 scripts/fetch-pinned-artifacts.py

# The files were published under the upstream repository's name and this commit id.
# That commit is an ancestor of every commit here and has the same src/ tree.
# Lake finds every archive already in the cache, so it only records which one each module uses.
printf 'Registering the archives with Lake (takes a few minutes)...\n'
lake -q cache get --repo leanprover-community/riemann-hypothesis \
  --rev e50d09817ad81469f737e8f637561e6ccf86c670
python3 scripts/restore-cache.py
