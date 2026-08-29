# Legacy Flow

**Task ID:** OTN-30  
**Role:** Manual modernization-architect role (non-Bob, post-budget)  
**Date:** 2026-08-29  
**Status:** COMPLETE  
**Labels:** Solid paths are `VERIFIED`; dashed dependencies contain `UNKNOWN` implementation details.

```mermaid
flowchart TD
    START["MENU.PRG startup"] --> OPEN["OpenDbf(): DBF work areas + NTX definitions"]
    START -. "UNKNOWN implementation" .-> LIB["Missing support callables / FTMENUTO.CH"]
    OPEN --> MENU["Main menu"]

    MENU --> OPER["Operations"]
    MENU --> INCOME["Income / collection"]
    MENU --> QUERY["Queries"]
    MENU --> REPORTS["Reports"]

    OPER --> WF3["WF-003 New reservation"]
    OPER --> WF4["WF-004 New inhumation"]
    OPER --> WF7["WF-007 Batch expense liquidation"]
    INCOME --> WF5["WF-005 Expense collection"]
    INCOME --> WF6["WF-006 Installment collection"]

    WF3 --> RES[("RESERVA")]
    WF3 --> PAR[("PARQUENU")]
    WF3 --> TIT[("TITULAR / SUPLENTE")]
    WF3 --> PLAN[("CTACTE")]
    WF3 -. "runtime staging schema UNKNOWN" .-> AXPL[("AxPl / AxSupl")]

    WF4 --> PAR
    WF4 --> SUB[("SUBNIVEL")]
    WF4 --> COCH[("COCHERIA")]
    WF4 --> ATAUD[("ATAUD")]

    WF5 --> DUES[("CTAEXP")]
    WF5 --> EXPC[("ExpCta runtime table")]
    WF6 --> PLAN
    WF6 --> REC[("RECIBO")]
    WF5 -. "schema UNKNOWN" .-> AUX[("AuxiRes staging")]
    WF6 -. "schema UNKNOWN" .-> AUX

    WF7 --> RES
    WF7 --> DUES
    WF7 -. "schemas UNKNOWN" .-> LIQ[("AuxLiq / ResuCta")]

    QUERY --> RES
    QUERY --> PAR
    REPORTS --> RES
    REPORTS --> DUES
```

## Evidence

- **VERIFIED:** Startup and `OpenDbf()` are documented in `legacy-system-overview.md` §5–§6 (`MENU.PRG:1–15,3854–4092`).
- **VERIFIED:** Candidate workflows and their reads/writes are documented in `04-workflows.md`, WF-003 through WF-007.
- **VERIFIED:** Persistent relationships are documented in `data-model.md` §3.
- **UNKNOWN:** Runtime-only table schemas and missing callable implementations are not reconstructed here (`data-model.md` §2 and §5; `migration-risks.md` MR-030 and MR-033).

Only the sanitized reports and synthetic-data context were used. No legacy file was executed or modified.

