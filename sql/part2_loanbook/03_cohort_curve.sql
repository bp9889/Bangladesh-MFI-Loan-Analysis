-- Cumulative collection curve by cohort, at weeks 8, 13, 20 and 26
WITH cohort_week AS (
    SELECT date_trunc('month', l.disbursed_date)::date AS cohort_month,
           p.week_no,
           SUM(p.due_amount)  AS due,
           SUM(p.paid_amount) AS paid
    FROM loans l
    JOIN payments p USING (loan_id)
    WHERE l.disbursed_date >= DATE '2023-01-01'
      AND l.disbursed_date <  DATE '2024-07-01'
      AND p.week_no <= 26
    GROUP BY 1, 2
),
running AS (
    SELECT cohort_month,
           week_no,
           ROUND(100.0 * SUM(paid) OVER w / SUM(due) OVER w, 2) AS cum_collected_pct
    FROM cohort_week
    WINDOW w AS (PARTITION BY cohort_month ORDER BY week_no)
)
SELECT cohort_month,
       MAX(cum_collected_pct) FILTER (WHERE week_no = 8)  AS wk8,
       MAX(cum_collected_pct) FILTER (WHERE week_no = 13) AS wk13,
       MAX(cum_collected_pct) FILTER (WHERE week_no = 20) AS wk20,
       MAX(cum_collected_pct) FILTER (WHERE week_no = 26) AS wk26
FROM running
GROUP BY cohort_month
ORDER BY cohort_month;
