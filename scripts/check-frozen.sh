#!/usr/bin/env bash
# Check that the frozen files of this repository are still the ones it was frozen with.
# Needs the full Git history, which a normal clone has. Uses no network.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

# The first commit: the archive from alpo.ge, exactly as published.
FIRST=40e56bab026552e089d7afcfeff08d2defb9c005
FROZEN=(src lean-toolchain lake-manifest.json lakefile.toml comparator.json export-targets.txt)

fail() { echo "NOT FROZEN: $*" >&2; exit 1; }

# 1. History starts at the mirror commit.
[[ "$(git rev-list --max-parents=0 HEAD)" == "$FIRST" ]] ||
  fail "history does not start at $FIRST (in a shallow clone, run: git fetch --unshallow)"

# 2. Under src/, the only difference from that commit is the added Challenge.lean.
[[ "$(git diff --name-status "$FIRST" HEAD -- src)" == $'A\tsrc/Challenge.lean' ]] ||
  fail "src/ differs from the first commit by more than the added Challenge.lean"

# 3. Each frozen path is the Git object it was frozen as.
while read -r object frozen_path; do
  [[ "$(git rev-parse "HEAD:$frozen_path")" == "$object" ]] || fail "$frozen_path has changed"
done <<'EOF'
24df20b62d9976ccd20da819bc20b16f808f0fdd src
a8afa7d1b02d96f0671eba854a8dc4b416beb473 lean-toolchain
b4d1ec31575a26b2159ec3a262b482bc051f3f6f lake-manifest.json
975bd703cae6b766d2aba2b89738a644be30efcc lakefile.toml
e989bcf90ff0c487a7146319a026e661a5bad47c comparator.json
e2d4c02bac8a1411eae85af0376c1aad3b6b5294 export-targets.txt
EOF

# 4. The checkout has no local edits to them.
git diff --quiet HEAD -- "${FROZEN[@]}" || fail "the checkout has uncommitted changes to frozen files"
[[ -z "$(git ls-files --others --exclude-standard -- src)" ]] || fail "there are untracked files under src/"

echo "Frozen files are unchanged."
