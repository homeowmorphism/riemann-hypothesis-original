# The compiled files

`lake exe cache get` downloads one fixed set of compiled files for this source and unpacks it.
This page says where those files come from, what the download checks, and what it does not show.

## Using it

```bash
lake exe cache get
lake build --no-build
```

You need Lean's `elan`, `curl`, `git`, Python 3.11 or newer as `python3`, and about 105 GB of
free disk.

1. The first command fetches Mathlib's compiled files from Mathlib's own server. It then fetches
   this project's: 175,187 archives, 4.94 GB in total. Last, it unpacks them into `.lake/build`.
2. The second command asks Lake whether anything still needs compiling. It should end with
   `All targets up-to-date`.

For Mathlib alone, run `lake exe mathlib/cache get`. The steps for checking the proof in the
[README](../README.md#checking-the-proof-yourself) use that command, so that the proof is compiled on your
machine and not downloaded.

## Where the files come from

Nobody compiled these files for this repository. They were put together on 2026-11-21 in
[leanprover-community/riemann-hypothesis#7](https://github.com/leanprover-community/riemann-hypothesis/pull/7),
by Kim Morrison, from two published builds of the unmodified source:

- The `.olean` and `.ilean` files are from
  [Jack McCarthy's build](https://huggingface.co/datasets/JackMcCarthy/riemann-hypothesis-build/tree/9036e64326acf4acfae159b96664e9708445c1d1):
  175,187 pairs, 28.6 GB compressed and 99.3 GB unpacked.
- The generated C files are from a second build, published as
  [Lake build extras](https://huggingface.co/datasets/JackMcCarthy/riemann-hypothesis-build/tree/d4a057ad21e2f699743f0ed061fa2be73edfd68b/lake-extras).
  Each was checked against the first build before use.

[Upstream's cache notes](https://github.com/leanprover-community/riemann-hypothesis/blob/f28a764e76a18f68680446bf09682c24d1a8b5c4/verification/CACHE.md)
describe how the two were combined and repacked for Lake. The tools that did it are in
[`scripts/`](https://github.com/leanprover-community/riemann-hypothesis/tree/f28a764e76a18f68680446bf09682c24d1a8b5c4/scripts)
of that repository at the same commit. They are not copied here.

The files are served from shared TauCeti storage at `https://rh-cache.taucetiproject.org`.
This repository has no separate archival copy of its own. If that address ever stops
answering, recovery depends on continued access to the two published builds above or on
rebuilding the source with its pinned toolchain and dependencies. The checksums identify the
expected files; they do not guarantee continued availability. A separate archival copy of the
cache and its manifests remains to be established.

## What is pinned

| What | Value |
|---|---|
| Lean | `leanprover/lean4:v4.33.1` |
| Upstream commit the files were published under | `e50d09817ad81469f737e8f637561e6ccf86c670` |
| Git tree of `src/` | `24df20b62d9976ccd20da819bc20b16f808f0fdd` |
| sha256 of the list of archives (`modules.jsonl.gz`) | `292caa386a620d935cfc736b56fcceaab9fe7073086693b62e899c1ee4725f04` |
| sha256 of Lake's map from inputs to outputs | `fed2443b161bd8194d9507e5c9c0e555b865dbba6963a0d57172723a439e6941` |
| sha256 of `lake-manifest.json` | `fee57ee9ed399d0a638ca955e5ad40a37a36eeb9b6dfd9f5964114fa7bbe4774` |

The downloader requests this fixed upstream commit, so later upstream builds do not change
which cache it selects. That commit is an ancestor of every commit in this repository, and
`src/` here has the same Git tree. The values live in
[`scripts/restore-cache.py`](../scripts/restore-cache.py) and
[`scripts/lake-cache-get.sh`](../scripts/lake-cache-get.sh).

## What the download checks

Before unpacking, `restore-cache.py` checks that:

- `src/`, `lean-toolchain`, `lakefile.toml` and `lake-manifest.json` in your checkout are the
  pinned ones, with no local edits and no extra files under `src/`;
- the list of archives has the sha256 stored in this repository and names all 175,187 modules;
- every downloaded archive has the sha256 that the list gives for it.

If your checkout differs, it stops with `Bulk restore stopped` and unpacks nothing.

## What it does not show

These checks show that you received the recorded published files. They do not independently
establish that those files were faithfully compiled from the source or that the proof is correct.
The connection to the original submission rests on the documented community builds and cache
preparation described above. For independent verification, compile the source yourself and
judge it with Comparator, as [CHECKING.md](CHECKING.md) describes.

## Where the client came from

`scripts/Cache.lean` is an unchanged copy from upstream commit
`f28a764e76a18f68680446bf09682c24d1a8b5c4`. `scripts/cache-env.sh` is the copy from that commit
with one change, described below. `scripts/restore-cache.py` is an unchanged copy from
upstream commit `96465db8f1917d03402ebfed3e8893253a1a191a`. Since `f28a764e` it has gained one
step, from
[leanprover-community/riemann-hypothesis#202](https://github.com/leanprover-community/riemann-hypothesis/pull/202)
and [#241](https://github.com/leanprover-community/riemann-hypothesis/pull/241): it removes
Lake's saved `.hash` files before unpacking. Without that step, a checkout that has been built
or checked before can report correct files as out of date. `scripts/lake-cache-get.sh` is
upstream's without the steps for later source revisions and later Lean versions, which this
repository never has. The cache lines in `lakefile.toml` are upstream's as well.

Upstream commit `c9883164b0b3d762cee21f889d03d59a53b3ba3b` is the last one compared with these
files. Two steps in `scripts/lake-cache-get.sh` come from upstream commits later than
`f28a764e`:

- The step that raises the open-file limit is from
  [#637](https://github.com/leanprover-community/riemann-hypothesis/pull/637), at commit
  `362d9476fbd4548dead48ed7b6a54600879e1e17`.
- The `cd` that finds the project root ignores `CDPATH`. That is from
  [#483](https://github.com/leanprover-community/riemann-hypothesis/pull/483), at commit
  `b37b32c236352418f6edf1ed85dd2e4b14420686`. `scripts/cache-env.sh` has the same change, made
  here.

#637 removed `scripts/restore-cache.py`, `scripts/cache-env.sh` and the Lean 4.33.1 path of
`scripts/lake-cache-get.sh` from upstream's `main`, so later fixes to them will not come from
there.
