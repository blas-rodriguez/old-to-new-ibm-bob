# Business Rules Extraction Report

**Task ID:** OTN-22  
**Persona:** business-rules  
**Date:** 2026-08-28
**Output:** `bob_result/agents/03-business-rules.md`

---

## 1. Scope and Files Inspected

All 25 root-level `*.PRG` files were read in full. Primary sources of business logic:

| File | Role |
|------|------|
| `MENU.PRG` | Main entry point, all menus, reservation creation, inhumation entry, expense collection, liquidation, reporting (4131 lines) |
| `COBRA.PRG` | Standalone payment/fee-posting utility |
| `LIQUIDA.PRG` | Batch expense-liquidation utility |
| `INFORME.PRG` | Statistical inhumation report |
| `RESERVA.PRG` | One-off data-fix utility (mass replace on Reserva) |
| `CCTA.PRG` | CtaExp initializer from PExpensa |
| `CARVALOR.PRG` | One-off utility: set all `Expensa = 13` |
| `REPL.PRG` | One-off utility: set all `Expensa = 10`, reset Ult_Mes/Ult_Ano |
| `ARMAPAR.PRG` | Parcel batch-creation utility |
| `CARGACOB.PRG` | Cobrador back-fill utility (ParqueNu ← Reserva) |
| `CAMBIO.PRG` | ParqueNu → Reserva field sync utility |
| `PASANO.PRG` | Ult_Ano year-2000 migration utility |
| `AGRGA.PRG` | One-off: `ano = ano + 1900` in CtaExp |
| `BANCODIS.PRG` | Mutual bank-debit file generator |
| `ANA.PRG` / `ANA2.PRG` | Ad-hoc analysis scripts |
| `BORRA.PRG` | Conditional bulk-delete utility: `DELE ALL FOR recno()>246260`, then PACK — CtaExp |
| `CTA01.PRG` | Date-scoped delete utility: removes mes=12/ano=1999 and all ano=2000 rows, then PACK — CtaExp |
| `VERCTA.PRG`, `RESUCTA.PRG`, `CTACTE.PRG`, `VALOR.PRG`, `RECIBO.PRG` | Browse/pack utilities only |

No production data was accessed. All observations are based on the sanitized synthetic-record workspace. This workspace is not a production installation; missing behavior is UNKNOWN and must be resolved through approved evidence or stakeholder review.

---

## 2. VERIFIED Business Rules

### 2.1 Authorization / Access Control

#### BR-001 — Maintenance-Mode Password Gate
- **Category:** Authorization  
- **Source:** `MENU.PRG`, `MenuOperaciones()`, line 233  
- **Description:** Accessing the "Liquidación de Expensas" batch operation (menu option 8 in `MenuOperaciones`) is guarded by `Pass1('DEMO00')`. Only if this password is verified does the system call `Reserva->(Nucleo())`. All other menu items in `MenuOperaciones` are unguarded.  
- **Inputs:** Hardcoded token `'DEMO00'` (sanitized demo value; original was a maintenance secret).  
- **Outputs:** If `Pass1` returns false, the liquidation batch does not execute.  
- **Label:** VERIFIED — `MENU.PRG:233`: `If Pass1('DEMO00')`

#### BR-002 — Login Attempt Limit
- **Category:** Authorization  
- **Source:** `MENU.PRG`, `Contrasenia()`, lines 37–61  
- **Description:** The login dialog allows a maximum of 3 consecutive login attempts. If none succeeds, `xUsuario` is set to `'9999999999'` (a sentinel value) instead of a valid user. The function is called but its return value is assigned to a commented-out Public variable (`*Public xUser:=Contrasenia()`), so in the current codebase the login dialog is **inactive**; the system launches directly without authentication.  
- **Inputs:** `Contras` DBF (username/password store). Password entered character-by-character, max 10 chars.  
- **Outputs:** Returns username string on success, `'9999999999'` on failure.  
- **Label:** VERIFIED (function logic) — the call is commented out (`MENU.PRG:12`), rendering actual login check INFERRED as inactive.

#### BR-003 — Cobrador Validation on Collection Entry
- **Category:** Authorization / Validation  
- **Source:** `MENU.PRG`, `CargaDatos()`, lines 2657–2663 (commented-out block)  
- **Description:** Original code had a check preventing payment entry if the reservation's assigned cobrador did not match the current cobrador session (`Reserva->Cobrador != tCobrador`). This check is currently commented out, meaning any cobrador can accept any reservation. The check was excepted for cobrador code 1.  
- **Label:** VERIFIED (commented-out guard) — code is present but disabled.

---

### 2.2 Reservation Rules

#### BR-010 — Reservation Number Auto-Increment
- **Category:** Calculation / Constraint  
- **Source:** `MENU.PRG`, `TraeNroRes()`, line 3054–3055; called from `AltaReservas()`, line 3094  
- **Description:** The next reservation number is computed by going to the bottom of the `Reserva` DBF and returning `Reserva + 1`. No gap detection or collision check is performed before presenting the value to the operator. The operator can override the suggested number at the prompt.  
- **Inputs:** `Reserva` DBF, current last record.  
- **Outputs:** `xReserva` — proposed next reservation number.  
- **Label:** VERIFIED — `MENU.PRG:3054-3055`, `3094`.

#### BR-011 — Duplicate Reservation Guard
- **Category:** Validation  
- **Source:** `MENU.PRG`, `AltaReservas()`, lines 3117–3120  
- **Description:** Before creating a new reservation, the system seeks the entered reservation number in `Reserva`. If found, it displays "Reserva Ya Entregada. Verifique." and loops back.  
- **Inputs:** `xReserva` (operator-entered or auto-suggested number).  
- **Outputs:** Error message; loop prevents duplicate creation.  
- **Label:** VERIFIED — `MENU.PRG:3117-3120`.

#### BR-012 — Expense Rate Read from ValorExp at Reservation Creation
- **Category:** Calculation
- **Source:** `MENU.PRG`, `GrabaReserva()`, lines 3430–3449
- **Description:** When a new reservation is created, `GrabaReserva()` reads `ValorExp->ValorExpen` at line 3431 (`Local xExpensa:=ValorExp->ValorExpen`) and stores it in `Reserva->Expensa`. This snapshot is taken from whichever ValorExp record is current at call time. `GrabaReserva()` does not call `DbGoBottom()` before reading; the record position depends on prior caller context. The caller (`AltaReservas`) does not explicitly position ValorExp either. Whether the most-recently-added rate is reliably read depends on the open-time pointer state — INFERRED that it reads whatever record is current, which may be the first record in the table if no repositioning has occurred.
- **Inputs:** `ValorExp` DBF — current record at call time (position UNKNOWN without runtime observation).
- **Outputs:** `Reserva.Expensa` field populated.
- **Label:** VERIFIED (code reads `ValorExp->ValorExpen` at line 3431); which record is read is INFERRED.

#### BR-013 — Ult_Mes / Ult_Ano Initialized to Current Month/Year at Creation
- **Category:** State Transition  
- **Source:** `MENU.PRG`, `GrabaReserva()`, lines 3444–3445  
- **Description:** When a reservation is saved, `Ult_Mes` and `Ult_Ano` are set to the current system month and year (`Month(Date())`, `Year(Date())`). These fields track the last paid month and are used as the starting point for future liquidation scans.  
- **Inputs:** System date at time of creation.  
- **Outputs:** `Reserva.Ult_Mes`, `Reserva.Ult_Ano`.  
- **Label:** VERIFIED — `MENU.PRG:3444-3445`.

#### BR-014 — Parcela Occupancy and Reservation Status
- **Category:** Constraint  
- **Source:** `MENU.PRG`, `CargaParcela()`, lines 3495–3506  
- **Description:** When assigning a parcel to a new reservation:
  - If `ParqueNu->CanTit > 3`: blocked ("No Puede haber más de 3 Titulares por Parcela").
  - If `ParqueNu->Tipo_p_s = 'P'`: blocked ("Esta Parcela Está Reservada").
  - If a `SubNivel` record exists for the parcel code: warning "Esta Parcela Está Adjudicada" is shown, but the `Loop` that would block assignment is commented out, allowing override.  
- **Inputs:** `ParqueNu.CanTit`, `ParqueNu.Tipo_p_s`, `SubNivel` DBF.  
- **Outputs:** Error/warning message; blocks or warns before assignment.  
- **Label:** VERIFIED — `MENU.PRG:3495-3506`.

#### BR-015 — Parcel Type Set to 'P' (Reserved) Upon Assignment
- **Category:** State Transition  
- **Source:** `MENU.PRG`, `GrabaParque()`, lines 3460 and 3475  
- **Description:** When a reservation is linked to a parcel (either update or append), `ParqueNu->Tipo_P_S` is always set to `'P'` (Particular/Reserved), regardless of the original type. The previous type is overwritten.  
- **Inputs:** `xCodigo` (parcel code), reservation data.  
- **Outputs:** `ParqueNu.Tipo_P_S = 'P'`.  
- **Label:** VERIFIED — `MENU.PRG:3460, 3475`.

#### BR-016 — Reservation Cancellation (CodBaja)
- **Category:** State Transition / Constraint  
- **Source:** `MENU.PRG`, lines 876, 895; `LIQUIDA.PRG`, line 13  
- **Description:** A reservation with `CodBaja != 0` is considered cancelled or inactive. Both the batch liquidation loop (`Nucleo()` in `MENU.PRG:895`) and LIQUIDA.PRG's `Nucleo()` (line 13) skip reservations where `CodBaja = 0` is false (i.e., where the code is non-zero). The `Baja` DBF holds descriptions for each cancellation code. A `Baja` date field and `CodBaja` are displayed on the reservation consultation screen.  
- **Inputs:** `Reserva.CodBaja`, `Baja` DBF.  
- **Outputs:** Cancelled reservations excluded from expense generation.  
- **Label:** VERIFIED — `MENU.PRG:876, 895`; `LIQUIDA.PRG:13`.

#### BR-017 — Reservation Type Classification
- **Category:** Constraint  
- **Source:** `MENU.PRG`, `AltaReservas()`, lines 3192–3208; display at lines 1975, 1320
- **Description:** At creation, the operator selects one of three plan types stored in `Reserva.Tipo` / `ParqueNu.Tipo_P_S`:
  - `'S'` → "Plan Demo A" / "Socio"
  - `'P'` → "Particular"
  - `'V'` → "Socio Demo B" / "120c x $20" (special plan)  
  These are also used as filter categories in the inhumation statistics report.  
- **Label:** VERIFIED — `MENU.PRG:3197-3208`.

#### BR-018 — Required Fields for Reservation (Validation)
- **Category:** Validation  
- **Source:** `MENU.PRG`, `AltaReservas()`, lines 3123–3178  
- **Description:** The following fields are captured during reservation creation. Only `xAlta` (creation date) has an explicit `Valid !Empty(xAlta)` guard. `Nombre`, `Domicilio`, `Barrio`, `Telefono`, `Localidad`, `Provincia`, `Cobrador`, and `Mutual` are entered interactively but do not have non-empty guards enforced in code (Cobrador/Mutual have lookups that reject unknown codes). Document type (DNI/LE/LC/CI/CE) and document number are required by the UI flow but no explicit `!Empty` guard enforces them.  
- **Label:** VERIFIED (field flow) — strict non-empty validation only on `xAlta` (`MENU.PRG:3178`).

---

### 2.3 Installment Plan Rules

#### BR-020 — Plan Created at Reservation — Installments from AxPl
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `CargaPlan()`, lines 3256–3278  
- **Description:** After a reservation is saved, `CargaPlan(xReserva)` opens the workstation-specific temporary plan table (`AxPl<Puesto>`) and reads `Cuotas` (installment count) and `Precio` (per-installment amount). It creates `Cuotas` records in `CtaCte`, one per installment, each with:
  - `Cuota = t` (sequential number, 1 to n)
  - `Importe = Precio` (per-installment amount)
  - `Saldo = Precio` (initial balance equals full amount)
  - `Vencimient = xVigencia` (due date, advanced one month per installment by `AuMes()`)
  - `Marca = 'I'`  
- **Inputs:** `AxPl<Puesto>.Cuotas`, `AxPl<Puesto>.Precio`, `AxPl<Puesto>.Desde`.  
- **Outputs:** Multiple records in `CtaCte`.  
- **Label:** VERIFIED — `MENU.PRG:3256-3278`.

#### BR-021 — Cash Plan Installment Count Constraint
- **Category:** Validation  
- **Source:** `MENU.PRG`, `Facturar()`, line 3310  
- **Description:** For payment mode "Contado" (Op=1), the number of installments is validated with `xCuotas > 0 .And. xCuotas <= 24`. No such maximum is enforced for "Cuenta Corriente" (Op=3).  
- **Inputs:** User-entered `xCuotas`.  
- **Outputs:** Error if outside range; re-prompt.  
- **Label:** VERIFIED — `MENU.PRG:3310`.

#### BR-022 — Due Date Advances One Calendar Month Per Installment
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `AuMes()`, lines 3280–3289  
- **Description:** Each installment's due date is advanced by exactly one month using `AuMes()`: increments `Month` by 1, wraps December → January and increments year. Day-of-month is preserved (no 28/29/30/31 boundary check is applied in `AuMes`).  
- **Label:** VERIFIED — `MENU.PRG:3280-3289`.

#### BR-023 — Leap-Year Table Lookup for February Days
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `SumaMes()`, lines 3370–3385  
- **Description:** `SumaMes()` advances a date by N months with correct day counts. For February it queries the `Bisiesto` DBF using `DbSeek(xAno)`. If a matching year is found, February = 29 days; otherwise 28. All other months use standard lengths (31 for Jan/Mar/May/Jul/Aug/Oct/Dec; 30 for Apr/Jun/Sep/Nov). This function is used during installment plan construction in `Facturar`.  
- **Inputs:** `Bisiesto` DBF, year integer.  
- **Outputs:** Corrected date advanced by N months.  
- **Label:** VERIFIED — `MENU.PRG:3370-3386`.

---

### 2.4 Expense Liquidation Rules

#### BR-030 — Batch Liquidation Skips Cancelled Reservations
- **Category:** Constraint  
- **Source:** `MENU.PRG`, `Nucleo()`, line 895; `LIQUIDA.PRG`, `Nucleo()`, line 13  
- **Description:** The top-level `Nucleo()` loop iterates all reservations. Any reservation with `CodBaja != 0` is skipped entirely; no expense record is generated.  
- **Label:** VERIFIED — `MENU.PRG:895`; `LIQUIDA.PRG:13`.

#### BR-031 — Expense Record Created for Current Liquidation Period If Missing
- **Category:** State Transition  
- **Source:** `MENU.PRG`, `Liquidacion()`, lines 913–923  
- **Description:** Inside `Liquidacion()`, the system seeks `CtaExp` for the target `(Reserva, Año_Liq, Mes_Liq)` key. If no matching record is found (`Reserva != xReserva .Or. Ano != Ano_Liq .Or. Mes != Mes_Liq`), a new `CtaExp` record is appended with `Pagada = 'N'`, `Valor = xExpensa`, and `Vence = FechaVence`. If the record already exists, no action is taken.  
- **Inputs:** `CtaExp` DBF (key: Reserva+Ano+Mes), `xExpensa` (from `Reserva.Expensa`), `FechaVence`.  
- **Outputs:** New `CtaExp` record if absent.  
- **Label:** VERIFIED — `MENU.PRG:913-923`.

#### BR-032 — Liquidation Accumulates Unpaid Installments Starting January 1991
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `Nucleo()` / `N_ucleo()`, lines 878–879 and 896–897  
- **Description:** In both the batch (`Nucleo`) and single-reservation (`N_ucleo`) liquidation flows, the scan always starts from `xUlt_Mes = 1`, `xUlt_Ano = 1991` (a fixed historical baseline), regardless of the reservation's stored `Ult_Mes`/`Ult_Ano`. It advances month by month up to and including `(Mes_Liq, Ano_Liq)`, counting all `CtaExp` records where `Pagada = 'N'`.  
- **Inputs:** `CtaExp` DBF, `Mes_Liq`, `Ano_Liq` (current period).  
- **Outputs:** `xTotal` (sum of unpaid values), `xCantidad` (count), written to `ResuCta`.  
- **Label:** VERIFIED — `MENU.PRG:878-879, 896-897`.

#### BR-033 — Minimum Payment = 30% of Total Debt, Rounded Up to Whole Installments
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `CargaLiq()`, lines 959–975  
- **Description:** After the total unpaid amount (`xTotal`) is computed, the minimum payment (`xMinimo`) is calculated as:
  1. `xMinimo = xTotal × 0.30`
  2. Compute `xCan = Int(xMinimo / Reserva->Expensa)` (how many whole installments that is)
  3. `xMinimo = Reserva->Expensa × (xCan + 1)` — round up to the next whole installment.  
  The `ResuCta` record is only created when `!DbSeek(xReserva)` (i.e., the reservation does not yet exist in `ResuCta`).  
- **Inputs:** `xTotal`, `Reserva->Expensa`.  
- **Outputs:** `ResuCta.Minimo`, `ResuCta.Total`, `ResuCta.Vence`.  
- **Label:** VERIFIED — `MENU.PRG:959-975`.

> **Note:** The standalone `LIQUIDA.PRG` uses a simpler formula: `xMinimo = xTotal × 0.30`, capped at `xTotal` if it exceeds it (lines 85–88), with no whole-installment rounding. This is a divergence from `MENU.PRG`. See Section 6.

#### BR-034 — Months Owed String Built from AuxLiq
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `TraeMesAde()`, lines 978–985  
- **Description:** `TraeMesAde` scans all records in the `AuxLiq` temp table and concatenates a human-readable string of the form `YYYY/MM YYYY/MM ...` listing every month/year with an unpaid balance. This string is stored in `ResuCta.Adeuda`.  
- **Outputs:** `ResuCta.Adeuda` — text string of overdue months.  
- **Label:** VERIFIED — `MENU.PRG:978-985`.

---

### 2.5 Payment / Collection Rules

#### BR-040 — Payment Must Be At Least the Minimum
- **Category:** Validation  
- **Source:** `COBRA.PRG`, `Cobranza()`, lines 28–31  
- **Description:** After looking up the reservation summary in `ResuCta`, the operator enters a payment amount (`xPaga`). If `xPaga < xMinimo` (from `ResuCta->Minimo`), the system displays "No puede pagar menos del mínimo." and loops back.  
- **Inputs:** `xPaga` (entered), `ResuCta->Minimo`.  
- **Outputs:** Error prompt; no payment written.  
- **Label:** VERIFIED — `COBRA.PRG:28-31`.

#### BR-041 — Payment Applied to Oldest Unpaid CtaExp Records First (FIFO)
- **Category:** Calculation / State Transition  
- **Source:** `COBRA.PRG`, `Descarga()`, lines 41–91  
- **Description:** `Descarga()` iterates `CtaExp` from the earliest unpaid record (order 2: Reserva+Ano+Mes, starting from 1990/01) while `Reserva = xReserva`:
  - If `Pagada = 'N'` and `Valor < xPaga`: marks record `Pagada = 'S'`, `Valor = 0`; subtracts from `xPaga`.
  - If `Valor = xPaga`: marks `Pagada = 'S'`, `Valor = 0`; updates `Reserva.Ult_Mes/Ult_Ano` to this record's month/year; exits.
  - If `xPaga > 0` and `Valor > xPaga`: updates `Valor = Abs(xPaga)` (remaining balance on that record); updates `Reserva.Ult_Mes/Ult_Ano` to the prior record's month/year; exits.  
- **Inputs:** `CtaExp` (sorted by Reserva+Ano+Mes), `xPaga`.  
- **Outputs:** `CtaExp.Pagada`, `CtaExp.Valor` updated; `Reserva.Ult_Mes`, `Reserva.Ult_Ano` updated.  
- **Label:** VERIFIED — `COBRA.PRG:41-91`.

#### BR-042 — Excess Payment Creates Future Installment Records
- **Category:** Calculation / State Transition  
- **Source:** `COBRA.PRG`, `Descarga()`, lines 92–127  
- **Description:** If `xPaga > 0` after all existing records are exhausted, the remainder is applied to future months. For each future month (advancing 30 days each iteration from `FechaVence`):
  - `xCuota = xPaga − Reserva->Expensa`
  - If `xCuota >= 0`: new record with `Pagada = 'S'`, `Valor = 0`.
  - If `xCuota < 0`: new record with `Pagada = 'N'`, `Valor = Abs(xCuota)`.
  - Each future record's `Vence = FechaVence + xDias` (30-day increments).
  - Loop continues until `xPaga <= 0`.  
- **Inputs:** `Reserva->Expensa`, `xPaga`, `FechaVence`.  
- **Outputs:** New appended `CtaExp` records for future months.  
- **Label:** VERIFIED — `COBRA.PRG:92-127`.

#### BR-043 — Collection Entry: Cobrador Required and Validated
- **Category:** Validation  
- **Source:** `MENU.PRG`, `CobroExpensas()` / `CobroCuotas()`, lines 2598, 2547  
- **Description:** Both expense and installment collection workflows begin with `CargaCobrador()`, which requires a valid cobrador code. If `DbSeek` fails, "Código De Cobrador No Encontrado. Verifique." is shown. Pressing Escape aborts the entire collection session.  
- **Label:** VERIFIED — `MENU.PRG:2598, 2547`.

#### BR-044 — Duplicate Expense Entry Detected by Date + Cobrador
- **Category:** Validation  
- **Source:** `MENU.PRG`, `Busca_Rep()`, lines 2695–2731  
- **Description:** When recording an expense payment, `Busca_Rep` checks whether a record for the same `xReserva` already exists in `AuxiRes` with the same `FechaPago`. If found:
  - An audible alert is raised.
  - The operator can modify `Bonifica` (bonus) or `Importe`.
  - If `Importe = 0`, the record is deleted by `Muestra()` (line 2738–2741).
  - If the operator does not Escape, the modified values are saved.  
- **Label:** VERIFIED — `MENU.PRG:2695-2731`.

#### BR-045 — Collection Amount Calculation: Total = Importe + Bonifica
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `CargaCuoCta()`, line 2840; `TakeRec()`, lines 511-514, 519-521  
- **Description:** When posting installment payments, the effective amount applied to `CtaCte` is `xMonto = Importe + Bonifica`. The `Bonifica` (discount/bonus) reduces the net charge. `TakeRec()` also accumulates both `Bonificaci + Importe` from `Recibo` (line 842).  
- **Label:** VERIFIED — `MENU.PRG:2840, 842`.

#### BR-046 — Payment Posts to CtaCte Installments: Saldo Decremented FIFO
- **Category:** Calculation / State Transition  
- **Source:** `MENU.PRG`, `GrabaCuoCta()`, lines 2846–2925  
- **Description:** After collection, `GrabaCuoCta` applies the payment to `CtaCte` records:
  - Iterates installments in order while `Reserva = xReserva` and `Saldo > 0`.
  - `xResta = Saldo − xImporte`: if `>= 0`, updates `Saldo = xResta`, writes `Recibo` record, exits.
  - If `< 0` (payment exceeds this installment), writes `Recibo`, sets `Saldo = 0`, carries `xImporte = Abs(xResta)` to next installment.
  - Handles `tBonifica` separately before `tImporte` when both are non-zero.  
- **Inputs:** `CtaCte.Saldo`, `xImporte`, `tBonifica`.  
- **Outputs:** `CtaCte.Saldo` decremented; `Recibo` records appended.  
- **Label:** VERIFIED — `MENU.PRG:2846-2925`.

#### BR-047 — Expense Payment Posts to ExpCta; CtaExp Rows Marked Paid
- **Category:** State Transition  
- **Source:** `MENU.PRG`, `CargaExpCta()` → `GrabaExpCta()` + `Actualiza()`, lines 2929–3006  
- **Description:** After expense collection batch:
  - `GrabaExpCta`: looks up the most recent `ValorExp` rate; computes month/year of the highest period covered, and appends to `ExpCta`.
  - `Actualiza`: iterates `CtaExp` for the reservation; applies `xImporte + ACuenta`; marks installments `Pagada = 'S'` if fully covered or updates `ACuenta` for partial; creates future advance records if overpayment.  
- **Label:** VERIFIED — `MENU.PRG:2929-3006`.

---

### 2.6 Account / Ledger Rules

#### BR-050 — CtaCte Saldo Recalculated Against Recibo on Consultation
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `BuscaDatos()`, lines 2083–2138  
- **Description:** During reservation consultation, `BuscaDatos` re-derives which `CtaCte` installment each `Recibo` payment applies to by accumulating `Importe + Bonificaci` from `Recibo` and comparing to `CtaCte->Importe`. When the running total meets or exceeds the installment amount, `CtaCte.Saldo` is set to 0; otherwise it is set to `Importe − xValorRec`.  
- **Inputs:** `Recibo` DBF, `CtaCte` DBF.  
- **Outputs:** `CtaCte.Saldo` updated in place.  
- **Label:** VERIFIED — `MENU.PRG:2096-2114`.

#### BR-051 — Credit (Credito) = Sum of All CtaCte Imports for Reservation
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `TraeCredito()`, lines 739–750  
- **Description:** `TraeCredito(xReserva)` sums `CtaCte.Importe` for all records matching the reservation. This total is stored in `Reserva.Credito` before printing the cobrador report.  
- **Inputs:** `CtaCte.Importe` (all cuotas for the reservation).  
- **Outputs:** `Reserva.Credito`.  
- **Label:** VERIFIED — `MENU.PRG:739-750`.

#### BR-052 — Debit on Cobrador Report: Credito − PagCta
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `PutExpensa()`, lines 711–717  
- **Description:** The cobrador listing computes:
  - `xCredito = CtaCte->(TraeCredito(xReserva))` — total installment value.
  - `xPagCta = Recibo->(TraeDR(xReserva))` — sum of all Recibo `Bonificaci + Importe`.
  - `xDebCta = xCredito − xPagCta` — remaining debit (balance still owed on installments).  
- **Inputs:** `CtaCte`, `Recibo`.  
- **Outputs:** `ImpCob.DebCta`, `ImpCob.Total`.  
- **Label:** VERIFIED — `MENU.PRG:711-717`.

#### BR-053 — Mutual Report Total: Expensa + PagCta (from CtaCte)
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `PonExpensa()` and `DisExpensa()`, lines 676/605  
- **Description:** For mutual/bank-debit reports, the deducted total per reservation is `xImporte + xPagCta`, where `xImporte = Reserva->Expensa` and `xPagCta = CtaCte->(TraeDM(xReserva, xCredito))`.  
- **Inputs:** `Reserva.Expensa`, `CtaCte` (via `TraeDM`).  
- **Outputs:** `ImpMut.Total` or `AxMutu.Importe`.  
- **Label:** VERIFIED — `MENU.PRG:676, 605`.

#### BR-054 — TraeDM Returns 0 When CtaCte.Saldo = 0 for All Records
- **Category:** Calculation / Constraint  
- **Source:** `MENU.PRG`, `TraeDM()`, lines 822–834  
- **Description:** `TraeDM` accumulates `CtaCte->Saldo` for all records matching the reservation. If `xSuma = 0` (all paid), `xDevuelve` is forced to 0, regardless of the last `Importe` read. If `xSuma > 0`, returns the last `CtaCte->Importe` seen.  
- **Label:** VERIFIED — `MENU.PRG:822-834`.

---

### 2.7 Inhumation Rules

#### BR-060 — Inhumation Requires Parcel to Exist
- **Category:** Validation  
- **Source:** `MENU.PRG`, `AltaInhu()`, lines 280–303  
- **Description:** Before entering inhumation data, the system seeks `ParqueNu` by the composite code `Sector + StrZero(Fila,2) + StrZero(Parcela,2)`. If not found: "Código Inexistente. Verifique." and loops. Only if the parcel is found does the operator proceed to enter SubNivel.  
- **Label:** VERIFIED — `MENU.PRG:280-303`.

#### BR-061 — Duplicate SubNivel Guard
- **Category:** Validation  
- **Source:** `MENU.PRG`, `AltaInhu()`, lines 295–300  
- **Description:** Before saving a new inhumation sub-level, the system seeks `SubNivel` for the composite key `xCodigo + Str(xNivel,1) + Str(xSubNivel,1)`. If found, "Inhumación Existente. Verifique" is shown and the entry is not saved.  
- **Label:** VERIFIED — `MENU.PRG:295-300`.

#### BR-062 — SubNivel Must Be Entered Sequentially
- **Category:** Validation  
- **Source:** `MENU.PRG`, `CargaSub()`, lines 314–321  
- **Description:** Before saving SubNivel `t`, the code loops from 1 to `t-1` checking that each prior sub-level exists. If a prior sub-level (e.g., 1 or 2) is missing, "Debe Cargar primero el SubNivel N" is shown and the function returns without saving.  
- **Label:** VERIFIED — `MENU.PRG:314-321`.

#### BR-063 — Inhumation Service Type Classification
- **Category:** Constraint  
- **Source:** `MENU.PRG`, `CargaSub()`, `BuscaNivel()`, `Listado()`, lines 327–336, 1385, 2504  
- **Description:** `SubNivel.TipoI` (service type) holds `'T'` (Traslado / transfer) or `'S'` (Sepelio / burial service). This classification is used in the inhumation statistics report to break down counts by funeral home and service type.  
- **Inputs:** Operator entry via `xTipSer` prompt.  
- **Outputs:** `SubNivel.TipoI`; aggregated in statistics.  
- **Label:** VERIFIED — `MENU.PRG:333, 1385, 2504`.

#### BR-064 — Nivel Range: 1–3; SubNivel Range: 1–6
- **Category:** Validation  
- **Source:** `MENU.PRG`, `AltaInhu()`, line 289–290  
- **Description:** `xNivel` is entered with `Range 1,3` and `xSubNivel` with `Range 1,6`, enforcing valid level values.  
- **Label:** VERIFIED — `MENU.PRG:289-290`.

#### BR-065 — Recently Interred Parcel Highlighted (Within 15 Days)
- **Category:** Constraint / Display  
- **Source:** `MENU.PRG`, `StorParcela()` and `Superficie()`, lines 3597–3600, 1121–1125  
- **Description:** When displaying the sector map, if a parcel has a `SubNivel.FechaI` (inhumation date) within the last 15 days (`Date() - 15 <= SubNivel->FechaI`), it is highlighted with a distinct color (`'N*/R'` — blinking). Otherwise occupied parcels show `'G+/R+'`.  
- **Label:** VERIFIED — `MENU.PRG:1121-1125, 3597-3600`.

---

### 2.8 Report / Statistics Rules

#### BR-070 — Inhumation Report Filter: Inclusive Date Range on FechaI
- **Category:** Constraint  
- **Source:** `MENU.PRG`, `Inhumacion()`, line 2406; `INFORME.PRG`, `Inhumacion()`, line 8  
- **Description:** Both the menu-integrated and standalone `Inhumacion()` functions apply `DbSetFilter` on `SubNivel` (or the relevant table) using `FechaI >= xDesde .And. FechaI <= xHasta`. The `Valid` clause on the Hasta field enforces `xHasta >= xDesde`.  
- **Inputs:** `xDesde`, `xHasta` (operator-entered dates).  
- **Outputs:** Filtered record set for statistics.  
- **Label:** VERIFIED — `MENU.PRG:2401, 2406`; `INFORME.PRG:6, 8`.

#### BR-071 — Statistics Categorize by Parcel Type (S / P / V / Other)
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `Inhumacion()`, lines 2416–2425; `INFORME.PRG`, lines 41–50  
- **Description:** Each inhumation is classified by `ParqueNu->Tipo_P_S`:
  - `'S'` → Socio (member)
  - `'P'` → Particular
  - `'V'` → Especial (120c × $20 plan)
  - Any other value → Otros  
- **Label:** VERIFIED — `MENU.PRG:2416-2425`.

#### BR-072 — Statistics Count Parcelas per Unique Nivel (1/2/3) and SubNivel
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `Inhumacion()`, lines 2426–2443; `INFORME.PRG`, lines 51–68  
- **Description:** For each inhumation record, the level (1, 2, or 3) is tracked. A boolean flag (`tNivel1/2/3`) ensures the Nivel counter increments only once per parcel (`xCodigo` change resets all flags). The sub-level counter (`xSubNivel1/2/3`) increments for every individual inhumation at that level.  
- **Label:** VERIFIED — `MENU.PRG:2426-2479`.

#### BR-073 — Mutual Report Commission Deducted Before Net Total
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `ImpriM()`, lines 815–817  
- **Description:** The mutual liquidation report prints:
  - Sub-total = sum of all `Total` values.
  - Commission = `SubTotal × Mutual->Comisi / 100`.
  - Net total = `SubTotal − Commission`.  
- **Inputs:** `Mutual.Comisi` (commission rate percentage).  
- **Outputs:** Report lines with sub-total, commission, and net total.  
- **Label:** VERIFIED — `MENU.PRG:815-817`.

#### BR-074 — Cobranzas Report: Daily Aggregation of Cuota + Expensa
- **Category:** Calculation  
- **Source:** `MENU.PRG`, `LCobGen()` / `LCobCob()`, lines 397–503; `TakeRec()`, lines 505–526  
- **Description:** The collections report sums per calendar date:
  - `xCuota` from `Recibo` (installment receipts).
  - `xExpensa` from `ExpCta` (expense receipts).
  - `xTotal = xCuota + xExpensa`; `xAcum` is running total.
  - The cobrador-specific version filters by `Cobrador = xCob`; the general version does not.  
- **Label:** VERIFIED — `MENU.PRG:397-503`.

---

## 3. INFERRED Business Rules

#### BR-100 — ValorExp Rate Selection: Two Different Access Patterns
- **Category:** Calculation
- **Source:** `MENU.PRG`, `GrabaExpCta()` line 3011 and `GrabaReserva()` line 3431
- **Description:** The two main functions that read the expense rate use different access patterns:
  - `GrabaExpCta()` at line 3011 explicitly calls `ValorExp->(DbGoBottom())` before reading `ValorExp->ValorExpen`. For this code path, the bottom (most recently appended) record is the confirmed source — VERIFIED.
  - `GrabaReserva()` at line 3431 reads `ValorExp->ValorExpen` directly via `Local xExpensa:=ValorExp->ValorExpen` without any `DbGoBottom()` call. The record read is whatever ValorExp's pointer happens to be at that moment. Since ValorExp has no index and is opened shared with no explicit pointer positioning in `OpenDbf()`, which record is read by `GrabaReserva()` is UNKNOWN without runtime observation.
- **Uncertainty:** Whether both paths reliably return the same intended rate depends on the ValorExp pointer state at runtime.
- **Label:** VERIFIED (`GrabaExpCta` bottom-row access); INFERRED / UNKNOWN (`GrabaReserva` current-record access).

#### BR-101 — Suplentes (Substitutes) Linked to a Reservation
- **Category:** Constraint  
- **Source:** `MENU.PRG`, `CargaSuple()`, lines 3732–3830; `DatoSuple()`, lines 3832–3848  
- **Description:** Each reservation can have multiple substitutes (suplentes), numbered sequentially starting from 1 (`xSuplente++`). No explicit maximum is enforced in code. Substitutes share the same personal data fields as the primary holder. The substitute data is first staged in `AxSupl` (workstation-specific temp table) then moved to `Suplente` via `PasaCarga`.  
- **Uncertainty:** Whether substitutes have any inheritance rights or financial implications is not visible from the PRG code alone.  
- **Label:** INFERRED — no explicit cap; financial role unknown.

#### BR-102 — Reserva.Expensa Field Can Be Globally Overridden by Utility Scripts
- **Category:** Constraint / Risk  
- **Source:** `CARVALOR.PRG` (line 2: `Replace all Expensa with 13`); `REPL.PRG` (line 2: `Replace all Expensa with 10`)  
- **Description:** Two utility scripts exist that mass-replace the `Expensa` field across all reservations. These scripts are outside the main menu system and represent an operational mechanism for fee changes. Since `Expensa` is the per-reservation expense rate, running these scripts would affect all future liquidations.  
- **Uncertainty:** Whether these are one-time migration scripts or reusable maintenance utilities is unknown. Both are treated as high-risk destructive operations.  
- **Label:** INFERRED as operational rate-change mechanism — no in-menu equivalent visible.

#### BR-103 — Ult_Mes / Ult_Ano Used as Payment State Marker
- **Category:** State Transition  
- **Source:** `COBRA.PRG`, `Descarga()`, lines 67–86; `MENU.PRG`, `GrabaReserva()`, line 3444  
- **Description:** `Reserva.Ult_Mes` and `Reserva.Ult_Ano` appear to track the last calendar month for which the reservation has been fully paid. `Descarga` updates these fields when a payment exactly closes a month (`Valor = xPaga`) or when the last partial month is closed. However, the liquidation batch in `MENU.PRG` ignores these fields at the batch start (uses 1991/01 instead), so their use as a scan cursor appears to be partially abandoned.  
- **Label:** INFERRED — observed update logic in COBRA.PRG; batch ignores the field.

#### BR-104 — `SCargo` Flag Suppresses Parcel from Cobrador Report
- **Category:** Constraint  
- **Source:** `MENU.PRG`, `PutExpensa()`, line 705  
- **Description:** `If ParqueNu->SCargo=' '` — the parcel is included in the cobrador report only when `SCargo` is a space (i.e., blank/unset). Non-blank `SCargo` silently excludes the parcel.  
- **Uncertainty:** The domain values and meaning of `SCargo` are not defined in any visible PRG.  
- **Label:** INFERRED — field exists and is tested but not documented.

#### BR-105 — Puesto (Workstation ID) Controls Table Routing
- **Category:** Constraint  
- **Source:** `MENU.PRG`, `OpenDbf()`, lines 3854, 3898, 3987, 4006, 4045 (various `&Puesto.` macro calls)
- **Description:** Several transient/workstation-scoped tables are opened via `Use Aux&Puesto.`, `Use AuxLiq&Puesto.`, etc., using the `PUESTO` environment variable as a suffix. This implies multi-user workstation isolation for staging/temporary tables. `Puesto = '26'` specifically opens `ImpCob` and `ImpMut` in exclusive mode for printing.  
- **Label:** INFERRED multi-user design — environment variable scope not fully traceable from code alone.

---

## 4. UNKNOWN Items and Missing Dependencies

| ID | Item | Reason Unknown |
|----|------|---------------|
| UNK-001 | `Pass1()` function body | Not defined in any inspected PRG. Called at `MENU.PRG:233`. Password comparison logic and input mechanism unknown. |
| UNK-002 | `ValorExp` row-selection semantics | Schema is VERIFIED (fields: VIGENCIA D(8), VALOREXPEN N(9,2), HORA C(8), USUARIO C(15) — from `02-data-model.md`). Which record `GrabaReserva()` reads is UNKNOWN without runtime observation; `GrabaExpCta()` uses `DbGoBottom()` (VERIFIED bottom-record). |
| UNK-003 | `FTMENUTO.CH` include file | Commented out (`///#Include "FTMENUTO.CH"`, `MENU.PRG:1`). All menu `@Prompt` HotKey parameters may be defined there. |
| UNK-004 | `Bisiesto` DBF content | Table is opened and indexed on `Ano`. Which years are present and whether the table is complete for the system's operational date range is unknown. |
| UNK-005 | `AxPl<Puesto>` plan table schema | Schema of the workstation-specific plan table is not visible from PRG code. Fields `Cuotas`, `Precio`, `Desde` are observed by usage only. |
| UNK-006 | `Contras` login activation | Schema is VERIFIED (fields: USUARIO C(10), CLAVE C(10) — from `02-data-model.md`; the single synthetic record holds demo credentials in plaintext). The login path is inactive because the `Contrasenia()` startup call is commented out at `MENU.PRG:12`. |
| UNK-007 | `Recexpe` DBF role | Opened in `OpenDbf()` at line 3956 with index `Codigo+Mes+Anio`, but no function reads or writes it in the inspected code. |
| UNK-008 | `AuxParq` DBF role | Opened in `OpenDbf()` at line 4068 with index on `Reserva`, but no function reads or writes it in the inspected code. |
| UNK-009 | `PExpensa` DBF full role | Referenced in `CCTA.PRG` (commented out join with `ParqueNu`), and opened in `MENU.PRG:3963`. Fields `Reserva`, `Ult_Mes`, `Ult_Ano`, `Saldo` are used in `CCTA.PRG` but the active code path is not in the main menu. |
| UNK-010 | Complete `Baja` cancellation code table | `CodBaja` domain values and descriptions are in the `Baja` DBF. Only the existence of the lookup is confirmed; values are not documented. |
| UNK-011 | `Mutual.Comisi` domain | Commission rate field exists and is used in `ImpriM()`; valid range or default value is unknown. |

---

## 5. Conflicts with Other Reports

This report was prepared independently, without prior review of Phase 2 sibling reports (`01-source-inventory.md`, `02-data-model.md`, etc.). The following potential conflict points should be reconciled during OTN-25 consolidation:

- **LIQUIDA.PRG vs MENU.PRG minimum payment formula** (BR-033 note): The standalone utility uses `xTotal × 0.30` capped at `xTotal`; the main menu version rounds up to the next whole installment. Both paths write to `ResuCta.Minimo`. Whichever was run last wins, creating potential state inconsistency.
- **Ult_Mes / Ult_Ano scan baseline**: COBRA.PRG updates these fields meaningfully; MENU.PRG batch liquidation ignores them in favor of the 1991 baseline. The data-model report may document these as tracking fields; their actual functional role should be flagged as inconsistent.
- **Login call commented out**: If the security review or source inventory marked `Contrasenia()` as an active security control, this report refutes that; the call is commented out in the deployed `MENU.PRG`.

---

## 6. Risks and Recommended Next Action

| Risk | Severity | Recommendation |
|------|----------|---------------|
| Minimum payment formula divergence between LIQUIDA.PRG and MENU.PRG | High | Determine which formula is authoritative; document in approved business rules before modernization. |
| Login inactive — no access control at runtime | High | Confirm with stakeholders whether authentication is intentionally bypassed in production. |
| Batch liquidation scan starts from 1991 baseline every run | Medium | Verify whether this is intentional (full history re-evaluation) or a defect. Performance will degrade as history grows. |
| BORRA.PRG and CTA01.PRG are destructive utilities with no menu guard | High | These files contain `Dele all` / `Pack` for targeted record ranges; must not be executed during analysis or without explicit approval. |
| `Pass1()` function undefined in codebase | Medium | Source is missing. Before migrating the maintenance password gate, the implementation must be located or the behavior must be reconstructed. |
| ValorExp rate selected by natural bottom-of-file order | Medium | If rates are versioned, the selection logic must be made explicit in the modern implementation. |
| `SCargo` suppression flag in PutExpensa has undefined domain | Low | Document or remove; any reservation with a non-blank `SCargo` is silently hidden from cobrador reports. |

---

## 7. Synthetic Data Statement

All analysis was performed exclusively on sanitized source code (`*.PRG` files) and the 22 `*.DBF` files containing 45 fully synthetic demo records. No production data, real customer names, financial amounts, or identifiers were accessed, reproduced, or referenced. Every rule in this report is derived from code logic, not from data values.

---

*End of OTN-22 Business Rules Report.*
