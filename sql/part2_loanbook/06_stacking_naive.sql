-- Attempt 1 (naive): flag borrowers with more than one distinct lender, then score it
WITH flagged AS (
    SELECT borrower_id
    FROM loans
    GROUP BY borrower_id
    HAVING COUNT(DISTINCT lender_id) > 1
)
SELECT a.is_stacker,
       (f.borrower_id IS NOT NULL) AS flagged,
       COUNT(*) AS borrowers
FROM answer_key a
LEFT JOIN flagged f USING (borrower_id)
GROUP BY 1, 2
ORDER BY 1, 2;
