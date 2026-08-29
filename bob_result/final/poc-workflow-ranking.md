# Proof-of-Concept Workflow Ranking

**Task ID:** OTN-31  
**Role:** Manual workflow-ranking review (non-Bob, post-budget)  
**Date:** 2026-08-29  
**Status:** COMPLETE — Gate 3 APPROVED on 2026-08-29; WF-004 selected  
**Scope:** Rank only the four candidates approved for evaluation in `analysis-summary.md` §6

## 1. Method

Scores use 1 (poor) through 5 (strong). The weighted total is out of 5.

| Criterion | Weight | Meaning of a high score |
|---|---:|---|
| Behavioral completeness | 25% | End-to-end inputs, validations, writes, and failures are known |
| PoC feasibility | 25% | Small dependency and data surface; no blocking missing artifact |
| Demo value | 20% | Clear before/after interaction and visible business value |
| Privacy safety | 15% | Easy to demonstrate with minimal synthetic sensitive fields |
| Available source evidence | 15% | Narrow PRG citations and verified rules cover the flow |

The scoring is a transparent planning estimate, not a measured result.

## 2. Ranking

| Rank | Candidate | Completeness | Feasibility | Demo | Privacy safety | Evidence | Weighted total |
|---:|---|---:|---:|---:|---:|---:|---:|
| **1** | **WF-004 New Inhumation** | 5 | 5 | 4 | 3 | 5 | **4.50** |
| 2 | WF-003 New Reservation | 4 | 2 | 5 | 3 | 5 | 3.70 |
| 3 | WF-005/006 Expense or Installment Collection | 4 | 2 | 4 | 3 | 4 | 3.35 |
| 4 | WF-007 Batch Expense Liquidation | 2 | 1 | 4 | 4 | 5 | 2.90 |

## 3. Evidence by Candidate

### Rank 1 — WF-004 New Inhumation

- **VERIFIED:** Complete path is traced through `MENU.PRG`, `AltaInhu()`, lines 246–360 and `CargaSub()`, lines 308–360 (`04-workflows.md`, WF-004).
- **VERIFIED:** BR-060 through BR-064 cover parcel existence, duplicate prevention, sequential sublevels, service type, and numeric ranges (`business-rules.md` §7).
- **VERIFIED:** Main persistence is one `SUBNIVEL` record; logical composite key is `(CODIGO,NIVEL,SUBNIVEL)` (`data-model.md` §1.19; `MENU.PRG:3972,3975`).
- **TARGET ASSESSMENT:** Strong visual demo with limited implementation surface and deterministic negative cases.
- **Privacy consideration:** Interment fields are sensitive in a real system, so fixtures and screen recordings must use unmistakably synthetic names/documents. No real data is needed.
- **Blocking UNKNOWN items:** None for BR-060 through BR-064. `VerActiva()` internals remain UNKNOWN but can be replaced explicitly by a SQLite transaction rather than imitated.

### Rank 2 — WF-003 New Reservation

- **VERIFIED:** Fully traced at `MENU.PRG`, `AltaReservas()`, lines 3058–3254 (`04-workflows.md`, WF-003).
- **VERIFIED:** Demonstrates multiple validations and writes across TITULAR, RESERVA, PARQUENU, SUPLENTE, and CTACTE.
- **Risk:** `AxPl`/`AxSupl` staging, non-atomic reservation numbering, five-table writes, month-end date overflow, and the occupied-parcel bypass materially increase scope (`migration-risks.md`, MR-014, MR-051, MR-052, MR-055, MR-060).
- **UNKNOWN/INFERRED:** Deterministic `ValorExp` selection and some payment-mode behavior are not approved requirements (BR-012, BR-105).
- **TARGET ASSESSMENT:** Excellent demo value, but too large for the safest first vertical slice.

### Rank 3 — WF-005/006 Collections

- **VERIFIED:** Expense collection is traced at `MENU.PRG:2566–2616,2618–2693,2929–3051`; installment collection at `MENU.PRG:2515–2564,2835–2925` (`04-workflows.md`, WF-005/WF-006).
- **VERIFIED:** FIFO application rules are documented in BR-041, BR-046, and BR-047.
- **Risk:** Missing `AuxiRes` schema, multi-record financial updates, partial payments, bonuses, future rows, and receipt multiplicity enlarge the validation matrix (`data-model.md` §5; `migration-risks.md`, MR-033 and MR-055).
- **TARGET ASSESSMENT:** Valuable but higher-risk than WF-004, especially for independent parity validation.

### Rank 4 — WF-007 Batch Expense Liquidation

- **VERIFIED:** Main path is traced at `MENU.PRG:889–976` and rules BR-030 through BR-034.
- **UNKNOWN:** `Pass1()` implementation and missing `ResuCta`/`AuxLiq` schemas.
- **UNRESOLVED DIVERGENCE:** MENU.PRG and LIQUIDA.PRG use different minimum-payment formulas (BR-033 and BR-033b); neither is authoritative after Gate 2.
- **TARGET ASSESSMENT:** Cannot provide defensible parity without a stakeholder formula decision, so it is unsuitable as the first PoC.

## 4. Recommendation for Gate 3

**RECOMMENDATION:** Approve **WF-004 New Inhumation** with only BR-060, BR-061, BR-062, BR-063, and BR-064 in scope.

Recommended implementation boundary:

- one parcel-search step;
- one interment-entry form;
- one atomic save;
- explicit validation messages for the five approved rules;
- deterministic synthetic fixtures;
- automated unit and SQLite integration tests;
- no authentication, reservation creation, payments, liquidation, reporting, modification, or production import.

BR-065 recent-interment highlighting is verified but excluded from the initial recommendation because it is a display/report concern rather than a requirement for creating an interment. It can be added only if the user explicitly includes it at Gate 3.

## 5. Gate 3 Decision

**APPROVED on 2026-08-29.** The user selected WF-004 New Inhumation with BR-060 through BR-064 only and explicitly excluded BR-065. Manual post-budget implementation was authorized only under `modernized/`.

## 6. Synthetic Data Statement

The ranking uses only Gate-2-approved reports and source citations contained in those reports. No PRG/DBF was modified and no production or real personal data was used.
