"""Charts for the README. Values copied from the SQL outputs named in each comment."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from pathlib import Path

Path("docs").mkdir(exist_ok=True)

# sql/part2_loanbook/05_default_by_dti.sql
labels = ["<2", "2-3", "3-4", "4-5", "5-6", "6-8", "8-10", "10+"]
rates = [0.37, 0.72, 0.94, 2.40, 6.22, 15.14, 28.24, 36.07]
loans = [2447, 4044, 2562, 1292, 611, 502, 131, 61]

fig, ax = plt.subplots(figsize=(8, 4.5))
bars = ax.bar(labels, rates, color="#2b6cb0")
for bar, n in zip(bars, loans):
    ax.annotate(f"n={n:,}", (bar.get_x() + bar.get_width() / 2, bar.get_height()),
                ha="center", va="bottom", fontsize=8)
ax.set_xlabel("Debt-to-income at disbursement (x monthly income)")
ax.set_ylabel("Default rate (%) of finished loans")
ax.set_title("Default rate by debt-to-income (synthetic loan book)")
fig.tight_layout()
fig.savefig("docs/default_by_dti.png", dpi=150)
plt.close(fig)

# sql/part1_sector/03_cumulative_concentration.sql (MIX Market, 2017)
ranks = list(range(1, 11))
cum = [33.2, 56.1, 77.4, 81.2, 84.3, 86.1, 87.7, 89.2, 90.5, 91.7]

fig, ax = plt.subplots(figsize=(8, 4.5))
ax.plot(ranks, cum, marker="o", color="#2b6cb0")
for x, y in zip(ranks, cum):
    ax.annotate(f"{y}", (x, y), textcoords="offset points", xytext=(0, 7), ha="center", fontsize=8)
ax.set_ylim(0, 100)
ax.set_xticks(ranks)
ax.set_xlabel("MFI rank by active borrowers")
ax.set_ylabel("Cumulative share of borrowers (%)")
ax.set_title("Market concentration, MIX-reporting MFIs, 2017")
fig.tight_layout()
fig.savefig("docs/concentration.png", dpi=150)
plt.close(fig)
print("saved docs/default_by_dti.png and docs/concentration.png")
