# IBM Dev Day Submission — Copy/Paste Text

**Prepared:** 2026-08-29  
**Language:** English  
**Status:** Submitted on 2026-08-29 — Submission #51 received

## Video Demonstration URL

```text
https://youtu.be/AnG2Uk-wbL0
```

## Written Problem and Solution Statement

Old to New addresses a developer-workflow problem in an undocumented Clipper/xBase application where critical behavior is embedded in large PRG files, screen-coordinate code, global state, dynamic DBF aliases, and implicit index relationships. The sanitized snapshot contains 25 PRG files and 22 DBF schemas but lacks a complete compiler/runtime installation and several dynamically referenced tables. A developer must therefore inspect thousands of lines manually, separate active behavior from historical utilities, reconstruct data relationships, and avoid destructive maintenance scripts. Missing one validation or treating an assumption as a requirement can create regressions and rework.

The solution uses IBM Bob as a safety-first evidence and orchestration layer. Bob read a persistent project contract, created bounded tasks and reusable specialist personas, performed a privacy gate, and coordinated five independent read-only analyses in parallel: source inventory, data modeling, business-rule extraction, workflow reconstruction, and migration-risk assessment. Reports classify every conclusion as VERIFIED, INFERRED, or UNKNOWN and include narrow source citations. Only user-approved VERIFIED findings can become modernization requirements.

From this evidence, one representative flow—WF-004 New Inhumation—was selected with exactly five approved rules. A manual post-Bob-budget implementation rebuilt that vertical slice as an offline .NET 10, Avalonia, and SQLite application using only visibly synthetic fixtures. It separates UI, application, domain, and persistence responsibilities and uses transactions, foreign keys, typed checks, and composite uniqueness. An independent read-only validation compared BR-060 through BR-064 against the approved evidence: all five rules passed, all 21 automated tests passed, and no verified implementation discrepancy was found. The project demonstrates a repeatable path from undocumented code to traceable, approved, and testable modernization work without claiming to migrate the full legacy system.

**Word count:** 285

## Written Statement on Technology

IBM Bob was the central component of the legacy-understanding workflow in the official hackathon-provisioned instance. Bob first read `AGENTS.md` as the authoritative project contract, created the OTN task backlog, and created reusable specialist personas with bounded permissions. It then ran the OTN-10 privacy/security gate before functional analysis.

After approval, Bob coordinated five separate read-only analyses in parallel: OTN-20 source inventory, OTN-21 data model, OTN-22 business rules, OTN-23 workflow reconstruction, and OTN-24 migration risks. These tasks inspected the sanitized Clipper PRGs and DBF structures, reconstructed dependencies and rules, and produced source-cited reports under `bob_result/agents/`. Bob then consolidated the findings into the project-level reports under `bob_result/final/`. Task summaries, parallel-task evidence, and usage captures are included under `bob_sessions/` in the public repository.

The official fixed 40-Bobcoin allocation was exhausted during the final OTN-25 consistency pass. One terminology-only correction and all subsequent architecture, workflow selection, .NET/Avalonia/SQLite implementation, automated testing, independent validation, and submission preparation were completed manually outside IBM Bob and are explicitly labeled as post-budget work. IBM watsonx.ai and watsonx Orchestrate were not used. This attribution intentionally distinguishes verified IBM Bob usage from later manual contributions.

**Word count:** 209

## Code Repository, Including Exported IBM Bob Report

```text
https://github.com/blas-rodriguez/old-to-new-ibm-bob
```
