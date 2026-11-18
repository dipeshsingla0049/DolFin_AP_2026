-- =====================================================================
-- AP project (EquityLens): every SQL query the app uses, PostgreSQL.
-- Format: "-- <id> <READ|WRITE>: <what it does>" then the statement (ends with ;).
-- Literal values stand in for the parameters ($1, $2 ...) of the real app.
--
-- Source of each query:
--   R1, R2, W1   exist in the backend today (auth_route.js, register.js; Prisma calls
--                findUnique / create written here as plain SQL).
--   R3 - R6, W2, W3   are the queries the data-fetch route (routes/data_route.js, "/fetch/:id")
--                and the ratio analysis screens need. That route is not wired into
--                server.js yet, so these are the intended queries, not running code.
-- =====================================================================

-- R1 READ: login, find the user by email (then bcrypt compares the hash in the app)
SELECT user_id, name, email, password_hash
FROM app_user
WHERE email = 'user50000@example.com';

-- R2 READ: register, check whether the email already exists
SELECT user_id, name, email, password_hash
FROM app_user
WHERE email = 'user77777@example.com';

-- R3 READ: company page, latest market snapshot by ticker
SELECT company_id, ticker, name, price, last_price_date, market_cap, price_to_sales
FROM company
WHERE ticker = 'TCK02500';

-- R4 READ: ratio history of one company, newest quarter first (JOIN company + financial_report)
SELECT c.ticker, c.name, r.quarter_end, r.fiscal_year_end, r.gross_margin, r.operating_margin,
       r.return_on_assets, r.return_on_equity, r.revenue, r.ebitda, r.pat,
       r.total_cash, r.total_debt, r.debt_to_equity, r.current_ratio
FROM company c
JOIN financial_report r ON r.company_id = c.company_id
WHERE c.ticker = 'TCK02500'
ORDER BY r.quarter_end DESC;

-- R5 READ: latest quarter of every company with its snapshot (overview table)
SELECT DISTINCT ON (c.company_id)
       c.ticker, c.name, c.price, c.market_cap, r.quarter_end, r.revenue, r.pat, r.return_on_equity
FROM company c
JOIN financial_report r ON r.company_id = c.company_id
ORDER BY c.company_id, r.quarter_end DESC;

-- R6 READ: screener, companies whose LATEST quarter has ROE above 15 and debt to equity below 100
SELECT c.ticker, c.name, r.quarter_end, r.return_on_equity, r.debt_to_equity
FROM company c
JOIN financial_report r ON r.company_id = c.company_id
WHERE r.quarter_end = (SELECT max(r2.quarter_end) FROM financial_report r2 WHERE r2.company_id = c.company_id)
  AND r.return_on_equity > 15
  AND r.debt_to_equity < 100
ORDER BY r.return_on_equity DESC
LIMIT 50;

-- W1 WRITE: register a user
INSERT INTO app_user (name, email, password_hash)
VALUES ('New User', 'new.user@example.com', '$2b$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');

-- W2 WRITE: store the company snapshot fetched from the API (insert, or update when the ticker exists)
INSERT INTO company (ticker, name, price, last_price_date, market_cap, price_to_sales)
VALUES ('TCK02500', 'Company 2500', 151.2500, DATE '2026-11-16', 2600000000000, 7.5)
ON CONFLICT (ticker) DO UPDATE
   SET name = EXCLUDED.name, price = EXCLUDED.price, last_price_date = EXCLUDED.last_price_date,
       market_cap = EXCLUDED.market_cap, price_to_sales = EXCLUDED.price_to_sales;

-- W3 WRITE: store the latest quarter fetched from the API (insert, or update when already stored)
INSERT INTO financial_report (company_id, quarter_end, fiscal_year_end, gross_margin, operating_margin,
       return_on_assets, return_on_equity, revenue, ebitda, pat, total_cash, total_debt, debt_to_equity, current_ratio)
SELECT company_id, DATE '2026-09-30', DATE '2026-03-31', 46.5, 0.29, 0.19, 1.27,
       350000000000, 110000000000, 87000000000, 61000000000, 135000000000, 210.7, 1.06
FROM company WHERE ticker = 'TCK02500'
ON CONFLICT (company_id, quarter_end) DO UPDATE
   SET revenue = EXCLUDED.revenue, ebitda = EXCLUDED.ebitda, pat = EXCLUDED.pat,
       gross_margin = EXCLUDED.gross_margin, operating_margin = EXCLUDED.operating_margin,
       return_on_assets = EXCLUDED.return_on_assets, return_on_equity = EXCLUDED.return_on_equity,
       total_cash = EXCLUDED.total_cash, total_debt = EXCLUDED.total_debt,
       debt_to_equity = EXCLUDED.debt_to_equity, current_ratio = EXCLUDED.current_ratio;
