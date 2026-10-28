import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
S = json.loads((ROOT / "results" / "summary.json").read_text())


def test_two_of_ten_completed_both_on_a_4090():
    import pandas as pd
    a = pd.read_csv(ROOT / "data" / "supra_attempts.csv")
    assert S["attempts"] == 10 and S["completed"] == 2
    assert set(a[a.stage_reached == "complete"].gpu) == {"RTX 4090"}


def test_failures_dominate_the_cost():
    assert S["cost_error_share"] > 0.7


def test_parameterization_is_the_dominant_final_stage():
    assert S["param_share_min"] > 0.6


def test_interval_is_wide_with_ten_attempts():
    assert S["wilson_high"] - S["wilson_low"] > 0.3


def test_only_one_failure_is_a_platform_limit():
    import pandas as pd
    a = pd.read_csv(ROOT / "data" / "supra_attempts.csv")
    assert a.cause_class.str.startswith("platform").sum() == 1
