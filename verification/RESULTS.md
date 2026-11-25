# Verification evidence

Only checks of the [archive published on 2026-11-20](NOTES.md#source), preserved as
`as-published` (`40e56bab`), belong here. Newer checkers are included when they check that
archive's export or compiled modules.

Pass means reported success; — means no result recorded. Running reflects the report time,
not live status.

| Check | [Andrew Sutherland](https://math.mit.edu/~drew/grh/) | [Jack McCarthy](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/RH.3A.20conserving.20original.20proof/near/643222049) |
|---|---|---|
| Report time (UTC) | 2026-11-25 22:05 | 2026-11-24 11:27 |
| Source identification | Published archive, checksum recorded | `original` branch, as reported |
| Sandboxed source build | Pass | Pass |
| Reproduced solution export | Byte-for-byte match | Byte-for-byte match |
| Statement comparison and axiom check | Pass | Pass |
| nanoda | Pass | Pass |
| Lean paranoid kernel | Pass | Pass |
| Lean default kernel | Pass | Running |
| con-leche | Pass (checker commit `cd2eceab`) | — |
| con-leche statement comparison | Pass (checker commit `5dc36dc1`) | — |
| con-ron statement comparison | Pass (checker commit `3f22699b`) | — |
| lean4lean (compiled modules) | Pass (checker commit `67f63b0c`) | — |
| Comparator v4.33.0 | Pass (build step stubbed) | — |
| Full `lake comparator` run | Pass | Running (final kernel) |

Andrew used the published archive, with Lean v4.33.1 for builds and Lean v4.36.0 for nanoda
and the default/paranoid kernel checks. He built con-leche, con-ron, and lean4lean from source,
at the checker commits shown above. The versions bundled with Lean v4.36.0 cannot check this
archive, for the reasons in the [checker notes](NOTES.md#checkers).

Andrew's full `lake comparator` run, on Lean v4.36.0, finished on 2026-11-25. The results page
reports it in these words:

> statement comparison and axiom check pass; Lean paranoid kernel, nanoda and Lean default
> kernel all accept; "Your solution is okay!"; exit 0 at 21:49:00 UTC on 25 November. Started
> 19:03 UTC on 20 November; 122 h 45 min in all, its kernel stages being single-threaded

The run's [log](https://math.mit.edu/~drew/grh/lake-comparator-v4.36.0.log) ends with
`Your solution is okay!` and exit status 0. Its
[config](https://math.mit.edu/~drew/grh/lake-comparator-v4.36.0.json) has the same sha256 as
this repository's `comparator.json`. The page's
[checksum list](https://math.mit.edu/~drew/grh/SHA256SUMS) gives `5ea74b91…244e` for the solution
export and `bd484ac9…b2b9` for the challenge export.

Jack's report names his `original` branch. It gives no commit, checksum, tool versions,
machine, or logs. The export cell comes instead from the
[notes published with his build](https://huggingface.co/datasets/JackMcCarthy/riemann-hypothesis-build/blob/e7164f44c8c07fd05d738014502109dc3ce0d8f7/lake-build/README.txt).
They give the size and sha256 of the solution export made from that build, and both equal
Andrew's. They also identify the source as the published archive and name the build tools.

See [CHECKING.md](CHECKING.md) to reproduce the archive checks.

## Adding a result

We are looking for full, independent builds of the frozen source. If you have made one, please
open a pull request that adds it to this page. A report needs:

- a build of the whole submission from source, not from this repository's cache of it
  (Mathlib's own cache is fine);
- the source it started from: the archive's sha256, or a commit of this repository;
- the sha256 of the solution export made from that build;
- a public record to link to: a log, a script, a results file, or the build outputs themselves.

Please also say whether the build ran in a sandbox.
