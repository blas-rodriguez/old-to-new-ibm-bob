# Workflow Reconstruction Report

**Task ID:** OTN-23  
**Persona:** workflow-reconstructor  
**Date:** 2026-08-28
**Output file:** `bob_result/agents/04-workflows.md`

---

## 1. Scope and Files Inspected

All 25 PRG files in the workspace root were read. The following were the primary workflow sources:

| File | Relevance |
|------|-----------|
| `MENU.PRG` | ~4132 lines — all main menus and user-facing operations |
| `COBRA.PRG` | ~159 lines — standalone payment collection entry point |
| `LIQUIDA.PRG` | ~136 lines — standalone batch expense liquidation entry point |
| `INFORME.PRG` | ~144 lines — burial statistics (alternate version of the report function) |

No legacy files were modified. Only `bob_result/agents/04-workflows.md` was written. This workspace is a sanitized analysis snapshot, not a production installation; behavior not visible in the source files remains UNKNOWN.

---

## 2. VERIFIED Findings

---

### WF-001 — Application Startup

**Trigger:** User executes the application  
**Pre-conditions:** `Puesto` environment variable set to a workstation identifier (e.g., `'26'`)  
**Menu path:** Top-level program execution

**Steps (VERIFIED — `MENU.PRG` lines 1–21):**
1. Eight `Public` color-scheme variables are initialized.
2. `Public EmpNom := 'EMPRESA DEMO S.R.L.'` and `EmpDir := 'DOMICILIO FICTICIO'` are set.
3. `Public Puesto := GetEnv('Puesto')` reads the workstation ID from the OS environment.
4. `AbreSet()` is called (library function — configures screen/printer settings; UNKNOWN exact behavior).
5. `Fondo()` paints the background screen (company name banner, border box, status bar).
6. `OpenDbf()` opens all 28+ tables and creates/sets all NTX indexes if they do not exist.
7. `MenuPrincipal()` enters the main menu loop.
8. On exit: commits all pending writes, closes all databases, calls `SalNic()` to display a farewell screen.

**Workstation-specific behavior (VERIFIED — `MENU.PRG`, `OpenDbf()`, lines 3854–3862):**
In the current `MENU.PRG`, `If Puesto='26'` gates the exclusive open of `ImpCob` and `ImpMut`. The historical variant `MENU1.PRG` uses `If Puesto='01'` at the same location. Which value was in use in the production installation is UNKNOWN; this analysis is based on the current `MENU.PRG` only.

**Authentication:** The `Contrasenia()` call is commented out (line 12). Authentication is NOT enforced at startup in the current codebase.

**Post-conditions:** All tables open in shared mode (except Puesto-exclusive tables); main menu displayed.

---

### WF-002 — Main Menu Navigation

**Trigger:** Application startup completes  
**Menu path:** Top-level  
**VERIFIED — `MENU.PRG`, `Function MenuPrincipal`, lines 91–144**

**Menu structure:**
```
Main Menu
├── [1] Ingresos (Receipts/Collections)
│   ├── [1] Cobro de Expensas
│   ├── [2] Cobro de Cuotas
│   └── [Esc] Return
├── [2] Operaciones (Operations)
│   ├── [1] Adjudicación de Parcelas (New Reservation)
│   ├── [2] Modificación de Parcelas
│   ├── [3] Modificación de Reservas
│   ├── [5] Alta de Inhumaciones
│   ├── [6] Modificación en Inhumaciones (commented in code; Op=6 not handled)
│   ├── [8] Liquidación de Expensas (batch — requires Pass1 password)
│   ├── [9] Liquidación de Expensas x Reserva (single reservation)
│   ├── [11] Emisión de Listados → sub-menu
│   └── [Esc] Return
└── [3] Consultas (Queries)
    ├── [1] Inhumaciones
    ├── [2] Titulares de Parcelas
    ├── [3] Reservas y Cuotas
    ├── [4] Parcelas y Expensas
    ├── [5] Niveles
    ├── [6] Superficie
    └── [Esc] Return
```

**Navigation:** Arrow keys or number keys select menu items. Esc exits to previous menu or asks confirmation to exit the application (confirmation dialog: `_Quest()` with Yes/No).

**Exit confirmation (VERIFIED — `MENU.PRG` lines 116–120):** On Op=0 (Esc from main menu), a confirmation dialog is shown. User must confirm to exit; cancelling returns to the main menu loop.

---

### WF-003 — New Reservation (Adjudicación de Parcelas)

**Trigger:** Operaciones → [1] Adjudicación de Parcelas  
**Pre-conditions:** ParqueNu, Reserva, CtaCte, Titular, Suplente, Mutual, Cobrador, Promotor, Provinci, ValorExp, AxSupl all open  
**VERIFIED — `MENU.PRG`, `Function AltaReservas`, lines 3058–3254**

**Steps:**

1. **Reservation number display** — The system shows the next auto-incremented reservation number (from `TraeNroRes()` = `GoBottom()+1`). User can accept or change it. If the entered number already exists, error is shown and the step repeats.

2. **Personal data entry** — User enters:
   - Nombre (up to 30 chars, uppercase forced)
   - Domicilio (25 chars), Barrio (15 chars), Teléfono (12 chars, pattern `NNNN-NNNNNN`)
   - Localidad (15 chars)
   - Provincia — validated against PROVINCI table (mandatory; Esc aborts)
   - Código Postal (5 digits)

3. **Document type selection** — Menu: DNI / LE / LC / CI / CE. Selected type stored in `xTDoc`.

4. **Document number** — Numeric 8-digit entry.

5. **Mutual assignment** — User enters Mutual/Association code. Validated against MUTUAL table. Code 0 (Esc) means no association (optional).

6. **Cobrador assignment** — User enters Cobrador code. Validated against COBRADOR table. Mandatory; Esc aborts the entire reservation.

7. **Promotor assignment** — User enters Promotor code. Validated against PROMOTOR table. Esc aborts.

8. **Alta date** — User enters the reservation date (mandatory, cannot be empty).

9. **Alta Mutual date** — Only shown if `xAsociacion != 0`. Optional.

10. **Reservation type** — Menu: Plan Demo A ('S') / Particular ('P') / Socio Demo B ('V').

11. **Parcel selection** — `CargaParcela()` opens a visual grid of parcels by sector. User enters sector code, then selects row and parcel number. Validations: no more than 3 titulares, parcel must not be already reserved (Tipo_P_S='P'). Occupied parcels produce a warning but can still be selected (loop is commented out).

12. **Payment type selection** — Menu: Contado / Tarjeta / CtaCte. / Socio. `Facturar(Op)` is called for all except Op=0 (cancelled).
    - **Contado (Op=1):** User enters Cuotas (1–24), Precio per installment, Desde date. This populates the per-workstation temp table `AxPl&Puesto.`.
    - **CtaCte. (Op=3):** User enters Cuotas, Precio, Desde date with no maximum installment limit.
    - **Tarjeta (Op=2) / Socio (Op=4):** No installment entry required (INFERRED — `Facturar()` has no code for these Op values; the function returns without writing plan data).

13. **Optional suplentes entry** — User is offered a "Suplentes" prompt. If confirmed, `CargaSuple()` allows entry of one or more substitute holders with full personal data.

14. **Confirmation** — `_Quest()` confirmation dialog shown. If confirmed:
    - `GrabaTitular()` — writes to TITULAR table
    - `GrabaReserva()` — writes to RESERVA table (sets Expensa from ValorExp)
    - `GrabaParque()` — writes/updates PARQUENU table (sets Tipo_P_S='P')
    - `AxSupl->(PasaCarga())` — moves suplentes from temp to SUPLENTE table
    - `CtaCte->(CargaPlan())` — writes installment schedule to CTACTE
    - Reservation number incremented; loop continues for next reservation.

    If not confirmed: suplentes temp table is ZAPped; loop restarts from step 1.

**Data reads:** ParqueNu (parcel grid), PROVINCI (validation), MUTUAL (validation), COBRADOR (validation), PROMOTOR (validation), ValorExp (expense rate), BISIESTO (via SumaMes/AuMes for date calculation)  
**Data writes:** TITULAR, RESERVA, PARQUENU (Tipo_P_S→'P'), SUPLENTE, CTACTE  
**Side effects:** AxPl&Puesto. (per-workstation temp) is ZAPped and re-populated; AxSupl (per-workstation temp) is ZAPped and re-populated  
**Failure paths:**
- Duplicate reservation number → error, loop
- Invalid province/cobrador/promotor → error, loop
- Parcel already reserved → error, loop
- User Esc at any point before final confirmation → returns to step 1 or exits function
- Cobrador code 0 (Esc) → function returns immediately

---

### WF-004 — New Inhumation (Alta de Inhumaciones)

**Trigger:** Operaciones → [5] Alta de Inhumaciones  
**Pre-conditions:** ParqueNu, SubNivel open; context is ParqueNu->(AltaInhu())  
**VERIFIED — `MENU.PRG`, `Function AltaInhu`, lines 246–360 and `CargaSub`, lines 308–360**

**Steps:**

1. **Parcel lookup** — User enters Sector (3 chars, uppercase), Fila (2 digits), Parcela (2 digits). The system constructs `xCodigo = xSector + StrZero(xFila,2) + StrZero(xParcela,2)` and seeks ParqueNu by order 2 (Código index). If not found, `'Código Inexistente. Verifique.'` is shown and the step repeats.

2. **Parcel display** — If found, the system displays: Codigo, Nombre, Domicilio, Barrio, Telefono, Documento, Reserva, Tipo (S/V/P label), from the ParqueNu record.

3. **Level and sub-level entry** — User enters `xNivel` (1–3) and `xSubNivel` (1–6). Range validation enforced at UI level.

4. **Sequential sub-level check** — The system verifies that all prior sub-levels at the same Nivel already exist. If not, error shown and function returns without saving.

5. **Duplicate check** — System seeks SubNivel by `xCodigo + Str(xNivel,1) + Str(xSubNivel,1)`. If found, `'Inhumación Existente. Verifique'` is shown and the step loops.

6. **Burial data entry** — `CargaSub()` collects:
   - Fecha de Fallecimiento (Date)
   - Nombre del fallecido (25 chars, uppercase)
   - Documento (8 digits)
   - Sexo (M/F, validated)
   - Acta (10 digits)
   - Tipo (1 char)
   - Impuesto (numeric)
   - Fecha de Inhumación (Date)
   - Boleto (8 chars, uppercase)
   - Tipo Servicio (1 char: T=Traslado, S=Sepelio)
   - Cocheria (4 digits, funeral home code)
   - Feretro (4 digits, coffin code)

7. **Save** — On Enter (not Esc), `VerActiva()` locks and `DbAppend()` + `Replace` writes all fields to SUBNIVEL. `DbCommit()` + `DbUnLock()` completes the write.

**Data reads:** ParqueNu (parcel display), SubNivel (duplicate check, sequential check)  
**Data writes:** SUBNIVEL (new record)  
**Failure paths:** Invalid parcel code → error, loop; Esc at any point → returns to parcel entry loop or exits

---

### WF-005 — Expense Collection (Cobro de Expensas)

**Trigger:** Ingresos → [1] Cobro de Expensas  
**Pre-conditions:** CtaExp, AuxiRes, Cobrador, Reserva, ValorExp, ExpCta all open  
**VERIFIED — `MENU.PRG`, `Function CobroExpensas`, lines 2566–2616 and `CargaDatos`, lines 2618–2693; `CargaExpCta`, lines 2929–2938; `GrabaExpCta`, lines 3008–3051; `Actualiza`, lines 2940–3006**

**Steps:**

1. **Cobrador selection** — User enters Cobrador code. Validated against COBRADOR table. Esc exits the workflow.

2. **Payment date entry** — User enters `xFecha` (payment date, mandatory).

3. **Receipt line entry loop** — For each payment received:
   - Enter receipt number (format: NNNN-NNNNNNNN, i.e., branch + receipt number)
   - Enter Reservation number — validated against the current work area (CtaExp order 1). If not found, error and loop.
   - The reservation is also validated in RESERVA to confirm it exists.
   - **Duplicate check:** `Busca_Rep()` checks if this reservation has already been entered for this date/cobrador combination in AuxiRes. If duplicate: an alert is shown with the option to correct the amounts or set Importe=0 to delete.
   - Enter Bonificacion (discount/credit amount)
   - Enter Importe (expense payment amount)
   - Running totals `xTotBon` and `xTotImp` accumulate.
   - Data is staged in AuxiRes via `PasaDato()`.
   - Pressing Esc during receipt entry offers: [1] Control listing (print/view without posting), [2] Exit data entry.

4. **Control listing (optional)** — If user chooses the control listing option, `ListaControl()` displays/prints all entries for this cobrador/date without posting them.

5. **Confirmation** — `_Quest()` confirmation dialog. If confirmed, `CargaExpCta()` is called.

6. **Posting** — For each AuxiRes record, `GrabaExpCta()` writes an ExpCta record (reads latest rate from ValorExp), then `Actualiza()` scans CtaExp for the reservation and discharges outstanding records in chronological order, marking each `Pagada='S'` or updating `ACuenta`. Excess payment creates new future CtaExp records.

7. **AuxiRes cleanup** — After posting (INFERRED — not explicitly shown in code, but AuxiRes is ZAPped at the start of the next iteration of the outer `While .t.` loop, line 2592).

**Data reads:** COBRADOR (validation), RESERVA (validation), CtaExp (balance lookup), ValorExp (current rate), AuxiRes (staging)  
**Data writes:** ExpCta (new payment record), CtaExp (update Pagada, ACuenta, append future records)  
**Side effects:** AuxiRes is ZAPped at start of each collection session  
**Failure paths:** Invalid Cobrador → exit; Invalid reservation → loop; Duplicate entry → correction prompt; User cancels confirmation → nothing posted

---

### WF-006 — Installment Collection (Cobro de Cuotas)

**Trigger:** Ingresos → [2] Cobro de Cuotas  
**Pre-conditions:** CtaCte, AuxiRes, Cobrador, Reserva, Recibo open  
**VERIFIED — `MENU.PRG`, `Function CobroCuotas`, lines 2515–2564 and `CargaDatos`, `CargaCuoCta`, `GrabaCuoCta`, lines 2835–2925**

**Steps:**

1. **Cobrador selection** — Same as WF-005 step 1.
2. **Payment date entry** — Same as WF-005 step 2.
3. **Receipt line entry loop** — Same entry fields as WF-005: receipt number, reservation number, Bonificacion, Importe.
4. **Staging** — Data is staged in AuxiRes.
5. **Confirmation** — `_Quest()` confirmation dialog. If confirmed, `CargaCuoCta()` is called.
6. **Posting** — For each AuxiRes record, `GrabaCuoCta()` scans CTACTE for the reservation (order 1) and applies the payment amount against installments with `Saldo > 0`. For each installment:
   - If `Saldo >= xImporte`: Saldo is reduced, a RECIBO record is written, and the loop exits (excess handled).
   - If `Saldo < xImporte`: Installment is fully settled (Saldo=0), RECIBO is written, remainder continues to next installment.
   - Bonificacion is applied before Importe in allocation order.

**Data writes:** CTACTE (update Saldo), RECIBO (new payment receipt record)

---

### WF-007 — Batch Expense Liquidation (Liquidación de Expensas)

**Trigger:** Operaciones → [8] Liquidación de Expensas  
**Pre-conditions:** `Pass1('DEMO00')` must succeed; Reserva, CtaExp, ResuCta, AuxLiq all open  
**VERIFIED — `MENU.PRG`, `Function Nucleo`, lines 889–906 and `Liquidacion`, lines 908–949; `CargaDeta`, lines 951–957; `CargaLiq`, lines 959–976**

**Steps:**

1. **Password gate** — `Pass1('DEMO00')` is called. If it returns false, the operation is silently skipped.

2. **Reservation scan** — `DbGoTop()` on RESERVA. Each record is processed in sequence.

3. **Per-reservation liquidation** — For each reservation with `CodBaja = 0` (active):
   a. AuxLiq temp table is ZAPped.
   b. `FechaVence` is set to `'20/' + MM/YYYY` of the current month.
   c. `CtaExp->(Liquidacion(xReserva, 1, 1991, xExpensa, FechaVence))` is called.
   
4. **Liquidacion logic** (VERIFIED — lines 908–949):
   - Seeks CtaExp using order 2 (Reserva+Year+Month composite) to find the target month's record.
   - If the target month's record does NOT exist, a new CtaExp record is appended for `Mes_Liq / Ano_Liq` with `Pagada='N'` and `Valor=xExpensa`.
   - The function then scans backward from month 1/1991 to the target month, accumulating all unpaid records (`Pagada='N'`), recording each in AuxLiq via `CargaDeta()`, and summing the total.
   - After the scan, `ResuCta->(CargaLiq())` is called.

5. **ResuCta update** (VERIFIED — `CargaLiq`, lines 959–976):
   - If no ResuCta record exists for this reservation, a new one is appended.
   - `Total = sum of all unpaid Valor amounts`
   - `Minimo = Reserva->Expensa * (Int(Total*0.30 / Reserva->Expensa) + 1)` (rounds up to next full expense unit)
   - `Adeuda` = concatenated string of all unpaid month/year periods (from AuxLiq via `TraeMesAde()`)
   - `Vence = FechaVence` (20th of current month)

6. **Progress display** — `Say(24,0,Transform(xReserva,'999999'),'W+')` shows current reservation number during processing.

**Data reads:** RESERVA (all active records), CtaExp (existing expense records per reservation), ValorExp (INFERRED — not explicitly read in Nucleo but read in Liquidacion-path functions)  
**Data writes:** CtaExp (new expense record for current month if missing), ResuCta (new or updated summary record), AuxLiq (temp, ZAPped per reservation)  
**Post-conditions:** ResuCta contains current total outstanding and minimum payment amounts for all active reservations.  
**Failure paths:** Password gate fails → silent skip; already-existing month record → no duplicate appended; ZAP failure on AuxLiq → UNKNOWN behavior

---

### WF-008 — Single-Reservation Expense Liquidation (Liquidación x Reserva)

**Trigger:** Operaciones → [9] Liquidación de Expensas x Reserva  
**Pre-conditions:** Reserva, CtaExp, ResuCta, AuxLiq all open  
**VERIFIED — `MENU.PRG`, `Function N_ucleo`, lines 849–886**

**Steps:**
1. User enters reservation number — validated against RESERVA; error if not found.
2. User enters target liquidation month (`Mes_Liq`) and year (`Ano_Liq`) — defaults to current month/year.
3. Confirmation dialog shown.
4. If confirmed and `CodBaja = 0`: same Liquidacion / CargaLiq logic as WF-007 for the single reservation.
5. Loop continues for next reservation entry.

---

### WF-009 — Query: Reservations and Account Status (Reservas y Cuotas)

**Trigger:** Consultas → [3] Reservas y Cuotas  
**Pre-conditions:** Reserva, ParqueNu, CtaCte, Recibo, Baja, Auxiliar all open  
**VERIFIED — `MENU.PRG`, `Function Reservas`, lines 1904–1994 and helper functions `BuscaParque`, `BuscaDatos`, `BuscaRecibo`**

**Steps:**
1. User enters reservation number (or navigates with PgUp/PgDn keys).
2. If found: header data displayed (Reserva, Mutual, Cobrador, Promotor, Nombre, Domicilio, Barrio, Alta, AltaMut, Tipo, Credito, Baja description).
3. **Parcel panel** (`BuscaParque`) — shows all parcel codes linked to this reservation (seeking ParqueNu by Reserva).
4. **Cuota panel** (`BuscaRecibo`) — shows all CTACTE installments with due date, payment date, sucursal, receipt number, saldo. Running total of outstanding saldo displayed.
5. **Payment panel** (`BuscaDatos`) — cross-references CTACTE and RECIBO to update Cuota and Saldo fields in real-time; shows payment history.
6. **Plan de Pago (F5 key)** — `FunDeuda()` overlays the installment plan summary from the Auxiliar temp table.
7. **F2 key** — `FunDaniel()` shows the cuota detail view in a scrollable overlay.
8. **F3 key** — `FunPato()` shows the payments view in a scrollable overlay.

**Side effects:** `BuscaDatos()` writes `Cuota` field in Recibo and updates `CtaCte->Saldo` in real-time during the query (lines 2096–2119). This is a notable side effect of a read-oriented screen.

---

### WF-010 — Query: Parcel Levels / Inhumation Detail (Niveles)

**Trigger:** Consultas → [5] Niveles  
**Pre-conditions:** ParqueNu, SubNivel, Cocheria, Ataud open  
**VERIFIED — `MENU.PRG`, `Function Niveles`, lines 1251–1332 and `BuscaNivel`, lines 1707–1794**

**Steps:**
1. User enters parcel code (7 chars, uppercase). F9 key provides lookup assistance.
2. If found: parcel header displayed (Código, Sector, Fila, Parcela, Nombre, Domicilio, Barrio, Teléfono, Documento, Reserva, Tipo).
3. `BuscaNivel()` scans SubNivel for all records matching the parcel code. Records are separated into three panels: Nivel 1 (F2 key), Nivel 2 (F3 key), Nivel 3 (F4 key). Each panel shows SubNivel number and name.
4. Pressing F2/F3/F4 opens the corresponding level panel as a scrollable list (FunFede1/2/3).
5. Within a level panel, pressing Enter on a selected row shows full detail: Fallecimiento date, Nombre, Documento, Sexo, Acta, Tipo, Impuesto, Inhumación date, Boleto, Tipo Servicio, Cocheria name (from COCHERIA table), Denominación coffin (from ATAUD table), Exhumación date.
6. The detail panel can be repositioned on-screen with arrow keys.

---

### WF-011 — Query: Parcels and Expenses (Parcelas y Expensas)

**Trigger:** Consultas → [4] Parcelas y Expensas  
**Pre-conditions:** ParqueNu, CtaExp, Reserva open  
**VERIFIED — `MENU.PRG`, `Function CuotaExpensa`, lines 2229–2303 and `BuscaExpensa`, lines 2306–2358**

**Steps:**
1. User enters parcel code (7 chars) or navigates with PgUp/PgDn.
2. If found: displays Codigo, Sector, Fila, Parcela, Nombre, Domicilio, Barrio, Teléfono, Documento, Reserva (from ParqueNu).
3. The expense history for the linked reservation is shown in the lower panel (`BuscaExpensa`): Mes/Año, Vence, FechaPago, Recibo, Bonifica, Valor. Running sum of unpaid Valor amounts shown as "Monto Adeudado".
4. F2 key opens a scrollable view of the expense list.

---

### WF-012 — Query: Surface Map (Superficie)

**Trigger:** Consultas → [6] Superficie  
**Pre-conditions:** ParqueNu, SubNivel open  
**VERIFIED — `MENU.PRG`, `Function Superficie`, lines 1026–1212**

**Steps:**
1. User enters a Sector code (3 chars, uppercase). If not found, error message shown.
2. A visual grid is displayed: rows represent Filas, columns represent Parcela numbers. Color coding:
   - Reserved (Tipo_P_S='P'): gold/bright-gray background
   - Type 'M': green background
   - Occupied (SubNivel record exists): red background, with special highlighting if FechaI within last 15 days
   - Default: normal color
3. User enters Fila (F:) and Parcela (P:) to select a specific plot.
4. `BuscaNivel()` is called to display the three-panel inhumation detail for the selected plot.
5. **F5 key** — `Porcentajes()` overlays occupation statistics for the sector: occupied %, reserved %, free %, counts by Nivel and Cocheria.

---

### WF-013 — Listados: Cobrador Liquidation List

**Trigger:** Operaciones → Emisión de Listados → [1] Listado de Liquidación Por Cobrador  
**Pre-conditions:** Cobrador, Reserva, ParqueNu, ResuCta, Recibo, ImpCob all open  
**VERIFIED — `MENU.PRG`, `Function ListaCob`, lines 528–548 and `PutExpensa`, lines 695–737 and `Imprix`, lines 752–784**

**Steps:**
1. User enters Cobrador code (validated against COBRADOR; Esc exits).
2. `PutExpensa(xCob)` scans all Reserva records for this cobrador (order 3 = Cobrador), filtering `Empty(Baja)` and `ParqueNu->SCargo=' '`. For each qualifying reservation:
   - Reads Nombre, Domicilio, Barrio, Alta from ResuCta.
   - Reads Credito from CtaCte via `TraeCredito()`.
   - Updates `ResuCta->Credito` (SIDE EFFECT — updates the ResuCta record).
   - Calculates: `xImporte = ResuCta->Total`, `xPagCta = Recibo->(TraeDR(xReserva))` (sum of Bonificaci+Importe from all RECIBO records for this reservation, order 2).
   - Calculates: `xDebCta = xCredito - xPagCta`.
   - Appends a record to ImpCob with all above fields plus `Total = xImporte + xDebCta`.
3. `Imprix()` prints the report to the printer: one line per reservation showing Reserva, Nombre, Domicilio, Barrio, Alta, Credito, Expensa, Pag/Cuota, Deb/Cuota, Total Deuda.
4. **The report is printed 3 times** (lines 736–737: `Imprix` called 3 times). This appears intentional (3 copies for distribution).

---

### WF-014 — Listados: General Collections Report

**Trigger:** Operaciones → Emisión de Listados → [5] Listado de Cobranzas General  
**Pre-conditions:** Recibo, ExpCta open  
**VERIFIED — `MENU.PRG`, `Function LCobGen`, lines 397–443**

**Steps:**
1. User enters date range (Desde / Hasta, validated `xHasta >= xDesde`).
2. For each day in the date range, `TakeRec(0, xDesde, .f.)` reads the total Cuota collected from RECIBO (all cobradores, by date index) and `TakeRec(0, xDesde, .f.)` reads the total Expensa from ExpCta.
3. Each day's line: Fecha, Cuota, Expensa, Total, Acumulado (running total).
4. Summary row shows totals. Report displayed via `MChoice()` (scrollable on-screen viewer with optional print).

---

### WF-015 — Standalone Payment Collection (COBRA.PRG)

**Trigger:** Direct execution of `COBRA.PRG`  
**Pre-conditions:** CtaExp, ResuCta, Reserva, AuxLiq01 all opened by `AbreDbf()`  
**VERIFIED — `COBRA.PRG`, lines 1–159**

This is an older standalone version of payment collection, distinct from WF-005/006. It uses a simpler loop:

1. User enters reservation number — validated against RESERVA by seek.
2. Reads `ResuCta->Minimo` and `ResuCta->Total` for the reservation.
3. User enters payment amount (`xPaga`).
4. Validation: `xPaga < xMinimo` → error loop.
5. `CtaExp->(Descarga(xReserva, xPaga))` — applies payment to CtaExp records sequentially.
6. After Descarga, updates ResuCta: `Replace ResuCta->Pagado With xPaga` and commits.
7. `ResuCta->(VerActiva())` and `DbUnLock()` complete the operation.

**Key difference from MENU.PRG flows:** COBRA.PRG uses `FechaVence = CToD('12/10/1999')` (hardcoded stale date) for new future installments. It does not prompt for cobrador, date, or receipt number. INFERRED: this is an earlier prototype, not the production path.

---

### WF-016 — Standalone Batch Liquidation (LIQUIDA.PRG)

**Trigger:** Direct execution of `LIQUIDA.PRG`  
**Pre-conditions:** CtaExp, ResuCta, Reserva, AuxLiq01 all opened by `AbreDbf()`  
**VERIFIED — `LIQUIDA.PRG`, lines 1–136**

This is an older standalone version of WF-007. Key differences from the MENU.PRG version:
- `Mes_Liq` and `Ano_Liq` are hardcoded at top (March 2000 / year 2000).
- `FechaVence` is hardcoded to `CToD('03/10/1999')`.
- The `CargaLiq` here does not apply the Expensa-based rounding to the minimum (simpler `xMinimo = xTotal * 0.30`).
- No password gate; runs directly.

INFERRED: this is an earlier version. The MENU.PRG `Nucleo/Liquidacion` variant is the current production path.

---

## 3. INFERRED Findings

**WF-I-01 — Mutual disbursement list (DisExpensa/PonExpensa) creates 3 printer copies**  
- INFERRED from `MENU.PRG` lines 611–613 and 690–692: both `ImpriDis` and `ImpriM` are called three times consecutively. This appears intentional (triplicate copies) but no code comment explains it.

**WF-I-02 — CobroCuotas and CobroExpensas are the main production collection paths**  
- INFERRED from the structural position in the Ingresos menu (the two "Cobro de..." items) versus the older standalone COBRA.PRG. The MENU.PRG versions are more complete (include cobrador, date, receipt number) and do not use hardcoded dates.

**WF-I-03 — BuscaDatos() has a write side effect during a query screen**  
- INFERRED from lines 2096–2119: the Reservas query screen (`Reservas y Cuotas`) writes to RECIBO (`Replace Cuota`) and CTACTE (`Replace Saldo`) in real-time during display. This is a significant side effect of a nominally read-only query. Any discrepancy between accumulated payments and installment records is automatically corrected each time the query is opened.

**WF-I-04 — The Modificación de Parcelas and Modificación de Reservas workflows use Hojear()**  
- INFERRED from `MENU.PRG` lines 221–229: both modification operations call `VerActiva()` (lock) then `Hojear()` (apparently a browse/edit function) then `DbCommit()` / `DbUnLock()`. `Hojear()` is unresolved in the available PRGs; its original container and any relationship to `FTMENUTO.CH` are UNKNOWN. Therefore, the exact editable fields and validations are UNKNOWN.

---

## 4. UNKNOWN Items

| ID | Item |
|----|------|
| U-01 | `Hojear()` — library function used for Modificación de Parcelas and Modificación de Reservas. Field-level edit behavior unknown. |
| U-02 | `SalNic()` — called at application exit. Display/behavior unknown. |
| U-03 | `MChoice()` — used for all report display. Whether it provides a print option and how is unknown. |
| U-04 | COBRA.PRG collection path vs MENU.PRG paths — production use is unclear. COBRA.PRG may be obsolete. |
| U-05 | Payment types Tarjeta (Op=2) and Socio (Op=4) in Facturar() — no installment entry code found for these types. Whether they skip plan creation or use a default plan is UNKNOWN. |
| U-06 | `CCTA.PRG` workflow — this utility populates CtaExp from PExpensa. The PExpensa table is opened in `OpenDbf()` but never populated or read by MENU.PRG flows. Its exact role is UNKNOWN. |

---

## 5. Conflicts with Other Reports

- OTN-20 identified `INFORME.PRG` as a library called by MENU.PRG (Inhumacion function). This is confirmed — MENU.PRG contains its own `Inhumacion` function (line 2369) that is functionally equivalent to but slightly different from the one in `INFORME.PRG`. The MENU.PRG version uses `ParqueNu` and `TipoI` references; the `INFORME.PRG` version uses `Parque` (different alias). This alias inconsistency was flagged in OTN-20 and OTN-21 and is confirmed here.
- No conflicts with OTN-21 (data-model) or OTN-22 (business-rules) were identified.

---

## 6. Risks and Recommended Next Actions

| Risk | Severity | Recommendation |
|------|----------|---------------|
| BuscaDatos() writes during query (WF-I-03) | HIGH | This creates implicit data correction during read operations. The modernized system should separate read and write operations explicitly. |
| Authentication bypass (WF-001) | HIGH | No authentication at startup. Must be restored in modernization. |
| Triplicate printer output (WF-I-01, WF-013) | MEDIUM | Verify if this is intentional business practice before modernizing the report flow. |
| Hojear() edit behavior unknown (WF-I-04) | HIGH | The entire modification workflow for Parcelas and Reservas is inside the missing library. Full field-level edit rules are UNKNOWN. |
| COBRA.PRG stale FechaVence (WF-015) | HIGH | This standalone path, if used in production, would generate incorrect future installment dates. |
| Payment types Tarjeta/Socio incomplete (U-05) | MEDIUM | If these payment types are in use, their installment plan creation behavior is undefined in the source. |

---

## 7. Statement

Only synthetic demonstration data was used during this analysis. No real customer names, addresses, financial values, or personally identifiable information was read or reproduced. All workflow reconstructions are based solely on PRG source code logic and control flow analysis.
