# Phase 2 Analysis Summary

**Task ID:** OTN-25  
**Persona:** Bob (orchestrator consolidation)  
**Date:** 2026-08-28  
**Status:** COMPLETE — Gate 2 APPROVED by the user on 2026-08-29  
**Inputs:** OTN-20 (`01-source-inventory.md`), OTN-21 (`02-data-model.md`), OTN-22 (`03-business-rules.md`), OTN-23 (`04-workflows.md`), OTN-24 (`05-migration-risks.md`)

**Provenance note:** IBM Bob generated and consolidated OTN-25. After the official Bobcoin budget was exhausted, a manual consistency-only correction replaced stale approximate wording for unresolved callable identifiers; no new business-rule analysis was added. See `bob_result/logs/manual-post-budget-correction.md`.

---

## 1. Purpose

This document summarizes the consolidated findings from five independent Phase 2 analysis tasks, identifies agreements and resolved conflicts between reports, highlights the most important VERIFIED facts and highest-priority UNKNOWN items, and provides the Gate 2 review package for the user.

---

## 2. Cross-Report Agreement (All Five Reports Agree)

The following findings were independently confirmed by two or more Phase 2 reports and are raised to the highest confidence level:

| Finding | Reports | Label |
|---------|---------|-------|
| 25 PRG files in workspace root; MENU.PRG (4131 lines) is the canonical entry point | OTN-20, OTN-22, OTN-23, OTN-24 | VERIFIED |
| Authentication (`Contrasenia()`) is commented out at `MENU.PRG:12`; system launches without login | OTN-20, OTN-22, OTN-23 | VERIFIED |
| 22 DBF files; `bancos.dbf` is Visual FoxPro format (0x30); no PRG opens it | OTN-20, OTN-21, OTN-24 | VERIFIED |
| `CONTRAS.DBF` stores passwords as plaintext C(10) fields | OTN-21, OTN-22, OTN-24 | VERIFIED |
| `BuscaDatos()` writes `CtaCte.Saldo` and `Recibo.Cuota` during "Reservas y Cuotas" query | OTN-22, OTN-23, OTN-24 | VERIFIED |
| `INFORME.PRG` uses alias `Parque`; MENU.PRG uses `ParqueNu` — confirmed inconsistency | OTN-20, OTN-21, OTN-23 | VERIFIED |
| MENU.PRG minimum payment formula (BR-033): 30% of total, rounded up to next whole installment | OTN-22, OTN-23 | VERIFIED |
| LIQUIDA.PRG minimum payment formula (BR-033b): 30% of total, capped at total — diverges from MENU.PRG | OTN-22 (flagged); OTN-20 (function noted) | VERIFIED |
| `GrabaExpCta()` at `MENU.PRG:3011` uses `DbGoBottom()` — confirmed bottom-record rate read | OTN-21, OTN-22 | VERIFIED |
| `GrabaReserva()` at `MENU.PRG:3431` reads `ValorExp->ValorExpen` without `DbGoBottom()` — record position UNKNOWN | OTN-21, OTN-22 | INFERRED/UNKNOWN |
| No transaction support — multi-table writes not wrapped in any BEGIN/COMMIT | OTN-22, OTN-23, OTN-24 | VERIFIED |
| `FTMENUTO.CH` include is missing; 21 unresolved custom callable identifiers identified; `Contesta()`, `DbUnLock()`, and `DbSelectAr()` correctly excluded; original container UNKNOWN | OTN-20, OTN-23, OTN-24 | VERIFIED |
| BORRA, AGRGA, CARVALOR, CTA01, REPL are permanent destructive utilities — must never run during analysis | OTN-20, OTN-22, OTN-24 | VERIFIED |
| `Puesto='26'` in MENU.PRG gates exclusive ImpCob/ImpMut; MENU1.PRG uses `Puesto='01'` | OTN-20, OTN-24 | VERIFIED |
| Liquidation scan starts unconditionally from January 1991 (`MENU.PRG:878–879`) | OTN-22, OTN-23 | VERIFIED |

---

## 3. Conflicts Identified and Resolved

| Conflict | Source Reports | Resolution Applied |
|----------|---------------|-------------------|
| OTN-20 and OTN-23 stated INFORME.PRG is "called by" MENU.PRG | OTN-20, OTN-23 vs evidence | Corrected: both contain independent `Inhumacion()` implementations. The runtime relationship (separately compiled, linked, or absent from the active path) is UNKNOWN. `Parque` alias inconsistency is VERIFIED. |
| OTN-23 reported whole-file line ranges for COBRA.PRG and LIQUIDA.PRG | OTN-23 | All citations replaced with specific function/line references in the consolidated documents. |
| MENU1.PRG described as "identical duplicate" in some report sections | OTN-20 section 11 | Corrected throughout: MENU1.PRG is a historical variant with confirmed behavioral differences at `OpenDbf()` (Puesto gate) and `ImpriM()` (column widths). |
| LIQUIDA.PRG minimum payment formula differs from MENU.PRG | OTN-22 (flagged) | Confirmed as genuine divergence — two separately VERIFIED formulas (BR-033, BR-033b). Both write to `ResuCta.Minimo`. Which formula is authoritative is UNKNOWN pending stakeholder approval at Gate 3. Neither formula is designated as canonical during OTN-25. |
| INFERRED observations from the security review (OTN-10) regarding migration concerns | OTN-10 | Not propagated as approved business behavior. All Phase 2 reports independently verified from PRG source. |

No factual contradictions between the five Phase 2 reports were found after the above corrections were applied.

---

## 4. Key VERIFIED Facts for Gate 2 Review

### System Architecture
- LAN file-sharing, multi-workstation, Clipper/xBase, NTX indexes. Not web-based, not client-server.
- One primary entry point: `MENU.PRG` → `OpenDbf()` opens 28 table aliases at startup.
- Authentication: currently inactive (commented out).
- The missing `FTMENUTO.CH` include and the 21 unresolved callable identifiers are related only by an INFERRED dependency; the identifiers' implementations and original container are UNKNOWN.

### Core Data Model
- **Primary entity chain:** `reserva` → `parquenu` (1:1) → `SUBNIVEL` (1:N interments)
- **Billing chain:** `reserva` → `ctaexp` (1:N monthly dues) + `CTACTE` (1:N installment plan) → `RECIBO` (payment receipts)
- **14+ virtual/runtime tables** with no persistent DBF in the workspace; schemas reconstructed from write patterns only.

### Critical Business Rules (VERIFIED)
1. Minimum payment = `Reserva->Expensa × (Int(xTotal × 0.30 / Reserva->Expensa) + 1)` — rounded up to next whole installment.
2. Liquidation scans from January 1991 unconditionally on every run.
3. Expense rate at reservation creation: `GrabaReserva()` reads current-record `ValorExp->ValorExpen` (position UNKNOWN); `GrabaExpCta()` explicitly reads the bottom record.
4. Batch liquidation is password-gated (`Pass1('DEMO00')` at `MENU.PRG:233`); other operations are unguarded.
5. `BuscaDatos()` reconciles `CtaCte.Saldo` every time a user opens the "Reservas y Cuotas" query — this is a write side effect of a read operation.

### Top Migration Risks (VERIFIED)
1. Plaintext passwords in CONTRAS.DBF — must not be replicated.
2. Missing FTMENUTO include / original support artifacts — the implementations behind 21 unresolved callable identifiers must be investigated and, if required by the selected PoC, replaced deliberately.
3. No transaction support — partial multi-table writes can corrupt the database.
4. Per-workstation macro table pattern (`Puesto` variable) cannot be statically analyzed or directly ported.
5. `BuscaDatos()` hidden write must be separated into an explicit reconciliation operation.

---

## 5. UNKNOWN Items Requiring Stakeholder Resolution

These items cannot be resolved from the available source evidence. They must be addressed through stakeholder interviews or empirical testing — no production data access is required or permitted.

| Priority | ID | Item | Impact on Migration |
|----------|----|------|---------------------|
| HIGH | U-01 | `VerActiva()` locking behavior — in missing library | Concurrency design cannot proceed without knowing the locking strategy |
| HIGH | U-02 | `Pass1()` password check algorithm | Maintenance gate behavior cannot be replicated |
| HIGH | U-03 | `Hojear()` edit behavior — used for all modification workflows | Entire Modificación de Parcelas / Reservas path is inside the missing library |
| HIGH | U-04 | Production Puesto value | Which workstation gets exclusive ImpCob/ImpMut access is UNKNOWN |
| HIGH | U-05 | Whether COBRA.PRG and LIQUIDA.PRG are used in production | Standalone paths contain stale hardcoded dates; they may be fully obsolete |
| MEDIUM | U-06 | INFORME.PRG runtime relationship to MENU.PRG | Whether the `Parque` alias inconsistency causes a runtime failure is UNKNOWN |
| MEDIUM | U-07 | Whether the occupied-parcel `Loop` being commented out is intentional | Business rule BR-014 has an explicitly bypassed guard — confirmed behavior or defect? |
| MEDIUM | U-08 | `bancos.dbf` (VFP format) — role and owning process | Cannot assess bank integration scope without this |
| LOW | U-09 | `MAEASO.DBF` — superseded or still populated elsewhere | Can be excluded from PoC scope if stakeholder confirms it is obsolete |
| LOW | U-10 | Payment types Tarjeta (Op=2) and Socio (Op=4) in `Facturar()` — no installment creation code | Whether these types create a plan is UNKNOWN |

---

## 6. Proof-of-Concept Workflow Candidates (evaluated in OTN-31)

The following workflows formed the approved input to OTN-31. The completed ranking and recommendation are in `bob_result/final/poc-workflow-ranking.md`; the user must still select exactly one workflow at Gate 3.

| Workflow | Evidence Quality | Key VERIFIED rules | Key UNKNOWN items |
|----------|-----------------|-------------------|-------------------|
| **WF-003 New Reservation** — data validation, parcel assignment, installment plan creation, rate snapshot | HIGH — fully traced `MENU.PRG:3058–3254` | BR-010, BR-011, BR-013, BR-014, BR-015, BR-020, BR-021, BR-022 | BR-012 rate read position (INFERRED); `AxPl` schema |
| **WF-007 Batch Expense Liquidation** — password gate, FIFO accumulation, minimum payment, ResuCta writes | HIGH — fully traced `MENU.PRG:889–976` | BR-030, BR-031, BR-032, BR-033/BR-033b (divergent), BR-034 | `Pass1()` implementation; authoritative minimum-payment formula |
| **WF-004 New Inhumation** — parcel lookup, sequential SubNivel constraint, data entry and save | HIGH — fully traced `MENU.PRG:246–360` | BR-060, BR-061, BR-062, BR-063, BR-064 | None blocking |
| **WF-005/006 Expense or Installment Collection** — cobrador validation, staging, FIFO payment application | HIGH — traced `MENU.PRG:2515–2616, 2929–3051` | BR-040, BR-041, BR-043, BR-044, BR-046, BR-047 | `AuxiRes` schema INFERRED |

---

## 7. Phase 2 Output Summary

| Document | Path | Status |
|----------|------|--------|
| Legacy System Overview | `bob_result/final/legacy-system-overview.md` | Complete |
| Verified Business Rules | `bob_result/final/business-rules.md` | Complete |
| Logical Data Model | `bob_result/final/data-model.md` | Complete |
| Migration Risks | `bob_result/final/migration-risks.md` | Complete |
| This document | `bob_result/final/analysis-summary.md` | Complete |
| Source Inventory (raw) | `bob_result/agents/01-source-inventory.md` | Preserved |
| Data Model (raw) | `bob_result/agents/02-data-model.md` | Preserved |
| Business Rules (raw) | `bob_result/agents/03-business-rules.md` | Preserved |
| Workflow Reconstruction (raw) | `bob_result/agents/04-workflows.md` | Preserved |
| Migration Risk (raw) | `bob_result/agents/05-migration-risks.md` | Preserved |

---

## 8. Gate 2 Checklist

Gate 2 was explicitly approved by the user on 2026-08-29. The approval accepts only `VERIFIED` findings as approved behavior, keeps all `INFERRED` and `UNKNOWN` items outside the requirements baseline, and defers selection of the single PoC workflow to Gate 3.

- [x] The five `bob_result/final/` documents accurately represent the verified legacy behavior.
- [x] No INFERRED rule is classified as an approved business requirement.
- [x] The LIQUIDA.PRG minimum-payment divergence remains documented; neither formula is approved as authoritative.
- [x] The occupied-parcel assignment bypass (`//Loop` at `MENU.PRG:3503`) remains ambiguous and is not converted into a target requirement.
- [x] The `BuscaDatos()` hidden-write side effect is accepted as documented legacy behavior, not as a target design requirement.
- [x] The UNKNOWN items in §5 remain open questions and are not treated as requirements.
- [x] Selection of exactly one PoC workflow is deferred to Gate 3.

---

## 9. Measurements

All counts were derived from the corrected OTN-25 consolidated documents. No timing or productivity measurements are included — those require a reproducible baseline not yet established.

| Metric | Value | Method |
|--------|-------|--------|
| PRG files inventoried | 25 | Direct file count (`01-source-inventory.md`) |
| MENU.PRG functions/procedures | 87 | Source line scan, corrected header (`01-source-inventory.md:75`) |
| Functions/procedures across COBRA, LIQUIDA, INFORME, BANCODIS, CCTA | 13 | Source line scan (3 + 6 + 2 + 1 + 1) |
| DBF files analyzed (all schemas) | 22 (all 22 schemas parsed; `bancos.dbf` included; its application role is UNKNOWN) | Binary header parsing (`02-data-model.md`) |
| VERIFIED business rules | 46 (BR-001 to BR-074 with gaps, including BR-033b) | Counted from `bob_result/final/business-rules.md` |
| INFERRED business rules | 6 (BR-100 to BR-105) | Counted from `bob_result/final/business-rules.md` |
| UNKNOWN business-rule items | 10 (UNK-001 to UNK-010) | Counted from `bob_result/final/business-rules.md` |
| Migration risks documented | 38 (MR-001 to MR-063 with gaps) | Counted from `bob_result/final/migration-risks.md` |
| CRITICAL + HIGH risks | 23 (2 CRITICAL: MR-050, MR-030; 21 HIGH) | Counted from `bob_result/final/migration-risks.md` after MR-032 severity added |
| Runtime-only virtual tables (no workspace DBF) | 14+ | OTN-21 (`02-data-model.md`) |
| Unresolved custom callable symbols (not in any PRG; not Clipper/xBase runtime) | 21 (verified count — see `01-source-inventory.md §7` for full list) | Corrected: `Contesta()` removed (defined at `MENU.PRG:2760`); `DbUnLock()` and `DbSelectAr()` removed (standard runtime) |
| Parallel analysis tasks | 5 (OTN-20 through OTN-24) | This session |
| Cross-report conflicts resolved | 5 | OTN-25 §3 |
| Cross-report agreements independently confirmed | 15 (updated — BR-033b agreement added) | §2 above |

> All counts are evidence-based and derived from the corrected consolidated documents. Estimates are labeled with `~`. No fabricated timing or productivity numbers are included.

---

## 10. Synthetic Data Statement

All Phase 2 analysis was performed exclusively on the 25 PRG source files and 22 DBF files containing 45 fully synthetic demo records. No production data, real customer names, financial values, credentials, or personally identifiable information was accessed, reproduced, or transmitted.

---

*End of OTN-25 Phase 2 Analysis Summary*
