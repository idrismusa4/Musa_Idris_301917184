-- A separate performance table using the case's meter_event.occurred_at type.
-- Only this field and a lab row ID are copied. Business constraints stay in Portfolio 1.
-- Generated values are for measuring a selective lookup, not complete case records.
CREATE SCHEMA query_lab;
CREATE TABLE query_lab."meter_event" AS
SELECT "occurred_at", 0::bigint AS "lab_row_id" FROM portfolio."meter_event" WITH NO DATA;
INSERT INTO query_lab."meter_event" ("occurred_at", "lab_row_id")
SELECT (TIMESTAMPTZ '2030-01-01T00:00:00Z' + (g % 1000) * INTERVAL '1 second'), g FROM generate_series(1, 50000) AS g;
ANALYZE query_lab."meter_event";

-- Before: warm the lookup, then measure it three times.
SELECT "lab_row_id", "occurred_at"
FROM query_lab."meter_event"
WHERE "occurred_at" = (TIMESTAMPTZ '2030-01-01T00:00:00Z' + (42 % 1000) * INTERVAL '1 second')
ORDER BY "lab_row_id";
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "occurred_at"
FROM query_lab."meter_event"
WHERE "occurred_at" = (TIMESTAMPTZ '2030-01-01T00:00:00Z' + (42 % 1000) * INTERVAL '1 second')
ORDER BY "lab_row_id";
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "occurred_at"
FROM query_lab."meter_event"
WHERE "occurred_at" = (TIMESTAMPTZ '2030-01-01T00:00:00Z' + (42 % 1000) * INTERVAL '1 second')
ORDER BY "lab_row_id";
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "occurred_at"
FROM query_lab."meter_event"
WHERE "occurred_at" = (TIMESTAMPTZ '2030-01-01T00:00:00Z' + (42 % 1000) * INTERVAL '1 second')
ORDER BY "lab_row_id";

CREATE INDEX p2_filter_idx ON query_lab."meter_event" USING btree ("occurred_at");

-- After: run the same lookup and repeat the measurements.
SELECT "lab_row_id", "occurred_at"
FROM query_lab."meter_event"
WHERE "occurred_at" = (TIMESTAMPTZ '2030-01-01T00:00:00Z' + (42 % 1000) * INTERVAL '1 second')
ORDER BY "lab_row_id";
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "occurred_at"
FROM query_lab."meter_event"
WHERE "occurred_at" = (TIMESTAMPTZ '2030-01-01T00:00:00Z' + (42 % 1000) * INTERVAL '1 second')
ORDER BY "lab_row_id";
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "occurred_at"
FROM query_lab."meter_event"
WHERE "occurred_at" = (TIMESTAMPTZ '2030-01-01T00:00:00Z' + (42 % 1000) * INTERVAL '1 second')
ORDER BY "lab_row_id";
EXPLAIN (ANALYZE, BUFFERS)
SELECT "lab_row_id", "occurred_at"
FROM query_lab."meter_event"
WHERE "occurred_at" = (TIMESTAMPTZ '2030-01-01T00:00:00Z' + (42 % 1000) * INTERVAL '1 second')
ORDER BY "lab_row_id";
