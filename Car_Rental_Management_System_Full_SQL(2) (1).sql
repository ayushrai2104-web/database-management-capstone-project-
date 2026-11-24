/*
===============================================================================
CAR RENTAL MANAGEMENT SYSTEM
Database Management Capstone Project
Based on: AYUSH 2501420008.pdf (23 pages)
Dialect: SQLite 3.45+
===============================================================================

IMPORTANT:
1. Run this script in SQLite (DB Browser for SQLite / SQLite CLI).
2. The report describes a generated dataset (3 branches, 5 categories, 24 cars,
   18 customers and 248 rentals), but the PDF does NOT contain the full bulk
   INSERT script for those 248 rental rows. This file includes the complete
   schema and the SQL statements shown in the report, plus a small starter
   dataset so the database can be tested.
3. Dates are stored as TEXT in YYYY-MM-DD format, as in the report.
4. Run the sections in order. The script uses DROP IF EXISTS so it can be
   executed again from a clean state.
===============================================================================
*/

PRAGMA foreign_keys = ON;

-- ============================================================================
-- 1. DATABASE RESET
-- ============================================================================
DROP VIEW IF EXISTS v_customer_rental_summary;
DROP VIEW IF EXISTS v_available_cars;
DROP VIEW IF EXISTS v_car_fleet;

DROP TRIGGER IF EXISTS trg_no_double_booking;
DROP TRIGGER IF EXISTS trg_v_car_fleet_upd;

DROP TABLE IF EXISTS maintenance;
DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS cars;
DROP TABLE IF EXISTS car_categories;
DROP TABLE IF EXISTS branches;

-- ============================================================================
-- 2. TABLE CREATION
-- ============================================================================
CREATE TABLE branches (
    branch_id   INTEGER PRIMARY KEY,
    branch_name TEXT NOT NULL,
    city        TEXT NOT NULL
);

CREATE TABLE car_categories (
    category_id   INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE,
    daily_rate    INTEGER NOT NULL CHECK (daily_rate > 0)
);

CREATE TABLE cars (
    car_id      INTEGER PRIMARY KEY,
    reg_no      TEXT NOT NULL,
    make        TEXT NOT NULL,
    model       TEXT NOT NULL,
    year        INTEGER CHECK (year >= 2000),
    category_id INTEGER NOT NULL REFERENCES car_categories(category_id),
    branch_id   INTEGER NOT NULL REFERENCES branches(branch_id)
);

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    full_name   TEXT NOT NULL,
    phone       TEXT NOT NULL,
    email       TEXT,
    license_no  TEXT NOT NULL UNIQUE,
    city        TEXT
);

CREATE TABLE rentals (
    rental_id         INTEGER PRIMARY KEY,
    car_id            INTEGER NOT NULL REFERENCES cars(car_id),
    customer_id       INTEGER NOT NULL REFERENCES customers(customer_id),
    branch_id         INTEGER NOT NULL REFERENCES branches(branch_id),
    pickup_date       TEXT NOT NULL,
    return_date       TEXT NOT NULL,
    actual_return_date TEXT,
    daily_rate        INTEGER NOT NULL,
    late_fee          INTEGER NOT NULL DEFAULT 0,
    total_charge      INTEGER NOT NULL DEFAULT 0,
    status            TEXT NOT NULL DEFAULT 'BOOKED'
                      CHECK (status IN ('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED')),
    CHECK (return_date > pickup_date)
);

CREATE TABLE maintenance (
    maintenance_id INTEGER PRIMARY KEY,
    car_id         INTEGER NOT NULL REFERENCES cars(car_id),
    start_date     TEXT NOT NULL,
    end_date       TEXT,
    reason         TEXT
);

-- The report adds the registration-number unique index in the indexing section.
-- ============================================================================
-- 3. STARTER DATA
-- ============================================================================
INSERT INTO branches (branch_id, branch_name, city) VALUES
(1, 'Connaught Place', 'Delhi'),
(2, 'Andheri West', 'Mumbai'),
(3, 'Indiranagar', 'Bengaluru');

INSERT INTO car_categories (category_id, category_name, daily_rate) VALUES
(1, 'Economy', 1500),
(2, 'Sedan',   2200),
(3, 'SUV',     3500),
(4, 'Luxury',  7500),
(5, 'Van',     4200);

INSERT INTO cars (car_id, reg_no, make, model, year, category_id, branch_id) VALUES
(1,  'DL08RY8629', 'Maruti',   'Alto',          2024, 1, 1),
(2,  'MH09SG4025', 'Tata',     'Tiago',         2025, 1, 2),
(3,  'KA08UT4050', 'Renault',  'Kwid',          2021, 1, 3),
(4,  'DL08JE2485', 'Honda',    'City',          2025, 2, 1),
(5,  'MH13WJ1686', 'Hyundai',  'Verna',         2025, 2, 2),
(6,  'DL01QC1975', 'Skoda',    'Slavia',        2024, 2, 1),
(7,  'KA02SU4252', 'Maruti',   'Swift',         2025, 1, 3),
(8,  'MH04HT1492', 'Hyundai',  'Creta',         2025, 3, 2),
(9,  'KA06DS4200', 'Tata',     'Nexon',         2024, 3, 3),
(10, 'DL04UJ9188', 'Mahindra', 'XUV700',        2024, 3, 1),
(11, 'MH11CO5557', 'Kia',      'Seltos',        2025, 3, 2),
(12, 'KA12DA1981', 'Tata',     'Harrier',       2025, 3, 3),
(13, 'MH02SY2768', 'Audi',     'A4',            2024, 4, 2),
(14, 'KA09CW5161', 'BMW',      '3 Series',      2025, 4, 3),
(15, 'KA02JM2094', 'Toyota',   'Innova Crysta', 2024, 5, 3),
(16, 'DL14AW4498', 'Kia',      'Carens',        2025, 5, 1),
(17, 'MH01PM7511', 'Maruti',   'Ertiga',        2024, 5, 2),
(18, 'KA11MD7469', 'Mahindra', 'Marazzo',       2024, 5, 3),
(19, 'DL06CJ6449', 'Hyundai',  'i20',           2024, 1, 1),
(20, 'MH07YD3205', 'Honda',    'Amaze',         2024, 2, 2),
(21, 'KA07UJ3580', 'Maruti',   'Ciaz',          2024, 2, 3),
(22, 'MH09GX3145', 'Volvo',    'S90',            2024, 4, 3),
(23, 'DL01CA7788', 'Hyundai',  'Creta',         2024, 3, 1),
(24, 'KA05ON4200', 'Tata',     'Nexon',         2025, 3, 3);

INSERT INTO customers (customer_id, full_name, phone, email, license_no, city) VALUES
(1, 'Aarav Sharma',  '9818000001', 'aarav@example.com',  'DL01A0000001', 'Delhi'),
(2, 'Priya Nair',   '9818000002', 'priya@example.com',   'MH01B0000002', 'Mumbai'),
(3, 'Rohan Gupta',  '9818000003', 'rohan@example.com',   'DL01C0000003', 'Delhi'),
(4, 'Tanvi Agarwal','9818045521', 'tanvi.agarwal@example.com', 'DL0420240098765', 'New Delhi'),
(5, 'Neha Kapoor',  '9818000005', 'neha@example.com',    'MH01D0000005', 'Mumbai'),
(6, 'Ishita Bansal','9818000006', 'ishita@example.com',  'DL01E0000006', 'Delhi');

-- Starter bookings are examples only; the original report's 248-row generated
-- rental dataset is not printed in the PDF.
INSERT INTO rentals
(rental_id, car_id, customer_id, branch_id, pickup_date, return_date,
 actual_return_date, daily_rate, late_fee, total_charge, status)
VALUES
(1, 1, 1, 1, '2026-01-15', '2026-01-19', '2026-01-19', 1500, 0, 6000, 'COMPLETED'),
(2, 2, 2, 2, '2026-01-17', '2026-01-20', '2026-01-20', 1500, 0, 4500, 'COMPLETED'),
(3, 3, 3, 3, '2026-01-18', '2026-01-22', '2026-01-22', 1500, 0, 6000, 'COMPLETED');

INSERT INTO maintenance (maintenance_id, car_id, start_date, end_date, reason) VALUES
(1, 5, '2026-11-10', NULL, 'Routine service'),
(2, 9, '2026-11-12', '2026-11-16', 'Brake inspection');

-- ============================================================================
-- 4. BASIC TABLE COUNTS / SAMPLE READS
-- ============================================================================
SELECT 'branches' AS table_name, COUNT(*) AS row_count FROM branches
UNION ALL SELECT 'car_categories', COUNT(*) FROM car_categories
UNION ALL SELECT 'cars', COUNT(*) FROM cars
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'rentals', COUNT(*) FROM rentals
UNION ALL SELECT 'maintenance', COUNT(*) FROM maintenance;

SELECT status, COUNT(*) AS rentals
FROM rentals
GROUP BY status;

SELECT * FROM cars
ORDER BY car_id
LIMIT 5;

SELECT rental_id AS id, car_id AS car, customer_id AS cust,
       pickup_date AS pickup, return_date AS due,
       actual_return_date AS returned, daily_rate AS rate,
       late_fee, total_charge AS total, status
FROM rentals
ORDER BY rental_id
LIMIT 5;

-- ============================================================================
-- 5. CRUD OPERATIONS
-- ============================================================================

-- 5.1 CREATE: add a customer and a car.
-- Use a unique phone/license/registration number if you run this again.
INSERT INTO customers (full_name, phone, email, license_no, city)
VALUES ('Tanvi Agarwal', '9818045521', 'tanvi.agarwal@example.com',
        'DL0420240098765', 'New Delhi');

INSERT INTO cars (reg_no, make, model, year, category_id, branch_id)
VALUES ('DL01CA7788', 'Hyundai', 'Creta', 2024, 3, 1);

-- Create a booking and fetch the category's daily rate automatically.
INSERT INTO rentals
(car_id, customer_id, branch_id, pickup_date, return_date,
 daily_rate, total_charge, status)
SELECT c.car_id, cu.customer_id, c.branch_id, '2026-11-20', '2026-11-24',
       cat.daily_rate, 4 * cat.daily_rate, 'BOOKED'
FROM cars c
JOIN car_categories cat USING (category_id)
JOIN customers cu ON cu.phone = '9818045521'
WHERE c.reg_no = 'DL01CA7788';

-- 5.2 READ: active and booked rentals with customer and car details.
SELECT r.rental_id AS id, cu.full_name AS customer, c.reg_no,
       c.make || ' ' || c.model AS car,
       r.pickup_date AS pickup, r.return_date AS due, r.status
FROM rentals r
JOIN customers cu USING (customer_id)
JOIN cars c USING (car_id)
WHERE r.status IN ('ACTIVE', 'BOOKED')
ORDER BY r.pickup_date, r.rental_id
LIMIT 10;

-- Customer lookup by phone number.
SELECT customer_id AS id, full_name, phone, email, license_no, city
FROM customers
WHERE phone = '9818045521';

-- 5.3 UPDATE: update a customer's contact details.
UPDATE customers
SET phone = '9818099001', city = 'Gurugram'
WHERE phone = '9818045521';

SELECT customer_id AS id, full_name, phone, city
FROM customers
WHERE email = 'tanvi.agarwal@example.com';

-- Return a rental and calculate late fee (1.5 times the daily rate per late day).
-- The report's example uses rental_id 233 and a return date of 2026-11-11.
UPDATE rentals
SET actual_return_date = '2026-11-11',
    status = 'COMPLETED',
    late_fee = MAX(0, CAST(julianday('2026-11-11') - julianday(return_date) AS INTEGER))
              * daily_rate * 3 / 2
WHERE rental_id = 233 AND status = 'ACTIVE';

UPDATE rentals
SET total_charge =
    CAST(julianday(return_date) - julianday(pickup_date) AS INTEGER)
    * daily_rate + late_fee
WHERE rental_id = 233;

SELECT rental_id AS id, return_date AS due,
       actual_return_date AS returned, late_fee, total_charge AS total, status
FROM rentals
WHERE rental_id = 233;

-- 5.4 DELETE: a customer with no rental records can be deleted.
INSERT INTO customers (full_name, phone, email, license_no, city)
VALUES ('Test Entry', '9000000000', 'test@example.com', 'TEST0000', 'Delhi');

DELETE FROM customers WHERE phone = '9000000000';

SELECT COUNT(*) AS test_rows_left
FROM customers
WHERE phone = '9000000000';

-- This delete is expected to fail when the customer has rental records:
-- DELETE FROM customers WHERE customer_id = 1;

-- ============================================================================
-- 6. RENTAL CHARGES, HISTORY AND AVAILABILITY
-- ============================================================================

-- 6.1 Charge breakdown for completed late returns.
SELECT rental_id AS id, pickup_date AS pickup, return_date AS due,
       actual_return_date AS returned, daily_rate AS rate,
       CAST(julianday(return_date) - julianday(pickup_date) AS INTEGER) AS days,
       CAST(julianday(actual_return_date) - julianday(return_date) AS INTEGER) AS late_days,
       late_fee, total_charge AS total
FROM rentals
WHERE status = 'COMPLETED'
  AND actual_return_date > return_date
ORDER BY rental_id
LIMIT 6;

-- Check stored totals against the charge formula.
SELECT COUNT(*) AS rentals_checked,
       SUM(total_charge <>
           CAST(julianday(return_date) - julianday(pickup_date) AS INTEGER)
           * daily_rate + late_fee) AS mismatches
FROM rentals
WHERE status <> 'CANCELLED';

-- Revenue and late fees by category.
SELECT cat.category_name AS category,
       COUNT(*) AS rentals,
       SUM(r.total_charge) AS revenue,
       SUM(r.late_fee) AS late_fees
FROM rentals r
JOIN cars c USING (car_id)
JOIN car_categories cat USING (category_id)
WHERE r.status = 'COMPLETED'
GROUP BY cat.category_id
ORDER BY revenue DESC;

-- 6.2 Rental history for one customer (customer_id = 2).
SELECT r.rental_id AS id, c.reg_no,
       c.make || ' ' || c.model AS car,
       r.pickup_date AS pickup, r.actual_return_date AS returned,
       r.total_charge AS charge,
       CASE WHEN r.actual_return_date > r.return_date
            THEN 'LATE' ELSE 'on time' END AS return_status
FROM rentals r
JOIN cars c USING (car_id)
WHERE r.customer_id = 2 AND r.status = 'COMPLETED'
ORDER BY r.pickup_date DESC
LIMIT 8;

-- Rental history for one car (registration number shown in the report).
SELECT r.rental_id AS id, cu.full_name AS customer,
       r.pickup_date AS pickup, r.return_date AS due,
       r.actual_return_date AS returned, r.total_charge AS charge, r.status
FROM rentals r
JOIN customers cu USING (customer_id)
WHERE r.car_id = (SELECT car_id FROM cars WHERE reg_no = 'DL01QC1975')
ORDER BY r.pickup_date DESC
LIMIT 8;

-- 6.3 Find cars free over a requested date range.
-- A booking overlaps the requested range when both date intervals intersect.
SELECT c.car_id AS id, c.reg_no,
       c.make || ' ' || c.model AS car,
       cat.category_name AS category, b.branch_name AS branch
FROM cars c
JOIN car_categories cat USING (category_id)
JOIN branches b USING (branch_id)
WHERE NOT EXISTS (
    SELECT 1
    FROM rentals r
    WHERE r.car_id = c.car_id
      AND r.status <> 'CANCELLED'
      AND r.pickup_date < '2026-11-18'
      AND r.return_date > '2026-11-15'
)
AND NOT EXISTS (
    SELECT 1
    FROM maintenance m
    WHERE m.car_id = c.car_id
      AND m.start_date < '2026-11-18'
      AND COALESCE(m.end_date, '9999-12-31') > '2026-11-15'
)
ORDER BY b.branch_id, cat.category_id, c.reg_no;

-- 6.4 Prevent overlapping bookings using a BEFORE INSERT trigger.
CREATE TRIGGER trg_no_double_booking
BEFORE INSERT ON rentals
WHEN EXISTS (
    SELECT 1
    FROM rentals r
    WHERE r.car_id = NEW.car_id
      AND r.status <> 'CANCELLED'
      AND r.pickup_date < NEW.return_date
      AND r.return_date > NEW.pickup_date
)
BEGIN
    SELECT RAISE(ABORT, 'Car already booked for these dates');
END;

-- Example test (uncomment to test; it should be rejected if dates overlap):
-- INSERT INTO rentals
-- (car_id, customer_id, branch_id, pickup_date, return_date,
--  daily_rate, total_charge, status)
-- VALUES (1, 1, 1, '2026-11-22', '2026-11-25', 1500, 4500, 'BOOKED');

-- Fleet status by branch: maintenance, rented, available and fleet count.
SELECT b.branch_name AS branch,
       SUM(m.car_id IS NOT NULL) AS maintenance,
       SUM(a.car_id IS NOT NULL) AS rented,
       SUM(m.car_id IS NULL AND a.car_id IS NULL) AS available,
       COUNT(*) AS fleet
FROM cars c
JOIN branches b USING (branch_id)
LEFT JOIN (
    SELECT DISTINCT car_id FROM maintenance WHERE end_date IS NULL
) m ON m.car_id = c.car_id
LEFT JOIN (
    SELECT DISTINCT car_id FROM rentals WHERE status = 'ACTIVE'
) a ON a.car_id = c.car_id
GROUP BY b.branch_id;

-- Overdue active rentals.
SELECT r.rental_id AS id, c.reg_no, cu.full_name AS customer,
       r.return_date AS due,
       CAST(julianday('2026-11-11') - julianday(r.return_date) AS INTEGER) AS days_overdue
FROM rentals r
JOIN cars c USING (car_id)
JOIN customers cu USING (customer_id)
WHERE r.status = 'ACTIVE'
  AND r.return_date < '2026-11-11';

-- ============================================================================
-- 7. INDEXING
-- ============================================================================

-- Query plan before indexes (example overlap check).
EXPLAIN QUERY PLAN
SELECT *
FROM rentals
WHERE car_id = 7 AND status <> 'CANCELLED'
  AND pickup_date < '2026-12-05'
  AND return_date > '2026-12-01';

-- Four indexes from the report.
CREATE INDEX IF NOT EXISTS idx_rentals_car_dates
ON rentals (car_id, pickup_date, return_date);

CREATE UNIQUE INDEX IF NOT EXISTS ux_cars_reg_no
ON cars (reg_no);

CREATE INDEX IF NOT EXISTS idx_customers_phone
ON customers (phone);

CREATE INDEX IF NOT EXISTS idx_customers_email
ON customers (email);

-- List indexes.
SELECT name AS index_name, tbl_name AS on_table
FROM sqlite_master
WHERE type = 'index' AND sql IS NOT NULL
ORDER BY tbl_name, name;

-- Query plan after the composite index.
EXPLAIN QUERY PLAN
SELECT *
FROM rentals
WHERE car_id = 7 AND status <> 'CANCELLED'
  AND pickup_date < '2026-12-05'
  AND return_date > '2026-12-01';

-- Covering-index example from the report.
EXPLAIN QUERY PLAN
SELECT COUNT(*)
FROM rentals
WHERE car_id = 7 AND pickup_date < '2026-12-05'
  AND return_date > '2026-12-01';

-- Unique-index duplicate test (expected to fail; uncomment to test).
-- INSERT INTO cars (reg_no, make, model, year, category_id, branch_id)
-- VALUES ('DL01CA7788', 'Kia', 'Sonet', 2025, 3, 1);

-- Phone and email lookups use their indexes.
EXPLAIN QUERY PLAN
SELECT * FROM customers WHERE phone = '9818099001';

EXPLAIN QUERY PLAN
SELECT * FROM customers WHERE email = 'tanvi.agarwal@example.com';

-- Examples where these indexes are not useful.
EXPLAIN QUERY PLAN
SELECT * FROM rentals WHERE return_date >= '2026-11-01';

EXPLAIN QUERY PLAN
SELECT * FROM customers WHERE phone LIKE '%4321';

-- ============================================================================
-- 8. VIEWS
-- ============================================================================

-- 8.1 Available cars view.
CREATE VIEW v_available_cars AS
SELECT c.car_id, c.reg_no, c.make, c.model,
       cat.category_name, cat.daily_rate, b.branch_name
FROM cars c
JOIN car_categories cat USING (category_id)
JOIN branches b USING (branch_id)
WHERE c.car_id NOT IN (
    SELECT car_id FROM rentals WHERE status = 'ACTIVE'
)
AND c.car_id NOT IN (
    SELECT car_id FROM maintenance WHERE end_date IS NULL
);

SELECT car_id AS id, reg_no,
       make || ' ' || model AS car,
       category_name AS category, daily_rate AS rate, branch_name AS branch
FROM v_available_cars
ORDER BY branch_name, category_name, reg_no;

-- 8.2 Customer rental summary view.
CREATE VIEW v_customer_rental_summary AS
SELECT c.customer_id, c.full_name,
       COUNT(r.rental_id) AS total_rentals,
       COALESCE(SUM(r.total_charge), 0) AS total_spend,
       COALESCE(SUM(r.actual_return_date > r.return_date), 0) AS late_returns
FROM customers c
LEFT JOIN rentals r
       ON r.customer_id = c.customer_id
      AND r.status = 'COMPLETED'
GROUP BY c.customer_id, c.full_name;

SELECT *
FROM v_customer_rental_summary
ORDER BY total_spend DESC
LIMIT 10;

-- 8.3 Simple view and update-through-view demonstration.
CREATE VIEW v_car_fleet AS
SELECT car_id, reg_no, make, model, year, branch_id
FROM cars;

-- SQLite requires an INSTEAD OF trigger for updating this view.
CREATE TRIGGER trg_v_car_fleet_upd
INSTEAD OF UPDATE ON v_car_fleet
BEGIN
    UPDATE cars
    SET reg_no = NEW.reg_no,
        make = NEW.make,
        model = NEW.model,
        year = NEW.year,
        branch_id = NEW.branch_id
    WHERE car_id = OLD.car_id;
END;

-- Example update through the simple view.
-- UPDATE v_car_fleet SET year = 2025 WHERE reg_no = 'DL01CA7788';

-- An aggregate view such as v_customer_rental_summary is not directly
-- updatable in SQLite; UPDATE against it is expected to fail.
-- UPDATE v_customer_rental_summary SET total_spend = 0 WHERE customer_id = 1;

-- ============================================================================
-- 9. WINDOW FUNCTIONS
-- ============================================================================

-- 9.1 RANK(): top three customers by spend within each branch.
SELECT branch_name, full_name, total_spend, spend_rank
FROM (
    SELECT b.branch_name, c.full_name,
           SUM(r.total_charge) AS total_spend,
           RANK() OVER (
               PARTITION BY b.branch_id
               ORDER BY SUM(r.total_charge) DESC
           ) AS spend_rank
    FROM rentals r
    JOIN customers c ON c.customer_id = r.customer_id
    JOIN branches b ON b.branch_id = r.branch_id
    WHERE r.status = 'COMPLETED'
    GROUP BY b.branch_id, c.customer_id
)
WHERE spend_rank <= 3
ORDER BY branch_name, spend_rank;

-- 9.2 Running monthly revenue per branch using a CTE and SUM() OVER.
WITH monthly AS (
    SELECT b.branch_name,
           substr(r.actual_return_date, 1, 7) AS month,
           SUM(r.total_charge) AS revenue
    FROM rentals r
    JOIN branches b ON b.branch_id = r.branch_id
    WHERE r.status = 'COMPLETED'
    GROUP BY b.branch_id, month
)
SELECT branch_name, month, revenue,
       SUM(revenue) OVER (
           PARTITION BY branch_name
           ORDER BY month
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_revenue
FROM monthly
ORDER BY branch_name, month;

-- 9.3 LAG(): gap between consecutive rentals for a customer.
SELECT c.full_name, r.rental_id AS id,
       r.pickup_date AS pickup,
       r.actual_return_date AS returned,
       LAG(r.actual_return_date) OVER w AS prev_returned,
       CAST(
           julianday(r.pickup_date) -
           julianday(LAG(r.actual_return_date) OVER w)
           AS INTEGER
       ) AS gap_days
FROM rentals r
JOIN customers c USING (customer_id)
WHERE r.customer_id = 2 AND r.status = 'COMPLETED'
WINDOW w AS (PARTITION BY r.customer_id ORDER BY r.pickup_date)
ORDER BY r.pickup_date
LIMIT 12;

-- 9.4 ROW_NUMBER(): most frequently rented car in each category.
WITH car_counts AS (
    SELECT cat.category_name, c.reg_no,
           c.make || ' ' || c.model AS car,
           COUNT(*) AS times_rented
    FROM rentals r
    JOIN cars c USING (car_id)
    JOIN car_categories cat USING (category_id)
    WHERE r.status IN ('COMPLETED', 'ACTIVE')
    GROUP BY c.car_id
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY category_name
               ORDER BY times_rented DESC, reg_no
           ) AS rn
    FROM car_counts
)
SELECT category_name AS category, reg_no, car, times_rented
FROM ranked
WHERE rn = 1
ORDER BY category_name;

-- ============================================================================
-- 10. OPTIONAL MYSQL 8 CONVERSION NOTES
-- ============================================================================
-- SQLite INTEGER PRIMARY KEY       -> MySQL INT AUTO_INCREMENT PRIMARY KEY
-- SQLite TEXT dates (YYYY-MM-DD)    -> MySQL DATE
-- julianday(date2)-julianday(date1) -> DATEDIFF(date2, date1)
-- substr(date, 1, 7)                -> DATE_FORMAT(date, '%Y-%m')
-- EXPLAIN QUERY PLAN                -> EXPLAIN
-- PRAGMA foreign_keys = ON          -> InnoDB foreign keys are enabled by default
-- RAISE(ABORT, 'message')           -> SIGNAL SQLSTATE '45000'
-- SQLite view update trigger        -> Simple MySQL views may be automatically updatable

-- ============================================================================
-- END OF PROJECT SQL
-- ============================================================================
