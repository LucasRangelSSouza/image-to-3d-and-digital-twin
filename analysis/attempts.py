"""Ten attempts to run an image-to-3D tool: what stopped each one, what it cost, and what the two finished runs looked like."""
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from benchkit import rule_of_three, wilson
from common import BLUE, GREEN, GREY, ORANGE, PURPLE, RED, read, save_fig, save_table, update_summary

a = read("supra_attempts.csv")
ok = read("supra_completed_runs.csv")
viewer = read("viewer_local_check.csv")
a["when"] = pd.to_datetime(a.session_start_utc, format="%Y%m%dT%H%M%S")
order = ["install", "models", "run", "complete"]
pos = {k: i for i, k in enumerate(order)}
colors = {"environment": ORANGE, "environment (not retried after the fix)": "#ecc94b", "platform (ARM)": PURPLE, "infrastructure (slow host)": GREY, "budget guard": "#a0aec0", "none": GREEN}
save_table(a.round(3), "attempts", index=False)


def secs(t):
    m, s = str(t).split(":")
    return int(m) * 60 + int(s)


stages = ["Building BVH", "Cleaning mesh", "Parameterizing new mesh", "Sampling attributes", "Finalizing mesh"]
rows = []
for _, r in ok.iterrows():
    cum = [secs(r[k]) for k in stages]
    dur = [cum[0]] + [b - x for x, b in zip(cum, cum[1:])]
    rows.append(dict(zip(["run"] + stages, [r.session_start_utc] + dur)))
st = pd.DataFrame(rows).set_index("run")
st["total_s"] = st.sum(axis=1)
st["parameterization_share"] = st["Parameterizing new mesh"] / st.total_s
save_table(st.round(3), "final_stage_seconds_of_finished_runs")

fig, axes = plt.subplots(1, 3, figsize=(15, 4.4))
for i, r in a.reset_index(drop=True).iterrows():
    axes[0].barh(len(a) - i, pos[r.stage_reached] + 1, color=colors[r.cause_class], height=0.65)
    axes[0].text(pos[r.stage_reached] + 1.05, len(a) - i, f"{r.gpu}, ${r.session_cost_usd:.2f}", va="center", fontsize=7)
axes[0].set_yticks(range(len(a), 0, -1))
axes[0].set_yticklabels([f"{k + 1}. {w:%d %b %H:%M}" for k, w in enumerate(a.when)], fontsize=7)
axes[0].set_xticks([1, 2, 3, 4])
axes[0].set_xticklabels(order, fontsize=8)
axes[0].set_xlim(0, 6.5)
axes[0].set_title("Furthest stage reached", fontsize=9)
axes[0].legend([plt.Rectangle((0, 0), 1, 1, color=c) for c in colors.values()], colors.keys(), fontsize=6, frameon=False, loc="upper center", bbox_to_anchor=(0.5, -0.08), ncol=2)
cost = a.session_cost_usd
axes[1].bar(range(1, len(a) + 1), cost, color=[colors[c] for c in a.cause_class])
axes[1].set_xlabel("Attempt")
axes[1].set_ylabel("Session rental (US$)")
left = np.zeros(len(st))
for k, c in zip(stages, (GREY, "#a0aec0", ORANGE, BLUE, GREEN)):
    axes[2].barh(["run 1", "run 2"], st[k].values, left=left, color=c, label=k)
    left += st[k].values
axes[2].set_xlabel("Seconds in the final mesh stages")
axes[2].legend(fontsize=6, frameon=False, loc="upper center", bbox_to_anchor=(0.5, -0.15), ncol=3)
save_fig(fig, "ten_attempts.png")

n_done = int((a.stage_reached == "complete").sum())
lo, hi = wilson(n_done, len(a))
reached_run = a[a.stage_reached.isin(["run", "complete"])]
update_summary({"attempts": len(a), "completed": n_done, "wilson_low": lo, "wilson_high": hi, "install_stops": int((a.stage_reached == "install").sum()),
                "cost_total": cost.sum(), "cost_productive": cost[a.stage_reached == "complete"].sum(), "cost_error_share": cost[a.stage_reached != "complete"].sum() / cost.sum(),
                "stage_total_min": st.total_s.min(), "stage_total_max": st.total_s.max(), "param_share_min": st.parameterization_share.min(), "param_share_max": st.parameterization_share.max(),
                "iou": ok.silhouette_iou.iloc[0], "faces_million": ok.intermediate_faces.iloc[0] / 1e6, "retry_rule_of_three": rule_of_three(50),
                "viewer_build_modules": float(viewer[viewer.check == "vite_build_modules_transformed"].value.iloc[0]), "viewer_build_s": float(viewer[viewer.check == "vite_build_seconds"].value.iloc[0])})
print(a[["gpu", "stage_reached", "cause_class", "session_cost_usd"]]); print(st.round(2))
