# Target Architecture

**Task ID:** OTN-30  
**Role:** Manual modernization-architect role (non-Bob, post-budget)  
**Date:** 2026-08-29  
**Status:** COMPLETE — Gate 3 APPROVED on 2026-08-29; WF-004 selected  
**Scope:** Architecture design only; no implementation

## 1. Evidence and Decision Boundary

- **VERIFIED:** Gate 2 was approved on 2026-08-29. Only findings labeled `VERIFIED` in the five consolidated Phase 2 documents are behavioral inputs.
- **VERIFIED:** The legacy snapshot contains 25 PRG files, 22 DBF schemas, no current NTX/CDX files, and only synthetic records (`analysis-summary.md` §2 and §10).
- **VERIFIED:** The application mixes UI, business rules, global state, work-area aliases, and persistence in PRG procedures (`migration-risks.md`, MR-003, MR-040, MR-041).
- **VERIFIED:** DBF storage provides no referential-integrity or transaction guarantees; multi-table operations can partially complete (`migration-risks.md`, MR-054 and MR-055; `MENU.PRG:3242–3246`).
- **UNKNOWN:** Missing callable implementations, runtime-only table schemas, and stakeholder intent remain outside the approved behavior baseline (`analysis-summary.md` §5).
- **TARGET DECISION:** Use a small offline modular desktop application in .NET + Avalonia + SQLite. This is a modernization decision, not a claim about legacy behavior.

This document was produced manually after the official IBM Bob budget was exhausted. Provenance is recorded in `bob_result/logs/manual-phase3-provenance.md`.

## 2. Architecture Options

Scores use 1 (poor) through 5 (strong). For “low complexity,” a higher score means less implementation and operational complexity.

| Option | Low complexity | Legacy-rule fidelity | Demo feasibility | Team ramp-up | Offline capability | Portability | Total / 30 |
|---|---:|---:|---:|---:|---:|---:|---:|
| **A. .NET + Avalonia + SQLite** | 4 | 5 | 5 | 4 | 5 | 5 | **28** |
| B. .NET + WPF + SQLite | 5 | 5 | 5 | 4 | 5 | 1 | 25 |
| C. ASP.NET Core + Blazor + PostgreSQL | 2 | 4 | 3 | 3 | 2 | 5 | 19 |

### Option A — .NET + Avalonia + SQLite

- **TARGET DECISION:** Best match for a self-contained, cross-platform desktop proof of concept.
- **VERIFIED basis:** The legacy system is an interactive desktop-style application with local/LAN file storage and no required production connection (`legacy-system-overview.md` §2, §5, §7).
- **Benefit:** Demonstrates clear before/after separation of screen, use-case, rule, and persistence concerns while remaining runnable offline.
- **Trade-off:** Avalonia introduces a framework learning cost compared with Windows-only WPF.

### Option B — .NET + WPF + SQLite

- **TARGET DECISION:** Technically feasible and simplest on Windows.
- **Trade-off:** Windows-only UI weakens portability and makes the architecture less reusable for future deployment options.
- **Disposition:** Viable fallback if Avalonia tooling blocks implementation, but not the recommended design.

### Option C — ASP.NET Core + Blazor + PostgreSQL

- **TARGET DECISION:** Better suited to a later multi-user deployment than to the bounded hackathon PoC.
- **Trade-off:** Adds server, network, deployment, identity, and database administration concerns that are unnecessary for the offline demonstration.
- **Disposition:** Defer until real concurrency and deployment requirements are known.

## 3. Recommended Architecture

Use a modular monolith with dependency direction from the UI and infrastructure toward application/domain contracts.

| Component | Responsibility | Evidence or rationale |
|---|---|---|
| Avalonia UI | Screens, form state, navigation, validation messages | **TARGET DECISION** addressing UI/business coupling in MR-040 |
| Presentation/ViewModels | Bind screen state to use-case requests; no SQL or business calculations | **TARGET DECISION** preserving testability and demo clarity |
| Application layer | One class per approved use case; transaction boundary; maps domain errors to results | **TARGET DECISION** addressing partial writes in MR-055 |
| Domain layer | Entities, value objects, and only Gate-3-approved rules | **TARGET DECISION** constrained by Gate 2 approval |
| Persistence ports | Repository and unit-of-work interfaces owned by the application layer | **TARGET DECISION** replacing implicit DBF work-area coupling in MR-041 |
| SQLite infrastructure | Tables, constraints, indexes, migrations, transactions | **TARGET DECISION** addressing MR-031, MR-054, and MR-055 |
| Synthetic fixture loader | Deterministic demo-only seed data | **VERIFIED constraint** from `AGENTS.md` and Gate 1 |
| Automated tests | Rule-level unit tests and SQLite integration tests | **TARGET DECISION** required for OTN-42 and OTN-50 |

### Dependency rules

1. Avalonia views must not reference SQLite, DBF files, or legacy aliases.
2. ViewModels call application use cases through explicit request/result types.
3. Domain code has no UI, file-system, network, clock, or database dependency.
4. SQLite access occurs only through infrastructure implementations.
5. Each write use case owns one SQLite transaction.
6. `INFERRED` or `UNKNOWN` legacy behavior may appear only as a documented exclusion, an explicit configurable target decision, or a failing/pending test—not as an approved rule.

## 4. Runtime and Repository Shape

The following structure is proposed only after Gate 3 approval:

```text
modernized/
  OldToNew.sln
  src/
    OldToNew.Domain/
    OldToNew.Application/
    OldToNew.Infrastructure.Sqlite/
    OldToNew.Desktop/
  tests/
    OldToNew.Domain.Tests/
    OldToNew.IntegrationTests/
  fixtures/
    synthetic-demo.json
```

- **TARGET DECISION:** Use the supported .NET LTS available in the environment at implementation time; do not pin a version until the local SDK is inspected during OTN-40.
- **TARGET DECISION:** Use Avalonia with MVVM, the standard SQLite provider for .NET, and a mainstream .NET test framework.
- **UNKNOWN:** The installed SDK and package-cache availability have not been checked because Execute remains outside Phase 3 scope.

## 5. Target Data Model Map

This map covers all 22 verified workspace DBFs while keeping the PoC implementation limited to the Gate-3-approved vertical slice. Target names are design decisions; source existence and fields are documented in `data-model.md` §1.

| Legacy DBF | Proposed SQLite table | PoC disposition | Confidence / constraint |
|---|---|---|---|
| PROVINCI | `provinces` | Deferred unless selected workflow needs it | **VERIFIED** lookup schema |
| AREAS | `collection_areas` | Deferred | **VERIFIED** schema |
| ATAUD | `coffin_catalog` | Include only for WF-004 reference data | **VERIFIED** `SUBNIVEL.FERETRO` lookup (`MENU.PRG:1391`) |
| BAJA | `cancellation_reasons` | Deferred | **VERIFIED** schema |
| bancos | `banks` | Exclude | **UNKNOWN** application role |
| cobrador | `collectors` | Include only for reservation/payment candidates | **VERIFIED** schema |
| COCHERIA | `funeral_homes` | Include only for WF-004 reference data | **VERIFIED** `SUBNIVEL.COCHERIA` lookup (`MENU.PRG:1387`) |
| CONTRAS | `users` / external identity | Exclude from PoC | **VERIFIED** plaintext legacy storage must not be copied; login inactive (`MENU.PRG:12,30–56`) |
| CTACTE | `installments` | Include only for WF-003 or WF-006 | **VERIFIED** logical plan rows |
| ctaexp | `expense_dues` | Include only for WF-005 or WF-007 | **VERIFIED** monthly ledger |
| FILTRO | `legacy_filter_staging` | Exclude | **UNKNOWN** active purpose |
| MAEASO | `legacy_association_master` | Exclude | **UNKNOWN** active purpose |
| mutual | `associations` | Include only for WF-003 | **VERIFIED** active lookup |
| parquenu | `parcels` | Include for WF-003 or WF-004 | **VERIFIED** logical key `CODIGO` (`MENU.PRG:3934–3951`) |
| PROMOTOR | `promoters` | Include only for WF-003 | **VERIFIED** schema |
| RECIBO | `receipts` | Include only for WF-006 | **UNKNOWN** uniqueness per reservation/installment; allow multiple rows |
| RENA | `bank_remittances` | Exclude | **UNKNOWN** write path |
| reserva | `reservations` | Include for WF-003, WF-005, WF-006, or WF-007 | **VERIFIED** master entity |
| SUBNIVEL | `interments` | Include for WF-004 | **VERIFIED** composite logical key `(CODIGO,NIVEL,SUBNIVEL)` (`MENU.PRG:3972,3975`) |
| SUPLENTE | `alternate_holders` | Include only for WF-003 | **VERIFIED** schema |
| titular | `parcel_holders` | Include only for WF-003 | **VERIFIED** schema |
| VALOREXP | `expense_rates` | Include only for reservation/expense candidates | **VERIFIED** schema; lookup policy remains a target decision because BR-012 position is UNKNOWN |

### Constraint policy

- Use integer primary keys only where the legacy key semantics are verified; preserve meaningful codes as unique alternate keys.
- Enable SQLite foreign-key enforcement for verified relationships (`migration-risks.md`, MR-054).
- Replace concatenated NTX expressions with typed composite indexes (`migration-risks.md`, MR-031; `MENU.PRG:3865–4089`).
- Store dates as ISO-8601 values through the .NET provider and validate them before persistence.
- Store identifiers such as document and receipt numbers as text when arithmetic is not part of verified behavior.
- Do not create constraints for `INFERRED` relationships until approved.

## 6. Gate-3 Candidate Slice: WF-004 if Approved

This is a contingent design, not a workflow selection.

### Minimal tables

`parcels`, `interments`, `funeral_homes`, and `coffin_catalog`.

### Minimal integrity rules

- **VERIFIED BR-060:** parcel code must exist (`MENU.PRG`, `AltaInhu()`, lines 280–303).
- **VERIFIED BR-061:** `(parcel_code, level, sublevel)` must be unique (`AltaInhu()`, lines 295–300).
- **VERIFIED BR-062:** every earlier sublevel in the same level must exist before the requested sublevel (`CargaSub()`, lines 314–321).
- **VERIFIED BR-063:** service type is `T` or `S` (`CargaSub()`, line 333).
- **VERIFIED BR-064:** level is 1–3 and sublevel is 1–6 (`AltaInhu()`, lines 289–290).

### Deliberate target differences

- Replace the unresolved `VerActiva()` call with a SQLite transaction and a unique constraint. This is a **TARGET DECISION**; the exact legacy locking behavior remains UNKNOWN.
- Return structured validation errors instead of screen-coordinate output.
- Persist the new interment only after all approved validations succeed.
- Use visibly synthetic names, documents, dates, funeral homes, and coffin descriptions.

## 7. Security, Privacy, and Operations

- No network or production connection.
- No plaintext password migration; authentication is out of PoC scope.
- No reading or transformation of root DBFs during normal PoC execution.
- SQLite database and fixtures live under `modernized/` and contain synthetic data only.
- Destructive PRGs and DBF maintenance operations are never invoked.
- Logs contain rule IDs, synthetic record keys, outcomes, and timings—not personal fields.

## 8. Quality Gates

1. Gate 3 selects exactly one workflow and its approved rules.
2. OTN-40 creates only the solution skeleton and deterministic synthetic database.
3. OTN-41 implements one vertical workflow, not the whole application.
4. OTN-42 maps every approved rule to automated tests.
5. OTN-50 independently checks input handling, calculations, state changes, outputs, errors, and unsupported cases.

## 9. UNKNOWN and Deferred Items

- Exact behavior of all 21 unresolved callable identifiers.
- Original multi-user and record-locking semantics.
- Runtime-only DBF schemas and production `Puesto` values.
- Stakeholder intent behind occupied-parcel reuse and the LIQUIDA formula divergence.
- Deployment, identity, audit-retention, backup, and production data-migration requirements.

None of these items is silently converted into PoC behavior.

## 10. Synthetic Data Statement

Only Gate-2-approved reports describing the sanitized snapshot were used. No production system, external service, real identifier, or non-synthetic record was accessed or introduced.
