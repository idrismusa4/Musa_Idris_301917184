-- Prepaid Electricity Metering: tables, keys and business constraints.
-- Run once in a fresh PostgreSQL database.
BEGIN;
SET LOCAL standard_conforming_strings = on;
CREATE SCHEMA portfolio;
CREATE TABLE portfolio."account" (
  "account_id" bigint NOT NULL,
  "account_ref" text NOT NULL,
  "opened_on" date NOT NULL,
  "active" boolean NOT NULL,
  CONSTRAINT "pk_account" PRIMARY KEY ("account_id"),
  CONSTRAINT "uq_account_0" UNIQUE ("account_ref")
);
CREATE TABLE portfolio."meter" (
  "meter_id" bigint NOT NULL,
  "account_id" bigint NOT NULL,
  "serial_number" text NOT NULL,
  "installed_on" date NOT NULL,
  "balance_kwh" numeric(18,2) NOT NULL,
  "active" boolean NOT NULL,
  CONSTRAINT "pk_meter" PRIMARY KEY ("meter_id"),
  CONSTRAINT "uq_meter_0" UNIQUE ("serial_number")
);
CREATE TABLE portfolio."meter_event" (
  "event_id" bigint NOT NULL,
  "meter_id" bigint NOT NULL,
  "event_type" text NOT NULL,
  "occurred_at" timestamptz NOT NULL,
  "quantity_kwh" numeric(18,2) NOT NULL,
  "reference" text NOT NULL,
  CONSTRAINT "pk_meter_event" PRIMARY KEY ("event_id"),
  CONSTRAINT "uq_meter_event_0" UNIQUE ("meter_id", "reference")
);
ALTER TABLE portfolio."meter" ADD CONSTRAINT "fk_meter_0" FOREIGN KEY ("account_id") REFERENCES portfolio."account" ("account_id");
ALTER TABLE portfolio."meter_event" ADD CONSTRAINT "fk_meter_event_0" FOREIGN KEY ("meter_id") REFERENCES portfolio."meter" ("meter_id");
ALTER TABLE portfolio."meter" ADD CONSTRAINT "meter_balance_nonnegative" CHECK ("balance_kwh" >= 0);
ALTER TABLE portfolio."meter_event" ADD CONSTRAINT "event_quantity_positive" CHECK ("quantity_kwh" > 0);
COMMIT;
