# Verified Business Rules

**Task ID:** OTN-25 (consolidated from OTN-22, reconciled against OTN-20, OTN-21, OTN-23, OTN-24)  
**Date:** 2026-08-28  
**Status:** COMPLETE — Gate 2 APPROVED on 2026-08-29  
**Authoritative source:** `MENU.PRG` (4131 lines, canonical active version)  
**Secondary sources:** `COBRA.PRG`, `LIQUIDA.PRG`, `INFORME.PRG`

> **Important:** Rules marked INFERRED must NOT be converted into approved business requirements without explicit Gate 2 user approval. INFERRED rules are included for completeness and to identify questions requiring stakeholder confirmation.

---

## 1. Authorization and Access Control

### BR-001 — Maintenance Password Gate
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `MenuOperaciones()`, line 233  
- Batch liquidation (menu option 8) is guarded by `If Pass1('DEMO00')`. If the unresolved function `Pass1()` returns false, the operation is silently skipped. The token `'DEMO00'` is the sanitized demo value; the original was a maintenance secret. `Pass1()` is not defined in any available PRG; its implementation, original container, and any relationship to `FTMENUTO.CH` are UNKNOWN.  
- **No other menu options are guarded by this gate.**

### BR-002 — Login Function Exists but Is Inactive
- **Label:** VERIFIED (function logic); VERIFIED (call is commented out)  
- **Source:** `MENU.PRG`, `Contrasenia()`, lines 37–61; `MENU.PRG` line 12  
- `Contrasenia()` allows up to 3 consecutive login attempts against `CONTRAS.DBF`. On failure, it returns sentinel value `'9999999999'`. The call is commented out at line 12 (`*Public xUser:=Contrasenia()`). The system launches without any authentication in the current codebase.  
- **Risk:** Any user can operate all functions without credentials.

### BR-003 — Cobrador Validation on Collection Entry (Guard Currently Disabled)
- **Label:** VERIFIED (code is present but disabled)  
- **Source:** `MENU.PRG`, `CargaDatos()`, lines 2657–2663 (commented-out block)  
- A check that prevented payment entry if the session cobrador did not match the reservation's assigned cobrador (`Reserva->Cobrador != tCobrador`) is currently commented out. Exception was made for cobrador code 1.

---

## 2. Reservation Rules

### BR-010 — Reservation Number Auto-Increment
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `TraeNroRes()`, lines 3054–3055; called from `AltaReservas()`, line 3094  
- Next reservation number = `Reserva->DbGoBottom() + 1`. No collision check before presenting the value. The operator can override the suggested number.  
- **Risk:** Non-atomic in multi-user environment — two simultaneous workstations can generate the same number (MR-051).

### BR-011 — Duplicate Reservation Guard
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `AltaReservas()`, lines 3117–3120  
- Before creating a reservation, the system seeks the entered number in `Reserva`. If found: "Reserva Ya Entregada. Verifique." is shown and the step repeats.

### BR-012 — Expense Rate Snapshot at Reservation Creation
- **Label:** VERIFIED (code reads `ValorExp->ValorExpen`); which record is read is INFERRED  
- **Source:** `MENU.PRG`, `GrabaReserva()`, line 3431  
- `Local xExpensa := ValorExp->ValorExpen` reads the current-record value from `ValorExp` without calling `DbGoBottom()` first. `ValorExp` has no index and is opened without explicit pointer positioning in `OpenDbf()`. The record position at call time depends on prior caller context — the specific record that is read is UNKNOWN without runtime observation.  
- The value is stored in `Reserva.Expensa` at `MENU.PRG:3446`.

### BR-013 — Ult_Mes / Ult_Ano Initialized at Creation
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `GrabaReserva()`, lines 3444–3445  
- `Reserva.Ult_Mes` and `Reserva.Ult_Ano` are set to `Month(Date())` and `Year(Date())` when a reservation is saved. These track the last paid billing month.

### BR-014 — Parcel Assignment Constraints
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `CargaParcela()`, lines 3495–3506  
- Three checks are applied when assigning a parcel:
  1. `ParqueNu->CanTit > 3` → blocked: "No Puede haber más de 3 Titulares por Parcela."
  2. `ParqueNu->Tipo_p_s = 'P'` → blocked: "Esta Parcela Está Reservada."
  3. `SubNivel` record exists for the parcel code → warning shown, but the `Loop` that would block is **commented out**. Assignment is allowed despite the warning.

### BR-015 — Parcel Type Set to 'P' on Assignment
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `GrabaParque()`, lines 3460 and 3475  
- `ParqueNu->Tipo_P_S` is always set to `'P'` (Reserved/Particular) when a parcel is written, regardless of prior type.

### BR-016 — Reservation Cancellation Status
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `Nucleo()`, line 895; `LIQUIDA.PRG`, `Nucleo()`, line 13  
- `Reserva.CodBaja = 0` is the active-reservation test. Reservations with `CodBaja != 0` are skipped by all liquidation loops. `Baja.Codigo` → `Baja.Descripcio` describes the reason.

### BR-017 — Reservation Type Classification
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `AltaReservas()`, lines 3197–3208  
- Three plan types: `'S'` = Plan Demo A / Socio; `'P'` = Particular; `'V'` = Socio Demo B. Stored in both `Reserva.Tipo` and `ParqueNu.Tipo_P_S`. Used in inhumation statistics.

### BR-018 — Reservation Required Fields
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `AltaReservas()`, lines 3123–3178  
- Only `xAlta` (creation date) has an explicit `Valid !Empty(xAlta)` guard. Cobrador and Mutual have lookup validation that rejects unknown codes. Other fields (Nombre, Domicilio, Provincia, Documento) are captured interactively but do not have mandatory non-empty guards in code.

---

## 3. Installment Plan Rules

### BR-020 — Installment Plan Written at Reservation Creation
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `CargaPlan()`, lines 3256–3278  
- After a reservation is saved, `CargaPlan(xReserva)` reads from the per-workstation temp table `AxPl<Puesto>` (fields: Cuotas, Precio, Desde) and appends `Cuotas` records to `CtaCte`:
  - `Cuota` = sequential number (1 to n)
  - `Importe` = Precio
  - `Saldo` = Precio (initial balance = full amount)
  - `Vencimient` = Desde date advanced one month per installment via `AuMes()`
  - `Marca` = `'I'`

### BR-021 — Cash Plan Installment Limit
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `Facturar()`, line 3310  
- For payment mode Contado (Op=1): `xCuotas > 0 .And. xCuotas <= 24`. No maximum is enforced for Cuenta Corriente (Op=3).

### BR-022 — Due Date Advances One Calendar Month Per Installment
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `AuMes()`, lines 3280–3289  
- Increments month by 1; wraps December → January and increments year. Day-of-month is preserved with no boundary check for short months (e.g., January 31 → February 31 is not corrected — see risk MR-060).

### BR-023 — February Day Count from Leap-Year Table
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `SumaMes()`, lines 3370–3386  
- `SumaMes()` advances a date by N months. For February it queries `Bisiesto->(DbSeek(xAno))`. If found: 29 days; otherwise 28. All other months use their standard lengths. The completeness of the `Bisiesto` table for all relevant years is UNKNOWN.

---

## 4. Expense Liquidation Rules

### BR-030 — Batch Liquidation Skips Cancelled Reservations
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `Nucleo()`, line 895; `LIQUIDA.PRG`, `Nucleo()`, line 13  
- The liquidation loop skips any reservation where `CodBaja != 0`.

### BR-031 — Expense Record Created for Current Period if Missing
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `Liquidacion()`, lines 913–923  
- Seeks `CtaExp` for `(Reserva, Ano_Liq, Mes_Liq)`. If not found, appends a new record with `Pagada='N'`, `Valor = xExpensa`, `Vence = FechaVence`. If the record already exists, no action is taken (no duplicate).

### BR-032 — Liquidation Scans from January 1991 Baseline
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `Nucleo()` / `N_ucleo()`, lines 878–879 and 896–897  
- The scan always starts from `xUlt_Mes = 1`, `xUlt_Ano = 1991` regardless of the stored `Reserva.Ult_Mes`/`Ult_Ano`. The batch iterates month by month up to the target period, accumulating all `CtaExp` records where `Pagada='N'`.  
- **Note:** `Reserva.Ult_Mes`/`Ult_Ano` are updated by `COBRA.PRG:Descarga()` (lines 67–86) but ignored by the batch. Their role as a scan cursor appears abandoned in the batch path (BR-103, INFERRED).

### BR-033 — Minimum Payment (MENU.PRG formula): 30% of Total, Rounded Up to Whole Installments
- **Label:** VERIFIED
- **Source:** `MENU.PRG`, `CargaLiq()`, lines 959–975
- Calculation:
  1. `xMinimo = xTotal × 0.30`
  2. `xCan = Int(xMinimo / Reserva->Expensa)` — whole installments at 30%
  3. `xMinimo = Reserva->Expensa × (xCan + 1)` — rounded up to next whole installment
- Written to `ResuCta.Minimo`.

### BR-033b — Minimum Payment (LIQUIDA.PRG formula): 30% of Total, Capped at Total
- **Label:** VERIFIED
- **Source:** `LIQUIDA.PRG`, `CargaLiq()`, line 85
- Calculation: `xMinimo = xTotal × 0.30`; if `xMinimo > xTotal` then `xMinimo = xTotal`. No installment-rounding step.
- Written to `ResuCta.Minimo` via the same field name.

> **Divergence note:** The two formulas produce different `ResuCta.Minimo` values. Both formulas are VERIFIED from their respective source files. Which formula governs the production minimum payment is **UNKNOWN pending stakeholder approval and workflow selection at Gate 3.** Do not treat either formula as authoritative before that decision.

### BR-034 — Adeuda String Built from AuxLiq
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `TraeMesAde()`, lines 978–985  
- Scans all `AuxLiq` records and concatenates a string of the form `YYYY/MM YYYY/MM ...` for every unpaid month. Stored in `ResuCta.Adeuda`.

---

## 5. Payment and Collection Rules

### BR-040 — Minimum Payment Enforcement
- **Label:** VERIFIED  
- **Source:** `COBRA.PRG`, `Cobranza()`, lines 28–31  
- If the entered payment `xPaga < ResuCta->Minimo`: "No puede pagar menos del mínimo." is shown and the entry loops.

### BR-041 — Expense Payment Applied FIFO by Month/Year
- **Label:** VERIFIED  
- **Source:** `COBRA.PRG`, `Descarga()`, lines 41–91  
- Iterates `CtaExp` from oldest unpaid record (order 2: Reserva+Ano+Mes, starting from 1990/01):
  - If `Pagada='N'` and `Valor < xPaga`: marks `Pagada='S'`, `Valor=0`; subtracts from `xPaga`.
  - If `Valor = xPaga`: marks `Pagada='S'`, `Valor=0`; updates `Reserva.Ult_Mes/Ult_Ano`; exits.
  - If `xPaga > 0` and `Valor > xPaga`: sets `Valor = Abs(xPaga)` (partial); updates `Reserva.Ult_Mes/Ult_Ano` to prior period; exits.

### BR-042 — Excess Payment Creates Future Installment Records
- **Label:** VERIFIED  
- **Source:** `COBRA.PRG`, `Descarga()`, lines 92–127  
- If `xPaga > 0` after all existing records consumed: new `CtaExp` records are appended for future months using `FechaVence + 30 days` increments. Each future record: `Pagada='S'` if fully covered, `Pagada='N'` with residual `Valor` if partial.  
- **Risk:** `FechaVence` in `COBRA.PRG` is hardcoded to `CToD('12/10/1999')` — would produce stale future dates if this path were used today (MR-062).

### BR-043 — Cobrador Required and Validated at Collection Entry
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `CobroExpensas()` / `CobroCuotas()`, lines 2598 and 2547  
- Both collection workflows begin with `CargaCobrador()`. Unknown cobrador code: "Código De Cobrador No Encontrado. Verifique." Esc aborts the session.

### BR-044 — Duplicate Expense Entry Detected by Date and Reservation
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `Busca_Rep()`, lines 2695–2731  
- If a record for the same `xReserva` already exists in `AuxiRes` with the same `FechaPago`, an alert is raised. The operator can modify `Bonifica` or `Importe`; if `Importe = 0`, the record is deleted.

### BR-045 — Collection Amount: Total = Importe + Bonifica
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `CargaCuoCta()`, line 2840; `TakeRec()`, lines 511–514 and 519–521  
- `xMonto = Importe + Bonifica` is the effective amount applied to `CtaCte`. Discount/bonus reduces net charge.

### BR-046 — Installment Payment Applied FIFO to CtaCte
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `GrabaCuoCta()`, lines 2846–2925  
- Iterates `CtaCte` records for the reservation while `Saldo > 0`:
  - `xResta = Saldo − xImporte >= 0` → `Saldo = xResta`; write `Recibo`; exit.
  - `xResta < 0` → `Saldo = 0`; write `Recibo`; carry `xImporte = Abs(xResta)` to next record.
  - Bonificacion is applied before Importe in allocation order.

### BR-047 — Expense Payment Posts to ExpCta; CtaExp Marked Paid
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `CargaExpCta()` → `GrabaExpCta()` and `Actualiza()`, lines 2929–3006  
- `GrabaExpCta()` (line 3011): explicitly calls `ValorExp->(DbGoBottom())` before reading `ValorExp->ValorExpen` — **confirmed bottom-record access.** Writes an `ExpCta` record.  
- `Actualiza()` iterates `CtaExp` for the reservation; applies `xImporte + ACuenta`; marks records `Pagada='S'` if fully covered or updates `ACuenta` for partial; creates future records if overpaid.

---

## 6. Account and Ledger Rules

### BR-050 — CtaCte Saldo Recalculated During Query (Hidden Side Effect)
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `BuscaDatos()`, lines 2096–2119  
- During "Reservas y Cuotas" query, `BuscaDatos()` cross-references `Recibo` and `CtaCte` to update `CtaCte.Saldo` and write `Recibo.Cuota` in real-time. **This is a write operation embedded in a nominally read-only display function.** Every time a user views a reservation's account, data is silently corrected.

### BR-051 — Credito = Sum of All CtaCte.Importe for Reservation
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `TraeCredito()`, lines 739–750  
- `TraeCredito(xReserva)` sums `CtaCte.Importe` for all matching records. Stored in `Reserva.Credito` before printing cobrador report.

### BR-052 — Debit on Cobrador Report: Credito − PagCta
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `PutExpensa()`, lines 711–717  
- `xCredito = TraeCredito(xReserva)`; `xPagCta = Recibo->(TraeDR(xReserva))` (sum of `Bonificaci + Importe`); `xDebCta = xCredito − xPagCta`.

### BR-053 — Mutual Report Total: Expensa + PagCta from CtaCte
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `PonExpensa()` and `DisExpensa()`, lines 676 and 605  
- Per-reservation deducted total = `xImporte + xPagCta` where `xImporte = Reserva->Expensa` and `xPagCta = CtaCte->(TraeDM(xReserva, xCredito))`.

### BR-054 — TraeDM Returns 0 When All CtaCte.Saldo = 0
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `TraeDM()`, lines 822–834  
- Accumulates `CtaCte->Saldo` for the reservation. If `xSuma = 0` (all paid): returns 0. If `xSuma > 0`: returns the last `CtaCte->Importe` seen.

---

## 7. Inhumation Rules

### BR-060 — Inhumation Requires Parcel to Exist
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `AltaInhu()`, lines 280–303  
- Seeks `ParqueNu` by composite code `Sector + StrZero(Fila,2) + StrZero(Parcela,2)`. If not found: "Código Inexistente. Verifique." and loops.

### BR-061 — Duplicate SubNivel Guard
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `AltaInhu()`, lines 295–300  
- Seeks `SubNivel` for `xCodigo + Str(xNivel,1) + Str(xSubNivel,1)`. If found: "Inhumación Existente. Verifique" — not saved.

### BR-062 — SubNivel Must Be Sequential
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `CargaSub()`, lines 314–321  
- Before saving sub-level `t`, loops from 1 to `t-1` verifying each prior sub-level exists. Missing prior: "Debe Cargar primero el SubNivel N" — function returns without saving.

### BR-063 — Inhumation Service Type
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `CargaSub()`, lines 333 and `BuscaNivel()` line 1385, `Listado()` line 2504  
- `SubNivel.TipoI`: `'T'` = Traslado (transfer), `'S'` = Sepelio (burial service). Used in statistics report.

### BR-064 — Nivel Range 1–3; SubNivel Range 1–6
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `AltaInhu()`, lines 289–290  
- `xNivel` entered with `Range 1,3`; `xSubNivel` entered with `Range 1,6`.

### BR-065 — Recently Interred Parcel Highlighted Within 15 Days
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `StorParcela()` / `Superficie()`, lines 3597–3600 and 1121–1125  
- `Date() - 15 <= SubNivel->FechaI`: highlight with blinking color `'N*/R'`. Otherwise occupied: `'G+/R+'`.

---

## 8. Report and Statistics Rules

### BR-070 — Inhumation Report: Inclusive Date Filter on FechaI
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `Inhumacion()`, lines 2401 and 2406; `INFORME.PRG`, `Inhumacion()`, lines 6 and 8  
- `DbSetFilter` on `FechaI >= xDesde .And. FechaI <= xHasta`. `xHasta >= xDesde` enforced by UI `Valid` clause.  
- **Note:** Both MENU.PRG (line 2369) and `INFORME.PRG` (line 2) contain separate `Inhumacion()` implementations. The MENU.PRG version uses `ParqueNu` alias; INFORME.PRG uses `Parque` alias. Whether INFORME.PRG is compiled separately or linked with MENU.PRG is UNKNOWN. Both implementations are documented for completeness.

### BR-071 — Statistics by Parcel Type (S / P / V / Other)
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `Inhumacion()`, lines 2416–2425; `INFORME.PRG`, lines 41–50  
- Classification: `'S'` → Socio; `'P'` → Particular; `'V'` → Especial; other → Otros.

### BR-072 — Statistics: Unique Nivel Count + SubNivel Count
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `Inhumacion()`, lines 2426–2479; `INFORME.PRG`, lines 51–68  
- Boolean flags `tNivel1/2/3` ensure each burial level is counted once per unique parcel. `xSubNivel1/2/3` counts every individual inhumation at that level.

### BR-073 — Mutual Report: Commission Deducted Before Net Total
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `ImpriM()`, lines 815–817  
- Sub-total = sum of all `Total` values. Commission = `SubTotal × Mutual->Comisi / 100`. Net = `SubTotal − Commission`.

### BR-074 — Collections Report: Daily Cuota + Expensa Aggregation
- **Label:** VERIFIED  
- **Source:** `MENU.PRG`, `LCobGen()` / `LCobCob()`, lines 397–503; `TakeRec()`, lines 505–526  
- Per-day: `xCuota` from `Recibo`; `xExpensa` from `ExpCta`; `xTotal = xCuota + xExpensa`; running `xAcum`. Cobrador-specific version filters by `Cobrador = xCob`.

---

## 9. INFERRED Rules (Require Stakeholder Confirmation Before Modernization)

| ID | Rule | Source | Uncertainty |
|----|------|--------|-------------|
| BR-100 | `GrabaReserva()` reads whichever ValorExp record is current at call time (may not be the most recent rate) | `MENU.PRG:3431` vs `GrabaExpCta():3011` | Position-dependent; UNKNOWN without runtime observation |
| BR-101 | Suplentes have no explicit cap and no visible financial role | `MENU.PRG:3732–3830` | Financial/legal implications UNKNOWN |
| BR-102 | `CARVALOR.PRG` and `REPL.PRG` are the only mechanism for bulk expense-rate changes | `CARVALOR.PRG:2`; `REPL.PRG:2` | Whether reusable or one-time is UNKNOWN |
| BR-103 | `Reserva.Ult_Mes/Ult_Ano` track last paid month but are ignored by the batch liquidation scan | `COBRA.PRG:67–86`; `MENU.PRG:878` | Functional role partially abandoned |
| BR-104 | `ParqueNu.SCargo != ' '` silently suppresses a parcel from the cobrador report | `MENU.PRG:705` | Domain values and business meaning of SCargo are UNKNOWN |
| BR-105 | `Puesto` variable routes all per-workstation table access; production value UNKNOWN | `MENU.PRG:3854, 3898, 3987, 4006, 4045` | Production Puesto for exclusive-print station is UNKNOWN |

---

## 10. UNKNOWN Items

| ID | Item |
|----|------|
| UNK-001 | `Pass1()` — password check logic and input mechanism |
| UNK-002 | `ValorExp` record position when `GrabaReserva()` reads it (no `DbGoBottom()` call) |
| UNK-003 | Completeness of `Bisiesto` DBF leap-year table |
| UNK-004 | `AxPl<Puesto>` plan table schema |
| UNK-005 | Whether login (`Contrasenia()`) is intentionally inactive or was accidentally disabled |
| UNK-006 | Role of `Recexpe` and `AuxParq` — opened in `OpenDbf()` but no reads/writes found in any function |
| UNK-007 | `PExpensa` DBF full role — used in `CCTA.PRG` but the active code path is not in the main menu |
| UNK-008 | Payment types `Tarjeta` (Op=2) and `Socio` (Op=4) in `Facturar()` — no installment creation code found |
| UNK-009 | `Baja` cancellation code domain values |
| UNK-010 | `Mutual.Comisi` valid range and default |

---

## 11. Synthetic Data Statement

All rules were derived exclusively from PRG source code logic. No production data, real financial values, credentials, or personally identifiable information was accessed or reproduced.

---

*End of OTN-25 Business Rules document*
