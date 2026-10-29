# Prepaid Electricity Metering — database design

My case study records account, meter, meter_event.

## Users

- Utility account administrators
- Metering operations staff
- Customers reviewing meter activity

## Main operations

- Register an account and its meters.
- Record positive energy-credit or energy-consumption events and update the meter balance in the same transaction.
- Benchmark filtering meter events by occurrence date with 50000 synthetic event rows, comparing an unindexed filter plan with a B-tree index plan; record plans and row counts without assuming performance results.

## Entities

| Entity | Information stored |
| --- | --- |
| account | Represents a utility customer account that can own multiple meters. |
| meter | Represents a prepaid electricity meter and its current available energy balance. |
| meter_event | Stores a credit or consumption event recorded for a meter. |

## account

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| account_id | BIGINT | PK | Yes |
| account_ref | TEXT | Unique | Yes |
| opened_on | DATE |  | Yes |
| active | BOOLEAN |  | Yes |
- Unique key: (account_ref).

## meter

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| meter_id | BIGINT | PK | Yes |
| account_id | BIGINT | FK | Yes |
| serial_number | TEXT | Unique | Yes |
| installed_on | DATE |  | Yes |
| balance_kwh | NUMERIC(18,2) |  | Yes |
| active | BOOLEAN |  | Yes |
- account_id → account.account_id
- Unique key: (serial_number).

## meter_event

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| event_id | BIGINT | PK | Yes |
| meter_id | BIGINT | FK | Yes |
| event_type | TEXT |  | Yes |
| occurred_at | TIMESTAMPTZ |  | Yes |
| quantity_kwh | NUMERIC(18,2) |  | Yes |
| reference | TEXT |  | Yes |
- meter_id → meter.meter_id
- Unique key: (meter_id, reference).

## Relationships and business rules

- Every account reference identifies exactly one account.
- Every meter belongs to an existing account.
- Every meter serial number identifies exactly one meter.
- A meter's available energy balance must never be below zero.
- Every meter event refers to an existing meter.
- Every recorded credit or consumption event has a quantity greater than zero.
- An event reference may identify at most one event for a given meter.

## Assumptions

- All records and examples use synthetic data; no real customer names, account numbers, meter serials, or payment references are included.
- A meter belongs to exactly one account, and each event belongs to exactly one meter.
- Event quantities are positive kilowatt-hours; event type determines whether the quantity adds to or subtracts from the available meter balance.
- The meter balance is a transactionally maintained current value, and recorded events are retained as its history.
- For the worked normalization example, meter_event is decomposed through its meter_id foreign key into meter and then account, with each ancestor represented once.

