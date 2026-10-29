# Portfolio 4 — NoSQL and Advanced Data Models

I used MongoDB collection meter_event_stream for credit_loaded and energy_consumed events. These are fictional event examples based on account, meter, meter_event.

## Document model

| Field | Meaning |
| --- | --- |
| _id | Unique string event ID |
| eventType | One of the two selected case event labels |
| occurredAt | Native BSON Date; sample timestamps are in 2030 |
| source | Original entity, primary key and saved JSON snapshot |
| embedded | Linked record snapshots read with the event |
| references | Keys for linked sources kept outside the embedded snapshots |
| details | Event metadata whose fields vary |

Related meter, account details are stored as snapshots with the event. This makes an event readable in one document. It duplicates some information, and later SQL changes do not automatically update the snapshots. PostgreSQL continues to enforce the relational rules.

## Example document

```javascript
{
    "_id": "event_000001",
    "schemaVersion": 1,
    "simulation": true,
    "eventType": "credit_loaded",
    "occurredAt": ISODate("2030-01-01T10:00:00Z"),
    "source": {
        "entity": "meter_event",
        "key": {
            "event_id": 3001
        },
        "snapshot": {
            "event_id": 3001,
            "meter_id": 2001,
            "event_type": "credit_loaded",
            "occurred_at": "2025-02-03T10:30:00Z",
            "quantity_kwh": 12.5,
            "reference": "EVT-SYN-001"
        }
    },
    "embedded": {
        "meter": [
            {
                "key": {
                    "meter_id": 2001
                },
                "snapshot": {
                    "meter_id": 2001,
                    "account_id": 1001,
                    "serial_number": "MTR-SYN-001",
                    "installed_on": "2025-02-01",
                    "balance_kwh": 12.5,
                    "active": true
                },
                "via": [
                    "meter_event.meter_id → meter"
                ]
            }
        ],
        "account": [
            {
                "key": {
                    "account_id": 1001
                },
                "snapshot": {
                    "account_id": 1001,
                    "account_ref": "ACCT-SYN-001",
                    "opened_on": "2025-01-15",
                    "active": true
                },
                "via": [
                    "meter_event.meter_id → meter.account_id → account"
                ]
            }
        ]
    },
    "references": {},
    "details": {
        "channel": "web"
    }
}
```

## Queries and results

| Query | Returned documents |
| --- | --- |
| Find the first sample event type (up to five documents). | 1 |
| Find events for the first source record using nested key fields (up to five). | 2 |
| Find events in the sample time range using a MongoDB Date filter (up to five). | 2 |
| Count documents for each event type. | 2 |

## 1. Find the first sample event type (up to five documents).

```javascript
db.getCollection("meter_event_stream").find({"eventType":"credit_loaded"}).sort({_id:1}).limit(5).toArray();
```

Selected fields from the returned documents:

```json
[
  {
    "_id": "event_000001",
    "eventType": "credit_loaded",
    "occurredAt": {
      "$date": "2030-01-01T10:00:00Z"
    },
    "source": {
      "event_id": 3001
    }
  }
]
```

## 2. Find events for the first source record using nested key fields (up to five).

```javascript
db.getCollection("meter_event_stream").find({"source.key.event_id":3001}).sort({_id:1}).limit(5).toArray();
```

Selected fields from the returned documents:

```json
[
  {
    "_id": "event_000001",
    "eventType": "credit_loaded",
    "occurredAt": {
      "$date": "2030-01-01T10:00:00Z"
    },
    "source": {
      "event_id": 3001
    }
  },
  {
    "_id": "event_000002",
    "eventType": "energy_consumed",
    "occurredAt": {
      "$date": "2030-01-01T10:01:00Z"
    },
    "source": {
      "event_id": 3001
    }
  }
]
```

## 3. Find events in the sample time range using a MongoDB Date filter (up to five).

```javascript
db.getCollection("meter_event_stream").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray();
```

Selected fields from the returned documents:

```json
[
  {
    "_id": "event_000001",
    "eventType": "credit_loaded",
    "occurredAt": {
      "$date": "2030-01-01T10:00:00Z"
    },
    "source": {
      "event_id": 3001
    }
  },
  {
    "_id": "event_000002",
    "eventType": "energy_consumed",
    "occurredAt": {
      "$date": "2030-01-01T10:01:00Z"
    },
    "source": {
      "event_id": 3001
    }
  }
]
```

## 4. Count documents for each event type.

```javascript
db.getCollection("meter_event_stream").aggregate([{"$group":{"_id":"$eventType", "documentCount":{"$sum":1}}}, {"$sort":{"_id":1}}]).toArray();
```

| _id | documentCount |
| --- | --- |
| credit_loaded | 1 |
| energy_consumed | 1 |

## Validation and suitability

MongoDB inserted 2 documents. An invalid date type was rejected with code 121 and a repeated event ID with 11000. The collection still contained 2 valid documents. The compound eventType/occurredAt index supports those access fields; this exercise does not measure its speed.

The details field can vary across event types, while the common fields have a validator. Events can be added as separate documents rather than growing one large history record.

## Run the script

Connect mongosh to a fresh exercise database and run Musa_Idris_301917184_P4_MongoDB.js. It selects portfolio_nosql, creates the collection, inserts the sample documents and displays the query results. [Implementation evidence](screenshots/Musa_Idris_301917184_P4_DocumentsAndQueries.png).

## References

- [MongoDB — data modelling](https://www.mongodb.com/docs/manual/data-modeling/)

