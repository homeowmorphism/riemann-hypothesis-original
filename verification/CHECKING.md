# Checking the proof independently

This procedure compiles the submitted source, exports its declarations, and judges them
against the statements in `Challenge.lean`. It uses Mathlib's official cache, but no compiled
files from the submission's cache. A successful build alone is not a Comparator verdict.

Use a Linux machine with Git, curl, [elan](https://github.com/leanprover/elan#installation),
rootless [Podman](https://podman.io/docs/installation), and bubblewrap (`bwrap` on `PATH`).
Bubblewrap needs working unprivileged user namespaces or a setuid installation. Run the
commands below in one Bash session. Download dependencies while online; the build and export
containers have no network.

Allow hours on a large machine and hundreds of GB of RAM for the full process. A reported
solution export occupies 61.6 GB and required 163 GB of memory to produce. Build intermediates
can approach **1 TB** unless completed modules' `.setup.json` files are removed. Provision
enough disk, or arrange the cleanup loop in the [building notes](NOTES.md#building) inside the
build sandbox. These are reported measurements, not minimum requirements.

## 1. Prepare separate work directories

Start in a directory with sufficient free space. The clean clone supplies the challenge and
judge configuration; the solution clone is the only project directory the build can change.

```bash
set -euo pipefail
export LEAN_ABORT_ON_PANIC=1
export LAKE_ARTIFACT_CACHE=false
export MATHLIB_CACHE_GET_URL=https://cache.mathlib.org/mathlib4

RH_CHECK_ROOT="$PWD/rh-check"
mkdir "$RH_CHECK_ROOT"
git clone https://github.com/homeowmorphism/riemann-hypothesis-original "$RH_CHECK_ROOT/clean"
git clone https://github.com/homeowmorphism/riemann-hypothesis-original "$RH_CHECK_ROOT/solution"
git -C "$RH_CHECK_ROOT/solution" checkout "$(git -C "$RH_CHECK_ROOT/clean" rev-parse HEAD)"

elan toolchain install leanprover/lean4:v4.33.1
elan toolchain install leanprover/lean4:v4.36.0
RH_LEAN=$(elan run leanprover/lean4:v4.33.1 lean --print-prefix)

git clone --depth 1 --branch v4.33.0 https://github.com/leanprover/lean4export "$RH_CHECK_ROOT/lean4export"
cp "$RH_CHECK_ROOT/clean/lean-toolchain" "$RH_CHECK_ROOT/lean4export/lean-toolchain"
(cd "$RH_CHECK_ROOT/lean4export" && lake build lean4export)
RH_EXPORTER="$RH_CHECK_ROOT/lean4export/.lake/build/bin/lean4export"
```

The exporter must be built with the project's Lean **v4.33.1**, even though its tag is
`v4.33.0`: Lean refuses compiled files from a different Lean build. Judging uses **v4.36.0**.
Keep the published toolchain and dependency pins; do not run `lake update`.

## 2. Export the challenge and fetch Mathlib

Do this before building the submission. The challenge imports only Mathlib; its `sorry`
warnings are expected because it contains theorem statements with placeholder proofs.

```bash
cd "$RH_CHECK_ROOT/clean"
lake exe mathlib/cache get
lake build Challenge
lake env "$RH_EXPORTER" Challenge -- $(cat export-targets.txt) > "$RH_CHECK_ROOT/challenge.export"
echo "bd484ac9886a96f26b1d9a7a59ebd45b7a70d102c015d4f31f9302bbdd6ab2b9  $RH_CHECK_ROOT/challenge.export" | sha256sum -c

cd "$RH_CHECK_ROOT/solution"
lake exe mathlib/cache get
```

The checksum is also checked by CI, which publishes a `challenge-export` artifact. Use
`lake exe mathlib/cache get` here: `lake exe cache get` would also restore the submission's
compiled files. Disabling the artifact cache does not remove files already restored, which
is why this procedure starts with fresh clones.

## 3. Build and export in a sandbox

Prepare the container image while online. The following commands create the sandbox;
they do not depend on an existing image from the verification run.

```bash
podman build -t rhcheck-sandbox:local - <<'EOF'
FROM docker.io/library/debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates procps \
    && rm -rf /var/lib/apt/lists/*
EOF

RH_SANDBOX=(podman run --rm --network none --read-only --tmpfs /tmp:rw
  --userns=keep-id --security-opt no-new-privileges --cap-drop all
  -v "$RH_LEAN:$RH_LEAN:ro"
  -e HOME=/tmp/home -e "PATH=$RH_LEAN/bin:/usr/bin:/bin"
  -e LEAN_ABORT_ON_PANIC=1 -e LAKE_ARTIFACT_CACHE=false
  -w /work)

"${RH_SANDBOX[@]}" -v "$RH_CHECK_ROOT/solution:/work:rw" \
  rhcheck-sandbox:local bash -c 'mkdir -p "$HOME"; lake build Main'

"${RH_SANDBOX[@]}" -v "$RH_CHECK_ROOT/solution:/work:ro" \
  -v "$RH_EXPORTER:/tools/lean4export:ro" \
  -v "$RH_CHECK_ROOT/clean/export-targets.txt:/tools/export-targets.txt:ro" \
  rhcheck-sandbox:local bash -c \
  'mkdir -p "$HOME"; lake env /tools/lean4export Main -- $(cat /tools/export-targets.txt)' \
  > "$RH_CHECK_ROOT/solution.export"
```

`Main` imports every module in the published submission. The build can write only to its
solution clone and temporary storage. The exporter and Lean toolchain are mounted read-only;
the export step also mounts the solution clone read-only. Only `solution.export` is passed
to the judge. Keep subsequent inspection or execution of files from the solution clone inside
the sandbox. The [sandbox notes](NOTES.md#sandbox) explain these boundaries.

## 4. Judge the exports

Run Comparator outside the build directory, using the clean clone's configuration and the
explicit judge toolchain. Comparator creates its own bubblewrap sandbox.

```bash
mkdir "$RH_CHECK_ROOT/judge"
cd "$RH_CHECK_ROOT/judge"
elan run leanprover/lean4:v4.36.0 lake comparator \
  --config "$RH_CHECK_ROOT/clean/comparator.json" \
  --challenge-from-export "$RH_CHECK_ROOT/challenge.export" \
  --solution-from-export "$RH_CHECK_ROOT/solution.export"
```

An accepted result exits with status 0 and prints `Your solution is okay!`. The configuration
requires Lean's kernel, Lean paranoid, and nanoda. Do not add `--paranoid`: that also enables
checkers with known incompatibilities described in the [checker notes](NOTES.md#checkers).
Read the [limits](NOTES.md#limits) before interpreting a passing result.
