-- Like-for-like yearly growth in loan portfolio (USD), 2008-2017
WITH yoy AS (
    SELECT
        mfi_id,
        fiscal_year,
        gross_loan_portfolio_usd,
        LAG(fiscal_year)              OVER w AS prev_year,
        LAG(gross_loan_portfolio_usd) OVER w AS prev_portfolio
    FROM mix_bangladesh_annual
    WINDOW w AS (PARTITION BY mfi_id ORDER BY fiscal_year)
)
SELECT
    fiscal_year,
    COUNT(*)                                   AS mfis_compared,
    ROUND(SUM(prev_portfolio) / 1e6, 0)        AS prev_year_musd,
    ROUND(SUM(gross_loan_portfolio_usd) / 1e6, 0) AS this_year_musd,
    ROUND(100.0 * (SUM(gross_loan_portfolio_usd) / SUM(prev_portfolio) - 1), 1) AS growth_pct
FROM yoy
WHERE prev_year = fiscal_year - 1
  AND gross_loan_portfolio_usd IS NOT NULL
  AND prev_portfolio IS NOT NULL
  AND fiscal_year BETWEEN 2008 AND 2017
GROUP BY fiscal_year
ORDER BY fiscal_year;
