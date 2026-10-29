// Run once in mongosh against a fresh exercise database.
// These records are fictional events for the case study.
(async function () {
  db = db.getSiblingDB('portfolio_nosql');
  if ((await db.getCollectionNames()).includes("meter_event_stream")) {
    throw new Error('The exercise collection already exists. Use a fresh database.');
  }

  // The validator checks the stable event fields while details can vary.
  await db.createCollection("meter_event_stream", {
    validator: {
    "$jsonSchema": {
        "bsonType": "object",
        "required": [
            "_id",
            "schemaVersion",
            "simulation",
            "eventType",
            "occurredAt",
            "source",
            "embedded",
            "references",
            "details"
        ],
        "properties": {
            "_id": {
                "bsonType": "string",
                "minLength": 1
            },
            "schemaVersion": {
                "enum": [
                    1
                ]
            },
            "simulation": {
                "enum": [
                    true
                ]
            },
            "eventType": {
                "bsonType": "string",
                "enum": [
                    "credit_loaded",
                    "energy_consumed"
                ]
            },
            "occurredAt": {
                "bsonType": "date"
            },
            "source": {
                "bsonType": "object",
                "required": [
                    "entity",
                    "key",
                    "snapshot"
                ],
                "properties": {
                    "entity": {
                        "enum": [
                            "meter_event"
                        ]
                    },
                    "key": {
                        "bsonType": "object",
                        "required": [
                            "event_id"
                        ]
                    },
                    "snapshot": {
                        "bsonType": "object"
                    }
                }
            },
            "embedded": {
                "bsonType": "object"
            },
            "references": {
                "bsonType": "object"
            },
            "details": {
                "bsonType": "object"
            }
        }
    }
},
    validationLevel: 'strict', validationAction: 'error'
  });

  // Insert the four example events and show their IDs.
  printjson(await db.getCollection("meter_event_stream").insertMany([
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
    },
    {
        "_id": "event_000002",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "energy_consumed",
        "occurredAt": ISODate("2030-01-01T10:01:00Z"),
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
            "channel": "mobile",
            "note": "Illustrative event-specific metadata",
            "examples": {
                "payment_reference": "illustrative payment_reference",
                "tariff_code": "illustrative tariff_code",
                "firmware_version": "illustrative firmware_version"
            }
        }
    }
]));
  await db.getCollection("meter_event_stream").createIndex({eventType: 1, occurredAt: -1}, {name: 'event_type_time'});

  // 1. Find the first sample event type (up to five documents).
  printjson(await db.getCollection("meter_event_stream").find({"eventType":"credit_loaded"}).sort({_id:1}).limit(5).toArray());

  // 2. Find events for the first source record using nested key fields (up to five).
  printjson(await db.getCollection("meter_event_stream").find({"source.key.event_id":3001}).sort({_id:1}).limit(5).toArray());

  // 3. Find events in the sample time range using a MongoDB Date filter (up to five).
  printjson(await db.getCollection("meter_event_stream").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray());

  // 4. Count documents for each event type.
  printjson(await db.getCollection("meter_event_stream").aggregate([{"$group":{"_id":"$eventType", "documentCount":{"$sum":1}}}, {"$sort":{"_id":1}}]).toArray());

  // A date stored as text should be rejected by the validator.
  try {
    await db.getCollection("meter_event_stream").insertOne({...{
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
}, _id: 'invalid_date_example', occurredAt: 'not-a-date'});
  } catch (error) { print('Invalid date error: ' + error.code); }

  // Reusing an event ID should be rejected by the unique _id index.
  try { await db.getCollection("meter_event_stream").insertOne({
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
}); }
  catch (error) { print('Duplicate ID error: ' + error.code); }

  print('Document count: ' + await db.getCollection("meter_event_stream").countDocuments());
})().catch(error => { print(error.stack || String(error)); quit(1); });
