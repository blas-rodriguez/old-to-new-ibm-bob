# Legacy System Overview

**Task ID:** OTN-25 (consolidation of OTN-20 through OTN-24)  
**Date:** 2026-08-28  
**Status:** COMPLETE — Gate 2 APPROVED on 2026-08-29  
**Source reports:** `01-source-inventory.md`, `02-data-model.md`, `03-business-rules.md`, `04-workflows.md`, `05-migration-risks.md`

---

## 1. System Identity

**Label:** VERIFIED  
**Evidence:** `MENU.PRG` lines 9–10 (sanitized demo values); `AGENTS.md` workspace description.

This is a Clipper/xBase cemetery management application. It manages burial plot reservations, inhumation records, recurring expense billing, installment-plan collection, and statistical reporting for a single cemetery operator. The application runs on a local area network with multiple operator workstations sharing DBF files through file-system locking.

All values shown in this document are derived from the sanitized demo workspace. No production data was accessed.

---

## 2. Technology Stack

| Layer | Technology | Status |
|-------|-----------|--------|
| Language | Clipper/xBase (CA-Clipper 5.x) | VERIFIED — syntax and idioms confirmed throughout all PRG files |
| Data storage | dBASE III DBF format (version byte 3) | VERIFIED — binary header inspection of 21 of 22 DBF files |
| Data storage exception | `bancos.dbf` — Visual FoxPro format (version byte 0x30 / 48) | VERIFIED — binary header; no PRG opens this file |
| Indexes | NTX (Clipper-native) | VERIFIED — `MENU.PRG`, `OpenDbf()`, lines 3865–4089 (45 index definitions) |
| UI library | FTMENUTO.CH (include missing; 21 custom callable identifiers unresolved) | INFERRED — `///#Include "FTMENUTO.CH"` at `MENU.PRG:1`; original container (library or archive) UNKNOWN; 21 project-specific identifiers unresolvable (see MR-030) |
| Deployment model | LAN file-sharing; multi-workstation | INFERRED — per-workstation `Puesto` variable, shared table opens, record locking via `VerActiva()` |
| FoxPro file (`cpzero.prg`) | Not part of the Clipper application | VERIFIED — FoxPro-specific syntax; excluded from all analysis |

---

## 3. Source File Inventory

**VERIFIED:** 25 PRG files in the workspace root. `cpzero.prg` uses FoxPro dialect and is excluded from analysis.

| Category | Files | Notes |
|----------|-------|-------|
| Primary entry point | `MENU.PRG` (4131 lines) | 87 functions/procedures; canonical active version |
| Historical variant | `MENU1.PRG` (4131 lines) | Same structure; confirmed behavioral differences (see §4) |
| Standalone utilities (active paths) | `COBRA.PRG` (158 lines), `LIQUIDA.PRG` (135 lines), `INFORME.PRG` (~144 lines), `BANCODIS.PRG` (~90 lines) | Standalone entry points |
| Bulk-operation scripts (read-only; do not execute) | `BORRA.PRG`, `AGRGA.PRG`, `CARVALOR.PRG`, `CTA01.PRG`, `REPL.PRG` | Destructive/irreversible operations on persistent tables — see §6 |
| Mass-update migration utilities | `RESERVA.PRG`, `CAMBIO.PRG`, `CARGACOB.PRG`, `CCTA.PRG`, `PASANO.PRG`, `ARMAPAR.PRG` | Historical data-fix scripts |
| Ad-hoc analysis scripts | `ANA.PRG`, `ANA2.PRG` | Historical analysis only |
| Browse utilities | `CTACTE.PRG`, `RESUCTA.PRG`, `VALOR.PRG`, `RECIBO.PRG` | Administrative table viewers |
| Non-Clipper | `cpzero.prg` | FoxPro dialect — excluded from scope |

---

## 4. MENU.PRG vs MENU1.PRG — Historical Variant

**VERIFIED — `MENU.PRG` and `MENU1.PRG` each contain 4131 lines and share the same 87 function names. They are NOT identical.**

Confirmed behavioral differences:

| Location | MENU.PRG | MENU1.PRG | Impact |
|----------|---------|----------|--------|
| `OpenDbf()` — workstation gate | `If Puesto='26'` | `If Puesto='01'` | Controls which workstation gets exclusive `ImpCob`/`ImpMut` access |
| `ImpriM()` column widths | `Transform(Expensa,'999.99')` | `Transform(Expensa,'99999.99')` | Mutual report column widths differ |
| `ImpriM()` alignment | `PadL(...,75)` | `PadL(...,73)` | Print layout differs |

**Conclusion:** MENU.PRG is the canonical active version per AGENTS.md. MENU1.PRG is preserved for comparison only. The production Puesto value for the workstation-exclusive gate is UNKNOWN.

---

## 5. Application Startup and Entry Point

**VERIFIED — `MENU.PRG` lines 1–21.**

Startup sequence (top-level code, not inside any function):
1. Eight `Public` color-scheme variables initialized (lines 2–8).
2. `Public EmpNom` and `EmpDir` set to company name/address (lines 9–10; demo values in workspace).
3. `Public Puesto := GetEnv('Puesto')` reads workstation ID from OS environment (line 11).
4. `Contrasenia()` call **commented out** at line 12 — authentication is NOT enforced at startup.
5. `AbreSet()` — library function, configures screen/printer; implementation UNKNOWN (line 13).
6. `Fondo()` — paints background screen (line 14).
7. `OpenDbf()` — opens 28 table aliases and creates all NTX indexes (line 15).
8. `MenuPrincipal()` — enters main menu loop (line 16).
9. On exit: `UltTecla(0)`, `DbCloseAll()`, `SalNic(EmpNom, EmpDir)` (lines 18–20).

---

## 6. Database Layer

**VERIFIED: 22 DBF files in workspace root; 28 aliases opened by `OpenDbf()`.**

### Persistent tables (22 DBF files in workspace):

AREAS, ATAUD, BAJA, bancos (VFP format — role UNKNOWN), cobrador, COCHERIA, CONTRAS, CTACTE, ctaexp, FILTRO, MAEASO (not opened — role UNKNOWN), mutual, parquenu, PROMOTOR, PROVINCI, RECIBO, RENA, reserva, SUBNIVEL, SUPLENTE, titular, VALOREXP.

### Runtime-only virtual tables (no DBF in workspace):

These are created at runtime. Schemas are INFERRED from REPLACE write patterns only:

| Alias | Purpose | Status |
|-------|---------|--------|
| AuxLiq (per workstation) | Batch liquidation temp work area | INFERRED schema |
| Auxiliar (per workstation) | Payment accumulator | INFERRED schema |
| AuxiRes (per workstation) | Payment batch staging | INFERRED schema |
| AxSupl (per workstation) | Suplente staging during reservation creation | INFERRED schema |
| AxPl (per workstation) | Installment plan staging | INFERRED schema |
| ResuCta | Expense summary per reservation | INFERRED schema |
| ExpCta | Expense payment receipts | INFERRED schema |
| ImpCob | Cobrador report staging (Puesto='26' only) | INFERRED schema |
| ImpMut | Mutual report staging (Puesto='26' only) | INFERRED schema |
| AuxParq, Recexpe, Pexpensa, Bisiesto | Supporting temp/lookup tables | Partial schemas only |

---

## 7. Main Menu Structure

**VERIFIED — `MENU.PRG`, `MenuPrincipal()`, lines 91–144.**

```
Main Menu
├── [1] Ingresos
│   ├── [1] Cobro de Expensas          → expense payment collection (WF-005)
│   └── [2] Cobro de Cuotas            → installment payment collection (WF-006)
├── [2] Operaciones
│   ├── [1] Adjudicación de Parcelas   → new reservation (WF-003)
│   ├── [2] Modificación de Parcelas   → parcel edit (Hojear() — behavior UNKNOWN)
│   ├── [3] Modificación de Reservas   → reservation edit (Hojear() — behavior UNKNOWN)
│   ├── [5] Alta de Inhumaciones        → new inhumation (WF-004)
│   ├── [8] Liquidación de Expensas    → batch liquidation, Pass1 gated (WF-007)
│   ├── [9] Liquidación x Reserva      → single-reservation liquidation (WF-008)
│   └── [11] Emisión de Listados        → sub-menu (cobrador list, collections report)
└── [3] Consultas
    ├── [1] Inhumaciones               → inhumation statistics
    ├── [2] Titulares de Parcelas      → parcel titleholder query
    ├── [3] Reservas y Cuotas          → account status query with hidden side effect (WF-009)
    ├── [4] Parcelas y Expensas        → expense history query (WF-011)
    ├── [5] Niveles                    → interment level detail (WF-010)
    └── [6] Superficie                 → visual sector map (WF-012)
```

---

## 8. Key Operational Characteristics

| Characteristic | Finding | Label |
|----------------|---------|-------|
| Authentication | `Contrasenia()` call commented out at `MENU.PRG:12`; system launches without login | VERIFIED |
| Maintenance password | `Pass1('DEMO00')` gates batch liquidation at `MENU.PRG:233` | VERIFIED |
| Workstation isolation | Per-workstation tables via `Puesto` macro: `AuxLiq&Puesto.`, `Auxi&Puesto.`, `AxSup&Puesto.`, `Aux&Puesto.`, `AxPl&Puesto.` | VERIFIED |
| Concurrency model | Record locking via `VerActiva()` before every write; LAN file-sharing | INFERRED (library function unresolvable) |
| Transaction support | None — each write is individually committed | VERIFIED (by absence) |
| Referential integrity | Application-level `DbSeek()` validation only; no DB-level constraints | VERIFIED (by absence) |
| Print output | Direct printer via `_Alpt()` / `_Clpt()` library calls; reports print 3 copies (INFERRED intentional) | INFERRED |
| Hidden write in query | `BuscaDatos()` writes `CtaCte.Saldo` and `Recibo.Cuota` during "Reservas y Cuotas" query | VERIFIED — `MENU.PRG:2096–2119` |
| Credential storage | CONTRAS.DBF stores passwords as plaintext C(10) fields; login path currently inactive | VERIFIED |

---

## 9. UNKNOWN Items

| ID | Item |
|----|------|
| U-01 | Production `Puesto` value for the exclusive-print workstation |
| U-02 | `VerActiva()` locking implementation — unresolved custom symbol; origin UNKNOWN |
| U-03 | `Hojear()` edit behavior — modification workflows for Parcelas and Reservas rely on this unresolved symbol; origin UNKNOWN |
| U-04 | `Pass1()` password check algorithm — unresolved custom symbol; origin UNKNOWN |
| U-05 | `bancos.dbf` role — Visual FoxPro format; no PRG opens it |
| U-06 | `MAEASO.DBF` purpose — not opened by any PRG |
| U-07 | Whether `COBRA.PRG` and `LIQUIDA.PRG` are used in production or are fully obsolete |
| U-08 | Whether `INFORME.PRG` was compiled separately from MENU.PRG or linked together — both contain `Inhumacion()` implementations; the relationship is UNKNOWN |
| U-09 | All schemas for runtime-only virtual tables |

---

## 10. Conflicts Resolved During Consolidation

| Conflict | Resolution |
|----------|-----------|
| OTN-20 stated INFORME.PRG is "called by" MENU.PRG | Corrected: both PRGs contain an `Inhumacion()` implementation. Whether INFORME.PRG is compiled separately, linked, or has any runtime relationship to MENU.PRG is UNKNOWN. The alias `Parque` (INFORME.PRG) vs `ParqueNu` (MENU.PRG) difference is confirmed as a genuine code inconsistency. |
| OTN-20 / OTN-24 cited file-wide line ranges (e.g., "COBRA.PRG lines 1–159") | Replaced throughout with narrow function/line citations where cited behavior is actually located. |
| OTN-22 / OTN-23 described MENU1.PRG as a duplicate | Corrected: MENU1.PRG is a historical variant with confirmed behavioral differences; it is not an identical duplicate. |

---

## 11. Synthetic Data Statement

All analysis was performed exclusively on PRG source files and 22 DBF files containing 45 fully synthetic demo records (confirmed by `AGENTS.md` and the OTN-10 security review). No production data, real customer names, credentials, financial values, or personally identifiable information was accessed or reproduced.

---

*End of OTN-25 Legacy System Overview*
