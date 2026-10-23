-- Part 1: real sector data

DROP TABLE IF EXISTS mix_bangladesh_annual;
CREATE TABLE mix_bangladesh_annual (
    mfi_id                   INTEGER,
    mfi_name                 TEXT,
    country                  TEXT,
    legal_status             TEXT,
    fiscal_year              INTEGER,
    as_of_date               DATE,
    gross_loan_portfolio_usd NUMERIC,
    active_borrowers         NUMERIC,
    loans_outstanding        NUMERIC,
    PRIMARY KEY (mfi_id, fiscal_year)
);

DROP TABLE IF EXISTS mra_sector_yearly;
CREATE TABLE mra_sector_yearly (
    fiscal_year           INTEGER PRIMARY KEY,
    mra_mfis              INTEGER,
    disbursement_crore_tk NUMERIC,
    outstanding_crore_tk  NUMERIC,
    borrowers_million     NUMERIC,
    source                TEXT,
    note                  TEXT
);
