# Old to New — Three-Minute Demo Script

**Task ID:** OTN-61  
**Execution:** Manual post-Bob-budget submission preparation  
**Target duration:** 2:58 maximum  
**Language:** English  
**Recording rule:** Keep the IDE account/settings, Slack, email, and private browser tabs out of frame.

## Recording Setup

Before recording:

1. Open the public-safe workspace view, `bob_sessions/`, `business-rules.md`, and the modern application.
2. Start with a fresh application database so `D010101 / Level 1 / Sublevel 1` succeeds once and then demonstrates BR-061 when repeated.
3. Prepare a terminal at `C:\LEGACY_SISTEM\modernized` with the test command ready.
4. Use 1080p or higher, enlarge text, and keep the cursor movement deliberate.
5. Do not show account settings, Bobanalytics, email addresses, Slack, or unpublished URLs.

## Timed Script and Shot List

### 0:00–0:12 — Title and Problem

**Show:** Title slide: “Old to New — Evidence-Based Legacy Modernization with IBM Bob.”

**Say:**

“Old to New addresses a common modernization problem: critical behavior is buried in undocumented Clipper PRG code and implicit DBF relationships. Rewriting everything at once would be slow and risky.”

### 0:12–0:33 — Safety First

**Show:** `otn-01-project-initialization.png`, then `otn-10-security-review.png`.

**Say:**

“IBM Bob was the central discovery layer. It first read the project contract, created bounded tasks and specialist personas, and ran a privacy gate. The workspace contains only sanitized source and synthetic records; production access was prohibited.”

### 0:33–0:53 — Parallel Bob Analysis

**Show:** `otn-20-24-parallel-analysis-overview.png`, then the five task screenshots quickly.

**Say:**

“Bob then coordinated five read-only analyses in parallel: source inventory, data model, business rules, workflow reconstruction, and migration risk. Each report separated verified evidence from inference and unknowns, with narrow source citations.”

### 0:53–1:08 — Evidence to Approved Scope

**Show:** `bob_result/final/business-rules.md` at BR-060 through BR-064, then `poc-workflow-ranking.md`.

**Say:**

“From 46 verified rules, we selected exactly one bounded workflow: New Inhumation, with only BR-060 through BR-064 approved. The Bob budget ended after consolidation, so everything from architecture onward is clearly recorded as manual post-budget work.”

### 1:08–1:33 — Working Modern Application

**Show:** Launch or foreground the Avalonia application. Point to `SYNTHETIC DATA ONLY`, the rule list, and suggested scenarios.

**Say:**

“This is the working offline proof of concept, built with .NET, Avalonia, and SQLite. The UI, use case, domain rules, and persistence are separated. It never reads the legacy DBFs, and every demo value is visibly synthetic.”

### 1:33–1:55 — Successful Creation

**Show:** Submit `D010101`, level `1`, sublevel `1`, service type `S`, using the prefilled synthetic form.

**Say:**

“The first scenario uses an existing synthetic parcel and valid ranges. The record is created in one SQLite transaction after the approved checks pass.”

### 1:55–2:16 — Duplicate Rejection

**Show:** Submit the same parcel, level, and sublevel again. Highlight the BR-061 message.

**Say:**

“Repeating the same location is rejected as BR-061. The database also enforces the composite uniqueness rule, so validation is not limited to the screen.”

### 2:16–2:36 — Sequential Rule Rejection

**Show:** Submit `D020101`, level `1`, sublevel `2`. Highlight BR-062.

**Say:**

“Requesting sublevel two without sublevel one is rejected as BR-062, with no partial insert. Domain and database checks also cover parcel existence, service type, and level and sublevel ranges.”

### 2:36–2:50 — Automated and Independent Validation

**Show:** Run or reveal `dotnet test OldToNew.sln --no-build --configuration Release`, then briefly show `validation-report.md`.

**Say:**

“All 21 unit and SQLite integration tests pass. A separate read-only validation confirmed five of five approved rules, zero discrepancies, and two deliberate Gate 4 presentation differences.”

### 2:50–2:58 — Close

**Show:** Final slide with “IBM Bob: evidence and orchestration / Manual post-budget: PoC and validation.”

**Say:**

“Old to New turns undocumented code into traceable, approved, testable modernization work—without pretending the whole legacy system was migrated.”

## Demonstration Integrity

- IBM Bob segment: official Bob task/session evidence only.
- Manual segment: architecture, PoC, tests, validation, and submission package are labeled post-budget.
- IBM watsonx was not used.
- Only synthetic data appears.
- Do not claim a measured time-saving percentage; use the verified counts and test results.

## Backup Plan if Live Execution Is Slow

Use `manual-otn-41-poc-running.png` for the successful screen and `manual-otn-50-validation.png` for a rule rejection, then show the recorded 21/21 result in `test-results.md`. State clearly that these are captured results, not a live run.
