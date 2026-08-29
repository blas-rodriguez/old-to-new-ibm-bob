# Logical Data Model

**Task ID:** OTN-25 (consolidated from OTN-21, reconciled against OTN-20, OTN-22, OTN-23, OTN-24)
**Date:** 2026-08-28
**Status:** COMPLETE — Gate 2 APPROVED on 2026-08-29  
**Source:** Binary DBF header parsing + PRG write-pattern analysis

> **Storage note:** DBF/NTX provides no PRIMARY KEY, FOREIGN KEY, or UNIQUE constraints at the storage level. All PKs listed below are **logical/candidate keys** — fields used as lookup targets by PRG `DbSeek()` calls. Uniqueness is not enforced by the storage engine and cannot be verified from static analysis alone unless direct enforcement evidence exists in the code. All FK relationships are application-enforced only.

---

## 1. Persistent Tables (22 DBF Files in Workspace)

### 1.1 PROVINCI — Province catalog (lookup)
**VERIFIED** (header; `MENU.PRG`, `OpenDbf()`, line 4038)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| CODIGO | N | 2 | PK |
| PROVINCIA | C | 50 | Name |

Index: `Prov1.Ntx` on `Codigo` (`MENU.PRG:4040`).  
FK source for: cobrador, COCHERIA, PROMOTOR, parquenu, SUPLENTE, titular, and reservation address data.

---

### 1.2 AREAS — Service/collection zones
**VERIFIED** (header; `MENU.PRG:4`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| AREA | N | 6 | PK |
| DESCRIPCIO | C | 30 | |
| COBRADOR | N | 6 | FK → cobrador.COBRADOR |
| REPORTE | N | 6 | Report routing code |

Index: none found in `OpenDbf()`. Not opened in main `OpenDbf()`.

---

### 1.3 ATAUD — Coffin catalog (lookup)
**VERIFIED** (header; `MENU.PRG:3980`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| CODIGO | N | 6 | PK |
| DESCRIPCIO | C | 25 | |

Index: `Ataud1.Ntx` on `Codigo` (`MENU.PRG:3982`).  
FK source: `SUBNIVEL.FERETRO` → `ATAUD.CODIGO` (`MENU.PRG:1391`).

---

### 1.4 BAJA — Cancellation reason codes (lookup)
**VERIFIED** (header; `MENU.PRG:3927`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| CODIGO | N | 6 | PK |
| DESCRIPCIO | C | 50 | |

Index: `Baja1.Ntx` on `Codigo` (`MENU.PRG:3929`).  
FK source: `reserva.CODBAJA` → `BAJA.CODIGO` (`MENU.PRG:1983`).  
Domain values: UNKNOWN — content is in the Baja DBF at runtime.

---

### 1.5 bancos — Bank catalog
**VERIFIED** (header — schema only; role UNKNOWN)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| CODIGO | C | 2 | Candidate key |
| BANCO | C | 30 | |
| DIRECCION | C | 40 | |
| TELEFONO | C | 15 | |
| FAX | C | 15 | |
| CONTACTO | C | 25 | |

**Version byte:** 0x30 (48) — Visual FoxPro format. Clipper does not natively open VFP DBFs.  
**No PRG in the workspace opens `bancos.dbf`.** Role is UNKNOWN. `BANCODIS.PRG` opens `Imp&xGrupo` (e.g., Imp002), not this file.

---

### 1.6 cobrador — Collector/agent catalog
**VERIFIED** (header; `MENU.PRG:4018`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| COBRADOR | N | 6 | PK |
| NOMBRE | C | 25 | |
| DOMICILIO | C | 25 | |
| LOCALIDAD | C | 15 | |
| PROVINCIA | N | 6 | FK → PROVINCI.CODIGO |
| TELEFONO | C | 12 | |
| COMISION | N | 10,2 | Commission rate % |
| COMISIONC | N | 10,2 | Purpose UNKNOWN |

Indexes: `Cobra1.Ntx` on `Cobrador`; `Cobra2.Ntx` on `Nombre` (`MENU.PRG:4020, 4023`).  
FK target for: reserva.COBRADOR, RECIBO.COBRADOR, ctaexp.COBRADOR, parquenu.COBRADOR, AREAS.COBRADOR.

---

### 1.7 COCHERIA — Funeral home catalog
**VERIFIED** (header; `MENU.PRG:3992`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| CODIGO | N | 6 | PK |
| NOMBRE | C | 20 | |
| DOMICILIO | C | 25 | |
| BARRIO | C | 15 | |
| PROVINCIA | N | 6 | FK → PROVINCI.CODIGO |
| TELEFONO | C | 11 | |

Index: `Coche1.Ntx` on `Codigo` (`MENU.PRG:3994`).  
FK source: `SUBNIVEL.COCHERIA` → `COCHERIA.CODIGO` (`MENU.PRG:1387`).

---

### 1.8 CONTRAS — System credentials
**VERIFIED** (header; `MENU.PRG:30`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| USUARIO | C | 10 | PK (login username) |
| CLAVE | C | 10 | **Plaintext password — do not replicate** |

Index: `Contras.Ntx` on `Usuario` (`MENU.PRG:32`).  
The login call is commented out at `MENU.PRG:12`; authentication is not enforced at startup.  
The single synthetic demo record holds demo credentials in plaintext.

---

### 1.9 CTACTE — Installment plan ledger
**VERIFIED** (header; `MENU.PRG:3917`)

| Field | Type | Width,Dec | Notes |
|-------|------|-----------|-------|
| RESERVA | N | 19,5 | FK → reserva.RESERVA |
| CUOTA | N | 19,5 | Installment sequence number |
| VENCIMIENT | D | 8 | Due date |
| IMPORTE | N | 19,5 | Amount due |
| SALDO | N | 19,5 | Outstanding balance |
| MARCA | C | 1 | Status: `'I'`=initial |

**Composite PK:** (RESERVA, CUOTA) — VERIFIED from composite NTX index and write pattern.  
The N(19,5) fields for sequence integers are oversized — INFERRED to hold integer values only.

Indexes: `CtaCt1.Ntx` on `Reserva` (order 1); `CtaCt2.Ntx` on `StrZero(Reserva,6)+StrZero(Cuota,4)` (order 2) (`MENU.PRG:3919, 3921`).

Relationships:
- One row per installment, created by `CargaPlan()` at `MENU.PRG:3256–3278`.
- `RECIBO` cross-references CTACTE via (RESERVA, CUOTA).
- `BuscaDatos()` at `MENU.PRG:2096–2114` updates `CtaCte.Saldo` in real-time during query.

---

### 1.10 ctaexp — Monthly expense dues ledger (core billing table)
**VERIFIED** (header; `MENU.PRG:3865`; `COBRA.PRG:130`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| RESERVA | N | 6 | FK → reserva.RESERVA |
| VENCE | D | 8 | Due date |
| MES | N | 2 | Month |
| ANO | N | 4 | Year |
| CUOTA | N | 4 | Installment count for this row |
| VALOR | N | 5 | Amount due |
| PAGADA | C | 1 | `'N'`=unpaid, `'S'`=paid |
| INTERES | N | 2 | Interest flag/rate |
| BONIFICA | N | 4 | Discount |
| FECHAPAGO | D | 8 | Payment date |
| TRECIBO | C | 4 | Receipt type code |
| RECIBO | C | 13 | Receipt number |
| COBRADOR | N | 2 | FK → cobrador.COBRADOR (**⚠ width N(2) vs PK N(6) — see §3**) |
| COMPROBANT | C | 40 | Voucher reference |
| ACUENTA | N | 4 | Partial payment |

**Composite lookup key:** (RESERVA, ANO, MES) — VERIFIED.  
Indexes: `CtaExp.Ntx` on `Reserva` (order 1); `CtaExp2.Ntx` on `StrZero(Reserva,6)+StrZero(Ano,4)+StrZero(Mes,2)` (order 2) (`MENU.PRG:3867, 3870`).

---

### 1.11 FILTRO — ctaexp-format staging (purpose uncertain)
**VERIFIED** (header — schema only; not opened in `OpenDbf()`)

15-field structure identical to `ctaexp` but with wider numeric fields (e.g., COBRADOR N(6), ACUENTA N(9,2)).  
**Status:** INFERRED as a work/export copy of ctaexp. Role UNKNOWN.

---

### 1.12 MAEASO — Association master (purpose uncertain — INFERRED possibly superseded)
**VERIFIED** (header — schema only; not opened in any PRG)

17-field structure matching `mutual` minus `DISKETTE` and `GRUPO`. **INFERRED** to be a predecessor to `mutual.dbf` that was superseded; this is not VERIFIED. Not referenced by any PRG in the workspace. See §5 UNKNOWN items.

---

### 1.13 mutual — Association/mutual catalog (active)
**VERIFIED** (header; `MENU.PRG:4011`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| ASOCIACION | N | 6 | PK |
| DESCRIPCIO | C | 30 | |
| EMPRESA | N | 6 | Company code |
| AGENCIA | N | 6 | Agency code |
| NOMBRE | C | 25 | |
| CARGO | C | 10 | |
| DOMICILIO | C | 25 | |
| LOCALIDAD | C | 15 | |
| PROVIN | C | 15 | Province text (not FK) |
| CODPOSTAL | N | 10 | |
| TELEFONO | C | 8 | |
| FECHA | N | 6 | Date (numeric encoding) |
| COMISI | N | 10,2 | Commission rate % |
| PROVINCIA | N | 6 | FK → PROVINCI.CODIGO |
| REPORTE | N | 6 | |
| COPIAS | N | 6 | Print copies |
| IVA | N | 10,2 | VAT rate |
| DISKETTE | L | 1 | Export flag |
| GRUPO | N | 2 | Group/batch code (drives `Imp&Grupo` dynamic table) |

Index: `Mutual.Ntx` on `Asociacion` (`MENU.PRG:4013`).  
FK source: `reserva.MUTUAL` → `mutual.ASOCIACION` (`MENU.PRG:3435`).

---

### 1.14 parquenu — Cemetery parcel register (core spatial entity)
**VERIFIED** (header; `MENU.PRG:3934` — 56 fields)

Selected key fields:

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| CODIGO | C | 7 | PK — Sector(3)+StrZero(Fila,2)+StrZero(Parcela,2) |
| SECTOR | C | 3 | Cemetery sector |
| FILA | N | 2 | Row |
| PARCELA | N | 2 | Plot |
| FECHA | D | 8 | Assignment date |
| RESERVA | N | 6 | FK → reserva.RESERVA |
| TIPO_P_S | C | 1 | `'P'`=Reserved, `'S'`=Socio, `'V'`=Special |
| NOMBRE | C | 25 | Main titleholder name |
| COBRADOR | N | 6 | FK → cobrador.COBRADOR |
| CANTIT | N | 1 | Titleholder count (max 3) |
| SCARGO | C | 1 | Service flag (`' '`=active) |
| ULT_ANO | N | 6 | Last expense year |
| ULT_MES | N | 6 | Last expense month |
| DOCUMENTOB | N | 19,4 | **⚠ Anomalous — N(19,4) on a document number; see §3** |
| + titleholder blocks A, B, C and secondary address block | | | |

Indexes: `Parque1` on `Reserva`; `Parque2` on `Codigo`; `Parque3` on `Nombre`; `Parque4` on `Documento`; `Parque5` on `Sector+Str(Fila,2)+Str(Parcela,2)`; `Parque6` on `Cobrador` (`MENU.PRG:3936–3951`).

Integrity: `CanTit <= 3` enforced at `MENU.PRG:3495`; `Tipo_P_S='P'` blocks re-reservation at `MENU.PRG:3499`.

---

### 1.15 PROMOTOR — Salesperson catalog
**VERIFIED** (header; `MENU.PRG:4028`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| PROMOTOR | N | 6 | PK |
| AGENCIA | N | 6 | |
| NOMBRE | C | 30 | |
| DOCUMENTO | C | 8 | |
| DOMICILIO | C | 30 | |
| BARRIO | C | 15 | |
| LOCALIDAD | C | 15 | |
| PROVINCIA | N | 6 | FK → PROVINCI.CODIGO |
| TELEFONO | C | 12 | |
| PORCENTAJE | N | 9,2 | Commission % |
| EQUIPO | N | 6 | Team code |

Indexes: `Promot1` on `Promotor`; `Promot2` on `Nombre` (`MENU.PRG:4030, 4033`).

---

### 1.16 RECIBO — Payment receipt register
**VERIFIED** (header; `MENU.PRG:3901`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| RESERVA | N | 6 | FK → reserva.RESERVA |
| CUOTA | N | 6 | FK → CTACTE.CUOTA |
| FECHA | D | 8 | Payment date |
| SUCURSAL | N | 6 | Branch code |
| RECIBO | N | 15 | Receipt sequence number |
| BONIFICACI | N | 10,2 | Discount |
| IMPORTE | N | 10,2 | Amount paid |
| COBRADOR | N | 6 | FK → cobrador.COBRADOR |
| COMISION | N | 10,2 | Commission |

Indexes: `Recib1` on `StrZero(Reserva,6)+StrZero(Cuota,4)` (order 1); `Recib2` on `Reserva` (order 2); `Recib3` on `StrZero(Cobrador,6)+DtoC(Fecha)` (order 3); `Recib4` on `DtoC(Fecha)` (order 4) (`MENU.PRG:3903–3912`).

**Uniqueness of (RESERVA, CUOTA):** UNKNOWN — NTX indexes are ordered access paths, not unique constraints. `GrabaCuoCta()` at `MENU.PRG:2846–2925` iterates with `While Reserva=xReserva .And. !Eof()` and may append multiple rows per installment in partial-payment scenarios. Multiple rows per (RESERVA, CUOTA) cannot be excluded from static analysis alone.

---

### 1.17 RENA — Bank remittance output file
**VERIFIED** (header — schema only; `USE Rena` not found in `OpenDbf()`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| NUMSUC | N | 5 | Bank branch |
| GRUPO | N | 2 | Mutual group code |
| CUENTA | N | 11 | Account number |
| MONEDA | N | 2 | Currency code |
| NOMBRE | C | 30 | Account holder |
| NRODOC | N | 11 | Document number |
| IMPORTE | N | 14,2 | Amount |

INFERRED: staging table for bank disbursement output; same structure as `Imp&Grupo` tables written by `BANCODIS.PRG`.

---

### 1.18 reserva — Reservation master (core operational entity)
**VERIFIED** (header; `MENU.PRG:3875`; `COBRA.PRG:146`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| RESERVA | N | 10 | PK — auto-incremented (`TraeNroRes()` at `MENU.PRG:3053–3055`) |
| MUTUAL | N | 8 | FK → mutual.ASOCIACION (**⚠ width 8 vs PK 6 — see §3**) |
| COBRADOR | N | 11 | FK → cobrador.COBRADOR (**⚠ width 11 vs PK 6 — see §3**) |
| NOMBRE | C | 38 | |
| DOMICILIO | C | 41 | |
| BARRIO | C | 19 | |
| TELEFONO | C | 12 | |
| ALTA | D | 8 | Enrollment date (mandatory — `MENU.PRG:3178`) |
| BAJA | C | 9 | Cancellation date (text) |
| CODBAJA | N | 9 | FK → BAJA.CODIGO; 0 = active |
| PROMOTOR | N | 11 | FK → PROMOTOR.PROMOTOR |
| PROMOCION | C | 12 | Promotion code |
| CREDITO | N | 9,2 | Credit balance |
| TIPO | C | 5 | Plan type: S / P / V |
| ALTAMUT | C | 11 | Mutual join date (text) |
| LUGT | C | 11 | Location code |
| LEGAJO | C | 8 | Dossier number |
| AREA | N | 6 | FK → AREAS.AREA |
| INFOLAR | C | 11 | |
| COD_INFO | C | 10 | |
| CUENTA | N | 10 | Account number |
| EXPENSA | N | 9,2 | Monthly expense amount (from ValorExp at creation) |
| ULT_MES | N | 9 | Last processed expense month |
| ULT_ANO | N | 9 | Last processed expense year |
| PARCELA | C | 9 | INFERRED — parcel code cache; not written by `GrabaReserva()` |

Indexes: `Reser1` on `Reserva`; `Reser2` on `Nombre`; `Reser3` on `Cobrador`; `Reser4` on `Mutual` (`MENU.PRG:3877–3886`).

Integrity: `CodBaja=0` = active; `Alta` must not be empty; duplicate `Reserva` blocked at `MENU.PRG:3117`.

---

### 1.19 SUBNIVEL — Interment and exhumation register
**VERIFIED** (header; `MENU.PRG:3970`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| CODIGO | C | 7 | FK → parquenu.CODIGO |
| NIVEL | N | 6 | Burial level (1–3) |
| SUBNIVEL | N | 6 | Sub-level within level (1–6) |
| FECHA | D | 8 | Date of death |
| NOMBRE | C | 25 | Deceased name |
| DOCUMENTO | C | 8 | |
| SEXO | C | 1 | M/F |
| ACTA | N | 19,4 | Death certificate number |
| TIPO | C | 1 | Record type |
| IMPUESTO | N | 19,2 | Tax amount |
| FECHAI | D | 8 | Inhumation date (15-day recency check at `MENU.PRG:1121`) |
| BOLETO | C | 10 | Ticket/order number |
| TIPOI | C | 1 | `'S'`=Sepelio, `'T'`=Traslado |
| COCHERIA | N | 6 | FK → COCHERIA.CODIGO |
| FERETRO | N | 6 | FK → ATAUD.CODIGO |
| FECHAEXUMA | D | 8 | Exhumation date |

Composite PK: (CODIGO, NIVEL, SUBNIVEL) — VERIFIED from composite index.  
Indexes: `SubNiv1` on `Codigo`; `SubNiv2` on `Codigo+Str(Nivel,1)+Str(SubNivel,1)` (`MENU.PRG:3972, 3975`).

---

### 1.20 SUPLENTE — Alternate titleholders
**VERIFIED** (header; `MENU.PRG:3999`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| RESERVA | N | 6 | FK → reserva.RESERVA |
| SUPLENTE | N | 3 | Alternate sequence number |
| TITULAR | C | 25 | Name |
| DOMICILIO | C | 25 | |
| BARRIO | C | 25 | |
| LOCALIDAD | C | 15 | |
| PROVINCIA | N | 6 | FK → PROVINCI.CODIGO |
| CPOSTAL | N | 6 | |
| TDOC | C | 3 | Document type |
| DOCUMENTO | N | 8 | |
| TELEFONO | C | 12 | |

Index: `Suple1.Ntx` on `Reserva` (`MENU.PRG:4001`).  
Populated via `AxSupl` temp table during reservation creation (`MENU.PRG:3237, 3245`).

---

### 1.21 titular — Parcel titleholder
**VERIFIED** (header; `MENU.PRG:4085`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| CODIGO | C | 7 | FK → parquenu.CODIGO |
| RESERVA | N | 10 | FK → reserva.RESERVA |
| NOMBRE | C | 40 | |
| DOMICILIO | C | 50 | |
| BARRIO | C | 25 | |
| LOCALIDAD | C | 30 | |
| PROVINCIA | N | 6 | FK → PROVINCI.CODIGO |
| CPOSTAL | N | 6 | |
| TDOC | C | 3 | |
| DOCUMENTO | N | 8 | |
| TELEFONO | C | 15 | |

Index: `Titular.Ntx` on `Codigo` (`MENU.PRG:4087`).  
Written by `GrabaTitular()` at `MENU.PRG:3410–3426`.

---

### 1.22 VALOREXP — Expense fee table
**VERIFIED** (header; `MENU.PRG:4075`)

| Field | Type | Width | Notes |
|-------|------|-------|-------|
| VIGENCIA | D | 8 | Effective date |
| VALOREXPEN | N | 9,2 | Expense fee amount |
| HORA | C | 8 | Time of last update |
| USUARIO | C | 15 | User who set the value |

No index (`ValorExp` opened with no index at `MENU.PRG:4075`).  
`GrabaExpCta()` explicitly calls `ValorExp->(DbGoBottom())` before reading — VERIFIED bottom-record access (`MENU.PRG:3011`).  
`GrabaReserva()` reads `ValorExp->ValorExpen` without `DbGoBottom()` — which record is read is INFERRED/UNKNOWN (`MENU.PRG:3431`).

---

## 2. Runtime-Only Virtual Tables (No Workspace DBF)

These tables are created and managed at runtime. Schemas are INFERRED from REPLACE write patterns only.

| Alias | Pattern | Inferred Key Fields | Purpose |
|-------|---------|-------------------|---------|
| AuxLiq | `AuxLiq&Puesto.` | Reserva, Ano, Mes, Cuota | Batch liquidation work area (ZAPped per reservation) |
| Auxiliar | `Auxi&Puesto.` | Cantidad, Importe | Payment accumulator |
| AuxiRes | `Aux&Puesto.` | Reserva, Recibo, Nombre, Bonifica, Importe, FechaPago, Cobrador | Payment batch staging |
| AxSupl | `AxSup&Puesto.` | Titular, Reserva, Suplente + full address block | Suplente staging during reservation creation |
| AxPl | `AxPl&Puesto.` | Cuotas, Precio, Desde | Installment plan staging |
| ResuCta | `ResuCta` (shared) | Reserva, Total, Minimo, Vence, Adeuda, Pagado | Expense summary per reservation |
| ExpCta | `ExpCta` (shared) | Reserva, Bonifica, Importe, Acuenta, Fecha, Comprobant, Cobrador, Mes, Anio | Expense payment receipts |
| ImpCob | `ImpCob` (Puesto='26' only) | Reserva, Nombre, Domicilio, Barrio, Alta, Credito, Importe, PagCta, DebCta, Total | Cobrador report staging |
| ImpMut | `ImpMut` (Puesto='26' only) | Reserva, Nombre, LugT, Legajo, Expensa, Cuota, Total | Mutual report staging |
| AuxParq, Recexpe, Pexpensa, Bisiesto | Various | Partial only | Supporting lookup/temp tables |

---

## 3. Logical Relationship Map

> **Diagram legend**
> - All relationships are **application-enforced only**. DBF/NTX provides no PK, FK, or UNIQUE constraints at the storage level.
> - `PK*` = logical/candidate key (indexed for seek; uniqueness not storage-enforced unless stated)
> - `1:1 (logical)` = at most one row expected by the application design; not enforced by storage
> - `1:N` = one-to-many; cardinality derived from code write patterns
> - `? rows` = multiplicity UNKNOWN from static analysis

```
PROVINCI ─────────────────────────────────────────────────────────────────┐
  CODIGO (PK*)                                                              │ FK (PROVINCIA)
                                                                            │
mutual ────────────────────────────────────────────────────┐               │
  ASOCIACION (PK*)                                         │ FK (MUTUAL)    │
                                                           │               │
PROMOTOR ─────────────────────────────────────────────┐   │               │
  PROMOTOR (PK*)                                       │FK │               │
                                                       │   │               │
cobrador ───────────────────────────────────────┐      │   │               │
  COBRADOR (PK*)                                │FK    │FK │               │
                                                │      │   │               │
                                 AREAS ─────────┼──────┘   │               │
                                                │          │               │
reserva ◄───────────────────────────────────────┘ COBRADOR │               │
  RESERVA (PK*)─────────────────────────────────── MUTUAL ─┘               │
  CODBAJA ───────────────────────────────────────────────── ► BAJA.CODIGO  │
  AREA ──────────────────────────────────────────────────── ► AREAS.AREA   │
  EXPENSA ──────────────────────────────────── from VALOREXP.VALOREXPEN    │
  PROVINCIA (data entry) ──────────────────────────────────────────────────┘
      │
      ├── 1:N ──► CTACTE (RESERVA + CUOTA = installment plan rows)
      │               │
      │               └── ? rows ──► RECIBO per (RESERVA,CUOTA)
      │                              [uniqueness UNKNOWN; partial-payment
      │                               paths may append multiple rows —
      │                               see GrabaCuoCta() MENU.PRG:2846–2925]
      │
      ├── 1:N ──► ctaexp  (RESERVA + ANO + MES = monthly dues schedule)
      ├── 1:N ──► SUPLENTE (RESERVA = alternate titleholders)
      ├── 1:1 (logical) ──► ResuCta [virtual] (RESERVA = expense summary;
      │                               one row expected per active reservation;
      │                               not storage-enforced)
      │
      └── 1:1 (logical) ──► parquenu (RESERVA ↔ CODIGO = plot assignment;
                              at most one plot per reservation per design;
                              not storage-enforced)
                      │
                      ├── 1:N ──► SUBNIVEL (CODIGO = interments per plot)
                      │               │
                      │               ├──► COCHERIA.CODIGO (funeral home)
                      │               └──► ATAUD.CODIGO    (coffin)
                      │
                      └── 1:N ──► titular (CODIGO; up to 3 via CanTit check
                                   at MENU.PRG:3495; not storage-enforced)
```

---

## 4. Schema Inconsistencies

| # | Inconsistency | Severity | Note |
|---|--------------|----------|------|
| 4.1 | `ctaexp.COBRADOR` N(2) vs `cobrador.COBRADOR` N(6) | MEDIUM | Truncation risk for cobrador codes > 99 (`MENU.PRG:3045`) |
| 4.2 | `parquenu.DOCUMENTOB` N(19,4) vs all other DOCUMENTO N(8) | LOW | Anomalous decimal on document number in titleholder-B block |
| 4.3 | `reserva.COBRADOR` N(11) vs `cobrador.COBRADOR` N(6) | LOW | FK wider than PK; no functional impact at current scale |
| 4.4 | `reserva.MUTUAL` N(8) vs `mutual.ASOCIACION` N(6) | LOW | Same pattern as 4.3 |
| 4.5 | `CTACTE.RESERVA` and `CTACTE.CUOTA` N(19,5) for integer values | LOW | Oversized fields; INFERRED to hold integers only |
| 4.6 | `MAEASO.DBF` not opened in any PRG | INFO | INFERRED obsolete predecessor to mutual |
| 4.7 | `reserva.PARCELA` C(9) not written by `GrabaReserva()` | LOW | May be populated by missing code path |
| 4.8 | `ctaexp.COBRADOR` N(2) — `Recib3.Ntx` uses `StrZero(Cobrador,6)` | MEDIUM | Silent precision loss if cobrador code > 99 ever entered |

---

## 5. UNKNOWN Items

| Item | Status |
|------|--------|
| `bancos.dbf` role | UNKNOWN — Visual FoxPro format; not opened by any PRG |
| `MAEASO.DBF` purpose | UNKNOWN — not opened by any PRG |
| `RENA.DBF` write path | UNKNOWN — no direct `Use Rena` found |
| `FILTRO.DBF` active usage | UNKNOWN — not in `OpenDbf()` |
| All virtual/runtime table schemas | INFERRED from write patterns only |
| `Bisiesto` table completeness | UNKNOWN |
| `RECIBO` uniqueness per (Reserva,Cuota) | UNKNOWN — multiple rows per (Reserva,Cuota) are possible under partial-payment paths in `GrabaCuoCta()` (`MENU.PRG:2846–2925`); 1:1 cannot be assumed |
| `reserva.PARCELA` population path | UNKNOWN |
| `cobrador.COMISIONC` purpose | UNKNOWN — not referenced in any seek or replace |

---

## 6. Synthetic Data Statement

All schemas were derived from binary DBF header parsing and PRG write-pattern analysis. The 22 DBF files contain 45 fully synthetic demo records only (reservation IDs 900001–900003; parcel IDs D010101, D010102, D020101). No production data, real names, financial values, or credentials were accessed or reproduced.

---

*End of OTN-25 Data Model document*
