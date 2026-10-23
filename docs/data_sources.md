# Data sources and known issues

## MIX Market (World Bank Data Catalog)
- Files: Financial Performance Dataset in USD; MFI Company Metadata
- Coverage: 1999-2019, self-reported by MFIs; data collection ended in 2019
- Downloaded: 2026-10-24
- Raw files in data/raw/, cleaned output in data/clean/mix_bangladesh_annual.csv

## Cleaning steps
1. Joined financial data to metadata on MFI ID, kept Country = Bangladesh (86 MFIs)
2. Kept annual rows only (Period Type = ANN); quarterly rows would double-count
3. Four MFI-years had two annual snapshots six months apart (fiscal-year-end change);
   kept the earliest As of Date

## Known issues
- Number of MFIs reporting varies by year (28 to 40), so yearly totals partly reflect who reported
- 2018 is unreliable: Grameen Bank has no 2018 row and BRAC's borrower count falls sharply
- Number of loans outstanding is missing in about 43% of rows; average loan size uses
  Gross Loan Portfolio / Number of active borrowers instead
- Treat 2017 as the last reliable year for sector-level totals

## MRA sector figures
- Hand-entered headline figures in data/clean/mra_sector_yearly.csv with source URL per row
- Units: Tk crore (1 crore = 10 million). Sources conflict on units (one gives FY23 as 2.49 billion; correct figure is 2.49 trillion)
