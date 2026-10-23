-- Average outstanding loan balance per borrower, 2017
SELECT
    mfi_name,
    active_borrowers,
    ROUND(gross_loan_portfolio_usd / active_borrowers, 0) AS avg_balance_usd,
    ROUND(SUM(gross_loan_portfolio_usd) OVER ()
        / SUM(active_borrowers) OVER (), 0)               AS sector_avg_usd
FROM mix_bangladesh_annual
WHERE fiscal_year = 2017
  AND gross_loan_portfolio_usd IS NOT NULL
  AND active_borrowers IS NOT NULL
  AND active_borrowers > 0
ORDER BY active_borrowers DESC
LIMIT 10;
