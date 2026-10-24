-- Debt-to-income at the day each loan started
CREATE OR REPLACE VIEW loan_dti AS
SELECT
    l1.loan_id,
    l1.borrower_id,
    l1.lender_id,
    l1.outcome,
    b.monthly_income_bdt,
    SUM(l2.principal_bdt)                                    AS total_debt_bdt,
    ROUND(SUM(l2.principal_bdt) / b.monthly_income_bdt, 2)   AS dti
FROM loans l1
JOIN loans l2
  ON  l2.borrower_id    = l1.borrower_id
  AND l2.disbursed_date <= l1.disbursed_date
  AND l1.disbursed_date <  l2.disbursed_date + l2.term_weeks * 7
JOIN borrowers b ON b.borrower_id = l1.borrower_id
GROUP BY l1.loan_id, l1.borrower_id, l1.lender_id, l1.outcome, b.monthly_income_bdt;
