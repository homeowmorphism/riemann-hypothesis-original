# riemann-hypothesis-original

[![checks](https://github.com/homeowmorphism/riemann-hypothesis-original/actions/workflows/checks.yml/badge.svg)](https://github.com/homeowmorphism/riemann-hypothesis-original/actions/workflows/checks.yml)

The Lean formalization that claims a proof of the Riemann Hypothesis and of GRH for Dirichlet
L-functions, as Levent Alpöge published it on 2026-11-20 at <https://alpo.ge/remark.pdf>.
The published source is frozen here. Cleanup and further development happen in
[leanprover-community/riemann-hypothesis](https://github.com/leanprover-community/riemann-hypothesis).

## Getting started (cached build)

Use the published build cache to start exploring the proof without compiling it yourself.
Install [Lean via elan](https://lean-lang.org/install/), Git, curl, and Python 3.11 or newer
available as `python3`. Use a Bash terminal (WSL on Windows) and allow about 105 GB of free disk.

```bash
git clone https://github.com/homeowmorphism/riemann-hypothesis-original
cd riemann-hypothesis-original
lake exe cache get
lake build --no-build
```

Elan automatically selects Lean `v4.33.1` from `lean-toolchain`. The cache command restores
Mathlib and this project's compiled files under `.lake/`; the project download is 4.94 GB.
No cache configuration or `lake update` is needed. The final command checks that the default
targets are ready without compiling them; expect `All targets up-to-date`.

To browse the proof, open this folder in VS Code with the Lean 4 extension and start at
[`src/Main.lean`](src/Main.lean). The [cache notes](verification/CACHE.md) explain the download
and its checks. Downloaded build files do not independently verify the proof.

## Building from source

Start with a fresh clone so that no project build files are reused. This takes hours on a large
machine; read the [disk and memory requirements](verification/NOTES.md#building) first.
Temporary build files can approach 1 TB unless cleaned up as described there.

```bash
git clone https://github.com/homeowmorphism/riemann-hypothesis-original riemann-hypothesis-build
cd riemann-hypothesis-build
export LEAN_ABORT_ON_PANIC=1
export LAKE_ARTIFACT_CACHE=false
export MATHLIB_CACHE_GET_URL=https://cache.mathlib.org/mathlib4
lake exe mathlib/cache get
lake build Main
```

`mathlib/cache get` fetches only Mathlib's compiled dependencies. `lake build Main` compiles
the submitted proof and all its imports. Plain `lake build` builds all default targets;
`lake build Challenge` checks only the separately added theorem statements against Mathlib.
For independent verification, follow [Checking it](#checking-it) before starting the build.

## What is here

| Path | What it is |
|---|---|
| [`src/`](src/) | the 175,187 published `.lean` files, plus `Challenge.lean` |
| [`src/Main.lean`](src/Main.lean) | the five claimed theorems listed below |
| [`src/Challenge.lean`](src/Challenge.lean) | the same statements, importing only Mathlib |
| [`lean-toolchain`](lean-toolchain), [`lake-manifest.json`](lake-manifest.json) | the published Lean version and dependency pins |
| [`lakefile.toml`](lakefile.toml) | the build configuration, with marked additions for `Challenge` and the cache |
| [`comparator.json`](comparator.json), [`export-targets.txt`](export-targets.txt) | independent verification settings |
| [`scripts/`](scripts/), [`verification/`](verification/NOTES.md) | cache and source checks, verification instructions and notes |

## What is claimed

| Theorem in `Main.lean` | Statement |
|---|---|
| `riemannHypothesis` | Mathlib's `RiemannHypothesis` |
| `riemannZeta_eq_zero_re` | the same, written out |
| `LFunction_ne_zero_of_half_lt_re` | L(χ, s) ≠ 0 for Re s > 1/2, for every modulus and every Dirichlet character, except the trivial character at s = 1 |
| `LFunction_eq_zero_re` | every zero of L(χ, s) with 0 < Re s < 1 has Re s = 1/2 |
| `LFunction_eq_zero_re_of_isPrimitive` | the same, for primitive characters |

## Checking it

A fresh source build checks the proof with the pinned Lean version. For independent checking,
follow the [verification guide](verification/CHECKING.md): export the challenge in a clean
clone, build and export the solution in a sandbox, then judge both with Comparator under Lean
`v4.36.0`.

CI checks the frozen files, compares the published archive, and builds and exports `Challenge`.
It does not build or judge the full proof. Its `challenge-export` artifact has SHA-256
`bd484ac9886a96f26b1d9a7a59ebd45b7a70d102c015d4f31f9302bbdd6ab2b9` before compression.
See the [verification notes](verification/NOTES.md) for the checks' scope and limitations.

## What is frozen

`src/`, `lean-toolchain`, `lake-manifest.json`, `lakefile.toml`, `comparator.json` and
`export-targets.txt` are fixed at upstream commit
[`ab0b7522`](https://github.com/leanprover-community/riemann-hypothesis/tree/ab0b7522a5ccc9b8530edf475af5088f8f6464aa),
before any published source was edited. The shared first commit, `40e56bab` (tag
`as-published`), contains the original archive unchanged.

From the repository root, check this yourself:

```bash
scripts/check-frozen.sh    # compare with the pinned Git objects; requires full Git history
scripts/check-archive.sh   # download the 239 MB source archive and compare every file
```

Documentation, scripts and CI can still change. A bot proposes upstream verification results,
script fixes and instruction corrections as pull requests; a cache-server move opens an issue.
Changes to frozen files belong in the upstream repository.

## Who made what

- [Levent Alpöge](https://alpo.ge) published the source.
- [Jack McCarthy](https://github.com/Deicyde) made the mirror commit, `Challenge.lean`, the
  Comparator settings and the notes. Those commits are kept here as they were, together with
  one by [Marcelo Lynch](https://github.com/marcelolynch).
- Jack McCarthy also compiled the source and published
  [the compiled files](https://huggingface.co/datasets/JackMcCarthy/riemann-hypothesis-build).
- [Kim Morrison](https://github.com/kim-em) turned those files into the cache that
  `lake exe cache get` downloads, and wrote the download client.
- [James Chang](https://github.com/jamesyc) proposed a frozen repository beside the working
  one, in [issue #56](https://github.com/leanprover-community/riemann-hypothesis/issues/56).
- [Hang Lu Su](https://github.com/homeowmorphism) built this repository with Claude: the
  freeze, its two checks, this README and the cache notes. Hang Lu Su also wrote three small
  fixes to the download client.

## License

The submission belongs to its author and was published without a license. It is mirrored here
unmodified, for verification only. The files added around it come from
leanprover-community/riemann-hypothesis, which has no license file either.
