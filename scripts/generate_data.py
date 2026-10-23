"""Generate the synthetic loan book. Part 4a: lenders, borrowers, answer key.
Every value here is an ASSUMPTION unless noted. Nothing is real borrower data."""
import numpy as np
import pandas as pd
from pathlib import Path

SEED = 42
N_BORROWERS = 10_000
STACKER_RATE = 0.08          # assumption: share of borrowers who will stack loans
INCOME_MEDIAN_BDT = 14_000   # assumption: median monthly household income
INCOME_SIGMA = 0.45          # assumption: spread of incomes (lognormal)

OUT = Path("data/synthetic")
OUT.mkdir(parents=True, exist_ok=True)
rng = np.random.default_rng(SEED)

lenders = pd.DataFrame({
    "lender_id": [1, 2, 3, 4, 5],
    "lender_name": ["Lender A", "Lender B", "Lender C", "Lender D", "Lender E"],
    "target_borrower_share": [0.35, 0.25, 0.20, 0.12, 0.08],
})

divisions = ["Dhaka", "Chattogram", "Rajshahi", "Khulna",
             "Barishal", "Sylhet", "Rangpur", "Mymensingh"]
borrowers = pd.DataFrame({
    "borrower_id": np.arange(1, N_BORROWERS + 1),
    "division": rng.choice(divisions, size=N_BORROWERS),
    "monthly_income_bdt": np.round(
        rng.lognormal(np.log(INCOME_MEDIAN_BDT), INCOME_SIGMA, N_BORROWERS), -2),
})

answer_key = pd.DataFrame({
    "borrower_id": borrowers["borrower_id"],
    "is_stacker": rng.random(N_BORROWERS) < STACKER_RATE,
})

lenders.to_csv(OUT / "lenders.csv", index=False)
borrowers.to_csv(OUT / "borrowers.csv", index=False)
answer_key.to_csv(OUT / "answer_key.csv", index=False)

print("borrowers:", len(borrowers))
print("median income:", borrowers["monthly_income_bdt"].median())
print("stackers:", int(answer_key["is_stacker"].sum()))
