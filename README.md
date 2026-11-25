# riemann-hypothesis-original

[![preservation and challenge checks](https://github.com/homeowmorphism/riemann-hypothesis-original/actions/workflows/checks.yml/badge.svg)](https://github.com/homeowmorphism/riemann-hypothesis-original/actions/workflows/checks.yml)

This repository preserves Levent Alpöge's Lean submission claiming proofs of the Riemann
hypothesis and the generalized Riemann hypothesis for Dirichlet L-functions, announced on 2026-11-20 at [alpo.ge/remark.pdf](https://web.archive.org/web/20261120141958/https://alpo.ge/remark.pdf). It adds access to the community build
cache and a
[Comparator](https://github.com/leanprover/comparator) setup.

Community cleanup and upgrades happen in
[leanprover-community/riemann-hypothesis](https://github.com/leanprover-community/riemann-hypothesis).

## Theorem Statements

[`src/Main.lean`](src/Main.lean) claims the following theorems:

| Theorem | Statement |
|---|---|
| `riemannHypothesis` | Mathlib's `RiemannHypothesis` |
| `riemannZeta_eq_zero_re` | the same statement as riemannHypothesis, spelled out: every zero of ζ other than −2, −4, −6, … has Re s = 1/2 |
| `LFunction_ne_zero_of_half_lt_re` | L(χ, s) ≠ 0 for Re s > 1/2, for every modulus and every Dirichlet character, except the trivial character at s = 1 |
| `LFunction_eq_zero_re` | every zero of L(χ, s) with 0 < Re s < 1 has Re s = 1/2 |
| `LFunction_eq_zero_re_of_isPrimitive` | the special case of LFunction_eq_zero_re for primitive characters |

[`src/Challenge.lean`](src/Challenge.lean) states these five theorems with
`sorry` in place of the proofs, in a file that imports only Mathlib. Comparator checks that
`Main.lean` proves exactly those statements, that the proofs use no axioms other than `propext`,
`Quot.sound` and `Classical.choice`, and that Lean's kernel and the independent checker nanoda
both accept them.

## Building from cache

If you want to explore the submission in Lean without compiling it yourself, use the cache:

```bash
lake exe cache get
lake build --no-build
```

The second command should finish with `All targets up-to-date`, meaning there is nothing
left to compile.

<!-- verification/CACHE.md links to this section by its former anchor. -->
<a id="checking-the-proof-yourself"></a>

## Building from source

If you want to build the submission yourself, run these commands in a fresh clone. Compiling the submission runs its code, so you may want to do it in a VM or your own sandbox. The project is pinned to Lean v4.33.1. 

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

A successful build is not a Comparator verdict. For the full Comparator check, follow
[CHECKING.md](verification/CHECKING.md) from the start. It covers the sandbox, building,
exporting and checking the submission.

[RESULTS.md](verification/RESULTS.md) records who has built and checked the frozen submission,
and what they found.

## What is frozen

The source, the Lean 4.33.1 toolchain and the pinned dependency versions stay unchanged from the
archive that Alpöge published on alpo.ge.

The first commit of this repository, tagged `as-published`, is that archive's `lean/` directory
with nothing changed. The [source notes](verification/NOTES.md#source) give the archive's
download URLs and checksum.

A few additions for the Comparator check and the build cache are frozen as well:
`src/Challenge.lean`, `comparator.json`, `export-targets.txt` and two marked blocks in
`lakefile.toml`.

Every frozen file is identical to its copy in
[leanprover-community/riemann-hypothesis at commit `ab0b7522`](https://github.com/leanprover-community/riemann-hypothesis/tree/ab0b7522a5ccc9b8530edf475af5088f8f6464aa).
That is the last commit on that repository's `main` branch before anyone edited the published
source.

To check the frozen files and compare the submission with the published archive:

```bash
scripts/check-frozen.sh    # compare with the pinned Git objects; requires full Git history
scripts/check-archive.sh   # download the 239 MB source archive and compare every file
```

The archive check downloads the 14 parts from the Wayback Machine's captures of alpo.ge, taken
between 2026-11-20 and 2026-11-23. Its result does not depend on what alpo.ge serves later: [part01], [part02], [part03], [part04], [part05], [part06], [part07],
[part08], [part09], [part10], [part11], [part12], [part13], [part14].

If the Wayback Machine does not supply the archive, the check downloads it from alpo.ge instead.
In that case the result does depend on alpo.ge. To download from alpo.ge only, run
`RH_ARCHIVE_URL=https://alpo.ge scripts/check-archive.sh`.

[part01]: https://web.archive.org/web/20261120142003/https://alpo.ge/lean.tar.gz.part01
[part02]: https://web.archive.org/web/20261120153908/https://alpo.ge/lean.tar.gz.part02
[part03]: https://web.archive.org/web/20261120154123/https://alpo.ge/lean.tar.gz.part03
[part04]: https://web.archive.org/web/20261120154256/https://alpo.ge/lean.tar.gz.part04
[part05]: https://web.archive.org/web/20261120154552/https://alpo.ge/lean.tar.gz.part05
[part06]: https://web.archive.org/web/20261120154647/https://alpo.ge/lean.tar.gz.part06
[part07]: https://web.archive.org/web/20261120154740/https://alpo.ge/lean.tar.gz.part07
[part08]: https://web.archive.org/web/20261120154744/https://alpo.ge/lean.tar.gz.part08
[part09]: https://web.archive.org/web/20261123144437/https://alpo.ge/lean.tar.gz.part09
[part10]: https://web.archive.org/web/20261121194229/https://alpo.ge/lean.tar.gz.part10
[part11]: https://web.archive.org/web/20261120155008/https://alpo.ge/lean.tar.gz.part11
[part12]: https://web.archive.org/web/20261120155011/https://alpo.ge/lean.tar.gz.part12
[part13]: https://web.archive.org/web/20261120155155/https://alpo.ge/lean.tar.gz.part13
[part14]: https://web.archive.org/web/20261120142002/https://alpo.ge/lean.tar.gz.part14

CI checks source preservation and builds and exports `Challenge`.

## Hosting and contributing

This repository sits under a personal account for now, with the idea that it could be transferred
to the [leanprover-community](https://github.com/leanprover-community) organization later.
Comments and pull requests are welcome, here or in the
[Zulip thread](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/RH.3A.20conserving.20original.20proof/with/642695513).

[homeowmorphism-bot](https://github.com/homeowmorphism-bot) is a bot that watches
[leanprover-community/riemann-hypothesis](https://github.com/leanprover-community/riemann-hypothesis)
and proposes verification results, download-script fixes and documentation corrections here. 

## Credits

The source is as [Levent Alpöge](https://alpo.ge) published it. Everything else was added
around it:

- [Jack McCarthy](https://github.com/Deicyde) mirrored the submission, set up the Comparator
  check, and compiled and published
  [a build of it](https://huggingface.co/datasets/JackMcCarthy/riemann-hypothesis-build).
- [Kim Morrison](https://github.com/kim-em) turned that build into the cache and wrote its
  download client.
- [Marcelo Lynch](https://github.com/marcelolynch) made the Mathlib cache download use
  `cache.mathlib.org`.
- [James Chang](https://github.com/jamesyc) proposed a separate frozen repository
  ([issue #56](https://github.com/leanprover-community/riemann-hypothesis/issues/56)).
- [Hang Lu Su](https://github.com/homeowmorphism) set up this repository with Claude and
  maintains it.

Later changes are credited in the
[commit history](https://github.com/homeowmorphism/riemann-hypothesis-original/commits/main).

## License

The submission belongs to its author and was published without a license. It is mirrored here
unmodified, for verification only. Most of the auxiliary files added around it come from
leanprover-community/riemann-hypothesis. The rest were written
for this repository.
