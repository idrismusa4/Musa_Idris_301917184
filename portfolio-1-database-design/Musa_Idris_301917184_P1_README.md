# Portfolio 1 — Database Design and Modelling

I organised the data into account, meter, meter_event. The design document explains the fields, keys, relationships and business rules. The normalisation document shows the sample tables at 1NF, 2NF and 3NF.

## Database checks

| Table | Rows |
| --- | --- |
| account | 1 |
| meter | 1 |
| meter_event | 1 |

The 11 invalid inserts were rejected at their expected constraints, and the valid sample rows remained unchanged.

## Files

- [Design](Musa_Idris_301917184_P1_Design.md)
- [ER diagram](Musa_Idris_301917184_P1_ERDiagram.md)
- [Normalisation](Musa_Idris_301917184_P1_Normalisation.md)
- [Schema](Musa_Idris_301917184_P1_Schema.sql)
- [Sample data](Musa_Idris_301917184_P1_SampleData.sql)
- [Constraint tests](Musa_Idris_301917184_P1_ConstraintTests.sql)
- [Table and constraint evidence](screenshots/Musa_Idris_301917184_P1_DatabaseResults.png)

## Run the SQL

Create a fresh PostgreSQL database. Run the schema first, then the sample data. Run the deliberately invalid statements in ConstraintTests.sql individually outside a transaction; each is expected to produce an error.

## References

- [PostgreSQL — constraints](https://www.postgresql.org/docs/17/ddl-constraints.html)

