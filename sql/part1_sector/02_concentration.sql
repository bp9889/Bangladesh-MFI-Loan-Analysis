-- Market concentration among MIX-reporting MFIs, 2017
SELECT
    mfi_name,
    active_borrowers,
    ROUND(100.0 * active_borrowers / SUM(active_borrowers) OVER (), 1) AS pct_of_borrowers,
    RANK() OVER (ORDER BY active_borrowers DESC) AS borrower_rank
FROM mix_bangladesh_annual
WHERE fiscal_year = 2017
  AND active_borrowers IS NOT NULL
ORDER BY active_borrowers DESC
LIMIT 10;
