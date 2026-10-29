# Prepaid Electricity Metering — ER diagram

```mermaid
erDiagram
    direction LR
    account {
        bigint account_id PK
        text account_ref UK
        date opened_on
        boolean active
    }
    meter {
        bigint meter_id PK
        bigint account_id FK
        text serial_number UK
        date installed_on
        numeric balance_kwh
        boolean active
    }
    meter_event {
        bigint event_id PK
        bigint meter_id FK
        text event_type
        timestamptz occurred_at
        numeric quantity_kwh
        text reference
    }
    account ||--o{ meter : "account_id"
    meter ||--o{ meter_event : "meter_id"
```

PK identifies a record; FK links to another table; UK marks a single-field unique value. The relationship ends show exactly one, zero or one, or zero or many records. Composite unique keys and conditional rules are listed in the schema and design.

[Diagram image](../images/Musa_Idris_301917184_ERDiagram.png)
