# OTN-21 — Data Model Report

**Task ID:** OTN-21
**Persona:** data-model
**Date:** 2026-08-28
**Output file:** `bob_result/agents/02-data-model.md`

---

## 1. Scope and Files Inspected

### DBF Files (22 total, all in workspace root)

| File | Version | Records | Fields |
|------|---------|---------|--------|
| `AREAS.DBF` | dBASE III (3) | 2 | 4 |
| `ATAUD.DBF` | dBASE III (3) | 2 | 2 |
| `BAJA.DBF` | dBASE III (3) | 2 | 2 |
| `bancos.dbf` | Visual FoxPro (0x30 / 48) | 2 | 6 |
| `cobrador.dbf` | dBASE III (3) | 2 | 8 |
| `COCHERIA.DBF` | dBASE III (3) | 2 | 6 |
| `CONTRAS.DBF` | dBASE III (3) | 1 | 2 |
| `CTACTE.DBF` | dBASE III (3) | 3 | 6 |
| `ctaexp.dbf` | dBASE III (3) | 3 | 15 |
| `FILTRO.DBF` | dBASE III (3) | 1 | 15 |
| `MAEASO.DBF` | dBASE III (3) | 2 | 17 |
| `mutual.dbf` | dBASE III (3) | 2 | 19 |
| `parquenu.dbf` | dBASE III (3) | 3 | 56 |
| `PROMOTOR.DBF` | dBASE III (3) | 2 | 11 |
| `PROVINCI.DBF` | dBASE III (3) | 2 | 2 |
| `RECIBO.DBF` | dBASE III (3) | 1 | 9 |
| `RENA.DBF` | dBASE III (3) | 2 | 7 |
| `reserva.dbf` | dBASE III (3) | 3 | 25 |
| `SUBNIVEL.DBF` | dBASE III (3) | 2 | 16 |
| `SUPLENTE.DBF` | dBASE III (3) | 2 | 11 |
| `titular.DBF` | dBASE III (3) | 3 | 11 |
| `VALOREXP.DBF` | dBASE III (3) | 1 | 4 |

### PRG Files Analyzed for Schema Verification

All 25 PRG files were read. Primary sources:
- `MENU.PRG` (~4,100 lines) — main program, `OpenDbf()` at line 3850, all `USE`, `INDEX ON`, `REPLACE`, and `SEEK` patterns.
- `COBRA.PRG` — payment/fee processing with `CtaExp`, `ResuCta`, `Reserva` SEEK patterns.
- `LIQUIDA.PRG` — bulk liquidation with `CtaExp`, `ResuCta`, `AuxLiq` write patterns.
- `BANCODIS.PRG` — bank disbursement utility with `Titular` external variant and `Rena`-schema temp files.
- `VALOR.PRG` — standalone `ValorExp` browser.
- `INFORME.PRG` — reporting over `SubNivel` and `Parque` (INFORME.PRG uses the historical alias `Parque`, not `ParqueNu` — a verified inconsistency with MENU.PRG; see §7).

---

## 2. VERIFIED Findings — Field Schemas

> All schemas verified by direct binary DBF header parsing (PowerShell `[System.IO.File]::ReadAllBytes`). Field types: C=Character, N=Numeric, D=Date, L=Logical.

---

### 2.1 AREAS — Service areas / collection zones

**VERIFIED** (AREAS.DBF header; `MENU.PRG` line 4 public variable `Puesto`)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| AREA | N | 6 | 0 | Primary key (area code) |
| DESCRIPCIO | C | 30 | 0 | Area description |
| COBRADOR | N | 6 | 0 | FK → COBRADOR.COBRADOR |
| REPORTE | N | 6 | 0 | Report routing code |

**Index expressions:** None identified in `OpenDbf()` — table not opened in main `OpenDbf()`.  
**Notes:** INFERRED reference to a `Puesto` environment variable that partitions workstations; `AREAS` may drive which work-area/station opens which collections.

---

### 2.2 ATAUD — Coffin catalog

**VERIFIED** (ATAUD.DBF header; `MENU.PRG` line 3980–3984)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| CODIGO | N | 6 | 0 | PK |
| DESCRIPCIO | C | 25 | 0 | Coffin description |

**Index expressions:**  
- `Ataud1.Ntx`: `INDEX ON Codigo TO Ataud1` (MENU.PRG:3982)

**Relationships:** Referenced as a lookup from `SubNivel.Feretro → ATAUD.CODIGO` (`MENU.PRG:1391–1392`).

---

### 2.3 BAJA — Cancellation/exit reason codes

**VERIFIED** (BAJA.DBF header; `MENU.PRG` line 3927–3931)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| CODIGO | N | 6 | 0 | PK |
| DESCRIPCIO | C | 50 | 0 | Reason text |

**Index expressions:**  
- `Baja1.Ntx`: `INDEX ON Codigo TO Baja1` (MENU.PRG:3929)

**Relationships:** Looked up via `Baja->(DbSeek(xBaja))` in `MENU.PRG:1983`; display of `Baja->Descripcio`.  
`reserva.CODBAJA` is the foreign key into this table.

---

### 2.4 bancos — Bank catalog

**Scope:** Schema fields are VERIFIED from binary DBF header parsing. Role and relationships are UNKNOWN — no PRG in the workspace opens this file directly.

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| CODIGO | C | 2 | 0 | Candidate key (char code, not numeric) |
| BANCO | C | 30 | 0 | Bank name |
| DIRECCION | C | 40 | 0 | Address |
| TELEFONO | C | 15 | 0 | Phone |
| FAX | C | 15 | 0 | Fax |
| CONTACTO | C | 25 | 0 | Contact person |

**Index expressions:** None found in inspected PRGs.

**Version byte:** 0x30 (48 decimal) — this is the Visual FoxPro version marker, not dBASE IV. INFERRED this file was created or last edited with Visual FoxPro or a compatible tool. The Clipper application does not open Visual FoxPro DBFs natively; this file may be incompatible with the runtime.

**Relationship to BANCODIS.PRG:** BANCODIS.PRG does not open `bancos.dbf`. It opens the dynamic alias `Use &ValGr. Alias Mary` where `ValGr := 'Imp'+StrZero(xGrupo,3)` (e.g., `Imp002`) — a per-group disbursement temp table with the same structure as `RENA.DBF`. No `USE bancos` was found in any PRG in the workspace.

**Role:** UNKNOWN. No source citation connects `bancos.dbf` to any application workflow. It may be a reference table for a bank integration path not represented in the available PRG files, or it may be obsolete.

---

### 2.5 cobrador — Collector/agent catalog

**VERIFIED** (cobrador.dbf header; `MENU.PRG` line 4018–4025)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| COBRADOR | N | 6 | 0 | PK |
| NOMBRE | C | 25 | 0 | Collector name |
| DOMICILIO | C | 25 | 0 | Address |
| LOCALIDAD | C | 15 | 0 | Locality |
| PROVINCIA | N | 6 | 0 | FK → PROVINCI.CODIGO |
| TELEFONO | C | 12 | 0 | Phone |
| COMISION | N | 10 | 2 | Commission rate % |
| COMISIONC | N | 10 | 2 | UNKNOWN — second commission rate; purpose unclear |

**Index expressions:**  
- `Cobra1.Ntx`: `INDEX ON Cobrador TO Cobra1` (MENU.PRG:4020)  
- `Cobra2.Ntx`: `INDEX ON Nombre TO Cobra2` (MENU.PRG:4023)

**Relationships:**
- `reserva.COBRADOR` → `cobrador.COBRADOR` (FK; `MENU.PRG:3436, 2621`)
- `RECIBO.COBRADOR` → `cobrador.COBRADOR` (FK; `MENU.PRG:2866`)
- `ctaexp.COBRADOR` → `cobrador.COBRADOR` (FK; `MENU.PRG:3045`)
- `AREAS.COBRADOR` → `cobrador.COBRADOR` (INFERRED)
- Validated via `CargaCobrador()` — seek fails on unknown code with error message (`MENU.PRG:461–462`).

---

### 2.6 COCHERIA — Funeral home catalog

**VERIFIED** (COCHERIA.DBF header; `MENU.PRG` line 3992–3996)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| CODIGO | N | 6 | 0 | PK |
| NOMBRE | C | 20 | 0 | Funeral home name |
| DOMICILIO | C | 25 | 0 | Address |
| BARRIO | C | 15 | 0 | District |
| PROVINCIA | N | 6 | 0 | FK → PROVINCI.CODIGO |
| TELEFONO | C | 11 | 0 | Phone |

**Index expressions:**  
- `Coche1.Ntx`: `INDEX ON Codigo TO Coche1` (MENU.PRG:3994)

**Relationships:**  
- `SUBNIVEL.COCHERIA` → `COCHERIA.CODIGO` (FK; `MENU.PRG:1387–1388`)

---

### 2.7 CONTRAS — System user credentials

**VERIFIED** (CONTRAS.DBF header; `MENU.PRG` line 30–34)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| USUARIO | C | 10 | 0 | PK — login username |
| CLAVE | C | 10 | 0 | Plaintext password |

**⚠ RISK:** Password stored as plaintext Character field. Confirmed in security review.

**Index expressions:**  
- `Contras.Ntx`: `INDEX ON Usuario TO Contras` (MENU.PRG:32)

**Notes:** Login uses `DbSeek(xUsuario)` then exact-match `If Clave=xClave` (`MENU.PRG:55–56`). No hashing.

---

### 2.8 CTACTE — Account ledger (installment plan)

**VERIFIED** (CTACTE.DBF header; `MENU.PRG` line 3917–3924)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| RESERVA | N | 19 | 5 | FK → reserva.RESERVA |
| CUOTA | N | 19 | 5 | Installment sequence number |
| VENCIMIENT | D | 8 | 0 | Due date |
| IMPORTE | N | 19 | 5 | Amount due |
| SALDO | N | 19 | 5 | Outstanding balance |
| MARCA | C | 1 | 0 | Status flag ('I'=initial; payment marker) |

**Composite PK:** (RESERVA, CUOTA) — VERIFIED from composite index and REPLACE pattern.

**Index expressions:**  
- `CtaCt1.Ntx`: `INDEX ON Reserva TO CtaCt1` (MENU.PRG:3919)  
- `CtaCt2.Ntx`: `INDEX ON StrZero(Reserva,6)+StrZero(Cuota,4) TO CtaCt2` (MENU.PRG:3921)

**Relationships:**
- One CTACTE row per installment (1–N per reserva).
- `RECIBO.RESERVA` + `RECIBO.CUOTA` references one CTACTE row.
- Payment processor reads `CtaCte->Importe` and updates `CtaCte->Saldo` (`MENU.PRG:2104, 2113`).

**Integrity:** `CargaPlan()` inserts one row per installment (1 to `xCuotas`) with `Marca='I'` (`MENU.PRG:3268–3273`). Balance (`Saldo`) initialized equal to `Importe`.

---

### 2.9 ctaexp — Expense account (monthly dues ledger)

**VERIFIED** (ctaexp.dbf header; `MENU.PRG` line 3865–3872; `COBRA.PRG` line 130–138)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| RESERVA | N | 6 | 0 | FK → reserva.RESERVA |
| VENCE | D | 8 | 0 | Due date |
| MES | N | 2 | 0 | Month |
| ANO | N | 4 | 0 | Year |
| CUOTA | N | 4 | 0 | Installment count for this row |
| VALOR | N | 5 | 0 | Amount due |
| PAGADA | C | 1 | 0 | Payment status: 'N'=unpaid, 'S'=paid |
| INTERES | N | 2 | 0 | Interest rate/flag |
| BONIFICA | N | 4 | 0 | Discount |
| FECHAPAGO | D | 8 | 0 | Payment date |
| TRECIBO | C | 4 | 0 | Receipt type code |
| RECIBO | C | 13 | 0 | Receipt number (formatted string) |
| COBRADOR | N | 2 | 0 | FK → cobrador.COBRADOR |
| COMPROBANT | C | 40 | 0 | Voucher/reference text |
| ACUENTA | N | 4 | 0 | Partial payment on account |

**Composite lookup key:** (RESERVA, ANO, MES) — VERIFIED.

**Index expressions:**  
- `CtaExp.Ntx`: `INDEX ON Reserva TO CtaExp` (MENU.PRG:3867)  
- `CtaExp2.Ntx`: `INDEX ON StrZero(Reserva,6)+StrZero(Ano,4)+StrZero(Mes,2) TO CtaExp2` (MENU.PRG:3870)

**Note on COBRADOR width mismatch:** Schema has width=2, but `cobrador.COBRADOR` is N(6). INFERRED the stored cobrador value is a short numeric code range. See §7 Inconsistencies.

---

### 2.10 FILTRO — Temporary/filter work area

**VERIFIED** (FILTRO.DBF header; no `USE Filtro` found in main `OpenDbf()`)

Same 15-field structure as `ctaexp.dbf` with wider numeric fields:

| Field | Type | Width | Dec |
|-------|------|-------|-----|
| RESERVA | N | 6 | 0 |
| VENCE | D | 8 | 0 |
| MES | N | 2 | 0 |
| ANO | N | 4 | 0 |
| CUOTA | N | 6 | 0 |
| VALOR | N | 10 | 2 |
| PAGADA | C | 1 | 0 |
| INTERES | N | 10 | 2 |
| BONIFICA | N | 10 | 2 |
| FECHAPAGO | D | 8 | 2 |
| TRECIBO | C | 4 | 0 |
| RECIBO | C | 13 | 0 |
| COBRADOR | N | 6 | 0 |
| COMPROBANT | C | 40 | 0 |
| ACUENTA | N | 9 | 2 |

**Status:** INFERRED — likely a work/export copy of `ctaexp`. Not opened in `OpenDbf()`. May be opened dynamically via `FILTRO` alias by a utility not present or within a conditional path.

---

### 2.11 MAEASO — Association/mutual master (legacy version)

**VERIFIED** (MAEASO.DBF header; no `Use Maeaso` found in main `OpenDbf()`)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| ASOCIACION | N | 6 | 0 | PK |
| DESCRIPCIO | C | 30 | 0 | Description |
| EMPRESA | N | 6 | 0 | Company code |
| AGENCIA | N | 6 | 0 | Agency code |
| NOMBRE | C | 25 | 0 | Contact name |
| CARGO | C | 10 | 0 | Contact title |
| DOMICILIO | C | 25 | 0 | Address |
| LOCALIDAD | C | 15 | 0 | Locality |
| PROVIN | C | 15 | 0 | Province (text, not FK) |
| CODPOSTAL | N | 10 | 0 | Postal code |
| TELEFONO | C | 8 | 0 | Phone |
| FECHA | N | 6 | 0 | Date (numeric encoding) |
| COMISI | N | 10 | 2 | Commission rate |
| PROVINCIA | N | 6 | 0 | FK → PROVINCI.CODIGO |
| REPORTE | N | 6 | 0 | Report code |
| COPIAS | N | 6 | 0 | Copies count |
| IVA | N | 10 | 2 | VAT rate |

**Notes:** Schema identical to `mutual.dbf` except missing `DISKETTE` and `GRUPO` fields. INFERRED to be the older version superseded by `mutual.dbf`. Not opened in `OpenDbf()`.

---

### 2.12 mutual — Association/mutual catalog (active)

**VERIFIED** (mutual.dbf header; `MENU.PRG` line 4011–4015)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| ASOCIACION | N | 6 | 0 | PK |
| DESCRIPCIO | C | 30 | 0 | Description |
| EMPRESA | N | 6 | 0 | Company code |
| AGENCIA | N | 6 | 0 | Agency code |
| NOMBRE | C | 25 | 0 | Contact name |
| CARGO | C | 10 | 0 | Contact title |
| DOMICILIO | C | 25 | 0 | Address |
| LOCALIDAD | C | 15 | 0 | Locality |
| PROVIN | C | 15 | 0 | Province (text) |
| CODPOSTAL | N | 10 | 0 | Postal code |
| TELEFONO | C | 8 | 0 | Phone |
| FECHA | N | 6 | 0 | Date (numeric) |
| COMISI | N | 10 | 2 | Commission rate % |
| PROVINCIA | N | 6 | 0 | FK → PROVINCI.CODIGO |
| REPORTE | N | 6 | 0 | Report code |
| COPIAS | N | 6 | 0 | Copies count |
| IVA | N | 10 | 2 | VAT rate |
| DISKETTE | L | 1 | 0 | Diskette flag (for export) |
| GRUPO | N | 2 | 0 | Group/batch code |

**Index expressions:**  
- `Mutual.Ntx`: `INDEX ON Asociacion TO Mutual` (MENU.PRG:4013)

**Relationships:**
- `reserva.MUTUAL` → `mutual.ASOCIACION` (FK; `MENU.PRG:3435`)
- Commission read via `Mutual->Comisi` to calculate net disbursement (`MENU.PRG:815`)
- `Mutual->Grupo` copied to temp table `AxMutu` for bank distribution (`MENU.PRG:600`)
- Validated via `CargaMutual()` — seek fails on unknown code with error (`MENU.PRG:564–565`).

---

### 2.13 parquenu — Cemetery parcel/plot register

**VERIFIED** (parquenu.dbf header; `MENU.PRG` line 3934–3953)

This is the largest table (56 fields, record size 657 bytes). It holds physical plot data and their reservation linkage plus up to 4 titleholders (A–C) and extended data.

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| CODIGO | C | 7 | PK — composite parcel code (Sector+Fila+Parcela) |
| SECTOR | C | 3 | Cemetery sector |
| FILA | N | 2 | Row within sector |
| PARCELA | N | 2 | Plot within row |
| FECHA | D | 8 | Assignment date |
| RESERVA | N | 6 | FK → reserva.RESERVA |
| TIPO_P_S | C | 1 | Plot type: 'P'=Particular, 'S'=Socio plan, 'V'=Special |
| NOMBRE | C | 25 | Main titleholder name |
| DOMICILIO | C | 25 | Address |
| BARRIO | C | 25 | District |
| LOCALIDAD | C | 15 | Locality |
| PROVINCIA | N | 6 | FK → PROVINCI.CODIGO |
| CPOSTAL | N | 6 | Postal code |
| TDOC | C | 3 | Document type (DNI/LE/LC/CI/CE) |
| DOCUMENTO | N | 8 | Document number |
| TELEFONO | C | 12 | Phone |
| DOMICILIOX–TELEFONOX | (x5 fields) | — | Secondary titleholder address block |
| TITULARA–TELEFONOA | (x9 fields) | — | Titleholder A block |
| TITULARB–TELEFONOB | (x9 fields) | — | Titleholder B block; DOCUMENTOB is N(19,4) — see §7 |
| TITULARC–TELEFONOC | (x9 fields) | — | Titleholder C block |
| ULT_ANO | N | 6 | Last expense year |
| ULT_MES | N | 6 | Last expense month |
| SECTORN | N | 6 | Numeric sector code |
| SECTORL | C | 1 | Sector letter code |
| SCARGO | C | 1 | Cargo/service flag (space=' ' means active) |
| COBRADOR | N | 6 | FK → cobrador.COBRADOR |
| CANTIT | N | 1 | Count of titleholders (max 3 enforced; `MENU.PRG:3495`) |

**Index expressions:**  
- `Parque1.Ntx`: `INDEX ON Reserva TO Parque1` (MENU.PRG:3936)  
- `Parque2.Ntx`: `INDEX ON Codigo TO Parque2` (MENU.PRG:3938)  
- `Parque3.Ntx`: `INDEX ON Nombre TO Parque3` (MENU.PRG:3941)  
- `Parque4.Ntx`: `INDEX ON Documento TO Parque4` (MENU.PRG:3944)  
- `Parque5.Ntx`: `INDEX ON Sector+Str(Fila,2)+Str(Parcela,2) TO Parque5` (MENU.PRG:3948)  
- `Parque6.Ntx`: `INDEX ON Cobrador TO Parque6` (MENU.PRG:3951)

**Integrity rules:**
- `CanTit <= 3` enforced: "No Puede haber más de 3 Titulares por Parcela" (`MENU.PRG:3495–3496`)
- `Tipo_P_S='P'` means "already reserved" — blocks duplicate assignment (`MENU.PRG:3499–3500`)
- A `SubNivel` record for same CODIGO means "already adjudicated/inhumed" (`MENU.PRG:3503–3505`)
- `SCargo=' '` (space) means "active / in service" (`MENU.PRG:705`)

---

### 2.14 PROMOTOR — Promoter/salesperson catalog

**VERIFIED** (PROMOTOR.DBF header; `MENU.PRG` line 4028–4035)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| PROMOTOR | N | 6 | 0 | PK |
| AGENCIA | N | 6 | 0 | Agency code |
| NOMBRE | C | 30 | 0 | Name |
| DOCUMENTO | C | 8 | 0 | ID document |
| DOMICILIO | C | 30 | 0 | Address |
| BARRIO | C | 15 | 0 | District |
| LOCALIDAD | C | 15 | 0 | Locality |
| PROVINCIA | N | 6 | 0 | FK → PROVINCI.CODIGO |
| TELEFONO | C | 12 | 0 | Phone |
| PORCENTAJE | N | 9 | 2 | Commission percentage |
| EQUIPO | N | 6 | 0 | Team code |

**Index expressions:**  
- `Promot1.Ntx`: `INDEX ON Promotor TO Promot1` (MENU.PRG:4030)  
- `Promot2.Ntx`: `INDEX ON Nombre TO Promot2` (MENU.PRG:4033)

**Relationships:**
- `reserva.PROMOTOR` → `PROMOTOR.PROMOTOR` (FK; INFERRED from `GrabaReserva()` at `MENU.PRG:3442`)
- Validated via `CargaPromotor()` — seek fails with error (`MENU.PRG:3722–3723`).

---

### 2.15 PROVINCI — Province/state catalog

**VERIFIED** (PROVINCI.DBF header; `MENU.PRG` line 4038–4042)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| CODIGO | N | 2 | 0 | PK |
| PROVINCIA | C | 50 | 0 | Province name |

**Index expressions:**  
- `Prov1.Ntx`: `INDEX ON Codigo TO Prov1` (MENU.PRG:4040)

**Relationships:**  
Referenced as FK from: `cobrador.PROVINCIA`, `COCHERIA.PROVINCIA`, `PROMOTOR.PROVINCIA`, `reserva` (via data entry at `MENU.PRG:3132`), `parquenu.PROVINCIA`, `SUPLENTE.PROVINCIA`, `titular.PROVINCIA`.  
Validated via `CargaProvi()` — seek fails when province not found (`MENU.PRG:3132`).

---

### 2.16 RECIBO — Payment receipt register

**VERIFIED** (RECIBO.DBF header; `MENU.PRG` line 3901–3914)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| RESERVA | N | 6 | 0 | FK → reserva.RESERVA |
| CUOTA | N | 6 | 0 | FK → CTACTE.CUOTA |
| FECHA | D | 8 | 0 | Payment date |
| SUCURSAL | N | 6 | 0 | Branch/office code |
| RECIBO | N | 15 | 0 | Receipt sequence number |
| BONIFICACI | N | 10 | 2 | Discount applied |
| IMPORTE | N | 10 | 2 | Amount paid |
| COBRADOR | N | 6 | 0 | FK → cobrador.COBRADOR |
| COMISION | N | 10 | 2 | Commission amount |

**Composite lookup index (RESERVA, CUOTA):** VERIFIED from `Recib1.Ntx` expression and from write patterns in `GrabaCuoCta()`. This index is used to locate existing payment records by reservation+installment.

**Uniqueness of (RESERVA, CUOTA):** INFERRED — the composite NTX index does not enforce uniqueness at the storage level (NTX indexes in Clipper are ordered access paths, not unique constraints). `GrabaCuoCta()` (`MENU.PRG:2846–2925`) uses `DbSeek()` and iterates with `While Reserva=xReserva .And. !Eof()`, implying it may encounter multiple RECIBO rows per (Reserva, Cuota) in partial-payment scenarios. Whether a 1:1 or 1:N relationship exists per installment payment is UNKNOWN from static analysis alone.

**Index expressions:**
- `Recib1.Ntx`: `INDEX ON StrZero(Reserva,6)+StrZero(Cuota,4) TO Recib1` (MENU.PRG:3903)
- `Recib2.Ntx`: `INDEX ON Reserva TO Recib2` (MENU.PRG:3906)
- `Recib3.Ntx`: `INDEX ON StrZero(Cobrador,6)+DtoC(Fecha) TO Recib3` (MENU.PRG:3909)
- `Recib4.Ntx`: `INDEX ON DtoC(Fecha) TO Recib4` (MENU.PRG:3912)

**Relationships:**
- Written when a cuota (installment) is paid: `Recibo->Reserva`, `Recibo->Cuota` cross-reference `CTACTE` (`MENU.PRG:2860`)
- `Recibo->(TraeDR(xReserva))` sums payments for a reserva in report generation (`MENU.PRG:716`)
- Multiple RECIBO rows per (Reserva, Cuota) are possible under partial-payment logic in `GrabaCuoCta()` (`MENU.PRG:2870–2916`): separate rows are appended for the bonificacion portion and the importe portion — INFERRED, not uniqueness-verified.

---

### 2.17 RENA — Bank remittance file (output)

**VERIFIED** (RENA.DBF header; not in main `OpenDbf()`)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| NUMSUC | N | 5 | 0 | Bank branch number |
| GRUPO | N | 2 | 0 | Mutual/group code |
| CUENTA | N | 11 | 0 | Account number |
| MONEDA | N | 2 | 0 | Currency code |
| NOMBRE | C | 30 | 0 | Account holder name |
| NRODOC | N | 11 | 0 | Document number |
| IMPORTE | N | 14 | 2 | Amount |

**Notes:** Schema matches the structure written by `BANCODIS.PRG` into dynamic `Imp&Grupo` temp files (`MENU.PRG:599–605`). INFERRED that `RENA.DBF` is used as a staging table for bank disbursement output. No `Use Rena` found in OpenDbf — UNKNOWN whether it is populated directly or via a separate batch.

---

### 2.18 reserva — Reservation master (core entity)

**VERIFIED** (reserva.dbf header; `MENU.PRG` line 3875–3888; `COBRA.PRG` line 146–153)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| RESERVA | N | 10 | 0 | PK — auto-incremented (`TraeNroRes()` at `MENU.PRG:3053–3055`) |
| MUTUAL | N | 8 | 0 | FK → mutual.ASOCIACION |
| COBRADOR | N | 11 | 0 | FK → cobrador.COBRADOR |
| NOMBRE | C | 38 | 0 | Member name |
| DOMICILIO | C | 41 | 0 | Address |
| BARRIO | C | 19 | 0 | District |
| TELEFONO | C | 12 | 0 | Phone |
| ALTA | D | 8 | 0 | Enrollment date (required: `MENU.PRG:3178`) |
| BAJA | C | 9 | 0 | Cancellation date (text) |
| CODBAJA | N | 9 | 0 | FK → BAJA.CODIGO |
| PROMOTOR | N | 11 | 0 | FK → PROMOTOR.PROMOTOR |
| PROMOCION | C | 12 | 0 | Promotion code |
| CREDITO | N | 9 | 2 | Credit balance |
| TIPO | C | 5 | 0 | Membership type |
| ALTAMUT | C | 11 | 0 | Mutual join date (text) |
| LUGT | C | 11 | 0 | Location/place code |
| LEGAJO | C | 8 | 0 | File/dossier number |
| AREA | N | 6 | 0 | FK → AREAS.AREA |
| INFOLAR | C | 11 | 0 | Information location |
| COD_INFO | C | 10 | 0 | Information code |
| CUENTA | N | 10 | 0 | Account number |
| EXPENSA | N | 9 | 2 | Monthly expense amount (set from `ValorExp->ValorExpen` at creation) |
| ULT_MES | N | 9 | 0 | Last processed expense month |
| ULT_ANO | N | 9 | 0 | Last processed expense year |
| PARCELA | C | 9 | 0 | INFERRED parcel code cache |

**Index expressions:**  
- `Reser1.Ntx`: `INDEX ON Reserva TO Reser1` (MENU.PRG:3877)  
- `Reser2.Ntx`: `INDEX ON Nombre TO Reser2` (MENU.PRG:3880)  
- `Reser3.Ntx`: `INDEX ON Cobrador TO Reser3` (MENU.PRG:3883)  
- `Reser4.Ntx`: `INDEX ON Mutual TO Reser4` (MENU.PRG:3886)

**Integrity rules:**
- `CodBaja=0` is the active-reservation test (MENU.PRG:876, LIQUIDA.PRG:13).
- `Alta` must not be empty (MENU.PRG:3178).
- Duplicate `Reserva` blocked: `MENU.PRG:3117–3119`.
- Reservation number auto-generated: `MENU.PRG:3053–3055`.
- `Expensa` copied from `ValorExp->ValorExpen` at creation time (`MENU.PRG:3431, 3446`).
- `Ult_Mes`/`Ult_Ano` updated after each expense payment cycle (`COBRA.PRG:67–69`).

---

### 2.19 SUBNIVEL — Interment/exhumation register

**VERIFIED** (SUBNIVEL.DBF header; `MENU.PRG` line 3970–3977)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| CODIGO | C | 7 | 0 | FK → parquenu.CODIGO (parcel code) |
| NIVEL | N | 6 | 0 | Burial level (1=top, 2, 3) |
| SUBNIVEL | N | 6 | 0 | Sub-level within burial level |
| FECHA | D | 8 | 0 | Interment date |
| NOMBRE | C | 25 | 0 | Deceased name |
| DOCUMENTO | C | 8 | 0 | Document number |
| SEXO | C | 1 | 0 | Sex (M/F) |
| ACTA | N | 19 | 4 | Death certificate number |
| TIPO | C | 1 | 0 | Record type |
| IMPUESTO | N | 19 | 2 | Tax amount |
| FECHAI | D | 8 | 0 | Inhumation date (used in recency check: `Date()-15 <= SubNivel->FechaI` at `MENU.PRG:1121`) |
| BOLETO | C | 10 | 0 | Ticket/order number |
| TIPOI | C | 1 | 0 | Service type: 'S'=Service, 'T'=Transfer (`MENU.PRG:2447`) |
| COCHERIA | N | 6 | 0 | FK → COCHERIA.CODIGO |
| FERETRO | N | 6 | 0 | FK → ATAUD.CODIGO |
| FECHAEXUMA | D | 8 | 0 | Exhumation date |

**Composite lookup key:** (CODIGO, NIVEL, SUBNIVEL) — VERIFIED from composite index.

**Index expressions:**  
- `SubNiv1.Ntx`: `INDEX ON Codigo TO SubNiv1` (MENU.PRG:3972)  
- `SubNiv2.Ntx`: `INDEX ON Codigo+Str(Nivel,1)+Str(SubNivel,1) TO SubNiv2` (MENU.PRG:3975)

**Relationships:**
- `SUBNIVEL.CODIGO` → `parquenu.CODIGO` (FK; core link)
- `SUBNIVEL.COCHERIA` → `COCHERIA.CODIGO` (FK; `MENU.PRG:1387`)
- `SUBNIVEL.FERETRO` → `ATAUD.CODIGO` (FK; `MENU.PRG:1391`)

**Integrity rules:**
- `Fechaexuma <> CtoD('  /  /    ')` guards exhumation display (`MENU.PRG:1114`)
- `Date()-15 <= FechaI` used as a 15-day recency gate (`MENU.PRG:1121`)
- Nivel 1/2/3 drives display formatting (`MENU.PRG:1135–1153`)

---

### 2.20 SUPLENTE — Alternate/secondary titleholders

**VERIFIED** (SUPLENTE.DBF header; `MENU.PRG` line 3999–4003)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| RESERVA | N | 6 | 0 | FK → reserva.RESERVA |
| SUPLENTE | N | 3 | 0 | Alternate sequence number |
| TITULAR | C | 25 | 0 | Alternate titleholder name |
| DOMICILIO | C | 25 | 0 | Address |
| BARRIO | C | 25 | 0 | District |
| LOCALIDAD | C | 15 | 0 | Locality |
| PROVINCIA | N | 6 | 0 | FK → PROVINCI.CODIGO |
| CPOSTAL | N | 6 | 0 | Postal code |
| TDOC | C | 3 | 0 | Document type |
| DOCUMENTO | N | 8 | 0 | Document number |
| TELEFONO | C | 12 | 0 | Phone |

**Index expressions:**  
- `Suple1.Ntx`: `INDEX ON Reserva TO Suple1` (MENU.PRG:4001)

**Relationships:**
- `SUPLENTE.RESERVA` → `reserva.RESERVA` (one-to-many; a reservation can have multiple alternates)
- Populated via `AxSupl` temp table during reservation creation (`MENU.PRG:3237, 3245`)

---

### 2.21 titular — Reservation title holder

**VERIFIED** (titular.DBF header; `MENU.PRG` line 4085–4089)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| CODIGO | C | 7 | 0 | FK → parquenu.CODIGO (parcel code) |
| RESERVA | N | 10 | 0 | FK → reserva.RESERVA |
| NOMBRE | C | 40 | 0 | Name |
| DOMICILIO | C | 50 | 0 | Address |
| BARRIO | C | 25 | 0 | District |
| LOCALIDAD | C | 30 | 0 | Locality |
| PROVINCIA | N | 6 | 0 | FK → PROVINCI.CODIGO |
| CPOSTAL | N | 6 | 0 | Postal code |
| TDOC | C | 3 | 0 | Document type |
| DOCUMENTO | N | 8 | 0 | Document number |
| TELEFONO | C | 15 | 0 | Phone |

**Index expressions:**  
- `Titular.Ntx`: `INDEX ON Codigo TO Titular` (MENU.PRG:4087)

**Relationships:**
- `titular.CODIGO` → `parquenu.CODIGO` (FK; one-to-many, up to 3 per parcel per `CanTit` check)
- `titular.RESERVA` → `reserva.RESERVA` (FK)
- Written via `GrabaTitular()` at `MENU.PRG:3410–3426`

**Note:** The `bancos.dbf` variant `Titular.Sn` opened in `BANCODIS.PRG:11` is a separate file with `.Sn` suffix and extra fields (`Agencia`). INFERRED to be a bank-partner-specific extension. Its schema is UNKNOWN.

---

### 2.22 VALOREXP — Expense fee table

**VERIFIED** (VALOREXP.DBF header; `MENU.PRG` line 4075)

| Field | Type | Width | Dec | Notes |
|-------|------|-------|-----|-------|
| VIGENCIA | D | 8 | 0 | Effective date |
| VALOREXPEN | N | 9 | 2 | Current expense amount |
| HORA | C | 8 | 0 | Time of last update |
| USUARIO | C | 15 | 0 | User who set the value |

**Index expressions:** None (`ValorExp` opened with no index at `MENU.PRG:4075`).

**Integrity rules:**
- `GrabaReserva()` reads `ValorExp->ValorExpen` directly at line 3431 (`Local xExpensa:=ValorExp->ValorExpen`) without calling `DbGoBottom()` first. The record position of ValorExp at the time of the call is determined by the caller's context; the "current record" semantics depend on how ValorExp was last positioned. INFERRED: since ValorExp has no index and is opened shared with no explicit positioning in `OpenDbf()`, the record pointer position is UNKNOWN at the point `GrabaReserva()` is called. Whether this reads the first, last, or some intermediate record is UNKNOWN without runtime observation.
- `GrabaExpCta()` at `MENU.PRG:3011` explicitly calls `ValorExp->(DbGoBottom())` before reading `ValorExp->ValorExpen`. For that call path, the bottom record (most recently appended) is confirmed as the rate source — VERIFIED.
- The current `ValorExpen` is assigned to `reserva.EXPENSA` at reservation creation (`MENU.PRG:3431, 3446`).
- Also directly referenced in liquidation payment loop: `ValorExp->ValorExpen` at `MENU.PRG:2942`.

---

## 3. INFERRED Findings

### 3.1 Virtual / Runtime-generated tables (UNKNOWN schemas)

The following aliases are opened dynamically via macro substitution (`&Puesto.`) and **do not correspond to any DBF file in the workspace root**:

| Alias | `USE` expression | Observed fields used | Purpose |
|-------|-----------------|----------------------|---------|
| AuxLiq | `Use AuxLiq&Puesto. Alias AuxLiq` | Reserva, Ano, Mes, Cuota | Temporary bulk liquidation work area |
| Auxiliar | `Use Auxi&Puesto. Alias Auxiliar` | Cantidad, Importe | Temporary accumulator |
| AuxiRes | `Use Aux&Puesto. Alias AuxiRes` | Reserva, Recibo, Nombre, Bonifica, Importe, FechaPago, Cobrador | Payment batch staging area |
| AxSupl | `Use AxSup&Puesto. Alias AxSupl` | Titular, Domicilio, Barrio, Localidad, Provincia, CPostal, TDoc, Documento, Telefono, Reserva, Suplente | Temporary suplente staging |
| AxPl | `Use AxPl&Puesto.` | Cuotas, Precio, Desde | Temporary plan/installment staging |
| AxMutu | (via `ImpMut` alias) | NumSuc, Grupo, Cuenta, Moneda, Nombre, NroDoc, Importe | Bank mutual disbursement temp |
| ImpCob | `Use ImpCob` (Puesto='26' only) | Reserva, Nombre, Domicilio, Barrio, Alta, Credito, Importe, PagCta, DebCta, Total | Collector report staging |
| ImpMut | `Use ImpMut` (Puesto='26' only) | Reserva, Nombre, LugT, Legajo, Expensa, Cuota, Total | Mutual report staging |
| ResuCta | `Use ResuCta Shared New` | Reserva, Total, Minimo, Vence, Adeuda, Pagado | Expense summary per reservation |
| ExpCta | `Use ExpCta Shared New` | Reserva, Bonifica, Importe, Acuenta, Fecha, Comprobant, Cobrador, Mes, Anio | Expense payment register (secondary) |
| AuxParq | `Use AuxParq Shared New` | Reserva | Temporary parcel auxiliary |
| Recexpe | `Use Recexpe Shared New` | Codigo, Mes, Anio | Expense receipt index |
| Pexpensa | `Use Pexpensa Shared New` | Codigo | Expense plan staging |
| Bisiesto | `Use Bisiesto Shared New` | Ano | Leap year lookup table |
| Mary | `Use &ValGr. Alias Mary` | NumSuc, Grupo, Cuenta, Moneda, Nombre, NroDoc, Importe | Bank group disbursement (BANCODIS) |

> **INFERRED:** These tables are created at runtime by each workstation process. Their DBF schemas are not persisted in the workspace and must be reverse-engineered from the `REPLACE` statements that write to them.

---

### 3.2 ResuCta inferred schema

From `CargaLiq()` (`MENU.PRG:959–975`) and `COBRA.PRG:23–35`:

| Field | Inferred Type | Notes |
|-------|--------------|-------|
| RESERVA | N | FK → reserva.RESERVA; primary index key |
| TOTAL | N(dec) | Sum of unpaid expense amounts |
| MINIMO | N(dec) | Minimum payment = 30% of Total, rounded up to next expense unit |
| VENCE | D | Due date |
| ADEUDA | C/N | String of "year/month" pairs for overdue months |
| PAGADO | N(dec) | Amount last paid (updated in COBRA.PRG:34) |

---

### 3.3 ExpCta inferred schema (distinct from ctaexp)

From `GrabaExpCta()` (`MENU.PRG:3008–3051`):

| Field | Notes |
|-------|-------|
| RESERVA | FK → reserva.RESERVA |
| BONIFICA | Discount |
| IMPORTE | Payment amount |
| ACUENTA | Residual/partial |
| FECHA | Payment date |
| COMPROBANT | Receipt reference |
| COBRADOR | FK → cobrador.COBRADOR |
| MES | Month |
| ANIO | Year |

Separate from `ctaexp.dbf`. INFERRED `ExpCta` = expense payment receipts (what was received), while `ctaexp` = dues schedule (what is owed).

---

## 4. Logical Relationship Map

```
PROVINCI ──────────────────────────────────────────────────────────────────────┐
  CODIGO                                                                       │ FK (PROVINCIA)
                                                                               │
mutual ──────────────────────────────────────────────────────┐                │
  ASOCIACION (PK)                                            │ FK (MUTUAL)     │
                                                             │                │
PROMOTOR ─────────────────────────────────────────────┐      │                │
  PROMOTOR (PK)                                       │ FK   │                │
                                                      │      │                │
cobrador ──────────────────────────────────────┐      │      │                │
  COBRADOR (PK)                                │ FK   │ FK   │                │
                                               │      │      │                │
                                      AREAS ───┼──────┘      │                │
                                               │             │                │
reserva ◄──────────────────────────────────────┘ FK COBRADOR │                │
  RESERVA (PK) ─────────────────────────────────── FK MUTUAL─┘                │
  CODBAJA ────────────────────────────────────────────────────► BAJA.CODIGO   │
  AREA ──────────────────────────────────────────────────────► AREAS.AREA     │
  EXPENSA ──────────────────────────────────────── from VALOREXP.VALOREXPEN   │
  PROVINCIA ──────────────────────────────────────────────────────────────────┘
      │
      ├── 1:N ──► CTACTE (RESERVA + CUOTA = installment plan rows)
      │               │
      │               └── 1:1 ──► RECIBO (RESERVA + CUOTA = payment receipt)
      │
      ├── 1:N ──► ctaexp (RESERVA + ANO + MES = monthly expense dues)
      ├── 1:N ──► SUPLENTE (RESERVA = alternate titleholders)
      ├── 1:1 ──► ResuCta [virtual] (RESERVA = expense summary)
      │
      └── 1:1 ──► parquenu (RESERVA ↔ CODIGO = plot assignment)
                      │
                      └── 1:N ──► SUBNIVEL (CODIGO = interments per plot)
                                       │
                                       ├──► COCHERIA.CODIGO (funeral home)
                                       └──► ATAUD.CODIGO    (coffin)

titular ◄──────────── parquenu (CODIGO; up to 3 per plot via CanTit)
```

---

## 5. UNKNOWN Items and Missing Dependencies

| Item | Status | Notes |
|------|--------|-------|
| `MAEASO.DBF` usage | UNKNOWN | No `Use Maeaso` found in any PRG. May be obsolete. |
| `bancos.dbf` usage | UNKNOWN | No `Use bancos` found; `BANCODIS.PRG` uses `&ValGr.` dynamic alias. |
| `RENA.DBF` write path | UNKNOWN | Structure matches `BANCODIS` output but no direct `Use Rena` found. |
| `FILTRO.DBF` usage | UNKNOWN | Not opened in `OpenDbf()`. May be a pre-export staging file. |
| `AuxLiq`, `Auxiliar`, `AuxiRes`, `AxSupl`, `AxPl`, `AxMutu`, `ImpCob`, `ImpMut` | UNKNOWN exact schemas | Only field names inferred from REPLACE patterns. |
| `Recexpe` schema | UNKNOWN | Fields: Codigo, Mes, Anio — remainder unverified. |
| `Pexpensa` schema | UNKNOWN | Field Codigo confirmed; rest unverified. |
| `Bisiesto` schema | UNKNOWN | Only field `Ano` confirmed from `DbSeek(xAno)`. |
| `ExpCta` schema | INFERRED | Differs from `ctaexp`; no persistent DBF found. |
| `ResuCta` schema | INFERRED | No persistent DBF found; schema reconstructed from REPLACE/read patterns. |
| `AuxParq` schema | UNKNOWN | Only `Reserva` field confirmed. |
| `Titular.Sn` schema | UNKNOWN | External `.Sn` variant used in `BANCODIS.PRG`. |
| `Respon.Sn` schema | UNKNOWN | External file used in `BANCODIS.PRG`. |
| `FTMENUTO.CH` include file | MISSING | Included at line 1 of `MENU.PRG` but not in workspace. |
| `COBRADOR.COMISIONC` purpose | UNKNOWN | Second commission field; not referenced in any SEEK or REPLACE found. |
| `reserva.PARCELA` field usage | INFERRED | C(9) field in schema matching parcel code format; not written in `GrabaReserva()`. |

---

## 6. Conflicts with Other Reports

None at this stage. The security review (`OTN-10`) confirmed the workspace contains only synthetic data, which is consistent with this analysis (3 synthetic reservations: 900001, 900002, 900003; parcels: D010101, D010102, D020101).

---

## 7. Schema Inconsistencies Between DBF and PRG Usage

### 7.1 ctaexp.COBRADOR width (N 2) vs cobrador.COBRADOR (N 6)
**VERIFIED:** `ctaexp.dbf` field `COBRADOR` is N(2). The `cobrador.dbf` PK `COBRADOR` is N(6). The index `Cobra1.Ntx` uses `Cobrador` as a 6-digit key. This means `ctaexp` can only reference cobrador codes 0–99. This may reflect that cobrador codes in practice are small, or it may be a schema design defect that limits the number of supported collectors.

### 7.2 parquenu.DOCUMENTOB is N(19,4) vs all other DOCUMENTO fields N(8)
**VERIFIED:** All other document number fields across all tables are N(8). The `DOCUMENTOB` field in the titleholder-B block of `parquenu` is N(19,4) — 4 decimal places on a document number is anomalous. INFERRED to be an accidental field-width change or copy error during schema evolution.

### 7.3 reserva.COBRADOR is N(11) vs cobrador.COBRADOR N(6)
**VERIFIED:** The FK in `reserva` is wider than the PK in `cobrador`. No functional impact at current data scale, but indicates schema drift between the two tables.

### 7.4 reserva.MUTUAL is N(8) vs mutual.ASOCIACION N(6)
**VERIFIED:** Same pattern — FK is wider than PK. No functional impact at current data scale.

### 7.5 CTACTE.RESERVA and CTACTE.CUOTA are N(19,5)
**VERIFIED:** These fields have 5 decimal places, which is atypical for integer sequence numbers. INFERRED to be oversized fields that in practice hold integer values only.

### 7.6 MAEASO.DBF not opened in any PRG
**VERIFIED:** No `Use Maeaso`, `Use MAEASO`, or `MaeAso->` reference found in any of the 25 PRG files. INFERRED this table is either: (a) an obsolete predecessor to `mutual.dbf`, or (b) accessed via a batch tool not present in the workspace.

### 7.7 reserva.PARCELA field not written by GrabaReserva()
**VERIFIED:** `reserva.dbf` has a `PARCELA C(9)` field, but `GrabaReserva()` (`MENU.PRG:3430–3448`) does not write to it. The parcel code is instead stored in `parquenu`. INFERRED this field may be a denormalized cache populated by a separate update that is not visible in the current PRG set.

### 7.8 ctaexp.COBRADOR (N,2) width truncation risk
**VERIFIED:** `Recib3.Ntx` on RECIBO uses `StrZero(Cobrador,6)` — padded to 6 digits. The `ctaexp` COBRADOR field only stores 2 digits. If cobrador codes above 99 were ever introduced, ctaexp records would lose precision silently.

---

## 8. Risks and Recommended Next Actions

| Risk | Severity | Recommendation |
|------|----------|----------------|
| Plaintext passwords in CONTRAS | HIGH | Do not migrate as-is. Replace with salted hash authentication. |
| 14 runtime-only virtual tables with no persisted schema | HIGH | Reconstruct schemas from REPLACE patterns before implementing any migration. |
| ctaexp.COBRADOR N(2) truncation vs cobrador N(6) | MEDIUM | Confirm max cobrador code value against source evidence or stakeholder review before migration — do not read production data directly. |
| parquenu.DOCUMENTOB N(19,4) anomaly | LOW | Normalize to N(8) in target schema after confirming no decimal values in data. |
| MAEASO vs mutual schema duplication | MEDIUM | Confirm MAEASO is obsolete before excluding from migration scope. |
| VALOREXP single-row rate table | MEDIUM | Rate changes overwrite the effective rate for all existing reservations — confirm whether historical audit is needed. |
| Missing FTMENUTO.CH include | LOW | Only affects ability to compile; does not affect data model analysis. |
| reserva.PARCELA unused by GrabaReserva | LOW | Investigate if populated by another code path before treating as dead field. |

---

## 9. Synthetic Data Statement

Only the 22 DBF files containing fully synthetic demo records (as confirmed in `AGENTS.md` and the OTN-10 security review) were read during this analysis. No production data, credentials, personal information, or real business identifiers were inspected or reproduced. All field-value examples referenced in this report are structural (widths, types) rather than content-based.

---

*End of OTN-21 Data Model Report*
