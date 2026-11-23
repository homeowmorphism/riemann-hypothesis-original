# riemann-hypothesis-original

[![preservation and challenge checks](https://github.com/homeowmorphism/riemann-hypothesis-original/actions/workflows/checks.yml/badge.svg)](https://github.com/homeowmorphism/riemann-hypothesis-original/actions/workflows/checks.yml)

This repository preserves Levent Alpöge's Lean submission of 2026-11-20, announced at
<https://alpo.ge/remark.pdf>, which claims proofs of the Riemann Hypothesis and of GRH for
Dirichlet L-functions. The published source, its Lean 4.33.1 toolchain and its dependency pins
are kept unchanged so that anyone can examine and check them. Cleanup and upgrades happen in
[leanprover-community/riemann-hypothesis](https://github.com/leanprover-community/riemann-hypothesis).

[Hang Lu Su](https://github.com/homeowmorphism) hosts this repository for now, with the idea that
it could be transferred to the [leanprover-community](https://github.com/leanprover-community)
organization later if there's interest. Comments and pull requests are welcome, here or in the
[Zulip thread](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/RH.3A.20conserving.20original.20proof/with/642695513).

## Theorem Statements

[`src/Main.lean`](src/Main.lean) claims the following theorems:

| Theorem | Statement |
|---|---|
| `riemannHypothesis` | Mathlib's `RiemannHypothesis` |
| `LFunction_ne_zero_of_half_lt_re` | L(χ, s) ≠ 0 for Re s > 1/2, for every modulus and every Dirichlet character, except the trivial character at s = 1 |
| `LFunction_eq_zero_re` | every zero of L(χ, s) with 0 < Re s < 1 has Re s = 1/2 |

`Main.lean` also claims `riemannZeta_eq_zero_re` and `LFunction_eq_zero_re_of_isPrimitive`, which
add no new mathematics. [`src/Challenge.lean`](src/Challenge.lean), added for checking, states
every theorem in `Main.lean` with `sorry` in place of the proofs, in a file that imports only
Mathlib. Comparator checks that `Main.lean` proves exactly those statements, that it uses no
axioms other than `propext`, `Quot.sound` and `Classical.choice`, and that Lean's kernel and
nanoda both accept the proof.

## Cache

A full build takes hours, so you should use the cache:

```bash
lake exe cache get
lake build --no-build
```

A full build makes Lean check every proof on your machine. The cache downloads files that were
compiled elsewhere, so you can read the proof without that build, but Lean does not re-check
them. [CACHE.md](verification/CACHE.md) says where those files come from.

## Checking the proof yourself

Compiling the submission runs its code, so you may want to do it in a VM or your own sandbox.
To compile it with its own Lean 4.33.1, take a fresh clone and run:

```bash
export LEAN_ABORT_ON_PANIC=1        # as Comparator does
export LAKE_ARTIFACT_CACHE=false    # in case cache-env.sh was sourced
MATHLIB_CACHE_GET_URL=https://cache.mathlib.org/mathlib4 lake exe mathlib/cache get
lake build Main
```

The `mathlib/cache` command fetches Mathlib's compiled files and nothing of the submission's.
Don't use `lake exe cache get` here, because that also downloads the prebuilt copy of the
submission. The build takes hours on a large machine and can write around 1 TB of temporary
files; see the [building notes](verification/NOTES.md#building).

A successful build is not a Comparator verdict. Lean 4.33.1 has neither `lake comparator` nor
`leanexport`, so getting one takes two toolchains. Follow
[CHECKING.md](verification/CHECKING.md) from the start instead of the commands above: it exports
`Challenge` in a clean clone, builds and exports `Main` in a sandbox with no network, and judges
both exports with Comparator under Lean 4.36.0. [RESULTS.md](verification/RESULTS.md) lists the
checks recorded so far.

## What is frozen

`src/`, `lean-toolchain`, `lake-manifest.json`, `lakefile.toml`, `comparator.json` and
`export-targets.txt` are fixed at upstream commit
[`ab0b7522`](https://github.com/leanprover-community/riemann-hypothesis/tree/ab0b7522a5ccc9b8530edf475af5088f8f6464aa),
before any published source was edited. Beyond the published archive, they hold only
`Challenge.lean`, the Comparator settings and marked additions to `lakefile.toml`. The first
commit, `40e56bab` (tag `as-published`), is the archive's `lean/` directory unchanged; the
[source notes](verification/NOTES.md#source) record the archive's download URLs and checksum.
To check both yourself:

```bash
scripts/check-frozen.sh    # compare with the pinned Git objects; requires full Git history
scripts/check-archive.sh   # download the 239 MB source archive from alpo.ge and compare every file
```

The Wayback Machine captured each of the archive's 14 parts between 2026-11-20 and 2026-11-22,
with the same contents:
[part01][wb01], [part02][wb02], [part03][wb03], [part04][wb04], [part05][wb05],
[part06][wb06], [part07][wb07], [part08][wb08], [part09][wb09], [part10][wb10],
[part11][wb11], [part12][wb12], [part13][wb13], [part14][wb14].

[wb01]: https://web.archive.org/web/20261120142003/https://alpo.ge/lean.tar.gz.part01
[wb02]: https://web.archive.org/web/20261120153908/https://alpo.ge/lean.tar.gz.part02
[wb03]: https://web.archive.org/web/20261120154123/https://alpo.ge/lean.tar.gz.part03
[wb04]: https://web.archive.org/web/20261120154256/https://alpo.ge/lean.tar.gz.part04
[wb05]: https://web.archive.org/web/20261120154552/https://alpo.ge/lean.tar.gz.part05
[wb06]: https://web.archive.org/web/20261120154647/https://alpo.ge/lean.tar.gz.part06
[wb07]: https://web.archive.org/web/20261120154740/https://alpo.ge/lean.tar.gz.part07
[wb08]: https://web.archive.org/web/20261120154744/https://alpo.ge/lean.tar.gz.part08
[wb09]: https://web.archive.org/web/20261122154217/https://alpo.ge/lean.tar.gz.part09
[wb10]: https://web.archive.org/web/20261121194229/https://alpo.ge/lean.tar.gz.part10
[wb11]: https://web.archive.org/web/20261120155008/https://alpo.ge/lean.tar.gz.part11
[wb12]: https://web.archive.org/web/20261120155011/https://alpo.ge/lean.tar.gz.part12
[wb13]: https://web.archive.org/web/20261120155155/https://alpo.ge/lean.tar.gz.part13
[wb14]: https://web.archive.org/web/20261120142002/https://alpo.ge/lean.tar.gz.part14

## CI

CI runs both scripts and builds and exports `Challenge`. It does not build or judge the
submission, which is too big for hosted runners. A bot proposes upstream verification results,
script fixes and instruction corrections as pull requests; a cache-server move opens an issue.

## Credits

The source is as [Levent Alpöge](https://alpo.ge) published it. Everything else was added
around it:

- [Jack McCarthy](https://github.com/Deicyde) made the mirror commit, `Challenge.lean`, the
  Comparator settings and the notes. Those commits are kept here as they were, together with
  one by [Marcelo Lynch](https://github.com/marcelolynch) that fetches Mathlib's cache from
  `cache.mathlib.org`.
- Jack McCarthy also compiled the source and published
  [the compiled files](https://huggingface.co/datasets/JackMcCarthy/riemann-hypothesis-build).
- [Kim Morrison](https://github.com/kim-em) turned those files into the cache that
  `lake exe cache get` downloads, and wrote the download client.
- [James Chang](https://github.com/jamesyc) proposed a frozen repository beside the working
  one, in [issue #56](https://github.com/leanprover-community/riemann-hypothesis/issues/56).
- [Hang Lu Su](https://github.com/homeowmorphism) built this repository with Claude: the
  freeze, its two checks, this README, the cache notes, the verification guide and the results
  page. Hang Lu Su also wrote two small fixes to the download client.

## License

The submission belongs to its author and was published without a license. It is mirrored here
unmodified, for verification only. The files added around it come from
leanprover-community/riemann-hypothesis, which has no license file either.
