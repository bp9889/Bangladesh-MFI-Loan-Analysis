-- Default rate by debt-to-income bucket (active loans excluded: outcome not final)
SELECT
    CASE
        WHEN dti <  2 THEN '1) under 2'
        WHEN dti <  3 THEN '2) 2 to 3'
        WHEN dti <  4 THEN '3) 3 to 4'
        WHEN dti <  5 THEN '4) 4 to 5'
        WHEN dti <  6 THEN '5) 5 to 6'
        WHEN dti <  8 THEN '6) 6 to 8'
        WHEN dti < 10 THEN '7) 8 to 10'
        ELSE               '8) 10 and over'
    END AS dti_bucket,
    COUNT(*)                                            AS loans,
    COUNT(*) FILTER (WHERE outcome = 'defaulted')       AS defaults,
    ROUND(100.0 * COUNT(*) FILTER (WHERE outcome = 'defaulted') / COUNT(*), 2) AS default_rate_pct
FROM loan_dti
WHERE outcome IN ('repaid', 'defaulted')
GROUP BY 1
ORDER BY 1;
