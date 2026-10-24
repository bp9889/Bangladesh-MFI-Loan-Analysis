-- Do stackers default more than non-stackers at the SAME debt-to-income level?
WITH stackers AS (
    SELECT DISTINCT l1.borrower_id
    FROM loans l1
    JOIN loans l2
      ON  l1.borrower_id = l2.borrower_id
      AND l1.loan_id     < l2.loan_id
      AND l1.lender_id  <> l2.lender_id
      AND l1.disbursed_date < l2.disbursed_date + l2.term_weeks * 7
      AND l2.disbursed_date < l1.disbursed_date + l1.term_weeks * 7
)
SELECT
    CASE
        WHEN d.dti < 3 THEN '1) under 3'
        WHEN d.dti < 5 THEN '2) 3 to 5'
        WHEN d.dti < 6 THEN '3) 5 to 6'
        ELSE                '4) 6 and over'
    END AS dti_bucket,
    CASE WHEN s.borrower_id IS NOT NULL THEN 'stacker' ELSE 'non-stacker' END AS borrower_type,
    COUNT(*) AS loans,
    COUNT(*) FILTER (WHERE d.outcome = 'defaulted') AS defaults,
    ROUND(100.0 * COUNT(*) FILTER (WHERE d.outcome = 'defaulted') / COUNT(*), 2) AS default_rate_pct
FROM loan_dti d
LEFT JOIN stackers s USING (borrower_id)
WHERE d.outcome IN ('repaid', 'defaulted')
GROUP BY 1, 2
ORDER BY 1, 2;
