# Source Inventory Report

**Task ID:** OTN-20
**Persona:** source-inventory
**Date:** 2026-08-28
**Status:** COMPLETE

---

## 1. Scope and Files Inspected

All 25 PRG files in the workspace root were read in full. No files were modified.

| # | File | Size category | Role |
|---|------|--------------|------|
| 1 | `MENU.PRG` | Very large (4131 lines) | Primary entry point / main program |
| 2 | `MENU1.PRG` | Very large (4131 lines) | Historical variant of MENU.PRG |
| 3 | `COBRA.PRG` | Medium (158 lines) | Standalone payment processing |
| 4 | `LIQUIDA.PRG` | Medium (135 lines) | Standalone expense liquidation |
| 5 | `INFORME.PRG` | Small (~144 lines) | Burial statistics / reporting |
| 6 | `BANCODIS.PRG` | Small (~90 lines) | Bank disbursement printout utility |
| 7 | `ARMAPAR.PRG` | Small (~30 lines) | Parcel setup/population utility |
| 8 | `ANA2.PRG` | Tiny (~13 lines) | Historical analysis: counts by year |
| 9 | `ANA.PRG` | Small (~32 lines) | Historical analysis: BaseP population |
| 10 | `BORRA.PRG` | Tiny (~5 lines) | Conditional bulk-delete utility: `DELE ALL FOR recno()>246260` then PACK on CtaExp |
| 11 | `CTACTE.PRG` | Tiny (~8 lines) | Utility: open CtaCte, index, Browse |
| 12 | `RESUCTA.PRG` | Tiny (~4 lines) | Utility: open ResuCta, Browse |
| 13 | `VALOR.PRG` | Tiny (~5 lines) | Utility: open ValorExp, Browse |
| 14 | `RECIBO.PRG` | Tiny (~6 lines) | Utility: open Recibo, Browse, Pack |
| 15 | `RESERVA.PRG` | Tiny (~8 lines) | Conditional year-correction utility: `REPLACE ALL ult_mes WITH 1 FOR ult_ano=1900`, `REPLACE ALL ult_ano WITH 2000 FOR ult_ano=1900`, then Browse, then PACK on Reserva |
| 16 | `PASANO.PRG` | Small (~25 lines) | Utility: year-correction migration on Parquenu→Reserva |
| 17 | `VERCTA.PRG` | Tiny (~5 lines) | Utility: open CtaCte index Ctact1, Browse |
| 18 | `AGRGA.PRG` | Tiny (~3 lines) | One-off year-correction utility: `REPLACE ALL ano WITH ano+1900` in CtaExp (no PACK) |
| 19 | `CCTA.PRG` | Small (~36 lines) | Utility: populate CtaExp from PExpensa |
| 20 | `CARVALOR.PRG` | Tiny (~3 lines) | One-off rate-correction utility: `REPLACE ALL Expensa WITH 13` in Reserva |
| 21 | `CARGACOB.PRG` | Small (~22 lines) | Utility: copy Cobrador field from Reserva→ParqueNu |
| 22 | `CTA01.PRG` | Tiny (~6 lines) | Date-scoped cleanup utility: `DELE ALL FOR mes=12 .and. ano=1999`, then `DELE ALL FOR ano=2000`, then PACK — CtaExp |
| 23 | `REPL.PRG` | Tiny (~5 lines) | One-off field-reset utility: `REPLACE ALL Expensa WITH 10`, `Ult_Mes WITH 2`, `ult_ano WITH 1999` on Reserva |
| 24 | `CAMBIO.PRG` | Small (~35 lines) | Utility: copy address fields from ParqueNu→Reserva |
| 25 | `cpzero.prg` | Medium (~190 lines) | Third-party FoxPro codepage utility (NOT Clipper) |

---

## 2. Entry Points

### VERIFIED

**`MENU.PRG` — lines 1–21** is the primary application entry point. Its top-level code (not inside any function) executes this sequence:

1. Sets eight `Public` color-scheme variables (lines 2–8)
2. Sets `Public EmpNom` and `EmpDir` (company name/address, lines 9–10)
3. `Public Puesto:=GetEnv('Puesto')` — reads workstation ID from environment (line 11)
4. Calls `AbreSet()` — a library function (not defined in any PRG) to configure settings (line 13)
5. Calls `Fondo()` — paints the background screen (line 14)
6. Calls `OpenDbf()` — opens all databases and creates/sets all indexes (line 15)
7. Calls `MenuPrincipal()` — enters the main menu loop (line 16)
8. On exit: `UltTecla(0)`, `DbCloseAll()`, `SalNic(EmpNom,EmpDir)` (lines 18–20)

**`MENU1.PRG`** — shares the same top-level sequence (lines 1–21) and function names as MENU.PRG but is a **historical variant**, not a verified identical duplicate. Confirmed behavioral/configuration differences (see Section 3 below). Used for comparison only per AGENTS.md.

**`COBRA.PRG` — lines 1–6** is a standalone entry point for a payment-collection run. Top-level: calls `AbreSet()`, `AbreDbf()`, then `Reserva->(Cobranza())`.

**`LIQUIDA.PRG` — lines 1–8** is a standalone entry point for batch expense liquidation. Top-level: sets `Mes_Liq`, `Ano_Liq`, `FechaVence` as Private, calls `AbreSet()`, `AbreDbf()`, then `Reserva->(Nucleo())`.

**`INFORME.PRG`** — no top-level entry block; the file begins directly with `Function Inhumacion`. INFERRED: it is loaded/called as a library by MENU.PRG (Inhumacion is called in MENU.PRG Consultas menu, line 1010).

**Small utilities** (`BORRA.PRG`, `CTACTE.PRG`, `RESUCTA.PRG`, `VALOR.PRG`, `RECIBO.PRG`, `RESERVA.PRG`, `PASANO.PRG`, `VERCTA.PRG`, `AGRGA.PRG`, `CCTA.PRG`, `CARVALOR.PRG`, `CARGACOB.PRG`, `CTA01.PRG`, `REPL.PRG`, `CAMBIO.PRG`, `ARMAPAR.PRG`, `ANA.PRG`, `ANA2.PRG`, `BANCODIS.PRG`) all have top-level code that runs directly when invoked. They are standalone administrative/maintenance scripts.

**`cpzero.prg`** — a FoxPro-dialect utility (uses `PARAMETER`, `#DEFINE`, `PROCEDURE`, `DO...WITH` FoxPro syntax). INFERRED: was not part of the original Clipper application; it was added as a file-management tool to reset DBF codepage flags. It is NOT compatible with the Clipper compiler.

---

## 3. VERIFIED: Function and Procedure Definitions

### MENU.PRG (primary — 87 functions/procedures defined)

| Function/Procedure | Start Line | Modifier |
|---|---|---|
| `Contrasenia` | 23 | Function |
| `Fondo` | 70 | Static Function |
| `MenuPrincipal` | 91 | Function |
| `BoxSofi` | 146 | Function |
| `MenuIngresos` | 162 | Function |
| `MenuOperaciones` | 191 | Function |
| `AltaInhu` | 246 | Function |
| `CargaSub` | 308 | Function |
| `MenuListados` | 363 | Function |
| `LCobGen` | 397 | Function |
| `LCobCob` | 445 | Function |
| `TakeRec` | 505 | Function |
| `ListaCob` | 528 | Function |
| `ListaMut` | 551 | Function |
| `DisExpensa` | 577 | Function |
| `ImpriDis` | 616 | Function |
| `Cabecera` | 653 | Function |
| `PonExpensa` | 661 | Function |
| `PutExpensa` | 695 | Function |
| `TraeCredito` | 739 | Function |
| `Imprix` | 752 | Function |
| `ImpriM` | 786 | Function |
| `TraeDM` | 822 | Function |
| `TraeDR` | 836 | Function |
| `N_ucleo` | 849 | Function |
| `Nucleo` | 889 | Function |
| `Liquidacion` | 908 | Function |
| `CargaDeta` | 951 | Function |
| `CargaLiq` | 959 | Function |
| `TraeMesAde` | 978 | Function |
| `MenuConsultas` | 987 | Function |
| `Superficie` | 1026 | Function |
| `Porcentajes` | 1214 | Function |
| `Niveles` | 1251 | Function |
| `FunFede1` | 1334 | Function |
| `FunFede2` | 1447 | Function |
| `FunFede3` | 1562 | Function |
| `FunUsuario` | 1678 | Function |
| `BuscaNivel` | 1707 | Function |
| `Parcelas` | 1796 | Function |
| `Reservas` | 1904 | Function |
| `FunDaniel` | 1996 | Function |
| `FunPato` | 2028 | Function |
| `FunDeuda` | 2061 | Function |
| `BuscaDatos` | 2083 | Function |
| `BuscaRecibo` | 2140 | Function |
| `BuscaParque` | 2214 | Function |
| `CuotaExpensa` | 2229 | Function |
| `BuscaExpensa` | 2306 | Function |
| `FunGustavo` | 2361 | Function |
| `Inhumacion` | 2369 | Function |
| `Listado` | 2486 | Function |
| `CobroCuotas` | 2515 | Function |
| `CobroExpensas` | 2566 | Function |
| `CargaDatos` | 2618 | Function |
| `Busca_Rep` | 2695 | Function |
| `Muestra` | 2733 | Function |
| `Contesta` | 2760 | Static Function |
| `PasaDato` | 2794 | Function |
| `ListaControl` | 2810 | Function |
| `CargaCuoCta` | 2835 | Function |
| `GrabaCuoCta` | 2846 | Function |
| `CargaExpCta` | 2929 | Function |
| `Actualiza` | 2940 | Function |
| `GrabaExpCta` | 3008 | Function |
| `TraeNroRes` | 3053 | Function |
| `AltaReservas` | 3058 | Function |
| `CargaPlan` | 3256 | Function |
| `AuMes` | 3280 | Function |
| `Facturar` | 3291 | Function |
| `SumaMes` | 3367 | Function |
| `PasaCarga` | 3388 | Function |
| `GrabaTitular` | 3410 | Function |
| `GrabaReserva` | 3430 | Function |
| `GrabaParque` | 3451 | Function |
| `CargaParcela` | 3489 | Function |
| `StorParcela` | 3526 | Function |
| `CargaProvi` | 3631 | Function |
| `CargaMutual` | 3654 | Function |
| `CargaCobrador` | 3677 | Function |
| `CargaPromotor` | 3708 | Function |
| `CargaSuple` | 3732 | Function |
| `DatoSuple` | 3832 | Function |
| `OpenDbf` | 3850 | Function |
| `EnCurso` | 4094 | Function |
| `ReadOn` | 4119 | Static Function |
| `VerMensaje` | 4125 | Static Function |

### MENU1.PRG — Historical variant of MENU.PRG (~4131 lines)

MENU1.PRG is a historical variant of MENU.PRG (both 4131 lines under workspace line parsing). It shares the same function name set and the same top-level startup sequence, but **is not an identical duplicate**. Confirmed behavioral differences:

- **`OpenDbf()` line 3854:** MENU1.PRG tests `If Puesto='01'` before opening `ImpCob`/`ImpMut` exclusively; MENU.PRG tests `If Puesto='26'` at the same location. The exclusive-print-station assignment differs between the two versions.
- **`ImpriM()` lines 795–817 (MENU1) vs 795–817 (MENU.PRG):** Column-format widths in the mutual report differ. MENU1 uses `Transform(Expensa,'99999.99')`, `Transform(Cuota,'99999.99')`, `Transform(Total,'999999.99')` with wider fields; MENU.PRG uses `Transform(Expensa,'999.99')`, `Transform(Cuota,'999.99')`, `Transform(Total,'9999.99')`. The PadL column alignment values also differ (75 vs 73).

All function names in MENU1.PRG duplicate MENU.PRG names — see Section 6 (Duplicates).

### COBRA.PRG

| Function | Start Line |
|---|---|
| `Cobranza` | 8 |
| `Descarga` | 41 |
| `AbreDbf` | 130 |

### LIQUIDA.PRG

| Function | Start Line |
|---|---|
| `Nucleo` | 10 |
| `Liquidacion` | 25 |
| `CargaDeta` | 74 |
| `CargaLiq` | 82 |
| `TraeMesAde` | 100 |
| `AbreDbf` | 109 |

### INFORME.PRG

| Function | Start Line |
|---|---|
| `Inhumacion` | 2 |
| `Listado` | 112 |

### BANCODIS.PRG

| Function | Start Line |
|---|---|
| `Cabecera` | 82 |

### CCTA.PRG

| Function | Start Line |
|---|---|
| `Carga` | 28 |

### cpzero.prg (FoxPro, non-Clipper)

| Procedure | Start Line |
|---|---|
| `setup` | 55 |
| `cleanup` | 60 |
| `main` | 67 |
| `errormsg` | 187 |

### All Other Small PRGs

No FUNCTION or PROCEDURE definitions. All code is top-level sequential statements.

---

## 4. VERIFIED: Duplicate Function/Procedure Names

| Name | Files | Notes |
|---|---|---|
| `Nucleo` | MENU.PRG (line 889), LIQUIDA.PRG (line 10), MENU1.PRG | MENU.PRG and MENU1.PRG versions are nearly identical. LIQUIDA.PRG version is a simpler standalone batch version with different signature (4-arg Liquidacion vs 5-arg). |
| `Liquidacion` | MENU.PRG (line 908), LIQUIDA.PRG (line 25), MENU1.PRG | MENU.PRG takes 5 args including `FechaVence`; LIQUIDA.PRG takes 4 args. Different behavior. |
| `CargaDeta` | MENU.PRG (line 951), LIQUIDA.PRG (line 74), MENU1.PRG | Nearly identical in all three. |
| `CargaLiq` | MENU.PRG (line 959), LIQUIDA.PRG (line 82), MENU1.PRG | Differ: MENU.PRG version computes `xMinimo` using `Reserva->Expensa`; LIQUIDA.PRG has simpler minimum calculation. |
| `TraeMesAde` | MENU.PRG (line 978), LIQUIDA.PRG (line 100), MENU1.PRG | Identical. |
| `AbreDbf` | COBRA.PRG (line 130), LIQUIDA.PRG (line 109) | Both open similar sets of tables; LIQUIDA.PRG omits `AuxLiq01` alias. |
| `Inhumacion` | MENU.PRG (line 2369), INFORME.PRG (line 2) | Different implementations; MENU.PRG version uses Private variables and different counting logic; INFORME.PRG references `Parque` alias instead of `ParqueNu`. |
| `Listado` | MENU.PRG (line 2486), INFORME.PRG (line 112) | INFORME.PRG version is a simpler Public Vec; MENU.PRG version uses Local Vec and different output labels. |
| `Cabecera` | MENU.PRG (line 653), BANCODIS.PRG (line 82) | Different implementations printing different headers. |
| All MENU1.PRG functions | MENU.PRG | Historical variant (~4131 lines). Same function names as MENU.PRG but confirmed behavioral differences in `OpenDbf()` (Puesto='01' vs '26') and `ImpriM()` column widths. |

---

## 5. VERIFIED: DBF Aliases Opened (USE statements)

### MENU.PRG — OpenDbf() function (lines 3850–4092)

This is the canonical database-open routine for the live application:

| Alias | DBF File | Puesto-conditional | Notes |
|---|---|---|---|
| `ImpCob` | `ImpCob` | Yes (Puesto='26' only) | Exclusive; indexed on Barrio+Domicilio |
| `ImpMut` | `ImpMut` | Yes (Puesto='26' only) | Exclusive; indexed on Nombre |
| `CtaExp` | `CtaExp` | No | Shared; 2 indexes |
| `Reserva` | `Reserva` | No | Shared; 4 indexes |
| `ResuCta` | `ResuCta` | No | Shared; 1 index |
| `AuxLiq` | `AuxLiq&Puesto.` | No | **Dynamic macro** — alias depends on `Puesto` env variable |
| `Recibo` | `Recibo` | No | Shared; 4 indexes |
| `CtaCte` | `CtaCte` | No | Shared; 2 indexes |
| `Baja` | `Baja` | No | Shared; 1 index |
| `ParqueNu` | `ParqueNu` | No | Shared; 6 indexes |
| `Recexpe` | `Recexpe` | No | Shared; 1 index |
| `Pexpensa` | `Pexpensa` | No | Shared; 1 index |
| `SubNivel` | `SubNivel` | No | Shared; 2 indexes |
| `Ataud` | `Ataud` | No | Shared; 1 index |
| `Auxiliar` | `Auxi&Puesto.` | No | **Dynamic macro** — exclusive |
| `Cocheria` | `Cocheria` | No | Shared; 1 index |
| `Suplente` | `Suplente` | No | Shared; 1 index |
| `AxSupl` | `AxSup&Puesto.` | No | **Dynamic macro** — exclusive |
| `Mutual` | `Mutual` | No | Shared; 1 index |
| `Cobrador` | `Cobrador` | No | Shared; 2 indexes |
| `Promotor` | `Promotor` | No | Shared; 2 indexes |
| `Provinci` | `Provinci` | No | Shared; 1 index |
| `AuxiRes` | `Aux&Puesto.` | No | **Dynamic macro** — exclusive |
| `ExpCta` | `ExpCta` | No | Shared; 4 indexes |
| `AuxParq` | `AuxParq` | No | Shared; 1 index |
| `ValorExp` | `ValorExp` | No | Shared; no index |
| `Bisiesto` | `Bisiesto` | No | Shared; 1 index |
| `Titular` | `Titular` | No | Shared; 1 index |

**Total: 28 distinct aliases opened in OpenDbf()**

### Additional Dynamic Aliases Opened During Runtime (MENU.PRG functions)

| Alias | DBF Pattern | Location | Risk |
|---|---|---|---|
| `AxMutu` | `Imp&xGrupo` (e.g. Imp002) | `DisExpensa()` line 582 | **UNKNOWN** — table name depends on Mutual->Grupo value |
| `AxPl&Puesto.` | `AxPl<Puesto>` | `CargaPlan()` line 3258, `Facturar()` lines 3298, 3318, 3350 | **UNKNOWN** — multiple tables per workstation |

### COBRA.PRG — AbreDbf() (lines 130–157)

| Alias | DBF File |
|---|---|
| `CtaExp` | `CtaExp` |
| `ResuCta` | `ResuCta` |
| `Reserva` | `Reserva` |
| `AuxLiq` | `AuxLiq01` |

### LIQUIDA.PRG — AbreDbf() (lines 109–135)

| Alias | DBF File |
|---|---|
| `CtaExp` | `CtaExp` |
| `ResuCta` | `ResuCta` |
| `Reserva` | `Reserva` |
| `AuxLiq` | `AuxLiq01` |

### INFORME.PRG (uses Parque, not ParqueNu)

| Alias | DBF File | Notes |
|---|---|---|
| `Parque` | `Parque` (not `ParqueNu`) | Line 39 — INCONSISTENCY vs MENU.PRG which uses `ParqueNu` |

### BANCODIS.PRG

| Alias | DBF Pattern | Notes |
|---|---|---|
| `Mary` | `Imp&xGrupo.` (e.g. Imp002) | Dynamic macro — same pattern as DisExpensa |
| `Titular` | `Titular.Sn` | `.Sn` extension — different DBF than MENU.PRG's `Titular` |
| `Respon` | `Respon.Sn` | `.Sn` extension — **UNKNOWN** alias not opened in MENU.PRG |
| `Auxi01` | `Auxi01.Sn` | `.Sn` extension — **UNKNOWN** alias not opened in MENU.PRG |

### Other Small Utilities

| File | Alias | DBF |
|---|---|---|
| `ANA.PRG` | `BaseP` | `BaseP` (Exclusive, Zap) |
| `ANA.PRG` | `ParqueNu` | `ParqueNu` |
| `ANA.PRG` | `SubNivel` | `SubNivel` |
| `ANA2.PRG` | *(default)* | `BaseP` |
| `BORRA.PRG` | *(default)* | `ctaexp` |
| `CTACTE.PRG` | *(default)* | `CtaCte` |
| `RESUCTA.PRG` | *(default)* | `ResuCta` |
| `VALOR.PRG` | *(default)* | `ValorExp` |
| `RECIBO.PRG` | *(default)* | `Recibo` |
| `RESERVA.PRG` | *(default)* | `Reserva` |
| `PASANO.PRG` | `Parquenu` | `Parquenu` |
| `PASANO.PRG` | *(default)* | `Reserva` |
| `VERCTA.PRG` | *(default)* | `CtaCte` |
| `AGRGA.PRG` | *(default)* | `CtaExp` |
| `CCTA.PRG` | *(default)* | `CtaExp` |
| `CCTA.PRG` | *(default)* | `PExpensa` (line 7) |
| `CARVALOR.PRG` | *(default)* | `Reserva` |
| `CARGACOB.PRG` | `ParqueNu` | `ParqueNu` |
| `CARGACOB.PRG` | *(default)* | `Reserva` |
| `CTA01.PRG` | *(default)* | `CtaExp` |
| `REPL.PRG` | *(default)* | `Reserva` |
| `CAMBIO.PRG` | *(default)* | `ParqueNu` |
| `CAMBIO.PRG` | `Reserva` | `Reserva` |
| `ARMAPAR.PRG` | *(default)* | `ParqueNu` (Exclusive) |

---

## 6. VERIFIED: Index Definitions

### MENU.PRG — OpenDbf() (lines 3850–4092)

All indexes are `.NTX` format (Clipper native). Created on-demand if file not present.

| DBF | NTX File | Key Expression | Order# |
|---|---|---|---|
| `ImpCob` | `ImpCob` | `Barrio+Domicilio` | 1 |
| `ImpMut` | `ImpMut` | `Nombre` | 1 |
| `CtaExp` | `CtaExp` | `Reserva` | 1 |
| `CtaExp` | `CtaExp2` | `StrZero(Reserva,6)+StrZero(Ano,4)+StrZero(Mes,2)` | 2 |
| `Reserva` | `Reser1` | `Reserva` | 1 |
| `Reserva` | `Reser2` | `Nombre` | 2 |
| `Reserva` | `Reser3` | `Cobrador` | 3 |
| `Reserva` | `Reser4` | `Mutual` | 4 |
| `ResuCta` | `ResuCta` | `Reserva` | 1 |
| `Recibo` | `Recib1` | `StrZero(Reserva,6)+StrZero(Cuota,4)` | 1 |
| `Recibo` | `Recib2` | `Reserva` | 2 |
| `Recibo` | `Recib3` | `StrZero(Cobrador,6)+DtoC(Fecha)` | 3 |
| `Recibo` | `Recib4` | `DtoC(Fecha)` | 4 |
| `CtaCte` | `CtaCt1` | `Reserva` | 1 |
| `CtaCte` | `CtaCt2` | `StrZero(Reserva,6)+StrZero(Cuota,4)` | 2 |
| `Baja` | `Baja1` | `Codigo` | 1 |
| `ParqueNu` | `Parque1` | `Reserva` | 1 |
| `ParqueNu` | `Parque2` | `Codigo` | 2 |
| `ParqueNu` | `Parque3` | `Nombre` | 3 |
| `ParqueNu` | `Parque4` | `Documento` | 4 |
| `ParqueNu` | `Parque5` | `Sector+Str(Fila,2)+Str(Parcela,2)` | 5 |
| `ParqueNu` | `Parque6` | `Cobrador` | 6 |
| `Recexpe` | `Recex1` | `Codigo+StrZero(Mes,2)+Str(Anio,2)` | 1 |
| `Pexpensa` | `Pexpe1` | `Codigo` | 1 |
| `SubNivel` | `SubNiv1` | `Codigo` | 1 |
| `SubNivel` | `SubNiv2` | `Codigo+Str(Nivel,1)+Str(SubNivel,1)` | 2 |
| `Ataud` | `Ataud1` | `Codigo` | 1 |
| `Auxiliar` | `Auxi&Puesto.` | `Importe` | 1 |
| `Cocheria` | `Coche1` | `Codigo` | 1 |
| `Suplente` | `Suple1` | `Reserva` | 1 |
| `AxSupl` | `AxSup&Puesto.` | `Reserva` | 1 |
| `Mutual` | `Mutual` | `Asociacion` | 1 |
| `Cobrador` | `Cobra1` | `Cobrador` | 1 |
| `Cobrador` | `Cobra2` | `Nombre` | 2 |
| `Promotor` | `Promot1` | `Promotor` | 1 |
| `Promotor` | `Promot2` | `Nombre` | 2 |
| `Provinci` | `Prov1` | `Codigo` | 1 |
| `AuxiRes` | `AuxiRes` | `Reserva` | 1 |
| `ExpCta` | `ExpCta1` | `Fecha` | 1 |
| `ExpCta` | `ExpCta2` | `StrZero(Reserva,6)+StrZero(Anio,4)+StrZero(Mes,2)` | 2 (Descending) |
| `ExpCta` | `ExpCta3` | `StrZero(Cobrador,6)+DtoC(Fecha)` | 3 |
| `ExpCta` | `ExpCta4` | `DtoC(Fecha)` | 4 |
| `AuxParq` | `AuxParq1` | `Reserva` | 1 |
| `Bisiesto` | `Bisiesto` | `Ano` | 1 |
| `Titular` | `Titular` | `Codigo` | 1 |

**Note:** `AuxLiq` has NO index in OpenDbf() — opened with `Use AuxLiq&Puesto. Alias AuxLiq New` (line 3898) without any Set Index. VERIFIED.

### COBRA.PRG / LIQUIDA.PRG — AbreDbf()

Both files define `AbreDbf()` with near-identical CDX/NTX creation for CtaExp, ResuCta, Reserva. COBRA.PRG also creates `Reser3` and `Reser4`.

### CTACTE.PRG (line 4)

`Index On Reserva to oooo` — creates a temporary index named `oooo`. Destructive index creation not guarded by `File()` check.

### PASANO.PRG (line 5)

`Set index to pppp` — uses an index named `pppp` without creating it first (the creation line is commented out). **RISK: will fail if pppp.ntx does not exist.**

### BANCODIS.PRG (lines 12, 15)

`Set Index to Tit3`, `Set Index to Respo1` — sets existing index files not created in this script.

---

## 7. VERIFIED: Cross-File Dependency Map

### PRG-to-Function Call Graph

Only documented where a clear DO or function-call to an external-defined name exists. The following **21 unresolved custom callable identifiers** are called in the workspace PRGs but are not defined in any PRG and are not standard Clipper/xBase runtime functions — their origin (compiled library or other external artifact) is UNKNOWN:

`AbreSet()`, `BoxFede()`, `MueveLet()`, `VerActiva()`, `Pass1()`, `AyuOnLine()`, `MChoice()`, `WinShowR()`, `Lev_Pan()`, `_Alpt()`, `_Clpt()`, `_Quest()`, `Con_Tes()`, `SalNic()`, `UltTecla()`, `TimeBar()`, `Oscurece()`, `Oscureze()`, `CMes()`, `_SBoxDS()`, `Hojear()`

`Oscurece()` and `Oscureze()` are two distinct unresolved identifiers in the source. Whether they are aliases, separate routines, or a historical spelling error is **UNKNOWN**.

> **Excluded from the unresolved list:**
> - `Contesta()` — VERIFIED as `Static Function` defined at `MENU.PRG:2760`.
> - `DbUnLock()` — standard Clipper/xBase runtime function; not a missing project implementation.
> - `DbSelectAr()` / `DbSelectArea()` — standard Clipper/xBase runtime function; not a missing project implementation.

| Caller PRG | Calls Function In | Function Name |
|---|---|---|
| `MENU.PRG` (line 15) | `MENU.PRG` | `OpenDbf()` |
| `MENU.PRG` (line 14) | `MENU.PRG` | `Fondo()` |
| `MENU.PRG` (line 16) | `MENU.PRG` | `MenuPrincipal()` |
| `MENU.PRG MenuPrincipal` | `MENU.PRG` | `MenuIngresos()`, `MenuOperaciones()`, `MenuConsultas()`, `BoxSofi()` |
| `MENU.PRG MenuIngresos` | `MENU.PRG` | `CobroExpensas()`, `CobroCuotas()` |
| `MENU.PRG MenuOperaciones` | `MENU.PRG` | `AltaInhu()`, `AltaReservas()`, `Nucleo()`, `N_ucleo()`, `MenuListados()`, `Hojear()` (UNKNOWN — not defined in any PRG) |
| `MENU.PRG MenuListados` | `MENU.PRG` | `ListaCob()`, `ListaMut()`, `LCobCob()`, `LCobGen()` |
| `MENU.PRG MenuConsultas` | `MENU.PRG` | `Inhumacion()`, `Parcelas()`, `Reservas()`, `CuotaExpensa()`, `Niveles()`, `Superficie()` |
| `MENU.PRG Inhumacion` | `MENU.PRG` | `Listado()` |
| `MENU.PRG AltaInhu` | `MENU.PRG` | `CargaSub()` (via SubNivel alias-call) |
| `MENU.PRG AltaReservas` | `MENU.PRG` | `TraeNroRes()`, `CargaParcela()`, `CargaMutual()`, `CargaCobrador()`, `CargaPromotor()`, `CargaProvi()`, `Facturar()`, `GrabaTitular()`, `GrabaReserva()`, `GrabaParque()`, `CargaSuple()`, `PasaCarga()`, `CargaPlan()` |
| `MENU.PRG CargaPlan` | `MENU.PRG` | `AuMes()` |
| `MENU.PRG Facturar` | `MENU.PRG` | `SumaMes()` |
| `MENU.PRG SumaMes` | `MENU.PRG` | Uses `Bisiesto->` |
| `MENU.PRG Nucleo` | `MENU.PRG` | `Liquidacion()` (via CtaExp alias) |
| `MENU.PRG Liquidacion` | `MENU.PRG` | `CargaDeta()` (via AuxLiq), `CargaLiq()` (via ResuCta) |
| `MENU.PRG CobroExpensas` | `MENU.PRG` | `CargaDatos()`, `CargaExpCta()` (via AuxiRes) |
| `MENU.PRG CobroCuotas` | `MENU.PRG` | `CargaDatos()`, `CargaCuoCta()` (via AuxiRes) |
| `MENU.PRG CargaDatos` | `MENU.PRG` | `PasaDato()`, `Busca_Rep()`, `ListaControl()` (via AuxiRes) |
| `MENU.PRG CargaCuoCta` | `MENU.PRG` | `GrabaCuoCta()` (via CtaCte) |
| `MENU.PRG CargaExpCta` | `MENU.PRG` | `GrabaExpCta()` (via ExpCta), `Actualiza()` (via CtaExp) |
| `MENU.PRG Reservas` | `MENU.PRG` | `BuscaParque()`, `BuscaDatos()`, `BuscaRecibo()`, `FunDaniel()`, `FunPato()`, `FunDeuda()` |
| `MENU.PRG CuotaExpensa` | `MENU.PRG` | `BuscaExpensa()` (via CtaExp), `FunGustavo()` |
| `MENU.PRG Niveles/Superficie` | `MENU.PRG` | `BuscaNivel()` (via SubNivel), `FunFede1()`, `FunFede2()`, `FunFede3()`, `Porcentajes()` |
| `MENU.PRG ListaMut` | `MENU.PRG` | `PonExpensa()` or `DisExpensa()` (via Reserva), `ImpriM()` (via ImpMut), `ImpriDis()` (via AxMutu) |
| `MENU.PRG ListaCob` | `MENU.PRG` | `PutExpensa()` (via Reserva), `Imprix()` (via ImpCob) |
| `MENU.PRG PonExpensa` | `MENU.PRG` | `TraeDM()` (via CtaCte) |
| `MENU.PRG LCobGen/LCobCob` | `MENU.PRG` | `TakeRec()` (via Recibo and ExpCta) |
| `COBRA.PRG` | `COBRA.PRG` | `Cobranza()`, `AbreDbf()`, `Descarga()` |
| `LIQUIDA.PRG` | `LIQUIDA.PRG` | `Nucleo()`, `AbreDbf()`, `Liquidacion()`, `CargaDeta()`, `CargaLiq()`, `TraeMesAde()` |
| `INFORME.PRG Inhumacion` | `INFORME.PRG` | `Listado()` |
| `ANA.PRG` | *(none)* | No internal function calls |
| `CCTA.PRG` | `CCTA.PRG` | `Carga()` |

---

## 8. VERIFIED: INCLUDE Directives

Only one `#include` (comment-style `///`) directive found across all files:

- `MENU.PRG` line 1: `///#Include "FTMENUTO.CH"`
- `MENU1.PRG` line 1: `///#Include "FTMENUTO.CH"`

Both are commented out with `///`. **The `FTMENUTO.CH` include file is missing from the workspace.** Its contents and relationship to the unresolved callable identifiers are **UNKNOWN**; it may have contained only declarations/macros or may have accompanied a separately compiled library.

`cpzero.prg` uses `#define` and `#DEFINE` FoxPro preprocessor directives (not Clipper).

---

## 9. UNKNOWN Items and Missing Dependencies

| Item | Category | Details |
|---|---|---|
| `FTMENUTO.CH` | Missing include | Referenced by MENU.PRG and MENU1.PRG line 1 (commented). Contents and original role are UNKNOWN. |
| `AbreSet()` | Missing function | Called in MENU.PRG (line 13), COBRA.PRG (line 3), LIQUIDA.PRG (line 5), and several utilities. Not defined in any PRG. Original container is UNKNOWN. |
| `BoxFede()` | Missing function | Extensive use throughout MENU.PRG. Not defined in any PRG. Likely in FTMENUTO library. |
| `MueveLet()` | Missing function | Error display function. Not defined in any PRG. |
| `VerActiva()` | Unresolved custom function | Record-lock function. Called before every DbAppend/Replace. Not defined in any workspace PRG. Origin UNKNOWN. |
| `Pass1()` | Unresolved custom function | Called in MENU.PRG line 233. Password check. Not defined in any workspace PRG. Origin UNKNOWN. |
| `AyuOnLine()` | Missing function | Context-sensitive help. Not defined in any PRG. |
| `MChoice()` | Missing function | Multi-choice display/print dialog. Not defined in any PRG. |
| `WinShowR()` | Missing function | Window rendering. Not defined in any PRG. |
| `Lev_Pan()` | Missing function | Panel display. Not defined in any PRG. |
| `_Alpt()` / `_Clpt()` | Missing functions | Printer open/close. Not defined in any PRG. |
| `_Quest()` | Missing function | Yes/No question dialog. Not defined in any PRG. |
| `Con_Tes()` | Missing function | Confirmation dialog. Not defined in any PRG. |
| `SalNic()` | Missing function | Exit/sign-off function. Not defined in any PRG. |
| `UltTecla()` | Missing function | Key-state function. Not defined in any PRG. |
| `TimeBar()` | Missing function | Progress bar. Not defined in any PRG. |
| `Oscurece()` / `Oscureze()` | Missing functions | Two distinct unresolved identifiers used for screen dimming in both MENU.PRG and MENU1.PRG; whether they are aliases or a spelling error is UNKNOWN. |
| `CMes()` | Missing function | Month name. Not defined in any PRG. |
| `_SBoxDS()` | Unresolved custom function | Save/restore box. Not defined in any workspace PRG. Origin UNKNOWN. |
| `Hojear()` | Unresolved custom function | Called in MenuOperaciones() for ParqueNu and Reserva alias-calls. Not defined in any workspace PRG. Origin UNKNOWN. |
| `Diskette` | UNKNOWN variable | Used in ListaMut (MENU.PRG line 568, MENU1.PRG line 568). Never declared or assigned in any visible PRG. Presumably set by a library or startup sequence. |
| `AuxLiq&Puesto.` | Dynamic alias | Exact table name depends on `Puesto` env variable (e.g. `AuxLiq01`, `AuxLiq02`). Workspace contains `AuxLiq01.DBF`. Other variants UNKNOWN. |
| `Auxi&Puesto.` | Dynamic alias | e.g. `Auxi01`, `Auxi26`. UNKNOWN range. |
| `AxSup&Puesto.` | Dynamic alias | e.g. `AxSup01`. UNKNOWN range. |
| `Aux&Puesto.` | Dynamic alias | e.g. `Aux01`. UNKNOWN range. |
| `AxPl&Puesto.` | Dynamic alias | e.g. `AxPl01`. Schema UNKNOWN. |
| `Imp&xGrupo` | Dynamic alias | e.g. `Imp002`. Schema UNKNOWN. |
| `ResuCta` alias | Runtime alias | Used in MENU.PRG without being opened in OpenDbf(). INFERRED: it IS opened (line 3891). Verified present in AbreDbf() of COBRA/LIQUIDA. |
| `AxParq` / `AuxParq` | Temp alias | Opened in OpenDbf() (AuxParq) but never written to in MENU.PRG. Purpose UNKNOWN. |
| `Recexpe` | DBF opened | Opened in OpenDbf() (line 3956) but no read/write references found in MENU.PRG code. Purpose UNKNOWN. |
| `Pexpensa` | DBF opened | Opened in OpenDbf() (line 3963) and in CCTA.PRG. Limited use. |
| `Bisiesto` | DBF opened | Used in SumaMes (MENU.PRG line 3376) as a leap-year lookup table. |
| `Parque` vs `ParqueNu` | Inconsistency | INFORME.PRG uses alias `Parque` (line 39); MENU.PRG uses `ParqueNu`. One may be an older table name. |
| `BaseP` | DBF | Used only in ANA.PRG and ANA2.PRG. Not opened in MENU.PRG. |
| `Titular.Sn`, `Respon.Sn`, `Auxi01.Sn` | DBF | Used in BANCODIS.PRG with `.Sn` extension. Different from workspace DBF files. UNKNOWN — possibly a different installation or network path. |

---

## 10. VERIFIED: Global/Public Variables (Cross-Procedure State)

The following `Public` variables are set at the top level of MENU.PRG and used throughout all functions:

| Variable | Set At | Purpose |
|---|---|---|
| `FonCol`, `CurCol`, `EmuCol`, `PelCol`, `MonCol`, `DanCol`, `Alegre` | MENU.PRG lines 2–8 | Color scheme strings used throughout all UI functions |
| `EmpNom` | MENU.PRG line 9 | Company name — used in all print headers |
| `EmpDir` | MENU.PRG line 10 | Company address — used in all print headers |
| `Puesto` | MENU.PRG line 11 | Workstation ID — controls which dynamic aliases are opened |
| `Vec` | Multiple functions | Shared print/display array — declared Public in menu functions |
| `xCobrador` | MENU.PRG `AltaReservas()`, `CargaCobrador()` | Public cross-function state |
| `xPromotor` | MENU.PRG `AltaReservas()`, `CargaPromotor()` | Public cross-function state |
| `xAsociacion` | MENU.PRG `AltaReservas()`, `CargaMutual()` | Public cross-function state |
| `xCodigo` | MENU.PRG `AltaReservas()` (Public line 3083) | Shared parcel code state |
| `xProvincia` | MENU.PRG `AltaReservas()` (Public line 3084) | Shared province state |

`Private` variables used across nested function calls (visible to callees):
- `Mes_Liq`, `Ano_Liq`, `FechaVence` — set in `Nucleo()`/`N_ucleo()`, read in `Liquidacion()` (MENU.PRG, LIQUIDA.PRG)
- `xAgencia` — declared Private in menu functions, purpose unclear
- `xReserva` — frequently declared Private in multiple menu functions

---

## 11. Inferred Findings

| Finding | Reasoning | Confidence |
|---|---|---|
| MENU.PRG is the canonical active version; MENU1.PRG is historical | They share identical structure. AGENTS.md states MENU1.PRG is "older historical version useful only for comparison." | HIGH |
| All small utility PRGs are one-time administrative scripts | They contain destructive operations (ZAP, PACK, REPLACE ALL) with no interactive safety. They do not call OpenDbf(). | HIGH |
| `FTMENUTO.CH` defined a TBrowse/Achoice-style menu library | The `///#Include` comments and extensive use of `BoxFede`, `WinShowR`, `AyuOnLine`, `MChoice` suggest a third-party UI library. | MEDIUM |
| `cpzero.prg` was never part of the Clipper application | FoxPro syntax (`PROCEDURE`, `DO...WITH`, `WAIT WINDOW`, `DIMENSION`, `&&` comments) is incompatible with Clipper. It was likely added as a DBF maintenance tool. | HIGH |
| `Diskette` variable controls diskette vs printer output path in ListaMut | Control flow at MENU.PRG line 568 branches on `Diskette`. Never assigned in source. Likely set by a library startup or configuration file. | MEDIUM |
| INFORME.PRG was intended to be compiled into the same executable as MENU.PRG | `Inhumacion` in MENU.PRG (line 2369) duplicates and supersedes the INFORME.PRG version. Both refer to `SubNivel` fields directly — consistent with being compiled together. | MEDIUM |

---

## 12. Conflicts With Other Reports

None expected at this stage (Phase 2 parallel analysis).

---

## 13. Risks and Recommended Next Action

| Risk | Severity | Description |
|---|---|---|
| Dynamic macro aliases (`&Puesto.`, `&xGrupo`) | HIGH | Table names depend on runtime environment variables. Static analysis cannot determine all opened tables. Modernization must enumerate all valid Puesto values and Grupo values. |
| Missing `FTMENUTO.CH` and callable implementations | HIGH | 21 callable identifiers used throughout the PRGs are unresolvable from source alone. Their implementations and any relationship to the missing include are UNKNOWN. |
| Duplicate Nucleo/Liquidacion between MENU.PRG and LIQUIDA.PRG | HIGH | The two implementations differ in minimum-calculation logic. LIQUIDA.PRG's `CargaLiq()` uses `If xMinimo>xTotal then xMinimo:=xTotal` (a guard); MENU.PRG's version does not. This is a behavioral difference. |
| Permanent bulk-operation scripts | HIGH | BORRA.PRG, CTA01.PRG, AGRGA.PRG, CARVALOR.PRG, REPL.PRG contain irreversible bulk operations. They must not be executed during analysis or migration testing. |
| `Parque` vs `ParqueNu` inconsistency | MEDIUM | INFORME.PRG references `Parque` alias; MENU.PRG uses `ParqueNu`. It is UNKNOWN whether both DBFs exist and whether they are the same table under different names. |
| `PASANO.PRG` missing index | MEDIUM | Uses `Set index to pppp` without creating `pppp.ntx`. Will fail at runtime if the file is absent. |
| Global `Public` variable state | MEDIUM | `EmpNom`, `EmpDir`, `Puesto`, `Vec`, and several `x*` variables are shared across all functions via Public/Private scope. This creates hidden dependencies between menu functions. |

**Recommended next actions:**
1. Proceed with `data-model` (OTN-21) to enumerate all DBF schemas and confirm the `Parque` vs `ParqueNu` inconsistency.
2. Proceed with `business-rules` (OTN-22) using MENU.PRG `Nucleo/Liquidacion/CobroCuotas/CobroExpensas` as primary targets.
3. During modernization design, treat all dynamic macro aliases as requiring a static configuration table.
4. Do not attempt to run any utility PRG (BORRA, REPL, CARVALOR, AGRGA, CTA01) in any environment.

---

## 14. Statement on Data Usage

All analysis in this report was performed exclusively on the 25 PRG source files located in the workspace root. No DBF records were read, no data values were extracted, and no synthetic or production data was used. All citations reference file names, line numbers, and code patterns only.

---

*End of OTN-20 Source Inventory Report*
