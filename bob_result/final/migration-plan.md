# Migration Plan

**Task ID:** OTN-30  
**Role:** Manual modernization-architect role (non-Bob, post-budget)  
**Date:** 2026-08-29  
**Status:** COMPLETE — OTN-50 independent validation PASS; Gate 4 APPROVED  
**Target:** .NET + Avalonia + SQLite proof of concept

## 1. Scope

- **VERIFIED:** The requested outcome is one representative end-to-end workflow, not a full-system migration (`AGENTS.md`, Mission and Bob-owned scope).
- **VERIFIED:** Gate 2 approved only `VERIFIED` legacy findings; all `INFERRED` and `UNKNOWN` items remain outside the requirements baseline (`analysis-summary.md` §8).
- **TARGET DECISION:** Use an incremental strangler-style proof of concept: document the full boundary, implement one isolated vertical slice, validate it, and leave all other legacy behavior untouched.

This plan was prepared manually after IBM Bob reached the official budget limit. See `bob_result/logs/manual-phase3-provenance.md`.

## 2. Phase Plan

| Step | Backlog ID | Work | Exit criterion |
|---|---|---|---|
| 1 | Gate 3 | User selects exactly one ranked workflow | Written approval names one workflow and accepted rule IDs |
| 2 | OTN-40 | Inspect local .NET tooling; create solution and projects only under `modernized/` | Solution restores/builds or limitation is recorded |
| 3 | OTN-40 | Add SQLite schema/migrations and visibly synthetic fixtures for selected slice | Database can be recreated deterministically |
| 4 | OTN-41 | Implement domain rules and application use case | Use case passes approved happy/error examples without UI |
| 5 | OTN-41 | Add Avalonia screen and connect it to the use case | End-to-end synthetic demo succeeds offline |
| 6 | OTN-42 | Add rule-mapped unit and integration tests | Every approved rule has at least one positive and one relevant negative test |
| 7 | OTN-50 | Independent comparison against approved evidence | Parity, differences, and unsupported cases documented |
| 8 | Gate 4 | Correct verified discrepancies only | User accepts parity and explicit target differences |
| 9 | OTN-60–62 | Produce English submission package and demo narrative | Repository, evidence, metrics, script, and checklist complete |

## 3. Workflow Effort and Risk

Estimates are relative planning categories, not measured elapsed time.

| Candidate | Relative effort | Primary blockers | Migration risk |
|---|---|---|---|
| WF-004 New Inhumation | Small | None blocking; unresolved `VerActiva()` is replaced as a target decision | Low–Medium |
| WF-003 New Reservation | Large | Five persistent writes, two missing staging schemas, non-atomic numbering, ambiguous occupied-parcel rule, date overflow | High |
| WF-005/006 Collections | Medium–Large | Missing `AuxiRes` schema, FIFO multi-record updates, receipts and financial edge cases | High |
| WF-007 Batch Expense Liquidation | Large | Missing `Pass1`, `ResuCta`, and `AuxLiq`; two divergent minimum formulas | Critical until stakeholder decision |

Evidence: `analysis-summary.md` §6; `migration-risks.md` MR-003, MR-030, MR-033, MR-051, MR-052, MR-055, MR-060; `business-rules.md` BR-030–BR-047.

## 4. Recommended Gate-3 Slice

**RECOMMENDATION (not approval):** Select WF-004 New Inhumation.

If approved, include:

- Parcel lookup from synthetic `parcels` data.
- Level/sublevel entry.
- Burial/interment form using synthetic values.
- BR-060 through BR-064 exactly as verified.
- One atomic SQLite insert into `interments`.
- Clear success and validation-error states.
- Unit and SQLite integration tests mapped to every included rule.

Exclude:

- Reservation creation, payments, liquidation, reports, modification, exhumation, authentication, printers, and production import.
- BR-065 recent-interment highlighting unless explicitly added at Gate 3; it is verified but not necessary for the creation workflow.
- Any assumption about `VerActiva()` internals.

## 5. Data Approach

### Proof of concept

1. Create SQLite only under `modernized/`.
2. Seed deterministic synthetic parcels, funeral homes, coffin catalog entries, and existing interments.
3. Include at least:
   - one parcel with no interments;
   - one parcel with sublevel 1 present so sublevel 2 is valid;
   - one duplicate composite key case;
   - one missing-prior-sublevel case;
   - invalid level, sublevel, and service-type cases.
4. Never import the root DBFs during the demo or tests.

### Future migration, outside PoC

- Build a read-only extractor in an isolated migration tool.
- Validate row counts, key collisions, encodings, date validity, numeric precision, and orphan relationships before load.
- Quarantine `UNKNOWN` tables and relationships instead of guessing.
- Load reference tables before dependent tables and use a single controlled migration transaction per bounded batch.
- Reconcile results without modifying the source DBFs.

## 6. Rule-to-Test Plan for Recommended Slice

| Rule | Test intent | Expected result |
|---|---|---|
| BR-060 | Existing vs missing parcel | Missing parcel rejected; no insert |
| BR-061 | Existing composite `(parcel, level, sublevel)` | Duplicate rejected; row count unchanged |
| BR-062 | Prior sublevels complete vs missing | Requested sublevel accepted only when all previous values exist |
| BR-063 | `T`, `S`, and invalid service type | `T`/`S` accepted; other values rejected |
| BR-064 | Boundaries 1/3 and 1/6 plus out-of-range values | Boundaries accepted; invalid values rejected |
| Transaction decision | Inject persistence failure | No partial interment row remains |

Each test result must cite its rule ID in the test name or metadata and be summarized in `bob_result/logs/`.

## 7. Risk Controls

| Risk | Control |
|---|---|
| Legacy file mutation | No code path receives a root DBF/PRG path; repository checks verify legacy timestamps/hashes before and after work |
| Rule invention | Requirements manifest contains only Gate-3-approved rule IDs |
| Hidden locking behavior | Record the SQLite transaction/unique constraint as a deliberate target difference |
| Referential-integrity gaps | Enable SQLite foreign keys and test rejection behavior |
| Sensitive domain fields | Fixtures use explicit `DEMO`/`SYNTHETIC` values; screenshots avoid account details |
| Scope expansion | One use case, one screen flow, one bounded schema slice |
| Unmeasured impact claims | Capture actual command durations and counts; label estimates as estimates |

## 8. Measurement Plan

No improvement value is claimed yet. During OTN-40 through OTN-50 record:

- solution creation, build, and test elapsed time from command output;
- number of approved rule IDs implemented;
- tests mapped per approved rule;
- passing/failed test counts;
- verified parity count, accepted-difference count, and UNKNOWN count;
- manual steps needed to locate each selected rule using the generated documentation.

Any comparison baseline must record its method and timestamp. Parallel-agent benefits already demonstrated by Bob may be described using actual session evidence only.

## 9. Gate 3 Outcome

Gate 3 was approved on 2026-08-29 for WF-004 with BR-060 through BR-064 only; BR-065 was explicitly excluded. OTN-40 through OTN-42 were implemented exclusively under `modernized/`. OTN-50 independently validated all five rules with 21/21 tests passing and no verified discrepancy. Gate 4 was approved on 2026-08-29. The user accepted direct entry of the composed parcel code and modern English messages with rule identifiers as deliberate target-system differences; no implementation correction was required.

## 10. Synthetic Data Statement

This plan uses only the sanitized Phase 2 reports and proposes visibly synthetic fixtures. It does not use, request, or connect to production data.
