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
| Build and kernel checks by Andrew Sutherland | [Results page](https://math.mit.edu/~drew/grh/), as last updated 2026-11-24 03:30 UTC | The build and three kernel checks are reported complete. The `lake comparator` run was still in progress. Details are under [Andrew Sutherland's checks](#andrew-sutherlands-checks). |
| Comparator run by Jack McCarthy | [Status report on the Lean Zulip](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/RH.3A.20conserving.20original.20proof/near/643222049), posted 2026-11-24 11:27 UTC | The build, the comparison and axiom check, and two of the three kernels are reported complete. Lean's default kernel was still running. Details are under [Jack McCarthy's Comparator run](#jack-mccarthys-comparator-run). |
| Full Comparator verdict for the frozen submission | No completed verdict or full-run log is recorded here | Both runs above were still in progress when last reported. This describes this repository's records, not the status of checks performed elsewhere. |

[NOTES.md](NOTES.md) is a historical snapshot. Its statements about a run being in progress
describe that snapshot, not a live status report. The [verification procedure](CHECKING.md)
explains how to build, export, and judge the frozen submission. The
[limits](NOTES.md#limits) describe the remaining trust assumptions.

## Reported runs

Each run below was made by the person named, on their own machines. The tables give what that
person reports. None of it was run again for this repository.

### Andrew Sutherland's checks

Source: the [results page](https://math.mit.edu/~drew/grh/), as last updated 2026-11-24 03:30
UTC, and its [checksum list](https://math.mit.edu/~drew/grh/SHA256SUMS).

The checks ran on the published archive, not on a clone of this repository. Three checksums tie
them to this repository:

- The page gives the archive checksum that `scripts/check-archive.sh` expects.
- The checksum list gives the same sha256 for `comparator.json` as this repository's file.
- The checksum list gives the challenge export checksum in
  [CHECKING.md](CHECKING.md#2-export-the-challenge-and-fetch-mathlib).

| Check | Reported result |
|---|---|
| Build of the archive on Lean v4.33.1 | No errors |
| nanoda from Lean v4.36.0, run alone on the solution export | Accepts |
| Lean's kernel from Lean v4.36.0, run alone on the solution export | Accepts |
| Lean paranoid from Lean v4.36.0, run alone on the solution export | Accepts |
| Sandboxed `lake build Main` on a second machine | Reproduced the solution export byte for byte |
| Comparator v4.33.0, run on the files of the original build with a stub in place of `lake build` | Pass |
| `lake comparator` on Lean v4.36.0 | Still in progress at that update |

### Jack McCarthy's Comparator run

Source: a
[status report on the Lean Zulip](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/RH.3A.20conserving.20original.20proof/near/643222049),
posted 2026-11-24 11:27 UTC. Start times are in CET (UTC+1), as reported.

| Stage | Started | Duration | Reported result |
|---|---|---|---|
| Build (`lake build Main`, sandboxed) | 2026-11-20 15:02 | 8 h 17 min | Exit 0, 183,893 jobs |
| Parse, compare, axiom check | 2026-11-21 01:15 | 58 min | Passed |
| Lean paranoid kernel | 2026-11-21 02:13 | 68 h 53 min | Accepts |
| nanoda kernel | 2026-11-23 23:06 | 1 h 33 min | Accepts |
| Lean default kernel | 2026-11-24 00:39 | 11 h 45 min when reported | Still running |

The three kernels are the ones that the [judging step](CHECKING.md#4-judge-the-exports)
requires: Lean's own, Lean paranoid and nanoda.

The report says the run is on McCarthy's `original` branch. It does not give the commit, the
tool versions, the export checksums or the machine, and it links no logs. Those items from the
list below are still to be recorded.

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
