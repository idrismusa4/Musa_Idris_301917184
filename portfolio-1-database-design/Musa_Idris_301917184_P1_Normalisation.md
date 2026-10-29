# Prepaid Electricity Metering — normalisation

The example uses the saved sample records. The full set of fields is in the design and schema.

## Starting grouped records

| meter_id | meter_event records (list) |
| --- | --- |
| 2001 | [3001] |


The record IDs are grouped in a list. In 1NF, each record has its own row and each cell holds one value.

## 1NF: one value per cell

| meter_event.event_id | meter_event.meter_id | meter_event.event_type | meter.meter_id | meter.account_id | meter.serial_number | account.account_id | account.account_ref |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 3001 | 2001 | credit_loaded | 2001 | 1001 | MTR-SYN-001 | 1001 | ACCT-SYN-001 |

Key: event_id.

## 2NF: depend on the whole key

meter_event: meter_id is a proper part of candidate key (meter_id, reference), and determines meter details.

## meter_example

| meter.meter_id | meter.account_id | meter.serial_number | account.account_id | account.account_ref |
| --- | --- | --- | --- | --- |
| 2001 | 1001 | MTR-SYN-001 | 1001 | ACCT-SYN-001 |

## meter_event_example

| meter_event.event_id | meter_event.meter_id | meter_event.event_type |
| --- | --- | --- |
| 3001 | 2001 | credit_loaded |

## 3NF: store each entity’s details once

The entity keys determine their own descriptions. Related records keep foreign keys rather than repeating those descriptions.

## account

| account_id | account_ref | opened_on | active |
| --- | --- | --- | --- |
| 1001 | ACCT-SYN-001 | 2025-01-15 | true |

## meter

| meter_id | account_id | serial_number | installed_on | balance_kwh | active |
| --- | --- | --- | --- | --- | --- |
| 2001 | 1001 | MTR-SYN-001 | 2025-02-01 | 12.5 | true |

## meter_event

| event_id | meter_id | event_type | occurred_at | quantity_kwh | reference |
| --- | --- | --- | --- | --- | --- |
| 3001 | 2001 | credit_loaded | 2025-02-03T10:30:00+00:00 | 12.5 | EVT-SYN-001 |

## Dependencies

- account: (account_id) → account_ref, opened_on, active
- meter: (meter_id) → account_id, serial_number, installed_on, balance_kwh, active
- meter_event: (event_id) → meter_id, event_type, occurred_at, quantity_kwh, reference

Joining the decomposed sample tables reproduces the original 1 example rows. The design assumes the declared keys describe the relevant business dependencies.
