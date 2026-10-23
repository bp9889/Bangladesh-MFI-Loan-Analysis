-- Part 2: synthetic loan book (all data generated; see docs/data_sources.md)

DROP TABLE IF EXISTS answer_key, payments, loans, borrowers, lenders CASCADE;

CREATE TABLE lenders (
    lender_id             INTEGER PRIMARY KEY,
    lender_name           TEXT NOT NULL,
    target_borrower_share NUMERIC
);

CREATE TABLE borrowers (
    borrower_id        INTEGER PRIMARY KEY,
    division           TEXT,
    monthly_income_bdt NUMERIC NOT NULL CHECK (monthly_income_bdt > 0)
);

CREATE TABLE loans (
    loan_id                INTEGER PRIMARY KEY,
    borrower_id            INTEGER NOT NULL REFERENCES borrowers (borrower_id),
    lender_id              INTEGER NOT NULL REFERENCES lenders (lender_id),
    disbursed_date         DATE NOT NULL,
    principal_bdt          NUMERIC NOT NULL CHECK (principal_bdt > 0),
    term_weeks             INTEGER NOT NULL CHECK (term_weeks > 0),
    weekly_installment_bdt NUMERIC NOT NULL,
    outcome                TEXT CHECK (outcome IN ('repaid', 'active', 'defaulted'))
);

CREATE TABLE payments (
    loan_id     INTEGER NOT NULL REFERENCES loans (loan_id),
    week_no     INTEGER NOT NULL,
    due_date    DATE NOT NULL,
    due_amount  NUMERIC NOT NULL,
    paid_amount NUMERIC NOT NULL DEFAULT 0,
    paid_date   DATE,
    PRIMARY KEY (loan_id, week_no)
);

CREATE TABLE answer_key (
    borrower_id INTEGER PRIMARY KEY REFERENCES borrowers (borrower_id),
    is_stacker  BOOLEAN NOT NULL
);
