# Verification evidence

This page identifies the evidence recorded in this repository and what each check establishes.
Last reviewed: 2026-11-24.

The preserved submission is commit `40e56bab026552e089d7afcfeff08d2defb9c005` (tag
`as-published`). The frozen `src/` tree, including the separately added `Challenge.lean`, is
`24df20b62d9976ccd20da819bc20b16f808f0fdd`. Results for a later revision that changes the
submitted source must be identified separately.

## Available records

| Evidence | Record | Scope |
|---|---|---|
| Source preservation | [CI run logs](https://github.com/homeowmorphism/riemann-hypothesis-original/actions/workflows/checks.yml), with checks defined in the [workflow](../.github/workflows/checks.yml) | The frozen-file and archive checks compare source contents. Consult the individual run for its outcome. |
| Challenge export | The `challenge-export` artifact from a successful CI run; [reproduction instructions](CHECKING.md#2-export-the-challenge-and-fetch-mathlib) | Builds and exports the separately stated claims against pinned Mathlib. It does not check the submitted proofs. |
| Reported source builds and reproduced exports | [Historical build comparisons](NOTES.md#comparing-builds) | External reports preserved in the upstream notes dated 2026-11-21; their scope and limitations are recorded there. |
| Independent build and kernel checks by Andrew Sutherland | [Results page](https://math.mit.edu/~drew/grh/), as last updated 2026-11-24 03:30 UTC, and its [checksum list](https://math.mit.edu/~drew/grh/SHA256SUMS) | The checks ran on the published archive, not on a clone of this repository. The page gives the archive checksum that `scripts/check-archive.sh` expects. The checksum list gives the same sha256 for `comparator.json` as this repository's file, and the challenge export checksum in [CHECKING.md](CHECKING.md#2-export-the-challenge-and-fetch-mathlib). The page reports that the archive builds on Lean v4.33.1 without errors. It reports that nanoda, Lean's kernel and Lean paranoid, all from Lean v4.36.0, each accept the solution export when run alone. It reports that a sandboxed `lake build Main` on a second machine reproduced that export byte for byte. It reports a pass from Comparator v4.33.0, run on the files of the original build with a stub in place of `lake build`. Its `lake comparator` run on Lean v4.36.0 was still in progress at that update. |
| Full Comparator verdict for the frozen submission | No completed verdict or full-run log is recorded here | This describes this repository's records, not the status of checks performed elsewhere. |

[NOTES.md](NOTES.md) is a historical snapshot. Its statements about a run being in progress
describe that snapshot, not a live status report. The [verification procedure](CHECKING.md)
explains how to build, export, and judge the frozen submission. The
[limits](NOTES.md#limits) describe the remaining trust assumptions.

## Adding a result

For each result, record:

- who performed the check and when;
- the exact source commit, whether it includes any local changes, and the dependency pins;
- the Lean, exporter, and checker versions or revisions, and the checker configuration;
- the commands, execution environment, and whether the build used the submission's cache;
- the challenge and solution export checksums, where applicable;
- each checker's output and exit status, with links to the original logs and artifacts.

State exactly which check completed: source comparison, challenge export, source build,
solution export, or full judging. Keep results for modified source separate from results for
the preserved submission. Add new evidence here without rewriting the historical notes.
