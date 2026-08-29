# Old to New — IBM Bob Project Context

## Mission

Old to New is an IBM TechXchange 2026 Hackathon proof of concept. IBM Bob
must be the central component of the demonstrated workflow.

The project must show how Bob can safely understand an undocumented legacy
application, coordinate specialized subagents, reconstruct verified behavior,
design a modernization approach, migrate one representative workflow, and
independently validate the result.

Do not treat this as a request to migrate the entire application.

## Hackathon problem statement

Critical business behavior is embedded in old Clipper PRG files and implicit
DBF/NTX relationships. Understanding the application currently requires slow
manual analysis and scarce legacy expertise. This creates a high risk of missed
rules, regressions, rework, and dependence on the original developers.

## Proposed solution

Use IBM Bob 2.0 as an orchestration layer for an evidence-based modernization
workflow:

1. Inspect privacy and safety before functional analysis.
2. Map legacy sources, data structures, dependencies, and missing artifacts.
3. Delegate independent analyses to focused subagents.
4. Consolidate verified business rules and user workflows.
5. Propose and justify a target architecture.
6. Migrate exactly one representative end-to-end workflow.
7. Generate tests and run an independent legacy-versus-modern validation.
8. Produce traceable technical documentation and hackathon evidence.

## Hackathon requirements

- Build a working prototype that improves a specific developer workflow.
- IBM Bob must do more than assist with coding: demonstrate Agent mode,
  parallel tasks, subagents, and document/code understanding.
- Demonstrate measurable improvement in productivity, manual effort, errors,
  rework, or completion time.
- Optimize for the four judging areas, each worth 5 points:
  completeness and feasibility; creativity and innovation; design and
  usability; effectiveness and efficiency.
- Final submission material must be in English.
- Required evidence includes the working prototype or repository, a demo video,
  written problem/solution/Bob-usage explanations, and exported Bob task/session
  reports.
- Capture the Bob task summary and usage view for every major task. Store PNG
  evidence under `bob_sessions/` using the task IDs defined below.

## Current workspace — verified starting state

- Legacy language: Clipper/xBase.
- Source format: 25 root-level `*.PRG` files.
- Data format: 22 root-level `*.DBF` files.
- Index formats referenced by the code: NTX and CDX.
- Current index files: none. They were intentionally removed because original
  indexes could retain sensitive values.
- Current DBF content: 45 fully synthetic demo records across the 22 schemas.
- Synthetic reservation IDs: `900001`, `900002`, and `900003`.
- Synthetic parcel IDs: `D010101`, `D010102`, and `D020101`.
- Hard-coded company, address, provider, customer/entity, location, and funeral
  home names in active PRG display text were replaced with explicit demo labels.
- The former hard-coded maintenance secret was replaced with `DEMO00`.
- No production connection is required or permitted.

The operational PRG and DBF files remain in the workspace root deliberately.
The legacy code opens tables and indexes through relative paths, so moving them
before analysis could obscure or break behavior.

## Important source entry points

- `MENU.PRG`: newest main program, menus, operations, reports, DBF opening, and
  NTX creation in `OpenDbf()`.
- `MENU1.PRG`: older historical version useful only for comparison.
- `COBRA.PRG` and `LIQUIDA.PRG`: payment and fee-processing logic.
- `INFORME.PRG`: reporting/statistics logic.
- Small PRGs: historical administrative or bulk-update utilities. Treat scripts
  containing mass `REPLACE`, `ZAP`, or index creation as high risk.

## Known incompleteness

This is a sanitized analysis snapshot, not a complete runnable production
installation. It does not contain a Clipper compiler, executable, the
`FTMENUTO.CH` include, or every DBF/table referenced dynamically by the source.
Examples of missing or generated aliases include `ResuCta`, `AuxLiq*`,
`PExpensa`, `Recexpe`, `ExpCta`, `AuxParq`, `Bisiesto`, and other temporary
tables.

Never claim that the full legacy system builds or runs unless Bob verifies it.
Record missing evidence as `UNKNOWN`; do not invent it.

## Mandatory safety and privacy rules

These rules apply to the parent task and every subagent:

1. Treat all root-level PRG and DBF files as read-only legacy evidence.
2. Never modify, rename, move, delete, overwrite, pack, zap, or reindex legacy
   files.
3. Write new artifacts only under `.bob/`, `bob_result/`, `bob_sessions/`, or
   `modernized/`.
4. Never connect to production systems, databases, APIs, servers, network
   shares, or external storage.
5. Never upload or transmit workspace contents to external services.
6. Never introduce real people, customers, employees, company identifiers,
   addresses, credentials, financial information, or production data.
7. If `_resguardo_privado/`, `backup/`, `original/`, `production/`, archives,
   database backups, or potentially real records exist, stop before functional
   analysis. Report only the affected file and data category; never reproduce
   the value.
8. All generated test fixtures must be visibly synthetic.
9. Every technical claim must cite the supporting PRG file, function/procedure,
   and line or narrow code location.
10. Label every conclusion as `VERIFIED`, `INFERRED`, or `UNKNOWN`.
11. Do not convert an inference into a business requirement without user
    approval.
12. Do not expose chain-of-thought. Reports should contain concise evidence,
    conclusions, assumptions, and open questions.

## Bob-owned scope

The following work must be performed and evidenced by IBM Bob, not assumed from
this context file:

- Functional decomposition and PRG dependency analysis.
- DBF relationship reconstruction.
- Business-rule extraction.
- User-workflow reconstruction.
- Maintainability and migration-risk assessment.
- Target architecture design.
- Selection and migration of one proof-of-concept workflow.
- Test generation, comparison, and independent validation.
- Final hackathon reports, diagrams, metrics, and demo narrative.

## Required specialized subagents

Bob should create reusable project personas under `.bob/agents/` when the
corresponding phase begins. Persona files must use official YAML front matter,
have a filename matching the `name` field, and use `tools: [read]` for all
analysis/review roles.

1. `security-reviewer`: privacy, secrets, backups, production references, and
   safe-to-proceed decision. Read-only.
2. `source-inventory`: PRG functions, procedures, aliases, call/dependency map,
   entry points, duplicates, and missing includes/tables. Read-only.
3. `data-model`: DBF schemas, candidate keys, relationships, index expressions,
   and integrity assumptions. Read-only.
4. `business-rules`: explicit validations, calculations, state transitions, and
   conditions with source citations. Read-only.
5. `workflow-reconstructor`: end-to-end user flows, inputs, outputs, side
   effects, and failure paths. Read-only.
6. `migration-risk`: coupling, global state, dynamic aliases, destructive
   operations, unsupported dependencies, and migration hazards. Read-only.
7. `modernization-architect`: compare feasible target designs and recommend a
   .NET + Avalonia + SQLite proof-of-concept architecture. Read-only.
8. `poc-implementer`: implement only the approved workflow under `modernized/`;
   never edit legacy evidence. Edit/command access only after approval gate 3.
9. `independent-validator`: compare verified legacy behavior with the modernized
   workflow and its tests. Must not be the implementing subagent.

Subagents should receive only their bounded task and the necessary files. Run
independent read-only analysis tasks in parallel where possible.

## Task backlog and approval gates

Bob must create visible tasks with these IDs. Do not collapse the entire project
into one task or one conversation.

### Phase 0 — Initialize

- `OTN-00`: Read this file and inspect workspace metadata only.
- `OTN-01`: Create missing output directories and proposed read-only persona
  files. Do not analyze business logic yet.
- Output: `bob_result/final/project-initialization.md`.
- Evidence: `bob_sessions/otn-01-project-initialization.png`.

### Phase 1 — Safety gate

- `OTN-10`: Run `security-reviewer` over the entire shareable workspace.
- Output: `bob_result/agents/00-security-review.md`.
- Evidence: `bob_sessions/otn-10-security-review.png`.
- Gate 1: stop until the user approves the report. Any suspected sensitive or
  production artifact blocks all later phases.

### Phase 2 — Parallel legacy analysis

After gate 1 approval, run these independent tasks in parallel:

- `OTN-20`: `source-inventory` → `bob_result/agents/01-source-inventory.md`.
- `OTN-21`: `data-model` → `bob_result/agents/02-data-model.md`.
- `OTN-22`: `business-rules` → `bob_result/agents/03-business-rules.md`.
- `OTN-23`: `workflow-reconstructor` → `bob_result/agents/04-workflows.md`.
- `OTN-24`: `migration-risk` → `bob_result/agents/05-migration-risks.md`.
- Evidence: one screenshot per task, named with its task ID.

Then run:

- `OTN-25`: Consolidate results, identify agreement/conflicts, and produce:
  - `bob_result/final/legacy-system-overview.md`
  - `bob_result/final/business-rules.md`
  - `bob_result/final/data-model.md`
  - `bob_result/final/migration-risks.md`
  - `bob_result/final/analysis-summary.md`
- Gate 2: request user review and approval of verified behavior.

### Phase 3 — Modernization design

- `OTN-30`: Run `modernization-architect` using only approved Phase 2 findings.
- Required outputs:
  - `bob_result/final/target-architecture.md`
  - `bob_result/final/migration-plan.md`
  - `bob_result/diagrams/legacy-flow.md`
  - `bob_result/diagrams/target-architecture.md`
- `OTN-31`: Rank candidate proof-of-concept workflows by completeness,
  feasibility, demo value, privacy risk, and available evidence.
- Gate 3: the user selects and approves exactly one workflow before code changes.

### Phase 4 — Proof-of-concept implementation

- `OTN-40`: Create the approved .NET/Avalonia/SQLite solution only under
  `modernized/`.
- `OTN-41`: Implement the approved vertical workflow with synthetic fixtures.
- `OTN-42`: Add automated unit/integration tests for every approved rule in the
  selected workflow.
- Record build/test commands and results under `bob_result/logs/`.
- Never add behavior solely because it appears conventional; use approved
  evidence or mark the behavior as a deliberate target-system decision.

### Phase 5 — Independent validation

- `OTN-50`: Run `independent-validator`; it must compare inputs, calculations,
  state transitions, outputs, errors, and unsupported cases.
- Required outputs:
  - `bob_result/final/validation-report.md`
  - `bob_result/final/test-results.md`
- Gate 4: fix only verified discrepancies; record accepted differences.

### Phase 6 — Hackathon package

- `OTN-60`: Produce `bob_result/final/final-hackathon-report.md` in English.
- `OTN-61`: Produce `bob_result/final/demo-script.md` for a short before/after
  video that clearly shows Bob tasks, parallel agents, source evidence, the
  working proof of concept, tests, and measurable impact.
- `OTN-62`: Produce `bob_result/final/submission-checklist.md` covering the
  repository/prototype, public video URL, problem statement, solution statement,
  Bob usage explanation, task/session export, screenshots, privacy check, and
  English-language requirement.

## Report contract

Every agent report must contain:

1. Task ID and persona.
2. Scope and files inspected.
3. `VERIFIED` findings with source citations.
4. `INFERRED` findings with explicit reasoning and uncertainty.
5. `UNKNOWN` items and missing dependencies.
6. Conflicts with other reports, if any.
7. Risks and recommended next action.
8. Statement that only synthetic data was used.

Do not copy large PRG blocks into reports. Cite concise locations and paraphrase.

## Measurement plan

Bob must establish a reproducible baseline before claiming impact. Suggested
metrics include:

- Time to inventory PRG modules manually versus with the workflow.
- Number of business rules with traceable source evidence.
- Number of DBF relationships documented and confidence level.
- Parallel analysis elapsed time versus the sum of agent task durations.
- Automated tests mapped to approved legacy rules.
- Verified parity rate and count of unresolved/unknown behaviors.
- Time required for a new developer to locate a rule before and after generated
  documentation.

Never fabricate measurements. Mark estimates as estimates and record the method.

## First prompt to run in IBM Bob

Use Agent mode with Read and Edit enabled, Execute disabled, and subagents
disabled for the initial task:

```text
Read AGENTS.md completely and treat it as the authoritative project contract.

Do not overwrite AGENTS.md and do not analyze business rules yet.

Create tasks OTN-00 and OTN-01 only. Inspect workspace metadata, confirm the
sanitized starting state, create the required output directories, and propose
the project-level read-only subagent persona files under .bob/agents/.

Write bob_result/final/project-initialization.md and stop for my approval before
starting OTN-10.
```

