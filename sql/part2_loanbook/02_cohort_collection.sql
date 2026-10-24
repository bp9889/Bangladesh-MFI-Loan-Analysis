-- Collection rate by cohort (month of disbursement), first 26 weeks
SELECT
    date_trunc('month', l.disbursed_date)::date AS cohort_month,
    COUNT(DISTINCT l.loan_id) AS loans,
    ROUND(100.0 * SUM(p.paid_amount) FILTER (WHERE p.week_no <= 13)
                / SUM(p.due_amount)  FILTER (WHERE p.week_no <= 13), 2) AS collected_pct_wk1_13,
    ROUND(100.0 * SUM(p.paid_amount) FILTER (WHERE p.week_no BETWEEN 14 AND 26)
                / SUM(p.due_amount)  FILTER (WHERE p.week_no BETWEEN 14 AND 26), 2) AS collected_pct_wk14_26
FROM loans l
JOIN payments p USING (loan_id)
WHERE l.disbursed_date >= DATE '2023-01-01'
  AND l.disbursed_date <  DATE '2024-07-01'
  AND p.week_no <= 26
GROUP BY 1
ORDER BY 1;
