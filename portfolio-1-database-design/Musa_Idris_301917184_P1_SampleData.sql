-- Fictional sample records for Prepaid Electricity Metering.
BEGIN;
SET LOCAL standard_conforming_strings = on;
INSERT INTO portfolio."account" ("account_id", "account_ref", "opened_on", "active") VALUES (1001, 'ACCT-SYN-001', '2025-01-15', TRUE);
INSERT INTO portfolio."meter" ("meter_id", "account_id", "serial_number", "installed_on", "balance_kwh", "active") VALUES (2001, 1001, 'MTR-SYN-001', '2025-02-01', 12.5, TRUE);
INSERT INTO portfolio."meter_event" ("event_id", "meter_id", "event_type", "occurred_at", "quantity_kwh", "reference") VALUES (3001, 2001, 'credit_loaded', '2025-02-03T10:30:00Z', 12.5, 'EVT-SYN-001');
COMMIT;
