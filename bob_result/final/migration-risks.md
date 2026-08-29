# Migration Risks

**Task ID:** OTN-25 (consolidated from OTN-24, reconciled against OTN-20, OTN-21, OTN-22, OTN-23)  
**Date:** 2026-08-28  
**Status:** COMPLETE — Gate 2 APPROVED on 2026-08-29

---

## 1. Risk Registry — Ranked by Severity × Impact

| Rank | ID | Risk | Severity | Relevance to PoC |
|------|----|------|----------|-----------------|
| 1 | MR-050 | Plaintext password storage in CONTRAS.DBF | CRITICAL | Required only if authentication is in PoC scope; login is currently inactive in this snapshot |
| 2 | MR-030 | Missing FTMENUTO.CH include + unresolved external functions | CRITICAL | Functions needed depend on selected workflow; always required for any workflow that calls VerActiva, Pass1, or other missing functions |
| 3 | MR-055 | No transaction support — partial multi-table writes | HIGH | Required for any multi-table write workflow |
| 4 | MR-003 | `Puesto` macro-driven table partitioning | HIGH | Required for any workflow that uses per-workstation staging tables |
| 5 | MR-051 | Non-atomic reservation number increment | HIGH | Required if WF-003 (New Reservation) is selected |
| 6 | MR-042 | `BuscaDatos()` writes data during query | HIGH | Required if WF-009 (Reservas y Cuotas) is selected |
| 7 | MR-054 | No referential integrity at storage level | HIGH | Required for any workflow that writes across related tables |
| 8 | MR-020–025 | Permanent bulk-operation scripts in workspace | HIGH | Never execute during testing — applies universally |
| 9 | MR-040 | Screen layout mixed with business logic throughout | HIGH | Affects all workflows; PoC architecture decision deferred to OTN-30 |
| 10 | MR-060 | `AuMes()` month-end day overflow | MEDIUM | Required if WF-003 or any installment-plan workflow is selected |
| 11 | MR-031 | NTX indexes cannot be used by the proposed SQLite target | HIGH | Reconstruction required after OTN-30 architecture approval |
| 12 | MR-062 | `COBRA.PRG` `FechaVence` hardcoded to 1999 | HIGH | Deferred — standalone path likely obsolete; confirm at Gate 3 |
| 13 | MR-033 | Missing runtime DBF files for 14+ virtual tables | HIGH | Required for any workflow that reads or writes virtual tables |
| 14 | MR-052 | Occupied parcel `Loop` commented out | MEDIUM | Required if WF-003 (New Reservation / parcel assignment) is selected |

---

## 2. Category 1 — Global and Cross-Procedure State

### MR-001 — Public color-scheme variables
- **Severity:** LOW  
- **VERIFIED** — `MENU.PRG` lines 2–8  
- Eight `Public` variables (`FonCol`, `CurCol`, `EmuCol`, `PelCol`, `MonCol`, `DanCol`, `Alegre`) define screen colors. Used throughout all UI functions without parameter passing.  
- **Migration:** Replace with theme/style constants.

### MR-002 — Public company name and address in all print output
- **Severity:** LOW  
- **VERIFIED** — `MENU.PRG` lines 9–10; used in at least 12 report functions  
- `EmpNom` and `EmpDir` are global strings embedded in every printed report. No configuration file or table.  
- **Migration:** Must become configurable application settings.

### MR-003 — Public Puesto drives workstation table partitioning
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG` line 11; `OpenDbf()` lines 3854–3862, 3898, 3987, 3989, 4006–4008, 4045–4049  
- `Puesto = GetEnv('Puesto')`. Used in dynamic macro constructions opening per-workstation exclusive tables (`AuxLiq&Puesto.`, `Auxi&Puesto.`, `AxSup&Puesto.`, `Aux&Puesto.`, `AxPl&Puesto.`). In MENU.PRG, `Puesto='26'` gates exclusive ImpCob/ImpMut access; MENU1.PRG uses `Puesto='01'` for the same gate. Production value is UNKNOWN.  
- **Migration:** Per-workstation table pattern must be replaced with proper user-session scoping (e.g., database session ID or in-memory staging).

### MR-004 — Private xAgencia, Vec, xCob, xMut across procedure boundaries
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG` lines 165–166, 194–195, 400–401, 445–449, 530, 553–554  
- `Public Vec:={}` and related variables are re-declared in menu functions and accessed in sub-functions without parameter passing.  
- **Migration:** All callers must be refactored to pass these as explicit parameters.

### MR-005 — Private Linea shared between CargaDatos and Muestra
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG`, `CargaDatos()` line 2623 (`Private Linea:=7`); `Muestra()` lines 2733–2758  
- `Linea` is initialized in `CargaDatos` and directly read/modified in `Muestra` (called from `Busca_Rep`, which is called from within `CargaDatos`). Synchronizes display row position across three nested functions.  
- **Migration:** Convert to explicit parameters or display-state object.

### MR-006 — Private FechaVence in COBRA.PRG leaks to Descarga()
- **Severity:** HIGH  
- **VERIFIED** — `COBRA.PRG` top-level (`Private FechaVence:=CToD('12/10/1999')`); `Descarga()` line 113  
- `FechaVence` is Private at module scope and used inside `Descarga()` without parameter passing.  
- **Migration:** All PRG-scope Private variables must be converted to explicit function parameters or class fields.

---

## 3. Category 2 — Dynamic Alias Construction

### MR-010 — AuxLiq&Puesto. (per-workstation liquidation temp)
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `OpenDbf()` line 3898: `Use AuxLiq&Puesto. Alias AuxLiq New`  
- Table name (`AuxLiq01`, `AuxLiq26`, etc.) resolved at runtime. No corresponding DBF for Puesto values other than `'01'`.  
- **Migration:** Per-user/per-session staging must be replaced with parameterized in-memory or DB session tables.

### MR-011 — Auxi&Puesto. (Auxiliar)
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `OpenDbf()` line 3987: `Use Auxi&Puesto. Alias Auxiliar Exclusive New`  
- Used for Reservas query payment plan display. Same pattern as MR-010.

### MR-012 — AxSup&Puesto. (AxSupl — suplente staging)
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `OpenDbf()` line 4006: `Use AxSup&Puesto. Alias AxSupl Exclusive New`  
- Used during reservation creation for staging suplente data.

### MR-013 — Aux&Puesto. (AuxiRes — payment collection staging)
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `OpenDbf()` line 4045: `Use Aux&Puesto. Alias AuxiRes Exclusive New`  
- Core staging table for all payment collection workflows (WF-005, WF-006). Per-workstation design prevents simultaneous collection conflicts between stations.

### MR-014 — AxPl&Puesto. (installment plan staging)
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `CargaPlan()` line 3258; `Facturar()` lines 3298, 3318, 3350  
- Used during reservation creation for staging the installment plan. The `Zap` call in `Facturar()` (line 3299) resets this table before each new plan entry.

### MR-015 — Imp&xGrupo (mutual disbursement table)
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG`, `DisExpensa()` line 582: `Use Imp&xGrupo Alias AxMutu New`  
- `xGrupo = StrZero(Mutual->Grupo, 3)`. Table name depends on Mutual's group code. Corresponding DBF files (e.g., `Imp001.DBF`, `Imp002.DBF`) are not in the workspace. Schema inferred from REPLACE patterns.

---

## 4. Category 3 — Permanent Bulk Operations (Never Execute)

> The distinction between **persistent-table bulk operations** (dangerous — permanent data destruction) and **per-workstation ZAP operations on temp tables** (intentional design) is maintained throughout.

### MR-020 — BORRA.PRG: Conditional bulk delete on CtaExp
- **Severity:** HIGH  
- **VERIFIED** — `BORRA.PRG` lines 1–3: Opens CtaExp; `DELE ALL FOR recno()>246260`; then `PACK`  
- Deletes all CtaExp records after physical record number 246260 and permanently removes them. The `recno()` threshold was a one-time cleanup targeting records after a specific snapshot point. No confirmation dialog. **Do not execute.**

### MR-021 — AGRGA.PRG: Year-offset replace on CtaExp
- **Severity:** HIGH  
- **VERIFIED** — `AGRGA.PRG` lines 1–3: Opens CtaExp; `REPLACE ALL Ano WITH Ano+1900`. No PACK.  
- One-time Y2K-era year correction. Re-execution would offset all year values by 1900 (e.g., 2000 → 3900). **Do not execute.**

### MR-022 — RECIBO.PRG: Browse then Pack on Recibo
- **Severity:** MEDIUM  
- **VERIFIED** — `RECIBO.PRG` lines 1–6: Opens Recibo; sets index to `recib2`; `Browse()`; then `PACK`  
- Packs Recibo after interactive browse. Lower risk than unconditional DELETE scripts, but PACK is irreversible for any logically deleted records. **Do not run during analysis.**

### MR-023 — CARVALOR.PRG: Mass rate override on Reserva
- **Severity:** HIGH  
- **VERIFIED** — `CARVALOR.PRG` lines 1–3: Opens Reserva; `REPLACE ALL Expensa WITH 13`  
- Overwrites every reservation's expense amount to 13 with no filter. Historical rate-correction utility. **Do not execute.**

### MR-024 — CTA01.PRG: Date-scoped delete on CtaExp
- **Severity:** HIGH  
- **VERIFIED** — `CTA01.PRG` lines 1–5: Opens CtaExp; `DELE ALL FOR mes=12 .AND. ano=1999`; then `DELE ALL FOR ano=2000`; then `PACK`  
- Permanently removes December 1999 and all year-2000 expense records. Y2K transition cleanup. **Do not execute.**

### MR-025 — REPL.PRG: Multi-field mass replace on Reserva
- **Severity:** HIGH  
- **VERIFIED** — `REPL.PRG` lines 1–5: Opens Reserva; `REPLACE ALL Expensa WITH 10`; `REPLACE ALL Ult_Mes WITH 2`; `REPLACE ALL ult_ano WITH 1999`  
- Resets expense rate to 10 and payment state to February 1999 across all reservations. Historical fee-and-state reset. **Do not execute.**

### MR-026 — AuxLiq->(__DbZap()) in Nucleo and N_ucleo (intentional design)
- **Severity:** MEDIUM (awareness only)  
- **VERIFIED** — `MENU.PRG` lines 900 and 881; `LIQUIDA.PRG` line 18  
- The per-workstation AuxLiq temp table is ZAPped before each reservation's liquidation. **This is correct and intentional** — the table is per-session and stateless between reservations. Contrast with MR-020–025 which operate on persistent shared tables.

---

## 5. Category 4 — Unsupported Dependencies

### MR-030 — Missing FTMENUTO.CH include and 21 unresolved custom callable identifiers
- **Severity:** CRITICAL
- **VERIFIED** — `MENU.PRG` line 1: `///#Include "FTMENUTO.CH"` (commented out)
- The include file `FTMENUTO.CH` is not present in the workspace. The following **21 unresolved custom callable identifiers** are called throughout the workspace PRGs but are not defined in any workspace PRG and are not standard Clipper/xBase runtime functions:
  `AbreSet()`, `BoxFede()`, `MueveLet()`, `VerActiva()`, `Pass1()`, `AyuOnLine()`, `MChoice()`, `WinShowR()`, `Lev_Pan()`, `_Alpt()`, `_Clpt()`, `_Quest()`, `Con_Tes()`, `SalNic()`, `UltTecla()`, `TimeBar()`, `Oscurece()`, `Oscureze()`, `CMes()`, `_SBoxDS()`, `Hojear()`
- `Oscurece()` and `Oscureze()` are distinct identifiers in the source. Whether they are separate routines, aliases, or a historical spelling error is **UNKNOWN**.
- Excluded from this list: `Contesta()` (VERIFIED defined at `MENU.PRG:2760`); `DbUnLock()` and `DbSelectAr()`/`DbSelectArea()` (standard Clipper/xBase runtime functions, not missing project implementations).
- The original container (compiled `.LIB`, `.OBJ`, or other archive) for these 21 identifiers is UNKNOWN. `FTMENUTO.CH` may have been a header-only file, or it may have referenced a separately compiled library. Neither conclusion is verified.
- **Migration:** Unresolved symbols needed for the selected PoC workflow must be reverse-engineered or reimplemented. `VerActiva` (record locking), `Pass1` (password gate), and `AbreSet` (startup configuration) are candidates depending on which workflow is approved at Gate 3.

### MR-031 — NTX indexes cannot be used directly by the proposed SQLite target
- **Severity:** HIGH
- **VERIFIED** — 45 `INDEX ON ... TO ...` statements in `MENU.PRG`, `OpenDbf()`, lines 3865–4089; NTX is the Clipper-native index format.
- The workspace contains no NTX files (intentionally removed). NTX files cannot be used directly by the proposed SQLite target; all indexes must be reconstructed in the target schema after the architecture is confirmed in OTN-30.
- **Migration:** Composite string key expressions (e.g., `StrZero(Reserva,6)+StrZero(Ano,4)+StrZero(Mes,2)`) must be replaced with proper composite indexes or computed columns in the target schema.

### MR-032 — cpzero.prg: FoxPro dialect, incompatible with Clipper
- **Severity:** LOW
- **VERIFIED** — `cpzero.prg`: FoxPro `PARAMETER`, `#DEFINE`, `DO ... WITH` syntax. Not compilable with Clipper.
- **Migration:** Exclude entirely from scope.

### MR-033 — Missing runtime DBF files for 14+ virtual tables
- **Severity:** HIGH  
- **VERIFIED** — `OpenDbf()` opens 28 aliases; workspace contains 22 DBF files. Absent: ResuCta, AuxLiq01, Auxi01, AxSup01, Aux01, AxPl01, ImpCob, ImpMut, AuxiRes, Recexpe, Pexpensa, ExpCta, CtaExp (subset), CtaCte, Recibo, and per-workstation temp variants.  
- **Migration:** Full schema reconstruction required for all missing persistent tables before migration can proceed.

### MR-034 — MAEASO.DBF purpose unknown
- **Severity:** LOW  
- **VERIFIED** — `MAEASO.DBF` exists (17 fields) but is not opened or referenced by any PRG. INFERRED obsolete.

---

## 6. Category 5 — Tight Coupling and Control Flow

### MR-040 — Screen layout mixed with business logic throughout
- **Severity:** HIGH
- **VERIFIED** — All major functions in `MENU.PRG` (e.g., `AltaReservas()`, `CobroExpensas()`, `CobroCuotas()`, `Nucleo()`) intermix `@row,col Say/Get`, `BoxFede`, `SetColor`, `SaveScreen/RestScreen` calls with business validation, data reads, and data writes.
- **Migration note:** Separation of UI, domain logic, and data access layers is a prerequisite for testable modernization. The specific layering approach and technology decisions are deferred to OTN-30 (modernization architect). Do not prescribe a specific architecture before Gate 3.

### MR-041 — Nested procedures assume specific open work areas
- **Severity:** HIGH  
- **VERIFIED** — Examples:
  - `CargaDatos()` (line 2621) accesses `Cobrador->Cobrador` without opening or seeking it — assumes calling context positioned it.
  - `BuscaDatos()` (line 2085) accesses `CtaCte->` without verifying position.
  - `PutExpensa()` (line 706) accesses `ParqueNu->SCargo` without seeking.  
- **Migration:** Functions carry implicit pre-conditions (specific tables open and positioned). Must be discovered per call-chain before individual unit migration.

### MR-042 — BuscaDatos() writes during "Reservas y Cuotas" query
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `BuscaDatos()`, lines 2096–2119  
- Writes `REPLACE Cuota` to RECIBO and `REPLACE CtaCte->Saldo` to CTACTE during a nominally read-only display. Every query view silently updates data.  
- **Migration:** Must be separated into an explicit reconciliation operation.

### MR-043 — PrintReport called 3 times consecutively
- **Severity:** MEDIUM (clarification required)  
- **VERIFIED** — `MENU.PRG` lines 611–613 (`ImpriDis` called 3× in `ListaMut`) and lines 690–692 (`ImpriM` called 3×)  
- Three consecutive calls to the same report function produce three identical copies. No copy-count parameter. Whether this is intentional business policy (triplicate distribution) is UNKNOWN and must be confirmed before modernization.

---

## 7. Category 6 — Data Integrity Risks

### MR-050 — CONTRAS.DBF plaintext password storage
- **Severity:** CRITICAL
- **VERIFIED** — `MENU.PRG`, `Contrasenia()`, lines 30–56; `CONTRAS.DBF` in workspace
- Passwords stored as plaintext C(10). Comparison: `If Clave=xClave` (`MENU.PRG:55–56`). Login path currently **inactive** in this snapshot (`MENU.PRG:12`). The workspace contains only synthetic demo credentials.
- **Migration:** If authentication is included in the PoC scope, plaintext storage must NOT be replicated — use a salted cryptographic hash (e.g., BCrypt, Argon2). If the selected PoC workflow does not include authentication, this risk remains documented but does not block the PoC.

### MR-051 — Non-atomic reservation number increment
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `TraeNroRes()`, lines 3053–3055  
- `DbGoBottom()` + `Reserva + 1` is not atomic. In multi-workstation use, two simultaneous users can generate the same reservation number.  
- **Migration:** Replace with DB identity/auto-increment column or transactional sequence generator.

### MR-052 — Occupied parcel can be re-assigned (Loop commented out)
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG`, `CargaParcela()`, lines 3503–3506  
- Check `SubNivel->(DbSeek(xCodigo))` shows "Esta Parcela Está Adjudicada" but the `//Loop` is commented out, allowing assignment. Whether this is intentional (parcel reuse after exhumation) or a defect requires stakeholder confirmation before modernization.

### MR-053 — ValorExp rate: inconsistent access patterns
- **Severity:** MEDIUM  
- **VERIFIED / INFERRED** — `MENU.PRG`, `GrabaExpCta()` line 3011 and `GrabaReserva()` line 3431  
- `GrabaExpCta()`: explicitly calls `ValorExp->(DbGoBottom())` — VERIFIED bottom-record access.  
- `GrabaReserva()`: reads `ValorExp->ValorExpen` without `DbGoBottom()` — record position is UNKNOWN.  
- **Migration:** Implement an effective-date rate history table with a deterministic rate lookup.

### MR-054 — No referential integrity at storage level
- **Severity:** HIGH  
- **VERIFIED** — By absence: DBF format has no FOREIGN KEY constraints. Relationships enforced only by `DbSeek()` checks, which can be bypassed.  
- **Migration:** All foreign key relationships must be formalized as database constraints (e.g., SQLite `FOREIGN KEY`).

### MR-055 — No transaction support
- **Severity:** HIGH  
- **VERIFIED** — Throughout `MENU.PRG`, `COBRA.PRG`, `LIQUIDA.PRG`: each write is `VerActiva()` + `Replace` + `DbCommit()` + `DbUnLock()`. Multi-table writes (e.g., `GrabaReserva` + `GrabaTitular` + `GrabaParque` + `CargaPlan` at `MENU.PRG:3242–3246`) are not wrapped in any transaction.  
- A partial failure leaves the database inconsistent.  
- **Migration:** All related multi-table operations must use database transactions.

---

## 8. Category 7 — Calendar and Date Arithmetic

### MR-060 — AuMes() does not handle month-end day overflow
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG`, `AuMes()`, lines 3280–3289  
- Adds 1 to the month number; wraps December → January. Day-of-month is unchanged. A start date of January 31 produces February 31 — an invalid date. Clipper behavior on invalid dates is UNKNOWN without runtime observation.  
- **Migration:** Must use `AddMonths()` that clamps to the last valid day of the month.

### MR-061 — SumaMes() depends on Bisiesto table completeness
- **Severity:** MEDIUM (conditional)  
- **VERIFIED** — `MENU.PRG`, `SumaMes()`, lines 3367–3386  
- For February: `Bisiesto->(DbSeek(xAno))`. If the year is missing, February defaults to 28 days regardless of actual leap-year status. A missing year causes incorrect date arithmetic.  
- **Migration:** Use a built-in `DateTime.DaysInMonth()` equivalent.

### MR-062 — COBRA.PRG FechaVence hardcoded to October 1999
- **Severity:** HIGH  
- **VERIFIED** — `COBRA.PRG` top-level: `Private FechaVence:=CToD('12/10/1999')`  
- All future installments created via this standalone path would carry stale 1999-based due dates. Confirms this path is likely obsolete.

### MR-063 — LIQUIDA.PRG Mes_Liq and Ano_Liq hardcoded to March 2000
- **Severity:** LOW (standalone path likely obsolete)  
- **VERIFIED** — `LIQUIDA.PRG` lines 1–3  
- Standalone liquidation creates records for March 2000. Confirms this file is a historical artifact.

---

## 9. INFERRED Risks

| ID | Risk | Evidence | Uncertainty |
|----|------|----------|-------------|
| MR-I-01 | `VerActiva()` is a record-locking function — absence would cause multi-user data corruption | Appears before every `DbAppend()` and `Replace`; name suggests lock/activate | Implementation in missing library |
| MR-I-02 | Application is designed for LAN multi-workstation file-sharing | `Puesto` variable, per-workstation exclusive tables, `VerActiva()` locking pattern | Exact concurrency model requires verification |
| MR-I-03 | Print output goes directly to the system printer | `_Alpt()` / `_Clpt()` calls before/after all report output | Library functions; implementation UNKNOWN |

---

## 10. UNKNOWN Items

| ID | Item |
|----|------|
| U-01 | `VerActiva()` exact locking implementation — critical for concurrency safety |
| U-02 | `Pass1()` password verification algorithm |
| U-03 | `Hojear()` edit behavior for Modificación workflows |
| U-04 | Production Puesto value for the exclusive ImpCob/ImpMut workstation |
| U-05 | Whether COBRA.PRG and LIQUIDA.PRG standalone files are used in production or fully obsolete |
| U-06 | `bancos.dbf` role — no `USE` statement found in any PRG; Visual FoxPro format |
| U-07 | Whether any production NTX index expressions differ from the `OpenDbf()` versions |
| U-08 | `Diskette` variable — referenced in `MENU.PRG:568`; never assigned in any PRG source |

---

## 11. Deferred (Post-PoC) Risks

| ID | Risk | Recommendation |
|----|------|---------------|
| MR-001 | Color-scheme globals | Replace with theme constants |
| MR-002 | Hardcoded company name/address | Move to configuration table |
| MR-034 | MAEASO.DBF unknown purpose | Confirm obsolete via stakeholder review before excluding |
| MR-043 | Triple printer copies | Confirm with stakeholders before changing |
| MR-063 | LIQUIDA.PRG hardcoded dates | Document as obsolete; exclude from PoC |
| MR-032 | cpzero.prg FoxPro file | Exclude entirely from migration scope |

---

## 12. Conflicts Resolved During Consolidation

| Conflict | Resolution |
|----------|-----------|
| OTN-20 / OTN-23 implied INFORME.PRG is called by MENU.PRG | Corrected: INFORME.PRG contains its own `Inhumacion()` implementation; the runtime relationship between the two files is UNKNOWN. Both implementations are documented independently. |
| OTN-20 / OTN-23 cited whole-file line ranges for COBRA.PRG and LIQUIDA.PRG | Replaced with specific function and line citations throughout this document. |
| OTN-22 classified the batch liquidation baseline as a possible defect | Retained as VERIFIED behavior with the INFERRED note that it may be intentional (full history re-evaluation on every run). Stakeholder confirmation required before modernization. |
| No factual conflicts between OTN-20, OTN-21, OTN-22, OTN-23, OTN-24 were identified. | — |

---

## 13. Synthetic Data Statement

Only the 22 DBF files containing fully synthetic demo records and the 25 PRG source files were analyzed. No production data, real customer names, financial values, credentials, or personally identifiable information was accessed or reproduced. All risk assessments are based on PRG source code analysis only. Severity ratings reflect migration difficulty and data correctness impact, not production incident history.

---

*End of OTN-25 Migration Risks document*
