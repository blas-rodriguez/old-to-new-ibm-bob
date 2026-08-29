# Migration Risk Report

**Task ID:** OTN-24  
**Persona:** migration-risk  
**Date:** 2026-08-28
**Output file:** `bob_result/agents/05-migration-risks.md`

---

## 1. Scope and Files Inspected

All 25 PRG files in the workspace root were read in full. The following were the primary risk sources:

| File | Risk relevance |
|------|---------------|
| `MENU.PRG` | ~4132 lines — global state, dynamic aliases, tight coupling, all operations |
| `COBRA.PRG` | ~159 lines — standalone payment path, hardcoded dates |
| `LIQUIDA.PRG` | ~136 lines — standalone liquidation, hardcoded dates |
| `INFORME.PRG` | ~144 lines — alias inconsistency (Parque vs ParqueNu) |
| `BORRA.PRG`, `AGRGA.PRG`, `RECIBO.PRG`, `CTA01.PRG`, `CARVALOR.PRG`, `REPL.PRG` | Permanent bulk-operation utilities (see Category 3 for precise behavior of each) |
| `RESERVA.PRG`, `CAMBIO.PRG`, `CARGACOB.PRG`, `CCTA.PRG`, `PASANO.PRG`, `ARMAPAR.PRG` | Mass-update migration utilities |
| `cpzero.prg` | FoxPro-dialect incompatibility |
| `BANCODIS.PRG` | Bank disbursement utility |

No legacy files were modified. Only `bob_result/agents/05-migration-risks.md` was written. This workspace is a sanitized analysis snapshot, not a production installation; missing behavior remains UNKNOWN and must be resolved through approved evidence or stakeholder review. No recommendation to inspect production data is made.

---

## 2. VERIFIED Findings

---

### Category 1: Global State and Shared Variables

**MR-001 — PUBLIC color-scheme variables used application-wide**  
- **Severity:** LOW  
- **VERIFIED** — `MENU.PRG` lines 2–8  
- Eight `Public` variables (`FonCol`, `CurCol`, `EmuCol`, `PelCol`, `MonCol`, `DanCol`, `Alegre`) define screen color schemes. They are used throughout MENU.PRG functions without being passed as parameters.
- **Migration impact:** Low functional risk; affects UI rendering. In a GUI modernization, these become theme/style constants.

**MR-002 — PUBLIC EmpNom and EmpDir used in all print output**  
- **Severity:** LOW  
- **VERIFIED** — `MENU.PRG` lines 9–10; used in at least 12 report functions  
- Company name and address are public global strings embedded in every printed report. There is no configuration file or database table for these values.
- **Migration impact:** Must become configurable application settings in modernization.

**MR-003 — PUBLIC Puesto (workstation ID) drives table partitioning**  
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG` line 11; `OpenDbf()` lines 3854–3862; `OpenDbf()` lines 3898, 3987, 3989, 4006–4008, 4045–4049  
- `Puesto = GetEnv('Puesto')` reads a workstation identifier from the OS environment. This value is used in dynamic macro constructions to open per-workstation private tables (`AuxLiq&Puesto.`, `Auxi&Puesto.`, `AxSup&Puesto.`, `Aux&Puesto.`, `AxPl&Puesto.`). In the current `MENU.PRG`, `Puesto='26'` has additional exclusive table access; `MENU1.PRG` uses `Puesto='01'` for the same gate — production value is UNKNOWN.
- **Migration impact:** The per-workstation table pattern must be replaced with a proper user-session concept (e.g., database session ID or in-memory staging tables) in modernization. Cannot be directly ported.

**MR-004 — PRIVATE xAgencia, Vec, xCob, xMut used across procedure boundaries**  
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG` lines 165–166, 194–195, 400–401, 445–449, 530, 553–554  
- `Private xAgencia:=0` and `Public Vec:={}` are re-declared at the start of several menu functions (MenuIngresos, MenuOperaciones, MenuConsultas, ListaMut, ListaCob, LCobCob, LCobGen). Although locally re-initialized, they are accessed in called sub-functions without being passed as parameters (e.g., `Vec` in `ListaControl`, `Muestra`, `BuscaRecibo`).
- **Migration impact:** Callers implicitly depend on Private variable scope propagation. Functions must be explicitly refactored to accept and return these as parameters.

**MR-005 — PRIVATE Linea shared between CargaDatos and Muestra**  
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG`, `Function CargaDatos` line 2623 (`Private Linea:=7`) and `Function Muestra` lines 2733–2758  
- `Linea` is a Private variable initialized in `CargaDatos` and directly read and modified in `Muestra`. `Muestra` is called from `Busca_Rep` (which is called from within `CargaDatos`). The shared `Linea` variable synchronizes display row position across these three nested functions.
- **Migration impact:** This screen-layout coupling must be converted to explicit parameters or a display-state object.

**MR-006 — PRIVATE FechaVence in COBRA.PRG leaks to Descarga()**  
- **Severity:** HIGH  
- **VERIFIED** — `COBRA.PRG` lines 1 (top-level `Private FechaVence:=CToD('12/10/1999')`) and `Descarga()` lines 113  
- `FechaVence` is set as Private at the top-level module scope and used inside `Descarga()`. In Clipper, a Private variable is visible to all procedures called in the same call chain. The function `Descarga()` uses it without receiving it as a parameter.
- **Migration impact:** All PRG-scope Private variables must be identified and converted to explicit function parameters or class fields.

---

### Category 2: Dynamic Alias Construction (Macros)

**MR-010 — AuxLiq&Puesto. (per-workstation liquidation temp table)**  
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `OpenDbf()` line 3898: `Use AuxLiq&Puesto. Alias AuxLiq New`  
- The table name `AuxLiq01`, `AuxLiq02`, etc. is resolved at runtime using the `Puesto` environment variable. There is no corresponding DBF file for values of Puesto other than `'01'` (`AuxLiq01.DBF` exists).
- **Migration impact:** Per-user/per-session staging tables must be replaced with parameterized in-memory or database session tables. Cannot be statically analyzed.

**MR-011 — Auxi&Puesto. (auxiliary per-workstation table, alias Auxiliar)**  
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `OpenDbf()` line 3987: `Use Auxi&Puesto. Alias Auxiliar Exclusive New`  
- Same pattern as MR-010. This table is used for the Reservas query payment plan display (FunDeuda / BuscaRecibo). No static DBF file for non-01 values of Puesto.

**MR-012 — AxSup&Puesto. (per-workstation suplente staging)**  
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `OpenDbf()` line 4006: `Use AxSup&Puesto. Alias AxSupl Exclusive New`  
- Used during new reservation creation for staging suplente data. Same pattern.

**MR-013 — Aux&Puesto. (per-workstation AuxiRes table)**  
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `OpenDbf()` line 4045: `Use Aux&Puesto. Alias AuxiRes Exclusive New`  
- The AuxiRes table is the core staging table for all payment collection workflows (WF-005, WF-006). Its per-workstation variant means simultaneous collections from different stations do not conflict. Must be redesigned as a proper session-scoped staging mechanism.

**MR-014 — AxPl&Puesto. (per-workstation installment plan staging)**  
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `Function CargaPlan` line 3258 and `Facturar` lines 3298, 3318, 3350  
- Used during reservation creation for staging the installment plan. The `Zap` call in `Facturar` (line 3299) resets this table before each new plan entry.

**MR-015 — Imp&xGrupo (dynamic mutual disbursement table)**  
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG`, `Function DisExpensa` line 582: `Use Imp&xGrupo Alias AxMutu New`  
- `xGrupo` is derived from `StrZero(Mutual->Grupo, 3)`, making the table name dependent on the Mutual's group code. The corresponding DBF files (e.g., `Imp001.DBF`, `Imp002.DBF`) are not present in the workspace. Schema must be inferred from the REPLACE patterns in `DisExpensa`.

---

### Category 3: Permanent Bulk Operations

The following utilities operate on persistent tables with no undo mechanism. **None should be executed during migration testing or analysis.** Note the distinction between operations on persistent storage tables and ZAP operations on per-workstation temporary tables (which are intentional design — see MR-026).

**MR-020 — BORRA.PRG: Conditional bulk delete on CtaExp**
- **Severity:** HIGH
- **VERIFIED** — `BORRA.PRG` lines 1–3: Opens CtaExp; `DELE ALL FOR recno()>246260`; then `PACK`
- Deletes all CtaExp records after physical record number 246260 and permanently removes them via PACK. The recno() threshold implies this was a one-time cleanup operation targeting records appended after a specific point. No confirmation dialog. If re-executed on different data, the deletion scope is unpredictable.
- **Migration impact:** Do not execute. Document as a historical cleanup script for record number > 246260 in a specific CtaExp snapshot.

**MR-021 — AGRGA.PRG: Year-offset replace on CtaExp**
- **Severity:** HIGH
- **VERIFIED** — `AGRGA.PRG` lines 1–3: Opens CtaExp; `REPLACE ALL Ano WITH Ano+1900`. No PACK.
- A one-time year-correction migration utility (likely applied once to convert 2-digit years to 4-digit). If executed again, all year values in CtaExp would be offset by 1900 (e.g., year 2000 → year 3900). No confirmation dialog.
- **Migration impact:** Do not execute. Historical data-repair script; idempotent re-execution would corrupt data.

**MR-022 — RECIBO.PRG: Browse then PACK on Recibo**
- **Severity:** MEDIUM
- **VERIFIED** — `RECIBO.PRG` lines 1–6: Opens Recibo using `AbreSet()`, sets index to `recib2`, calls `Browse()`, then `PACK`
- Allows manual inspection of Recibo records, then packs the table, permanently removing any logically deleted records. Relatively low risk if no records are manually deleted during the browse session; PACK alone does not delete records.
- **Migration impact:** Do not run during analysis. Lower severity than unconditional DELETE utilities.

**MR-023 — CARVALOR.PRG: Mass rate override on Reserva**
- **Severity:** HIGH
- **VERIFIED** — `CARVALOR.PRG` lines 1–3: Opens Reserva; `REPLACE ALL Expensa WITH 13`
- Overwrites every reservation's expense amount to 13 with no filter or confirmation. A historical rate-correction utility. If re-executed, silently replaces any subsequent rate changes.
- **Migration impact:** Do not execute. Document as a one-off fee-correction script; the value 13 encodes a specific historical rate.

**MR-024 — CTA01.PRG: Date-scoped delete on CtaExp**
- **Severity:** HIGH
- **VERIFIED** — `CTA01.PRG` lines 1–5: Opens CtaExp; `DELE ALL FOR mes=12 .AND. ano=1999`; then `DELE ALL FOR ano=2000`; then `PACK`
- Permanently removes all December 1999 and all year-2000 expense records from CtaExp. Likely a Y2K transition cleanup script. Re-execution on any CtaExp containing records from those periods would permanently destroy them.
- **Migration impact:** Do not execute. Historical period-boundary cleanup; the specific months/years targeted confirm a one-time Y2K or transition operation.

**MR-025 — REPL.PRG: Multi-field mass replace on Reserva**
- **Severity:** HIGH
- **VERIFIED** — `REPL.PRG` lines 1–5: Opens Reserva; `REPLACE ALL Expensa WITH 10`; `REPLACE ALL Ult_Mes WITH 2`; `REPLACE ALL ult_ano WITH 1999`
- Overwrites three fields on every Reserva record: sets the expense rate to 10, the last-processed month to February, and the last-processed year to 1999. No filter or confirmation. Likely a one-time data-reset utility applied before a specific billing cycle.
- **Migration impact:** Do not execute. Document as a historical fee-and-payment-state reset for a specific February 1999 billing period.

**MR-026 — AuxLiq->(__DbZap()) in Nucleo and N_ucleo**  
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG` lines 900, 881; `LIQUIDA.PRG` line 18  
- The per-workstation AuxLiq temp table is ZAPped before each reservation's liquidation. This is intentional and correct design, but it means the AuxLiq content for the previous reservation is lost before it can be inspected. If the liquidation aborts mid-batch, partial state cannot be recovered from AuxLiq.

---

### Category 4: Unsupported Dependencies

**MR-030 — Missing FTMENUTO.CH include and unresolved callable implementations**  
- **Severity:** CRITICAL  
- **VERIFIED** — `MENU.PRG` line 1: `///#Include "FTMENUTO.CH"` (commented reference); the include itself is absent. Its former contents and any associated compiled library are **UNKNOWN**.  
- The following 21 custom callable identifiers are used but are neither defined in any workspace PRG nor recognized as standard Clipper/xBase runtime functions: `AbreSet()`, `BoxFede()`, `MueveLet()`, `VerActiva()`, `Pass1()`, `AyuOnLine()`, `MChoice()`, `WinShowR()`, `Lev_Pan()`, `_Alpt()`, `_Clpt()`, `_Quest()`, `Con_Tes()`, `SalNic()`, `UltTecla()`, `TimeBar()`, `Oscurece()`, `Oscureze()`, `CMes()`, `_SBoxDS()`, `Hojear()`.
- `Oscurece()` and `Oscureze()` are distinct source identifiers; whether they are separate routines, aliases, or a spelling error is **UNKNOWN**. `Contesta()` is excluded because it is defined at `MENU.PRG:2760`; `DbUnLock()` and `DbSelectAr()`/`DbSelectArea()` are standard runtime functions.
- **Migration impact:** Only identifiers required by the Gate 3-selected PoC workflow need deliberate replacement. Their exact legacy behavior remains UNKNOWN unless supported by additional evidence.

**MR-031 — NTX index format (Clipper-specific)**  
- **Severity:** HIGH  
- **VERIFIED** — All 45 `INDEX ON ... TO ...` statements in `MENU.PRG`, `OpenDbf()`, lines 3865–4089  
- NTX files are a Clipper-specific index format and are not used directly by the planned SQLite target. Equivalent indexes and constraints must be defined in SQLite from approved expressions and relationships. The workspace contains no NTX files (intentionally removed).
- **Migration impact:** All indexes must be recreated as proper database indexes or table constraints in the target system (e.g., SQLite). Index expressions (composite string keys like `StrZero(Reserva,6)+StrZero(Ano,4)+StrZero(Mes,2)`) must be analyzed and replaced with proper composite indexes or computed columns.

**MR-032 — cpzero.prg: FoxPro dialect, incompatible with Clipper**  
- **VERIFIED** — `cpzero.prg` (190 lines): Uses FoxPro `PARAMETER`, `#DEFINE`, `DO ... WITH` syntax, FoxPro functions. Not compilable with a Clipper compiler.
- **Migration impact:** This file is irrelevant to the Clipper application. Exclude from all analysis and modernization scope.

**MR-033 — Missing runtime DBF files for dynamic and operational tables**
- **VERIFIED** — `OpenDbf()` opens 28 aliases; the workspace contains only 22 DBF files. None of the following are present in the workspace root: ResuCta, AuxLiq01, Auxi01, AxSup01, Aux01, AxPl01, ImpCob, ImpMut, AuxiRes, Recexpe, Pexpensa, ExpCta, CtaExp, CtaCte, Recibo, Baja, Suplente, Titular, Auxiliar, AuxParq, Bisiesto, Contras.
- The per-workstation temporaries (AuxLiq&Puesto., Auxi&Puesto., etc.) are created at runtime by the application. The persistent operational tables (ResuCta, CtaExp, CtaCte, Recibo, etc.) are absent from this sanitized snapshot — their schemas must be reconstructed from REPLACE write patterns in the PRG files. Their presence or exact structure in the production installation is UNKNOWN.
- **Migration impact:** Full schema reconstruction required for all missing persistent tables before migration can proceed. Per-workstation temporaries must be redesigned as session-scoped constructs.

**MR-034 — Missing MAEASO.DBF purpose**  
- **SEVERITY:** LOW  
- **VERIFIED** — `MAEASO.DBF` exists in workspace (17 fields) but is not opened or referenced by any PRG. Its purpose is UNKNOWN; it may be a superseded master-associations table.

---

### Category 5: Tight Coupling / Spaghetti Flow

**MR-040 — Screen layout code mixed with business logic throughout**  
- **Severity:** HIGH  
- **VERIFIED** — All major functions in `MENU.PRG` (AltaReservas, CobroExpensas, CobroCuotas, Nucleo, etc.) intermix `@row,col Say/Get`, `BoxFede`, `SetColor`, `SaveScreen/RestScreen` calls with business validation logic, data reads, and data writes.
- **Migration impact:** The entire codebase has no separation of concerns. Every function combines UI rendering, user input, data validation, and data persistence. Modernization requires a complete rewrite with proper layering.

**MR-041 — Nested procedure assumptions about open work areas**  
- **Severity:** HIGH  
- **VERIFIED** — Many functions assume specific tables are open in specific work areas. For example:
  - `CargaDatos()` (line 2621) accesses `Cobrador->Cobrador` without opening or seeking Cobrador — it assumes the calling context (CobroExpensas/CobroCuotas) already positioned it correctly.
  - `BuscaDatos()` (line 2085) accesses `CtaCte->` methods without verifying CtaCte is open and positioned.
  - `PutExpensa()` (line 706) accesses `ParqueNu->SCargo` without seeking — it assumes the calling context positioned ParqueNu.
- **Migration impact:** Functions cannot be unit-tested or migrated independently. They carry implicit pre-conditions (specific tables open, specific record positioned) that must be discovered through analysis of each call chain.

**MR-042 — BuscaDatos() writes during query (hidden side effect)**  
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `BuscaDatos()`, lines 2096–2119  
- The "Reservas y Cuotas" query screen calls `BuscaDatos()` which writes `REPLACE Cuota` to RECIBO and `REPLACE CtaCte->Saldo` to CTACTE. This is a write operation embedded inside a nominally read-only display function. Every time a user views a reservation's account status, data is silently updated.
- **Migration impact:** This implicit reconciliation must be made an explicit, intentional operation in modernization. The query must be separated from the correction logic.

**MR-043 — PrintReport called 3 times consecutively (ImpriDis, ImpriM, Imprix)**  
- **VERIFIED** — `MENU.PRG` lines 611–613, 690–692, 736–737  
- Three consecutive calls to the same print function produce three identical printer copies. No copy-count parameter. Must be clarified as intentional business policy before modernization.

---

### Category 6: Data Integrity Risks

**MR-050 — CONTRAS.DBF plaintext password storage**  
- **Severity:** CRITICAL  
- **VERIFIED** — `MENU.PRG`, `Function Contrasenia`, lines 30–56; `CONTRAS.DBF` exists in workspace  
- Passwords are stored in plaintext in the CONTRAS DBF file. The comparison is exact-match character string equality.
- **Migration impact:** Must NOT be replicated. Use a salted cryptographic hash (e.g., BCrypt, Argon2) in modernization.

**MR-051 — Non-atomic reservation number increment (race condition)**  
- **Severity:** HIGH  
- **VERIFIED** — `MENU.PRG`, `Function TraeNroRes`, lines 3053–3055  
- `DbGoBottom()` followed by `Reserva+1` is not an atomic operation. In a multi-user scenario (multiple Puesto workstations), two users could simultaneously reach the same bottom record and generate the same next reservation number.
- **Migration impact:** Replace with a database identity/auto-increment column or a transactional sequence generator.

**MR-052 — Occupied parcel can be assigned (Loop commented out)**  
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG`, `Function CargaParcela`, lines 3503–3506  
- The check for `SubNivel->(DbSeek(xCodigo))` shows the warning `'Esta Parcela Está Adjudicada'` but the `Loop` is commented out with `//Loop`. This allows creating a new reservation on a parcel that already has inhumation records.
- **Migration impact:** Decision required: is this intended behavior (reuse of a parcel after exhumation?) or a bug? Must be explicitly defined in the modernized business rule.

**MR-053 — VALOREXP rate reading: inconsistent access patterns**
- **Severity:** MEDIUM
- **VERIFIED / INFERRED** — `MENU.PRG`, `GrabaReserva()` line 3431 and `GrabaExpCta()` lines 3011–3012
- `GrabaExpCta()` explicitly calls `ValorExp->(DbGoBottom())` before reading `ValorExpen` — VERIFIED as bottom-record access. `GrabaReserva()` reads `ValorExp->ValorExpen` without `DbGoBottom()` — the record position is UNKNOWN without runtime observation and may not reliably return the most recently added rate. No effective date, no historical rate sequence in the table design.
- **Migration impact:** Modernization should implement an effective-date rate history table and replace both access patterns with a deterministic rate lookup.

**MR-054 — No referential integrity enforcement**  
- **Severity:** HIGH  
- **VERIFIED** — By absence: no FOREIGN KEY constraints exist (DBF format has none). Relationships are enforced only by application-level `DbSeek()` validation checks, which can be bypassed by utilities or direct table manipulation.
- **Migration impact:** All foreign key relationships must be formalized as database constraints in the target schema (e.g., SQLite `FOREIGN KEY`).

**MR-055 — No transaction support (no BEGIN/COMMIT/ROLLBACK)**  
- **Severity:** HIGH  
- **VERIFIED** — Throughout MENU.PRG, COBRA.PRG, LIQUIDA.PRG: each write is individual `VerActiva()` + `Replace` + `DbCommit()` + `DbUnLock()`. Multi-table writes (e.g., GrabaReserva + GrabaTitular + GrabaParque + CargaPlan in AltaReservas, lines 3242–3246) are not wrapped in any transaction.
- **Migration impact:** A partial failure (e.g., GrabaParque succeeds but CargaPlan fails due to crash) leaves the database in an inconsistent state. The modernized system must wrap related multi-table operations in database transactions.

---

### Category 7: Calendar and Date Arithmetic

**MR-060 — AuMes() does not account for month-end day overflow**  
- **Severity:** MEDIUM  
- **VERIFIED** — `MENU.PRG`, `Function AuMes`, lines 3280–3289  
- Adds 1 to the month number and rolls the year at month 13. If the reservation start date is the 31st (e.g., January 31), adding one month produces `31/02/YYYY` — an invalid date. Clipper may silently roll this over or truncate; behavior is UNKNOWN without running the application.
- **Migration impact:** Must use a proper `AddMonths()` function that respects end-of-month rules (clamp to last valid day of the month).

**MR-061 — SumaMes() uses 30 as the default month length**  
- **VERIFIED** — `MENU.PRG`, `Function SumaMes`, lines 3367–3386  
- For months 4, 6, 9, 11 (30-day months), SumaMes correctly uses 30 days. For February it uses the BISIESTO table. For all others it uses 31 days. This is correct — but the BISIESTO table must contain all years being processed. A missing year causes February to be treated as 28 days (non-leap default) regardless of actual leap year status.

**MR-062 — COBRA.PRG FechaVence hardcoded to 1999**  
- **Severity:** HIGH  
- **VERIFIED** — `COBRA.PRG` line 1: `Private FechaVence:=CToD('12/10/1999')`  
- All future installments generated via the standalone COBRA.PRG path would have due dates calculated from October 1999. This would produce nonsensical future dates for any payment processed through this path.

**MR-063 — LIQUIDA.PRG Mes_Liq and Ano_Liq hardcoded to March 2000**  
- **VERIFIED** — `LIQUIDA.PRG` lines 1–3  
- The standalone liquidation tool hardcodes the target liquidation month as March 2000. Running it today would create records for a month 25 years in the past. This confirms the standalone file is obsolete.

---

## 3. INFERRED Findings

**MR-I-01 — VerActiva() is a record locking function**  
- INFERRED from context: it appears immediately before every `DbAppend()` and `Replace` statement. The name ("VerActiva" = "make active/lock") suggests it calls `RLock()` or a similar locking primitive. Its absence would cause multi-user data corruption. Since the implementation is in the missing library, the exact locking strategy is UNKNOWN.
- **Migration impact:** The modernized system must implement proper optimistic or pessimistic locking as appropriate to the concurrency model.

**MR-I-02 — The application is designed for a LAN multi-workstation environment**  
- INFERRED from the `Puesto` variable, the per-workstation exclusive tables, the `Shared` table opens, and the `VerActiva()` locking pattern. Multiple workstations share the same DBF files on a network drive.
- **Migration impact:** The migration must decide whether the target is single-user, client-server, or web-based. The current architecture is file-sharing based — not server-based. This has major implications for the chosen target architecture.

**MR-I-03 — Print output goes directly to the physical printer**  
- INFERRED from `_Alpt()` / `_Clpt()` calls before/after all report output. These are printer-start/end library functions. The `?` and `@row,col say` statements in report functions print directly to the system printer.
- **Migration impact:** All reports must be reimplemented using a proper document-generation library (e.g., PDF generation) in modernization.

---

## 4. UNKNOWN Items

| ID | Item |
|----|------|
| U-01 | `VerActiva()` exact locking implementation — critical for concurrency safety |
| U-02 | `Pass1()` password verification algorithm |
| U-03 | `Hojear()` edit behavior for Modificación workflows |
| U-04 | Which Puesto value is used in the production workstation for exclusive ImpCob/ImpMut access — MENU.PRG uses '26', MENU1.PRG uses '01', production value is UNKNOWN |
| U-05 | Production use of COBRA.PRG and LIQUIDA.PRG standalone files — may be completely obsolete |
| U-06 | `bancos.dbf` role and any PRG file that opens it — no USE statement found in any workspace PRG |
| U-07 | Whether any production NTX files have expressions that differ from the OpenDbf() versions (re-indexing after the app was modified) |

---

## 5. Top 10 Risks — Ranked by Severity × Likelihood

| Rank | ID | Risk | Severity | Must-fix for PoC? |
|------|----|------|----------|-------------------|
| 1 | MR-050 | Plaintext password storage | CRITICAL | YES — replace with hashed auth |
| 2 | MR-055 | No transaction support — partial writes | HIGH | YES — wrap multi-table ops in transactions |
| 3 | MR-030 | Missing FTMENUTO.CH library — 20 unknown functions | CRITICAL | YES — must reverse-engineer VerActiva, Pass1, MChoice for PoC |
| 4 | MR-003 | Public Puesto / dynamic table partitioning | HIGH | YES — redesign as session-scoped staging |
| 5 | MR-051 | Non-atomic reservation number increment | HIGH | YES — use identity/sequence in target DB |
| 6 | MR-042 | BuscaDatos() hidden write during query | HIGH | YES — separate read from write operations |
| 7 | MR-054 | No referential integrity | HIGH | YES — add FK constraints in target schema |
| 8 | MR-020–025 | Permanent bulk-operation PRGs in workspace | HIGH | YES — document and never execute during testing |
| 9 | MR-040 | Screen layout mixed with business logic | HIGH | YES — complete rewrite required |
| 10 | MR-060 | AuMes() month-end date overflow | MEDIUM | YES — implement proper AddMonths() |

---

## 6. Deferred (Post-PoC) Risks

| ID | Risk | Recommendation |
|----|------|---------------|
| MR-001 | Color-scheme globals | Replace with theme constants |
| MR-002 | Hardcoded company name/address | Move to configuration file or settings table |
| MR-034 | MAEASO.DBF unknown purpose | Investigate before full migration |
| MR-043 | Triple printer copies | Confirm with stakeholders before changing |
| MR-063 | LIQUIDA.PRG hardcoded dates | Document as obsolete; exclude from PoC |
| MR-032 | cpzero.prg FoxPro file | Exclude entirely from migration scope |

---

## 7. Conflicts with Other Reports

- OTN-20 flagged `INFORME.PRG` as using alias `Parque` while MENU.PRG uses `ParqueNu`. This is confirmed as a genuine inconsistency (MR-I-04, not separately numbered because it is an alias mismatch, not a migration risk per se, but it implies that INFORME.PRG was written against an older table structure).
- OTN-21 flagged `CONTRAS.DBF` plaintext passwords — confirmed as MR-050.
- OTN-22 flagged the non-atomic reservation number (BR-011) — confirmed as MR-051.
- OTN-22 flagged the authentication bypass — confirmed as consistent with MR-030 (library function unknown) and MR-050.
- No conflicts were identified between reports.

---

## 8. Statement

Only synthetic demonstration data was used during this analysis. No real customer names, financial values, credentials, or personally identifiable information was read or reproduced. All risk assessments are based on PRG source code analysis. Severity ratings reflect migration difficulty and data correctness impact, not production incident history.
