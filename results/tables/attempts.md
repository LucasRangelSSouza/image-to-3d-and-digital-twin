| session_start_utc | gpu | stage_reached | wall_s | what_happened | cause_class | session_cost_usd | when |
|---|---|---|---|---|---|---|---|
| 20261027T035103 | RTX 3090 | install | 9 | CUDA 12.4 toolkit missing (apt packages not found); installer stopped at the nvcc check | environment | 0.268 | 2026-10-27 03:51:03 |
| 20261027T045517 | RTX 4090 | install | 449 | native extension CuMesh failed to build | environment | 0.296 | 2026-10-27 04:55:17 |
| 20261027T062444 | RTX 5090 | install | 543 | native extension CuMesh failed to build | environment (not retried after the fix) | 0.538 | 2026-10-27 06:24:44 |
| 20261027T071330 | L40S | run | 0 | dependencies installed; example script needs the PIL imaging library, which was missing | environment | 0.535 | 2026-10-27 07:13:30 |
| 20261027T075632 | RTX PRO 6000 | install | 231 | native extension CuMesh failed to build | environment (not retried after the fix) | 1.25 | 2026-10-27 07:56:32 |
| 20261027T090319 | RTX 4090 | complete | 421 | textured GLB written on the remote machine; file not retrieved | none | 0.353 | 2026-10-27 09:03:19 |
| 20261027T095940 | GB10 | install | nan | pinned NATTEN wheel exists only for Linux x86_64; CUDA installer is an x86 binary | platform (ARM) | 0 | 2026-10-27 09:59:40 |
| 20261027T110728 | RTX 4090 | complete | 414 | textured GLB written on the remote machine; file not retrieved | none | 0.414 | 2026-10-27 11:07:28 |
| 20261027T234700 | RTX 4090 | models | 0 | model download still running (14 of 24 files); run started without models.json | infrastructure (slow host) | 0.321 | 2026-10-27 23:47:00 |
| 20261028T003529 | RTX 4090 | run | nan | inference started; instance destroyed by the credit guard before completion | budget guard | 0.365 | 2026-10-28 00:35:29 |
