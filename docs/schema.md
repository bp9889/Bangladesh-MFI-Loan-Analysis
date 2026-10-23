# Loan book schema

```mermaid
erDiagram
    LENDERS ||--o{ LOANS : issues
    BORROWERS ||--o{ LOANS : takes
    LOANS ||--o{ PAYMENTS : "has weekly"
    BORROWERS ||--o| ANSWER_KEY : "hidden label"
```

- `answer_key` marks which borrowers were generated as loan stackers. Detection queries never read it; it is only used to score them.
- Debt-to-income = total principal of a borrower's active loans / monthly income.
