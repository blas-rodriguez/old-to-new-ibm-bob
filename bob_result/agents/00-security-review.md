# OTN-10 Security Review Report

**Task ID:** OTN-10  
**Persona:** security-reviewer  
**Date:** 2026-08-28 (workspace sanitization reference date per `README.md`)  
**Scope:** Entire shareable workspace — PRG sources, DBF records, metadata, configuration, persona files, and prior reports  

---

## 1. Scope and Files Inspected

| Category | Count | Files / Patterns |
|---|---|---|
| PRG source files | 25 | All root-level `*.PRG` / `*.prg` — read in full |
| DBF data files | 22 | All root-level `*.DBF` / `*.dbf` — read as text for record content |
| Configuration / metadata | 3 | `README.md`, `.gitignore`, `AGENTS.md` (structure only) |
| Persona definitions | 9 | All `.bob/agents/*.md` files — read in full |
| Prior agent reports | 1 | `bob_result/final/project-initialization.md` — read in full |
| Output directories | 4 | `bob_result/agents/`, `bob_result/diagrams/`, `bob_result/final/`, `bob_result/logs/` — enumerated |
| Archive / credential file scan | — | Glob patterns: `*.zip`, `*.bak`, `*.rar`, `*.7z`, `*.tar`, `*.gz`, `*.sql`, `*.mdb`, `*.accdb`, `*.exe`, `*.com`, `*.dll`, `*.obj`, `*.lib`, `*.env`, `*.key`, `*.pem`, `*.p12`, `*.pfx` |
| Index file scan | — | Patterns: `*.[Nn][Tt][Xx]`, `*.[Cc][Dd][Xx]` |

---

## 2. VERIFIED Findings

### 2.1 Sensitive Directories — Absent
**VERIFIED** — No `_resguardo_privado/`, `backup/`, `original/`, or `production/` directory is present. The `.gitignore` explicitly lists `_resguardo_privado/` as a gitignored private backup path, confirming the operator is aware of its risk and has excluded it. The directory itself is absent from the workspace.

### 2.2 Archive and Backup Files — Absent
**VERIFIED** — Glob scans for `.zip`, `.bak`, `.rar`, `.7z`, `.tar`, `.gz`, `.sql`, `.mdb`, `.accdb`, `*.exe`, `*.com`, `*.dll`, `*.obj`, `*.lib`, `*.env`, `*.key`, `*.pem`, `*.p12`, `*.pfx` returned zero results. No archives or credential files are present.

### 2.3 Index Files (NTX/CDX) — Absent
**VERIFIED** — Glob scan returned zero `.NTX` or `.CDX` files. The `.gitignore` patterns `*.[Nn][Tt][Xx]` and `*.[Cc][Dd][Xx]` are in place. `README.md` documents that `OpenDbf()` regenerates NTX files at runtime; their absence is expected and intentional.

### 2.4 DBF File Count — Matches Contract
**VERIFIED** — Exactly 22 root-level `*.DBF`/`*.dbf` files are present, matching the AGENTS.md contract.

### 2.5 PRG File Count — Matches Contract
**VERIFIED** — Exactly 25 root-level `*.PRG`/`*.prg` files are present, matching the AGENTS.md contract.

### 2.6 Demo Password `DEMO00` — Present and Isolated
**VERIFIED** — The string `DEMO00` appears in `MENU.PRG` (line ~233) and `MENU1.PRG` (line ~233) only, in the expression `If Pass1('DEMO00')`. No other password or credential string was found in any PRG file. The `Contrasenia()` function (which reads from `CONTRAS.DBF`) is commented out in both files, making the access-control path inactive.

### 2.7 `CONTRAS.DBF` — Contains Only Demo Credentials
**VERIFIED** — The readable text in `CONTRAS.DBF` shows a single record: username `BOB` and password `DEMO`. No additional user accounts or real credential data are visible in the record bytes. The field names `USUARIO` and `CLAVE` are schema definitions, not PII.

### 2.8 Sanitization Labels in PRG Sources — Present
**VERIFIED** — The following demo labels are confirmed present in PRG source:
- `EMPRESA DEMO S.R.L.` — `MENU.PRG`, `MENU1.PRG`, `BANCODIS.PRG`
- `DOMICILIO FICTICIO` — `MENU.PRG`, `MENU1.PRG`
- `Cocheria Demo 1/2/3` — `MENU.PRG`, `MENU1.PRG`, `INFORME.PRG`
- `Plan Demo A` — `MENU.PRG`, `MENU1.PRG`
- `GRUPO DEMO - BANCO DEMO` — `BANCODIS.PRG`

### 2.9 Demo Reservation IDs — Verified in DBF Records
**VERIFIED** — Synthetic reservation IDs `900001`, `900002`, `900003` appear in the following DBF files:
- `reserva.dbf` — three records with IDs 900001, 900002, 900003
- `CTACTE.DBF` — records for 900001 (×2) and 900002
- `ctaexp.dbf` — records for 900001 (×2) and 900002
- `RECIBO.DBF` — one record for 900001
- `SUPLENTE.DBF` — records for 900001 and 900002
- `RENA.DBF` — records for 900001 and 900002
- `FILTRO.DBF` — one record for 900001

### 2.10 Demo Parcel Codes — Verified in DBF Records
**VERIFIED** — Synthetic parcel codes `D010101`, `D010102`, `D020101` appear in:
- `parquenu.dbf` — D010101 confirmed in record text
- `titular.DBF` — records for D010101 (→ 900001), D010102 (→ 900002), D020101 (→ 900003)
- `SUBNIVEL.DBF` — records for D010101 and D010102

### 2.11 All Adjacent Name/Address Data — Synthetic
**VERIFIED** — All readable person-identifying data in DBF records uses explicit synthetic labels:
- Names: `PERSONA FICTICIA UNO`, `PERSONA FICTICIA DOS`, `PERSONA FICTICIA TRES`, `FALLECIDO FICTICIO UNO`, `FALLECIDA FICTICIA DOS`, `SUPLENTE FICTICIO UNO/DOS`, `PROMOTOR DEMO UNO/DOS`, `COBRADOR DEMO UNO/DOS`
- Addresses: `CALLE DEMO 100/200/300`, `CALLE FICTICIA 101–502`, `BARRIO DEMO`, `CIUDAD DEMO`
- Document IDs: series `9900000x` (reserved fictitious range per README)
- Phone numbers: `0000-000001`, `0000-000002`, `0000-000003` — clearly non-real
- All entity names: `MUTUAL DEMO UNO/DOS`, `COCHERIA DEMO UNO/DOS`, `BANCO DEMO UNO/DOS`, `AREA DEMO CENTRO/NORTE`, `FERETRO DEMO BASICO/ESPECIAL`, `CORDOBA DEMO`, `BUENOS AIRES DEMO`, `PROMOTOR DEMO UNO/DOS`

### 2.12 No IP Addresses, Server Names, or Network Paths in PRG
**VERIFIED** — Grep scans for IP address patterns, UNC paths (`\\`), drive paths (`C:\`, `D:\`), URLs (`http://`, `ftp://`), and mail protocol references returned zero matches across all 25 PRG files.

### 2.13 No External Database Connection Strings
**VERIFIED** — No ODBC DSN, JDBC connection string, API key, or authentication token pattern was found in any PRG file. The legacy system uses native xBase/DBF file access only.

### 2.14 `VALOREXP.DBF` — Contains Only Demo/Operational Data
**VERIFIED** — The readable record bytes show: date `20260801`, value `1500.00`, time `12:00:00`, user `BOB-DEMO`. All values are synthetic or operational (no PII).

### 2.15 `FILTRO.DBF` — Contains Only Synthetic Data
**VERIFIED** — Readable text shows reservation 900001, date `20260810`, and the string `FILTRO DEMO`. Entirely synthetic.

### 2.16 Persona Files — No Credentials or Sensitive Data
**VERIFIED** — All nine `.bob/agents/*.md` persona files contain only task descriptions, tool lists, and structural constraints. No credentials, real entity names, or sensitive data appear in any persona file.

### 2.17 `bob_result/final/project-initialization.md` — No Sensitive Data
**VERIFIED** — The initialization report contains only filesystem metadata, file counts, and references to demo identifiers as documented. No real PII or credentials are present.

### 2.18 `BORRA.PRG` — Destructive Operation Present
**VERIFIED** — `BORRA.PRG` (lines 2–4) contains `Dele all for recno()>246260` and `Pack` against the `ctaexp` table. This is a high-risk destructive operation (bulk delete + pack). **It is a legacy operational script, not a privacy risk** — it references a record number threshold (246260) that suggests real production history but contains no PII itself. The record number is an operational artifact; no names, IDs, or personal data are embedded.

### 2.19 `ZAP` Operations in PRG Files — Bounded to Temporary Tables
**VERIFIED** — All `ZAP` (`__DbZap()`) operations in `MENU.PRG`, `MENU1.PRG`, `ANA.PRG`, `BANCODIS.PRG`, `CCTA.PRG`, and `LIQUIDA.PRG` target explicitly named temporary/working tables (e.g., `AuxLiq`, `ImpMut`, `ImpCob`, `AxMutu`, `BaseP`) or are commented out. The `Zap` in `BANCODIS.PRG` targets a dynamically constructed alias (`&ValGr.` = `Imp002`) which is a temporary output table. These are migration risks (flagged for `migration-risk` agent) but not privacy risks.

### 2.20 `PACK` Operations — Operational Maintenance Scripts
**VERIFIED** — `Pack` appears in `BORRA.PRG`, `CTACTE.PRG`, `RECIBO.PRG`, `RESERVA.PRG`, `CTA01.PRG`. These are standalone maintenance utility scripts that operate on their named DBF tables. No PII is embedded in or adjacent to these operations.

---

## 3. INFERRED Findings

### 3.1 Record Number 246260 in `BORRA.PRG`
**INFERRED** — The hard-coded threshold `recno()>246260` in `BORRA.PRG` implies the production `ctaexp` table had at least 246,260 records before sanitization. This is metadata about production data volume, not PII. It does not constitute a data exposure risk but confirms the system was used at production scale.  
*Uncertainty: LOW — the inference is about volume, not content.*

### 3.2 `.Sn` Extension Files Referenced in `BANCODIS.PRG`
**INFERRED** — `BANCODIS.PRG` (lines 11–17) references three files with `.Sn` extension (`Titular.Sn`, `Respon.Sn`, `Auxi01.Sn`) and named indexes (`Tit3`, `Respo1`). These files are **not present** in the workspace. Their absence is consistent with the sanitization claim.  
*Uncertainty: MEDIUM — absence is consistent with sanitization but cannot be independently confirmed as intentional removal vs. never-shared.*

### 3.3 `bancos.dbf` Contains a DBC Reference String
**INFERRED** — The header bytes of `bancos.dbf` contain a Visual FoxPro database container name. This is a schema artifact embedded in the DBF header by the FoxPro toolchain, not a record value. It likely reflects the original development environment name.  
*Note: The DBC name is not reproduced here. It is not PII and does not constitute a BLOCKED condition.*  
*Uncertainty: MEDIUM — header artifact; informational only.*

### 3.4 Historical Date References in Utility PRGs
**INFERRED** — Several PRGs contain hard-coded historical dates (e.g., `COBRA.PRG` line 1: `12/10/1999`; `LIQUIDA.PRG` lines 1–2: `03/2000`, `03/10/1999`; `CTA01.PRG` lines 2–3: `mes=12, ano=1999`). These are operational parameters from original batch runs, not PII. They carry no privacy risk.  
*Uncertainty: LOW.*

---

## 4. UNKNOWN Items

### 4.1 Content of `.Sn` Extension Files Referenced in `BANCODIS.PRG`
**UNKNOWN** — `Titular.Sn`, `Respon.Sn`, `Auxi01.Sn` are referenced in `BANCODIS.PRG` but are not present in the workspace. Their historical content (whether they ever contained real data) cannot be confirmed from static inspection of the current workspace.

### 4.2 Content of Dynamically Constructed Table Names
**UNKNOWN** — `BANCODIS.PRG` constructs a table name as `'Imp'+StrZero(xGrupo,3)` (e.g., `Imp002`). No such file exists at the workspace root. Whether such files were part of a production environment cannot be confirmed.

### 4.3 `FTMENUTO.CH` Content
**UNKNOWN** — `FTMENUTO.CH` is referenced in `MENU.PRG` and `MENU1.PRG` but is absent. Per AGENTS.md this is a known missing dependency, not a sanitization issue. Its content cannot be inspected.

---

## 5. BLOCKED Items

**None.** No item triggers a BLOCKED condition. All inspected content is consistent with the sanitization claim documented in `README.md`.

---

## 6. Conflicts with Other Reports

No conflicts. OTN-10 is the first agent report. The `project-initialization.md` (OTN-01/OTN-01A) pre-flagged the DBF record content items as **INFERRED — pending OTN-10**; this report upgrades all of those items to **VERIFIED**.

---

## 7. Risks and Recommended Next Action

| Risk | Privacy Severity | Migration Severity | Recommended Action |
|---|---|---|---|
| `BORRA.PRG` bulk-delete with hard-coded production record count | NONE | HIGH | Flag to `migration-risk` agent (OTN-24); do not execute this script |
| Multiple `ZAP` / `PACK` operations in utility PRGs | NONE | HIGH | Flag to `migration-risk` agent (OTN-24) |
| Absent `.Sn` files referenced in `BANCODIS.PRG` | LOW (absent = no exposure) | MEDIUM | Note in `source-inventory` agent (OTN-20) as missing dependencies |
| `CONTRAS.DBF` stores credentials; `Contrasenia()` is commented out but not removed | LOW (demo credentials only) | MEDIUM | Note for `business-rules` agent (OTN-22); authentication system is dormant |
| `bancos.dbf` header contains a DBC container name | INFORMATIONAL | LOW | No action required; toolchain header artifact |
| `FTMENUTO.CH` absent | NONE | MEDIUM | Carry forward as known incompleteness to all Phase 2 agents |

**Safe to proceed to Phase 2 (OTN-20 through OTN-24).** No privacy, PII, or credential risk was found.

---

## 8. DBF Record Inspection Summary

| DBF File | Readable Record Content | Result |
|---|---|---|
| `AREAS.DBF` | `AREA DEMO CENTRO`, `AREA DEMO NORTE` | ✅ VERIFIED SYNTHETIC |
| `ATAUD.DBF` | `FERETRO DEMO BASICO`, `FERETRO DEMO ESPECIAL` | ✅ VERIFIED SYNTHETIC |
| `BAJA.DBF` | `MOTIVO DEMO: SOLICITUD`, `MOTIVO DEMO: TRASLADO` | ✅ VERIFIED SYNTHETIC |
| `bancos.dbf` | `BANCO DEMO UNO/DOS`, `AV DEMO 100/200`, `CONTACTO FICTICIO`, `0000-000001/2` | ✅ VERIFIED SYNTHETIC |
| `cobrador.dbf` | `COBRADOR DEMO UNO/DOS`, `CALLE FICTICIA 101/202`, `CIUDAD DEMO`, `0000-000001/2` | ✅ VERIFIED SYNTHETIC |
| `COCHERIA.DBF` | `COCHERIA DEMO UNO/DOS`, `CALLE FICTICIA 301/302`, `BARRIO DEMO` | ✅ VERIFIED SYNTHETIC |
| `CONTRAS.DBF` | Single record: user=`BOB`, password=`DEMO` | ✅ VERIFIED SYNTHETIC (demo credential) |
| `CTACTE.DBF` | Reservations 900001 (×2), 900002; numeric amounts; dates in 2026 | ✅ VERIFIED SYNTHETIC |
| `ctaexp.dbf` | Reservations 900001 (×2), 900002; synthetic payment labels | ✅ VERIFIED SYNTHETIC |
| `FILTRO.DBF` | Reservation 900001; `FILTRO DEMO` | ✅ VERIFIED SYNTHETIC |
| `MAEASO.DBF` | `MUTUAL DEMO UNO/DOS`, `REFERENTE DEMO UNO/DOS`, `CALLE FICTICIA 401/402`, `CIUDAD DEMO` | ✅ VERIFIED SYNTHETIC |
| `mutual.dbf` | `MUTUAL DEMO UNO/DOS`, identical synthetic data as MAEASO | ✅ VERIFIED SYNTHETIC |
| `parquenu.dbf` | D010101→900001, `PERSONA FICTICIA UNO`, `CALLE DEMO 100`, `BARRIO DEMO`, `DNI99000001`, `0000-000001` | ✅ VERIFIED SYNTHETIC |
| `PROMOTOR.DBF` | `PROMOTOR DEMO UNO/DOS`, `CALLE FICTICIA 501/502`, reserved fictitious doc IDs | ✅ VERIFIED SYNTHETIC |
| `PROVINCI.DBF` | `CORDOBA DEMO`, `BUENOS AIRES DEMO` | ✅ VERIFIED SYNTHETIC |
| `RECIBO.DBF` | Reservation 900001, amount 1500.00, date 20260708 | ✅ VERIFIED SYNTHETIC |
| `RENA.DBF` | Reservations 900001/900002; `PERSONA FICTICIA UNO/DOS`; doc IDs 99000001/99000002 | ✅ VERIFIED SYNTHETIC |
| `reserva.dbf` | Reservations 900001/900002/900003; `PERSONA FICTICIA UNO/DOS/TRES`; `CALLE DEMO 100/200/300`; `0000-000001/2/3`; parcel codes D010101/D010102/D020101 | ✅ VERIFIED SYNTHETIC |
| `SUBNIVEL.DBF` | D010101/D010102; `FALLECIDO FICTICIO UNO`, `FALLECIDA FICTICIA DOS`; doc IDs 99000101/99000102 | ✅ VERIFIED SYNTHETIC |
| `SUPLENTE.DBF` | Reservations 900001/900002; `SUPLENTE FICTICIO UNO/DOS`; `CALLE DEMO 110/210` | ✅ VERIFIED SYNTHETIC |
| `titular.DBF` | D010101→900001, D010102→900002, D020101→900003; `PERSONA FICTICIA UNO/DOS/TRES`; `CALLE DEMO 100/200/300` | ✅ VERIFIED SYNTHETIC |
| `VALOREXP.DBF` | Date 20260801, value 1500.00, user `BOB-DEMO` | ✅ VERIFIED SYNTHETIC |

**All 22 DBF files: VERIFIED SYNTHETIC.**

---

## 9. VERDICT

**SAFE TO PROCEED**

All 25 PRG files and all 22 DBF files have been individually inspected. No real personal data, real credentials, real company names, IP addresses, server paths, external database connections, or sensitive backup directories were found. Every readable DBF record uses the documented synthetic identifiers (`PERSONA FICTICIA`, `CALLE DEMO`, `900001–900003`, `D010101/D010102/D020101`, `99000001` series, `0000-000001` series). All PRG hard-coded strings use explicit demo labels (`EMPRESA DEMO S.R.L.`, `DOMICILIO FICTICIO`, `Cocheria Demo`, `Plan Demo`). The only credential in the system (`DEMO00` / `BOB`/`DEMO`) is demonstrably synthetic and the access-control path using it is commented out. No archive files, index files, executable binaries, or credential files are present. The three absent files referenced in `BANCODIS.PRG` (`.Sn` extension) are not present in the workspace and represent no current exposure. All findings are consistent with the sanitization event documented in `README.md`. Phase 2 agents (OTN-20 through OTN-24) may proceed subject to user approval of Gate 1.

---

*Only synthetic data was used in this analysis. No legacy file was modified, renamed, moved, deleted, or overwritten during this review.*
