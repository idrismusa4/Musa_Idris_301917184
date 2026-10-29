-- Show related account, meter, meter_event records (up to 20).
SELECT t0."account_id" AS "account_account_id",
       t0."account_ref" AS "account_account_ref",
       t1."meter_id" AS "meter_meter_id",
       t1."serial_number" AS "meter_serial_number",
       t2."event_id" AS "meter_event_event_id",
       t2."event_type" AS "meter_event_event_type"
FROM portfolio."account" t0
JOIN portfolio."meter" t1 ON t1."account_id" = t0."account_id"
JOIN portfolio."meter_event" t2 ON t2."meter_id" = t1."meter_id"
ORDER BY t0."account_id", t1."meter_id", t2."event_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT t0."account_id" AS "account_account_id",
       t0."account_ref" AS "account_account_ref",
       t1."meter_id" AS "meter_meter_id",
       t1."serial_number" AS "meter_serial_number",
       t2."event_id" AS "meter_event_event_id",
       t2."event_type" AS "meter_event_event_type"
FROM portfolio."account" t0
JOIN portfolio."meter" t1 ON t1."account_id" = t0."account_id"
JOIN portfolio."meter_event" t2 ON t2."meter_id" = t1."meter_id"
ORDER BY t0."account_id", t1."meter_id", t2."event_id"
LIMIT 20;

-- Find meter_event records where occurred_at matches "2025-02-03T10:30:00Z" (up to 20).
SELECT * FROM portfolio."meter_event"
WHERE "occurred_at" IS NOT DISTINCT FROM '2025-02-03T10:30:00Z'
ORDER BY "event_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM portfolio."meter_event"
WHERE "occurred_at" IS NOT DISTINCT FROM '2025-02-03T10:30:00Z'
ORDER BY "event_id"
LIMIT 20;

-- Count meter records for each account_id (up to 20 groups).
SELECT "account_id", count(*) AS record_count
FROM portfolio."meter"
GROUP BY "account_id"
ORDER BY record_count DESC, "account_id" NULLS LAST
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT "account_id", count(*) AS record_count
FROM portfolio."meter"
GROUP BY "account_id"
ORDER BY record_count DESC, "account_id" NULLS LAST
LIMIT 20;
