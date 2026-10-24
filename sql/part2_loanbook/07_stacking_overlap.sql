-- Attempt 2: flag borrowers with two loans from DIFFERENT lenders that overlap in time
WITH flagged AS (
    SELECT DISTINCT l1.borrower_id
    FROM loans l1
    JOIN loans l2
      ON  l1.borrower_id = l2.borrower_id
      AND l1.loan_id     < l2.loan_id
      AND l1.lender_id  <> l2.lender_id
      AND l1.disbursed_date < l2.disbursed_date + l2.term_weeks * 7
      AND l2.disbursed_date < l1.disbursed_date + l1.term_weeks * 7
)
SELECT a.is_stacker,
       (f.borrower_id IS NOT NULL) AS flagged,
       COUNT(*) AS borrowers
FROM answer_key a
LEFT JOIN flagged f USING (borrower_id)
GROUP BY 1, 2
ORDER BY 1, 2;
