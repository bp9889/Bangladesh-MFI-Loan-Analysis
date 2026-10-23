-- Cumulative market share by borrower rank, 2017
WITH ranked AS (
    SELECT
        mfi_name,
        active_borrowers,
        RANK() OVER (ORDER BY active_borrowers DESC) AS borrower_rank
    FROM mix_bangladesh_annual
    WHERE fiscal_year = 2017
      AND active_borrowers IS NOT NULL
)
SELECT
    borrower_rank,
    mfi_name,
    ROUND(100.0 * SUM(active_borrowers) OVER (ORDER BY borrower_rank)
                / SUM(active_borrowers) OVER (), 1) AS cumulative_pct
FROM ranked
ORDER BY borrower_rank
LIMIT 10;
