# Old to New — Final Hackathon Report

**Task ID:** OTN-60  
**Execution:** Manual post-Bob-budget submission preparation  
**Date:** 2026-08-29  
**Status:** COMPLETE — repository and video URLs remain submission-time fields  
**Prototype:** WF-004 New Inhumation  
**Approved behavior:** BR-060 through BR-064 only  
**Excluded behavior:** BR-065 and every other legacy workflow

## Executive Summary

Old to New demonstrates an evidence-based way to understand and modernize one bounded workflow from an undocumented Clipper/xBase application. IBM Bob was the central discovery and orchestration component: it established a project contract, performed the safety gate, coordinated five specialized read-only analyses in parallel, and consolidated source inventory, data model, business rules, workflows, and migration risks. The official 40-Bobcoin allocation was exhausted during the final consolidation pass. All later architecture, implementation, testing, validation, and submission work is therefore identified as manual post-budget work and is not attributed to IBM Bob.

The proof of concept migrates only WF-004 New Inhumation to a local .NET, Avalonia, and SQLite application. Five user-approved legacy rules are implemented with synthetic fixtures and explicit traceability. An independent read-only validation found no verified discrepancy: 21 of 21 automated tests passed, all five approved rules passed, and Gate 4 accepted two deliberate presentation differences.

## Submission-Ready Problem Statement

Critical business behavior in the legacy application is embedded in large Clipper PRG files, screen-coordinate code, global state, dynamic DBF aliases, and implicit NTX relationships. The sanitized snapshot contains 25 PRG files and 22 DBF schemas but lacks a complete compiler/runtime installation and several dynamically referenced tables. A developer must therefore inspect thousands of lines manually, distinguish active code from historical utilities, infer data relationships, and avoid destructive maintenance scripts. This makes modernization slow and risky: a missed validation, hidden write, or unsupported assumption can produce regressions and rework. The challenge is not to rewrite the full system, but to create a safe, repeatable developer workflow that turns legacy evidence into approved, testable behavior while preserving privacy and uncertainty.

## Submission-Ready Solution Statement

Old to New uses IBM Bob as an orchestration layer for evidence-based legacy understanding. Bob first applied a privacy and safety gate, then coordinated five focused read-only roles in parallel: source inventory, data modeling, business-rule extraction, workflow reconstruction, and migration-risk analysis. Their reports classify each conclusion as VERIFIED, INFERRED, or UNKNOWN and cite narrow PRG locations. Only user-approved VERIFIED findings may become requirements.

After Bob produced the consolidated analysis, the bounded WF-004 New Inhumation flow was selected. A manual post-budget implementation rebuilt only that vertical slice as an offline .NET/Avalonia/SQLite application using visibly synthetic data. The modern design separates UI, application, domain rules, and persistence; uses transactions, foreign keys, and a composite uniqueness constraint; and returns rule identifiers with every rejection. A separate read-only validator compared BR-060 through BR-064 against the approved legacy evidence and reran the automated tests. The result was 5/5 rule parity and 21/21 passing tests, with no production connection and no modification of legacy evidence.

## Developer Workflow

| Before | With Old to New |
|---|---|
| Manually search mixed UI, business, and DBF code | Start from Bob-generated, persona-specific reports |
| Treat undocumented assumptions as probable behavior | Preserve VERIFIED, INFERRED, and UNKNOWN boundaries |
| Reconstruct relationships from aliases and indexes ad hoc | Use an evidence-backed data model and dependency inventory |
| Risk changing a large legacy program | Select one approved vertical slice behind explicit gates |
| Validate mainly by manual inspection | Map every approved rule to unit/integration tests and an independent review |

## IBM Bob Workflow and Evidence

| Phase | Work | Attribution | Evidence |
|---|---|---|---|
| OTN-00/01 | Contract intake, workspace initialization, reusable persona definitions | IBM Bob | `bob_sessions/otn-01-project-initialization.png` |
| OTN-10 | Privacy, secrets, backup, and production-reference review | IBM Bob | `bob_sessions/otn-10-security-review.png` |
| OTN-20 | Source/function/dependency inventory | IBM Bob read-only task | `bob_sessions/otn-20-source-inventory.png` |
| OTN-21 | DBF schemas and relationship reconstruction | IBM Bob read-only task | `bob_sessions/otn-21-data-model.png` |
| OTN-22 | Business-rule extraction | IBM Bob read-only task | `bob_sessions/otn-22-business-rules.png` |
| OTN-23 | End-to-end workflow reconstruction | IBM Bob read-only task | `bob_sessions/otn-23-workflow-reconstructor.png` |
| OTN-24 | Maintainability and migration-risk assessment | IBM Bob read-only task | `bob_sessions/otn-24-migration-risk.png` |
| OTN-25 | Consolidated reports and conflict review | IBM Bob, with one final terminology-only correction performed manually after budget exhaustion | `bob_sessions/otn-20-24-task-summary.png`, `bob_sessions/otn-25-budget-exceeded.png` |

**VERIFIED:** The five OTN-20 through OTN-24 tasks were represented as separate focused analyses and preserved as separate reports under `bob_result/agents/`. The evidence folder also contains overview and correction-review captures.

**VERIFIED:** The IBM Bob budget was exhausted at its fixed 40-Bobcoin allocation. The remaining work was completed outside IBM Bob and is logged in `bob_result/logs/manual-phase3-provenance.md`.

## Manual Post-Budget Continuation

| Phase | Result |
|---|---|
| OTN-30 | Target architecture, migration plan, and diagrams |
| OTN-31 | Candidate ranking; Gate 3 selected WF-004 |
| OTN-40 | Six-project .NET solution and deterministic SQLite data layer under `modernized/` |
| OTN-41 | Avalonia vertical slice for New Inhumation |
| OTN-42 | Rule-mapped unit and integration tests |
| OTN-50 | Separate read-only validation; Gate 4 approved |
| OTN-60/61/62 | English report, timed demo script, and delivery checklist |

No item in this table is claimed as an IBM Bob execution.

## Approved Workflow and Rule Traceability

| Rule | VERIFIED legacy behavior and source | Modern result |
|---|---|---|
| BR-060 | Parcel must exist — `MENU.PRG`, `AltaInhu()`, lines 280–303 | Missing parcel rejected; FK and transactional recheck |
| BR-061 | `(parcel, level, sublevel)` must be new — `MENU.PRG`, `AltaInhu()`, lines 295–300 | Duplicate rejected; composite unique constraint |
| BR-062 | Earlier sublevels must exist — `MENU.PRG`, `CargaSub()`, lines 314–321 | Gap rejected without partial insert |
| BR-063 | Service type is `S` or `T` — `MENU.PRG`, `CargaSub()`, line 333 | Domain, UI, and SQLite validation |
| BR-064 | Level 1–3 and sublevel 1–6 — `MENU.PRG`, `AltaInhu()`, lines 289–290 | Boundary validation in domain and SQLite |

BR-065 was explicitly excluded at Gate 3 and is not implemented.

## Target Architecture

The prototype is an offline modular desktop application:

```text
Avalonia View → ViewModel → Application Use Case → Domain Rules
                                             ↓
                                  SQLite Persistence
```

- The UI has no DBF or SQL responsibility.
- The domain contains only approved behavior.
- SQLite provides local transactions, foreign keys, typed checks, and uniqueness.
- Runtime and test fixtures are visibly synthetic.
- The application never reads or writes the root PRG/DBF evidence.
- No production or external runtime service is configured.

See `bob_result/final/target-architecture.md` and `bob_result/diagrams/target-architecture.md`.

## Verified Results and Measurements

| Metric | Verified result | Method/evidence |
|---|---:|---|
| Legacy sources inventoried | 25 PRG files | OTN-20 and `analysis-summary.md` |
| DBF schemas documented | 22 | OTN-21 and `data-model.md` |
| Synthetic legacy records | 45 | OTN-10 and `analysis-summary.md` |
| Parallel specialized analyses | 5 | OTN-20 through OTN-24 task evidence |
| Consolidated VERIFIED rules | 46 | Count recorded in `analysis-summary.md` |
| Rules selected for the PoC | 5 | Gate 3: BR-060 through BR-064 |
| Independently passing approved rules | 5/5 | `validation-report.md` |
| Automated tests | 21/21 passing | `test-results.md` |
| Release build | 0 warnings, 0 errors, 4.01 s | `logs/otn-40-42-build-test.md` |
| Implementation test run | 21 passed in 3.47 s | `logs/otn-40-42-build-test.md` |
| Independent test run | 21 passed in approximately 3.45 s | `test-results.md` |
| Verified implementation discrepancies | 0 | OTN-50 |
| Accepted target differences | 2 | Gate 4 |

No manual-before-versus-assisted elapsed-time baseline was recorded. The project therefore makes no fabricated percentage or time-saved claim. Its measured effectiveness claims are limited to evidence coverage, parallel-task count, rule/test traceability, build quality, and validation results.

## Gate 4 Accepted Differences

1. The modern screen accepts the already-composed parcel code instead of collecting Sector, Row, and Plot separately.
2. The modern screen uses concise English messages with rule IDs instead of reproducing the legacy Spanish wording.

Both preserve the approved rejection effects. No implementation correction was required.

## Judging-Criteria Alignment

- **Completeness and feasibility:** A runnable offline vertical slice, repeatable build/test commands, and independent validation are included.
- **Creativity and innovation:** IBM Bob coordinates safety-first, confidence-labeled, specialized legacy analyses before code is authorized.
- **Design and usability:** The modern UI exposes synthetic scenarios and rule identifiers; the architecture separates concerns that were interleaved in the PRG.
- **Effectiveness and efficiency:** Five analyses were organized in parallel, 46 verified rules were documented, and the selected five rules have 100% automated-test and validation coverage.

## Privacy and Safety

**VERIFIED:** OTN-10 inspected all 25 PRGs and all 22 DBFs and approved the sanitized workspace. The current evidence set contains 14 PNG captures; a final visual audit found no personal email address, account identifier, or production value. `DEMO00`, where visible, is an explicitly synthetic maintenance value.

**VERIFIED:** No `_resguardo_privado/`, `backup/`, `original/`, `production/`, or archive file was present during the final package audit. Generated build and SQLite test artifacts are ignored by `modernized/.gitignore`.

Only synthetic data was used. No production connection was made.

## Limitations, UNKNOWN Items, and Risks

- **UNKNOWN:** Full legacy runtime parity cannot be established because the sanitized snapshot lacks the complete Clipper toolchain, include files, and runtime-generated tables.
- **UNKNOWN:** Behavior outside BR-060 through BR-064 remains unimplemented and unvalidated.
- **INFERRED:** The isolated architecture is a feasible migration pattern for additional workflows, but extending it requires new evidence and approval gates.
- The four generated synthetic SQLite files noted by OTN-50 live under ignored `bin/` output. Generated `obj/` metadata also contains local build-machine paths. Neither directory may be included in a manually assembled archive.
- A public repository URL and public video URL have not yet been created.

These limitations do not block the approved proof-of-concept workflow.

## Bob Usage Statement

IBM Bob was the central component of the legacy-understanding workflow. In the official hackathon-provisioned instance, Bob read the project contract, created a task backlog and reusable specialist personas, performed a privacy/security gate, and coordinated five independent read-only analyses in parallel. Those tasks inventoried the Clipper sources, reconstructed DBF relationships, extracted business rules, traced user workflows, and assessed migration risks. Bob then consolidated the evidence into project-level reports while preserving VERIFIED, INFERRED, and UNKNOWN classifications and narrow source citations. Task summaries and usage evidence are stored in `bob_sessions/`.

The fixed 40-Bobcoin allocation was exhausted during the final OTN-25 consistency pass. One terminology-only consolidation correction and all architecture, implementation, automated testing, independent validation, and submission preparation after that point were completed manually outside IBM Bob and are explicitly labeled as post-budget work. IBM watsonx services were not used. This attribution avoids claiming unsupported Bob or watsonx usage while showing how Bob materially transformed the initial undocumented codebase into an evidence-backed modernization backlog.

## Reproduction

From `modernized/`:

```powershell
dotnet restore OldToNew.sln
dotnet format OldToNew.sln --verify-no-changes --no-restore --verbosity minimal
dotnet build OldToNew.sln --no-restore --configuration Release
dotnet test OldToNew.sln --no-build --configuration Release
dotnet run --project src/OldToNew.Desktop/OldToNew.Desktop.csproj
```

See `modernized/README.md` for the approved scope and demo scenarios.

## Conflicts and Recommended Next Action

No unresolved conflict remains between the approved Phase 2 rules, implementation, and OTN-50 validation. INFERRED and UNKNOWN findings remain outside requirements. The next action is not further development: it is to create the public repository, record the sub-three-minute demo using `demo-script.md`, insert both public URLs into the submission form, and complete `submission-checklist.md` before the official deadline.

Only synthetic data was used in this report and prototype.
