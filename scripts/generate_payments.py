"""Generate weekly payments and loan outcomes (Part 4c). Every parameter is an ASSUMPTION."""
import numpy as np
import pandas as pd
from pathlib import Path

SEED = 44
SYN = Path("data/synthetic")
AS_OF = pd.Timestamp("2025-06-30")
BASE_DEFAULT = 0.004        # default chance at low debt load
MAX_EXTRA_DEFAULT = 0.25    # extra chance at very high debt load
DTI_MIDPOINT = 6.5
DTI_STEEPNESS = 0.8
P_LATE = 0.05               # share of installments paid 1-14 days late
FAIL_FROM, FAIL_TO = 0.25, 0.85   # defaulters stop paying this far into the term

rng = np.random.default_rng(SEED)
loans = pd.read_csv(SYN / "loans.csv", parse_dates=["disbursed_date"])
orig_cols = list(loans.columns)
inc = pd.read_csv(SYN / "borrowers.csv")[["borrower_id", "monthly_income_bdt"]]
loans = loans.merge(inc, on="borrower_id")
loans["end_date"] = loans["disbursed_date"] + pd.to_timedelta(loans["term_weeks"] * 7, unit="D")

# Debt-to-income at disbursement: this loan + the borrower's other loans still running that day
dti = np.zeros(len(loans))
for _, g in loans.groupby("borrower_id"):
    s = g["disbursed_date"].values
    e = g["end_date"].values
    p = g["principal_bdt"].values
    income = g["monthly_income_bdt"].iloc[0]
    for pos, idx in enumerate(g.index):
        active = (s <= s[pos]) & (s[pos] < e)
        dti[idx] = p[active].sum() / income
loans["dti"] = dti

p_def = BASE_DEFAULT + MAX_EXTRA_DEFAULT / (1 + np.exp(-(loans["dti"] - DTI_MIDPOINT) / DTI_STEEPNESS))
loans["will_default"] = rng.random(len(loans)) < p_def
loans["fail_week"] = np.maximum(
    1, np.floor(loans["term_weeks"] * rng.uniform(FAIL_FROM, FAIL_TO, len(loans)))).astype(int)

pay_frames, outcomes = [], []
for r in loans.itertuples():
    weeks = np.arange(1, r.term_weeks + 1)
    due_dates = r.disbursed_date + pd.to_timedelta(weeks * 7, unit="D")
    n_due = int((due_dates <= AS_OF).sum())
    if n_due == 0:
        outcomes.append("active")
        continue
    w, dd = weeks[:n_due], due_dates[:n_due]
    late = rng.random(n_due) < P_LATE
    delay = np.where(late, rng.integers(1, 15, n_due), 0)
    paid_dt = dd + pd.to_timedelta(delay, unit="D")
    paid_dt = paid_dt.where(paid_dt <= AS_OF, dd)       # late payments past the cut-off count as on time
    unpaid = (w > r.fail_week) if r.will_default else np.zeros(n_due, dtype=bool)
    pay_frames.append(pd.DataFrame({
        "loan_id": r.loan_id,
        "week_no": w,
        "due_date": dd.strftime("%Y-%m-%d"),
        "due_amount": r.weekly_installment_bdt,
        "paid_amount": np.where(unpaid, 0, r.weekly_installment_bdt),
        "paid_date": np.where(unpaid, "", np.asarray(paid_dt.strftime("%Y-%m-%d"))),
    }))
    if r.will_default and n_due > r.fail_week:
        outcomes.append("defaulted")
    elif n_due == r.term_weeks:
        outcomes.append("repaid")
    else:
        outcomes.append("active")

pay = pd.concat(pay_frames, ignore_index=True)
pay.to_csv(SYN / "payments.csv", index=False)

out = loans[orig_cols].copy()
out["outcome"] = outcomes
out["disbursed_date"] = out["disbursed_date"].dt.strftime("%Y-%m-%d")
out.to_csv(SYN / "loans.csv", index=False)

print("outcomes:", out["outcome"].value_counts().to_dict())
print("defaulted share of all loans:", round((out["outcome"] == "defaulted").mean() * 100, 2), "%")
print("payment rows:", len(pay))
print("collected / due:", round(pay["paid_amount"].sum() / pay["due_amount"].sum() * 100, 2), "%")
