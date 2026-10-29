-- Run these deliberately invalid statements one at a time, outside a transaction.
-- Each should fail at the named constraint; the sample rows should remain unchanged.

-- 1. account pk rejection. Expected: pk_account, SQLSTATE 23505.
INSERT INTO portfolio."account" ("account_id", "account_ref", "opened_on", "active")
VALUES (1001, 'ACCT-SYN-PK-TEST', '2025-03-01', TRUE);

-- 2. account unique rejection. Expected: uq_account_0, SQLSTATE 23505.
INSERT INTO portfolio."account" ("account_id", "account_ref", "opened_on", "active")
VALUES (10001, 'ACCT-SYN-001', '2025-03-02', TRUE);

-- 3. meter pk rejection. Expected: pk_meter, SQLSTATE 23505.
INSERT INTO portfolio."meter" ("meter_id", "account_id", "serial_number", "installed_on", "balance_kwh", "active")
VALUES (2001, 1001, 'MTR-SYN-PK-TEST', '2025-03-03', 1, TRUE);

-- 4. meter unique rejection. Expected: uq_meter_0, SQLSTATE 23505.
INSERT INTO portfolio."meter" ("meter_id", "account_id", "serial_number", "installed_on", "balance_kwh", "active")
VALUES (10002, 1001, 'MTR-SYN-001', '2025-03-04', 1, TRUE);

-- 5. meter fk rejection. Expected: fk_meter_0, SQLSTATE 23503.
INSERT INTO portfolio."meter" ("meter_id", "account_id", "serial_number", "installed_on", "balance_kwh", "active")
VALUES (10003, 999999, 'MTR-SYN-FK-TEST', '2025-03-05', 1, TRUE);

-- 6. meter not null rejection. Expected: serial_number, SQLSTATE 23502.
INSERT INTO portfolio."meter" ("meter_id", "account_id", "serial_number", "installed_on", "balance_kwh", "active")
VALUES (10004, 1001, NULL, '2025-03-06', 1, TRUE);

-- 7. meter check rejection. Expected: meter_balance_nonnegative, SQLSTATE 23514.
INSERT INTO portfolio."meter" ("meter_id", "account_id", "serial_number", "installed_on", "balance_kwh", "active")
VALUES (10005, 1001, 'MTR-SYN-CHECK-TEST', '2025-03-07', -1, TRUE);

-- 8. event pk rejection. Expected: pk_meter_event, SQLSTATE 23505.
INSERT INTO portfolio."meter_event" ("event_id", "meter_id", "event_type", "occurred_at", "quantity_kwh", "reference")
VALUES (3001, 2001, 'credit_loaded', '2025-03-08T10:00:00Z', 1, 'EVT-SYN-PK-TEST');

-- 9. event unique rejection. Expected: uq_meter_event_0, SQLSTATE 23505.
INSERT INTO portfolio."meter_event" ("event_id", "meter_id", "event_type", "occurred_at", "quantity_kwh", "reference")
VALUES (10006, 2001, 'credit_loaded', '2025-03-09T10:00:00Z', 1, 'EVT-SYN-001');

-- 10. event fk rejection. Expected: fk_meter_event_0, SQLSTATE 23503.
INSERT INTO portfolio."meter_event" ("event_id", "meter_id", "event_type", "occurred_at", "quantity_kwh", "reference")
VALUES (10007, 999999, 'credit_loaded', '2025-03-10T10:00:00Z', 1, 'EVT-SYN-FK-TEST');

-- 11. event check rejection. Expected: event_quantity_positive, SQLSTATE 23514.
INSERT INTO portfolio."meter_event" ("event_id", "meter_id", "event_type", "occurred_at", "quantity_kwh", "reference")
VALUES (10008, 2001, 'credit_loaded', '2025-03-11T10:00:00Z', 0, 'EVT-SYN-CHECK-TEST');
