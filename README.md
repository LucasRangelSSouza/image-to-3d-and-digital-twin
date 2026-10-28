# Image to 3D and digital twin

Ten attempts to run an open image-to-3D tool on rented and owned GPUs, plus a note on COLMAP and a local build of an open room viewer.

Author: Lucas Rangel. All numbers below come from `evidence/results.json` (measured runs on rented Vast.ai GPUs, Oct 2026). This repository keeps the failed attempts on purpose, since they are the result. Every row is a real run on a shared marketplace host: values are single-session medians, outliers are kept (not filtered), and a different host of the same GPU model can differ noticeably.

## Conclusion

SUPRA-Tex completed twice, both times on an RTX 4090, and failed eight times: 5 attempts stopped at install, 1 during the model download, 2 at the run stage (one for a missing imaging library, one destroyed by my budget guard). One failure, on the ARM GB10, is a platform limit (an x86-only wheel). The rest are environment problems that I did not all retry. On both finished runs the final mesh stages took 83 and 93 seconds, 69 to 73 percent of that in the surface parameterization, and the reconstructed silhouette matched the input image with an intersection over union of 0.991. I did not copy the output GLB off the rented machine, so the evidence for the two completions is the run log, not the file. Read the full account in the Kaggle article "Ten attempts to run an image-to-3D tool".

## Ten attempts at one image-to-3D tool (SUPRA-Tex)

| session_start_utc | gpu | stage_reached | cause_class | session_cost_usd |
|---|---|---|---|---|
| 20261027T035103 | RTX 3090 | install | environment | 0.268 |
| 20261027T045517 | RTX 4090 | install | environment | 0.296 |
| 20261027T062444 | RTX 5090 | install | environment (not retried after the fix) | 0.538 |
| 20261027T071330 | L40S | run | environment | 0.535 |
| 20261027T075632 | RTX PRO 6000 | install | environment (not retried after the fix) | 1.25 |
| 20261027T090319 | RTX 4090 | complete | none | 0.353 |
| 20261027T095940 | GB10 | install | platform (ARM) | 0.0 |
| 20261027T110728 | RTX 4090 | complete | none | 0.414 |
| 20261027T234700 | RTX 4090 | models | infrastructure (slow host) | 0.321 |
| 20261028T003529 | RTX 4090 | run | budget guard | 0.365 |

Stages are ordered: install, models, run, complete. `what_happened` for each attempt is in `evidence/results.json`. Session cost is the rental estimate of the whole session, which usually also ran other tests.

## The two runs that finished (RTX 4090)

Stage readings are cumulative elapsed times of the final mesh stages (mm:ss).

| session_start_utc | Building BVH | Cleaning mesh | Parameterizing new mesh | Sampling attributes | Finalizing mesh | silhouette_iou | intermediate_faces |
|---|---|---|---|---|---|---|---|
| 20261027T090319 | 00:06 | 00:08 | 01:05 | 01:11 | 01:23 | 0.991 | 11408604 |
| 20261027T110728 | 00:06 | 00:07 | 01:15 | 01:20 | 01:33 | 0.991 | 11417778 |

## COLMAP

COLMAP 4.2.1 with CUDA support was installed and reported its version on three cards. The reconstruction test was skipped because no image dataset was available in the rented environments, so this repository has no COLMAP reconstruction timing. The `total_s` values that appear in the raw libs table for COLMAP (10.4, 11.5 and 599.1 seconds) are the wall time of the whole check block in each session, not a reconstruction time.

## Room viewer (local check, own computer)

| check | value | unit |
|---|---|---|
| node_version | v22.23.4 |  |
| repository_commit_date | 2026-10-22 |  |
| npm_ci_packages_added | 32 | packages |
| npm_ci_seconds | 5 | s |
| vite_build_modules_transformed | 115 | modules |
| vite_build_seconds | 1.493 | s |
| preview_http_status | 200 |  |
| pages_screenshotted | 2 | pages |
| bad_vertices_fixed_in_one_shelf_model | 312 | vertices |
| convex_decomposition_parts_one_chair | 13 | parts |
| convex_decomposition_ms_one_chair | 675 | ms |

The viewer's demo assets are not redistributable (see its asset terms), so no screenshots, models or textures are published here, only the build record.

## What this cost

Whole campaign: US$ 50.79 (about R$ 249), shared by all repositories of this series. Rental share of the GPUs used in this repo:

| GPU | rentals | hours | rental cost (USD) |
|---|---|---|---|
| RTX 3090 | 30 | 11.8 | 2.97 |
| RTX 4090 | 29 | 6.22 | 4.05 |
| RTX 5090 | 39 | 12.44 | 8.54 |
| L40S | 10 | 4.91 | 3.92 |
| RTX PRO 6000 | 15 | 3.67 | 5.71 |

Rental figures are hourly price x time of each rented instance; marketplace download fees and idle time are in the campaign total, not in this table.

## Reproduce

`bash scripts/run.sh` documents the exact commands used on the rented instance (Ubuntu, CUDA, Python venv). Evidence files are the unmodified measured rows (host location and reliability removed).
