# Prepaid Electricity Metering — SQL queries

## 1. Show related account, meter, meter_event records (up to 20).

```sql
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
```

| account_account_id | account_account_ref | meter_meter_id | meter_serial_number | meter_event_event_id | meter_event_event_type |
| --- | --- | --- | --- | --- | --- |
| 1001 | ACCT-SYN-001 | 2001 | MTR-SYN-001 | 3001 | credit_loaded |

## 2. Find meter_event records where occurred_at matches "2025-02-03T10:30:00Z" (up to 20).

```sql
SELECT * FROM portfolio."meter_event"
WHERE "occurred_at" IS NOT DISTINCT FROM '2025-02-03T10:30:00Z'
ORDER BY "event_id"
LIMIT 20;
```

| event_id | meter_id | event_type | occurred_at | quantity_kwh | reference |
| --- | --- | --- | --- | --- | --- |
| 3001 | 2001 | credit_loaded | 2025-02-03T10:30:00+00:00 | 12.5 | EVT-SYN-001 |

## 3. Count meter records for each account_id (up to 20 groups).

```sql
SELECT "account_id", count(*) AS record_count
FROM portfolio."meter"
GROUP BY "account_id"
ORDER BY record_count DESC, "account_id" NULLS LAST
LIMIT 20;
```

| account_id | record_count |
| --- | --- |
| 1001 | 1 |


## Index comparison

| Phase | Median (ms) | Three runs (ms) | Plan nodes | Buffer hits |
| --- | --- | --- | --- | --- |
| Before index | 2.274 | 2.243, 2.3, 2.274 | Sort → Seq Scan | 274 |
| After index | 0.298 | 0.298, 0.274, 0.306 | Sort → Bitmap Heap Scan → Bitmap Index Scan | 55 |

The median execution time changed from 2.274 ms to 0.298 ms. The measured plan used p2_filter_idx. The results matched in both phases. An index adds storage and write-maintenance costs; timings depend on the selected lookup and environment.

## Execution plans

### Before index, run 1

```text
Sort (actual time=2.211..2.214 rows=50 loops=1)
  Seq Scan on meter_event (actual time=0.015..2.175 rows=50 loops=1)
Planning Time: 0.347 ms
Execution Time: 2.243 ms
```

### Before index, run 2

```text
Sort (actual time=2.268..2.271 rows=50 loops=1)
  Seq Scan on meter_event (actual time=0.014..2.231 rows=50 loops=1)
Planning Time: 0.352 ms
Execution Time: 2.3 ms
```

### Before index, run 3

```text
Sort (actual time=2.24..2.243 rows=50 loops=1)
  Seq Scan on meter_event (actual time=0.016..2.201 rows=50 loops=1)
Planning Time: 0.369 ms
Execution Time: 2.274 ms
```

### After index, run 1

```text
Sort (actual time=0.219..0.222 rows=50 loops=1)
  Bitmap Heap Scan on meter_event (actual time=0.033..0.182 rows=50 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.016..0.017 rows=50 loops=1)
Planning Time: 0.554 ms
Execution Time: 0.298 ms
```

### After index, run 2

```text
Sort (actual time=0.214..0.217 rows=50 loops=1)
  Bitmap Heap Scan on meter_event (actual time=0.032..0.179 rows=50 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.016..0.017 rows=50 loops=1)
Planning Time: 0.561 ms
Execution Time: 0.274 ms
```

### After index, run 3

```text
Sort (actual time=0.245..0.248 rows=50 loops=1)
  Bitmap Heap Scan on meter_event (actual time=0.057..0.208 rows=50 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.021..0.022 rows=50 loops=1)
Planning Time: 0.541 ms
Execution Time: 0.306 ms
```

## Reproduce

Use a fresh database with the Portfolio 1 schema and sample data. Run Musa_Idris_301917184_P2_Queries.sql, then Musa_Idris_301917184_P2_Optimisation.sql. The optimisation script creates a separate performance table and runs EXPLAIN (ANALYZE, BUFFERS).

[Query screenshot](screenshots/Musa_Idris_301917184_P2_QueryResults.png) · [Index comparison](screenshots/Musa_Idris_301917184_P2_IndexComparison.png)

## References

- [PostgreSQL — EXPLAIN](https://www.postgresql.org/docs/17/using-explain.html)

