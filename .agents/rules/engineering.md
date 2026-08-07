---
trigger: always_on
glob:
description:
---

### Verification and Auditing Integrity
* **Never accept placeholders as completion:** Do not treat scaffolded or placeholder code (e.g., hardcoded defaults, empty arrays, or stubbed methods) as a completed implementation during audits, code reviews, or sprint tasks.
* **End-to-End Data Flow Verification:** Verification of feature completion must involve tracing and confirming the actual data flow (e.g., confirming data physically moved from the local SQLite database to the remote Postgres server).
* **Reject surface-level smoke tests:** Do not evaluate success based solely on whether code compiles or if an endpoint returns a `200 OK` with mocked data. Real database integration and logic execution are required.
