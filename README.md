# riemann-hypothesis-original

[![checks](https://github.com/homeowmorphism/riemann-hypothesis-original/actions/workflows/checks.yml/badge.svg)](https://github.com/homeowmorphism/riemann-hypothesis-original/actions/workflows/checks.yml)

The Lean formalization that claims a proof of the Riemann Hypothesis, and of GRH for Dirichlet
L-functions, exactly as Levent Alpöge published it on 2026-11-20 at <https://alpo.ge/remark.pdf>.

**This repository is frozen.** It holds the published source and the few files needed to check
it. The source here will not change. Work that shortens or cleans up the proof happens in
[leanprover-community/riemann-hypothesis](https://github.com/leanprover-community/riemann-hypothesis).
The history here starts with that repository's first 19 commits, made before anyone edited the
source.

## What is here

| Path | What it is |
|---|---|
| [`src/`](src/) | the published source, unchanged: 175,187 `.lean` files |
| `lean-toolchain`, `lake-manifest.json` | the published configuration, unchanged |
| [`lakefile.toml`](lakefile.toml) | the published file, with marked additions for `Challenge` and the cache |
| [`src/Challenge.lean`](src/Challenge.lean) | the five claimed theorems, stated in a file that imports only Mathlib |
| [`comparator.json`](comparator.json), [`export-targets.txt`](export-targets.txt) | settings for [Comparator](https://github.com/leanprover/comparator), the tool that judges a proof against its statement |
| [`scripts/`](scripts/) | the download of compiled files, and two checks of this repository |
| [`verification/`](verification/NOTES.md) | notes on the source, the tools and the compiled files |

## What is frozen

These never change: `src/`, `lean-toolchain`, `lake-manifest.json`, `lakefile.toml`,
`comparator.json` and `export-targets.txt`.
[`scripts/check-frozen.sh`](scripts/check-frozen.sh) compares each of them with the Git object
it had when this repository was frozen. CI runs that script on every push and pull request.

All six are identical to their copies at commit
[`ab0b7522`](https://github.com/leanprover-community/riemann-hypothesis/tree/ab0b7522a5ccc9b8530edf475af5088f8f6464aa)
of leanprover-community/riemann-hypothesis. That is the last commit on its `main` branch before
anyone edited the source. To confirm, run `git ls-tree HEAD` in this repository and
`git ls-tree ab0b7522` in that one: each of the six has the same object id in both.

The README, the notes, the scripts and the CI workflow can still change, for example when a
download address moves.

Pull requests that edit a frozen file belong in
[leanprover-community/riemann-hypothesis](https://github.com/leanprover-community/riemann-hypothesis).

## Checking that this is the published source

```bash
git clone https://github.com/homeowmorphism/riemann-hypothesis-original
cd riemann-hypothesis-original
scripts/check-frozen.sh    # the frozen files are the ones this repository was frozen with
scripts/check-archive.sh   # downloads the archive from alpo.ge and compares every file
```

The second script downloads `https://alpo.ge/lean.tar.gz.part01` to `part14`, 239 MB in all. It
joins them and checks that the sha256 is
`9631b4f020199e580ba86178cb56c6e9b09f690c2369a80dc4334aa93f49c7fc`. It then unpacks the archive
and compares every file with this checkout. CI runs both scripts.

The first commit, `40e56bab`, is the archive unpacked with nothing changed, and the tag
`as-published` points at it. It is also the first commit of
leanprover-community/riemann-hypothesis, so `git rev-list --max-parents=0 HEAD` prints the same
id in both repositories.

## Getting the compiled files

Compiling the source takes hours on a large machine. To read and explore the proof without
compiling it, download a published set of compiled files:

```bash
lake exe cache get
lake build --no-build
```

The first command downloads 4.94 GB and unpacks it. The second asks Lake whether anything still
needs compiling, and should end with `All targets up-to-date`. You need Python 3.11 or newer and
about 105 GB of free disk.

Other people's machines compiled these files. The download checks that you received the files
that were published, not that the proof is correct. The [cache notes](verification/CACHE.md) say
where the files come from and what is pinned.

## What is claimed

| Theorem in `Main.lean` | Statement |
|---|---|
| `riemannHypothesis` | Mathlib's `RiemannHypothesis` |
| `riemannZeta_eq_zero_re` | the same, written out |
| `LFunction_ne_zero_of_half_lt_re` | L(χ, s) ≠ 0 for Re s > 1/2, for every modulus and every Dirichlet character, except the trivial character at s = 1 |
| `LFunction_eq_zero_re` | every zero of L(χ, s) with 0 < Re s < 1 has Re s = 1/2 |
| `LFunction_eq_zero_re_of_isPrimitive` | the same, for primitive characters |

## Checking it

These steps compile the source on your own machine and judge the result with Comparator. They
do not use the compiled files from the section above.

```bash
export LEAN_ABORT_ON_PANIC=1   # as Comparator sets it: stop on an internal error, don't continue
export LAKE_ARTIFACT_CACHE=false   # rebuild the submission even if cache-env.sh was sourced earlier
export MATHLIB_CACHE_GET_URL=https://cache.mathlib.org/mathlib4   # Mathlib's current cache server

# 1. Export the challenge. Clean clone at $CLEAN, Lean v4.33.1.
cd "$CLEAN"
lake exe mathlib/cache get
lake build Challenge
lake env lean4export Challenge -- $(cat export-targets.txt) > challenge.export

# 2. Build the solution. Second clone, inside a sandbox with no network. Takes hours.
lake exe mathlib/cache get      # before entering the sandbox
lake build Main         # inside the sandbox

# 3. Export the solution. Still inside the sandbox; only solution.export comes out.
lake env lean4export Main -- $(cat "$CLEAN/export-targets.txt") > solution.export

# 4. Judge. Lean v4.36.0, from an empty directory, with the config from the clean clone.
lake comparator --config "$CLEAN/comparator.json" \
  --challenge-from-export "$CLEAN/challenge.export" --solution-from-export solution.export
```

What to know before running it:

- **Two Lean versions.** The project is pinned to Lean `v4.33.1`, and `lake comparator` exists
  only from Lean 4.35. So the proof is built and exported with `v4.33.1` and judged with
  `v4.36.0`. The exporter is [lean4export](https://github.com/leanprover/lean4export) at tag
  `v4.33.0`, built with Lean `v4.33.1`.
- **Challenge first.** Compiling the submission runs its code, so the challenge is exported
  where none of that code has been compiled. CI does step 1 on every push and publishes the
  result as the `challenge-export` artifact. Its sha256 is
  `bd484ac9886a96f26b1d9a7a59ebd45b7a70d102c015d4f31f9302bbdd6ab2b9`.
- **Not `lake exe cache get`.** In this repository that command also downloads compiled files
  for the submission itself, and `lake build Main` then compiles nothing. Steps 1 and 2 use
  `lake exe mathlib/cache get`, which fetches Mathlib only.
- **Cost.** Hours on a large machine, about 100 GB of disk, and a lot of memory for step 4.

The [notes](verification/NOTES.md) have the details: the Lean version and its known kernel
fixes, the tools, the sandboxes, a test of these steps on a smaller example, and the limits of
what a passing run shows.

## Who made what

- [Levent Alpöge](https://alpo.ge) published the source.
- [Jack McCarthy](https://github.com/Deicyde) made the mirror commit, `Challenge.lean`, the
  Comparator settings and the notes. Those commits are kept here as they were, together with
  one by [Marcelo Lynch](https://github.com/marcelolynch).
- [Kim Morrison](https://github.com/kim-em) built the cache of compiled files and wrote the
  download client.
- [James Chang](https://github.com/jamesyc) proposed a frozen repository beside the working
  one, in [issue #56](https://github.com/leanprover-community/riemann-hypothesis/issues/56).

## License

The submission belongs to its author and was published without a license. It is mirrored here
unmodified, for verification only. The files added around it come from
leanprover-community/riemann-hypothesis, which has no license file either.
