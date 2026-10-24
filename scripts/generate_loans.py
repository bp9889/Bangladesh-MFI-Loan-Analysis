"""Generate loans (Part 4b). Every parameter is an ASSUMPTION, not real data."""
import numpy as np
import pandas as pd
from pathlib import Path

SEED = 43
SYN = Path("data/synthetic")
FIRST_START = pd.Timestamp("2023-01-02")
FIRST_END = pd.Timestamp("2024-06-30")   # last date a first loan can start
AS_OF = pd.Timestamp("2025-06-30")       # data cut-off date
RATIO_MEDIAN, RATIO_SIGMA = 2.7, 0.4     # principal = monthly income x ratio
MIN_PRINCIPAL, MAX_PRINCIPAL = 5_000, 150_000
TERMS, TERM_P = [26, 46, 52], [0.2, 0.6, 0.2]
FLAT_INTEREST = 0.24                     # per year, on original principal
P_TWO_EXTRA = 0.3                        # of stackers: share with 2 extra loans
P_SEQUENTIAL = 0.15                      # of non-stackers: share with a decoy loan

rng = np.random.default_rng(SEED)
lenders = pd.read_csv(SYN / "lenders.csv")
b = pd.read_csv(SYN / "borrowers.csv").merge(pd.read_csv(SYN / "answer_key.csv"), on="borrower_id")
ids = [int(i) for i in lenders["lender_id"]]
probs = lenders["target_borrower_share"].values

def make_loan(bid, income, lender, start):
    ratio = rng.lognormal(np.log(RATIO_MEDIAN), RATIO_SIGMA)
    principal = float(np.clip(np.round(income * ratio, -3), MIN_PRINCIPAL, MAX_PRINCIPAL))
    term = int(rng.choice(TERMS, p=TERM_P))
    weekly = round(principal * (1 + FLAT_INTEREST * term / 52) / term)
    return dict(borrower_id=int(bid), lender_id=int(lender), disbursed_date=start,
                principal_bdt=int(principal), term_weeks=term, weekly_installment_bdt=int(weekly))

rows = []
for r in b.itertuples():
    days = int(rng.integers(0, (FIRST_END - FIRST_START).days + 1))
    start = FIRST_START + pd.Timedelta(days=days)
    first_lender = int(rng.choice(ids, p=probs))
    first = make_loan(r.borrower_id, r.monthly_income_bdt, first_lender, start)
    rows.append(first)

    if r.is_stacker:
        used, prev_start = {first_lender}, start
        for _ in range(2 if rng.random() < P_TWO_EXTRA else 1):
            lender = int(rng.choice([i for i in ids if i not in used]))
            prev_start = prev_start + pd.Timedelta(weeks=int(rng.integers(4, 21)))
            rows.append(make_loan(r.borrower_id, r.monthly_income_bdt, lender, prev_start))
            used.add(lender)
    elif rng.random() < P_SEQUENTIAL:
        end = start + pd.Timedelta(weeks=first["term_weeks"])
        second_start = end + pd.Timedelta(weeks=int(rng.integers(1, 9)))
        if second_start <= AS_OF - pd.Timedelta(days=28):
            lender = int(rng.choice([i for i in ids if i != first_lender]))
            rows.append(make_loan(r.borrower_id, r.monthly_income_bdt, lender, second_start))

df = pd.DataFrame(rows).sort_values(["disbursed_date", "borrower_id"]).reset_index(drop=True)
df.insert(0, "loan_id", np.arange(1, len(df) + 1))
df["outcome"] = ""                       # filled in during Part 4c
df["disbursed_date"] = df["disbursed_date"].dt.strftime("%Y-%m-%d")
df.to_csv(SYN / "loans.csv", index=False)

n_per = df.groupby("borrower_id").size()
print("loans:", len(df), "| borrowers:", n_per.size)
print("mean principal:", round(df["principal_bdt"].mean()), "| median:", df["principal_bdt"].median())
print("loans per borrower:", n_per.value_counts().sort_index().to_dict())
