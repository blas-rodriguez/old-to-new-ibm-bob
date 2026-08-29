# OTN-50 Independent Validation Report

**Task ID:** OTN-50  
**Persona:** independent-validator  
**Date:** 2026-08-29  
**Execution:** Manual post-Bob-budget independent validation  
**Workflow:** WF-004 — New Inhumation  
**Gate-3-approved scope:** BR-060, BR-061, BR-062, BR-063, BR-064  
**Explicitly excluded:** BR-065 and all other legacy behavior  
**Overall verdict:** VERIFIED PASS — Gate 4 APPROVED on 2026-08-29

## 1. Independence and Safety

This validation was performed in an agent context separate from the context that implemented OTN-40 through OTN-42.

- **VERIFIED:** No root-level PRG or DBF file was read, executed, or modified. The legacy side used only approved Phase 2 reports and their recorded source citations.
- **VERIFIED:** The modernized source and tests were inspected read-only. Pre/post SHA-256 comparison confirmed all 30 non-generated source/project files were unchanged.
- **VERIFIED:** The only executable validation command was the user-authorized `dotnet test OldToNew.sln --no-build --configuration Release`.
- **VERIFIED:** No restore, build, format, application launch, production connection, or external runtime service was used by the independent validator.
- **VERIFIED:** Only visibly synthetic data was used.

## 2. Scope and Files Inspected

Approved legacy findings:

- `bob_result/final/business-rules.md`
- `bob_result/final/data-model.md`
- `bob_result/agents/03-business-rules.md`
- `bob_result/agents/04-workflows.md`

Implementation and test evidence:

- `modernized/src/OldToNew.Domain/IntermentRules.cs`
- `modernized/src/OldToNew.Application/CreateIntermentUseCase.cs`
- `modernized/src/OldToNew.Infrastructure.Sqlite/SqliteDatabaseInitializer.cs`
- `modernized/src/OldToNew.Infrastructure.Sqlite/SqliteIntermentStore.cs`
- `modernized/src/OldToNew.Desktop/ViewModels/MainViewModel.cs`
- `modernized/src/OldToNew.Desktop/Views/MainWindow.axaml`
- `modernized/tests/OldToNew.Domain.Tests/IntermentRuleTests.cs`
- `modernized/tests/OldToNew.IntegrationTests/SqliteIntermentStoreTests.cs`
- `bob_result/logs/otn-40-42-build-test.md`

## 3. Per-Rule Comparison

| Rule | Approved legacy behavior | Modern implementation and test evidence | Verdict |
|---|---|---|---|
| BR-060 | **VERIFIED:** A new inhumation requires an existing parcel. Approved report: `business-rules.md:242–245`, citing `MENU.PRG`, `AltaInhu()`, lines 280–303. | **VERIFIED:** The use case normalizes and checks the parcel before creation (`CreateIntermentUseCase.cs:11–17`); SQLite repeats the check inside the transaction (`SqliteIntermentStore.cs:46–49`) and has a parcel FK (`SqliteDatabaseInitializer.cs:39–59`). Missing parcel is tested in `SqliteIntermentStoreTests.cs:37–43`. | **PASS** |
| BR-061 | **VERIFIED:** Existing `(parcel, level, sublevel)` is rejected. Approved report: `business-rules.md:247–250`, citing `MENU.PRG`, `AltaInhu()`, lines 295–300. | **VERIFIED:** Explicit duplicate query (`SqliteIntermentStore.cs:51–54,109–126`), composite unique constraint (`SqliteDatabaseInitializer.cs:59`), and duplicate-result mapping (`SqliteIntermentStore.cs:77–80`). Seeded and post-create duplicate paths are tested at `SqliteIntermentStoreTests.cs:45–51,66–74`. | **PASS** |
| BR-062 | **VERIFIED:** Every earlier sublevel for the same parcel and level must exist before saving the requested sublevel. Approved report: `business-rules.md:252–255`, citing `MENU.PRG`, `CargaSub()`, lines 314–321. | **VERIFIED:** Store loads the same parcel/level sublevels and rejects the first missing value before insert (`SqliteIntermentStore.cs:56–73,129–154`). Integration rejects sublevel 2, then creates 1 and 2, proving no partial row remained (`SqliteIntermentStoreTests.cs:53–64`). | **PASS** |
| BR-063 | **VERIFIED:** Service type is `S` or `T`. Approved report: `business-rules.md:257–260`, citing `MENU.PRG`, `CargaSub()`, `BuscaNivel()`, and `Listado()`. | **VERIFIED:** Domain accepts only normalized `S`/`T` (`IntermentRules.cs:20–26`); use case persists canonical value; SQLite enforces `S`/`T`; UI exposes only those options (`MainViewModel.cs:12`, `MainWindow.axaml:146–147`). Accepted and rejected values are tested at `IntermentRuleTests.cs:29–49`. | **PASS** |
| BR-064 | **VERIFIED:** Level is 1–3 and sublevel is 1–6. Approved report: `business-rules.md:262–265`, citing `MENU.PRG`, `AltaInhu()`, lines 289–290. | **VERIFIED:** Domain enforces both ranges (`IntermentRules.cs:5–18`); SQLite duplicates the checks (`SqliteDatabaseInitializer.cs:42–43`); UI requires whole-number input (`MainViewModel.cs:126–130`). Boundaries and invalid values are tested at `IntermentRuleTests.cs:8–27`. | **PASS** |

## 4. Validation Dimensions

### Inputs

- **VERIFIED:** Parcel codes are normalized to uppercase before lookup.
- **VERIFIED:** Level and sublevel must be whole numbers and satisfy BR-064.
- **VERIFIED:** The UI offers only `S` and `T`; domain validation also rejects every other value.
- **ACCEPTED DIFFERENCE — Gate 4 approved:** Legacy gathered Sector, Row, and Plot separately and composed the parcel code. The PoC accepts the already-composed synthetic parcel code. Parcel-existence behavior remains compliant with BR-060.
- **UNKNOWN:** Exact legacy behavior for lowercase service-type keystrokes was not approved as a requirement. The PoC normalizes lowercase but persists only canonical `S` or `T`.

### Calculations

- **VERIFIED:** BR-060 through BR-064 define no monetary, fee, total, or aggregation calculation.
- **NOT APPLICABLE:** No calculation-parity claim is made.

### State Transitions

- **VERIFIED:** Creation checks parcel existence, approved ranges, service type, duplicate identity, and prior-sublevel sequence before inserting.
- **VERIFIED:** Duplicate and sequential checks occur inside the same SQLite transaction as the insert.
- **VERIFIED:** Success commits one interment; rejection inserts no interment.
- **UNKNOWN:** Precedence among multiple simultaneously invalid inputs is not specified by approved findings and is not treated as a requirement.

### Outputs

- **VERIFIED:** Success persists one interment and returns `CREATED`.
- **VERIFIED:** Rule failures return BR-060, BR-061, BR-062, BR-063, or BR-064.
- **ACCEPTED DIFFERENCE — Gate 4 approved:** Modern messages are concise English target-system messages rather than exact replicas of legacy Spanish text. Rule identity and rejection effect are preserved.

### Error Paths

- **VERIFIED:** Missing parcel, duplicate location, missing prior sublevel, unsupported service type, and invalid ranges are rejected.
- **VERIFIED:** BR-062 integration demonstrates no partial insert.
- **VERIFIED:** SQLite constraints provide defense in depth for parcel reference, duplicate identity, ranges, service type, funeral-home reference, and coffin reference.

### Unsupported and Excluded Cases

- **VERIFIED:** BR-065, the 15-day recent-interment highlight, is explicitly excluded and has no implementation. Its only `modernized/` reference is the README exclusion statement.
- **VERIFIED:** Detailed legacy display, navigation, cancellation, modification, exhumation, and unrelated workflows were not treated as approved PoC behavior.
- **VERIFIED:** No parity claim is made for the full legacy application.

## 5. VERIFIED Findings

1. All five Gate-3-approved rules have implementation and automated-test traceability.
2. All rule-rejection paths map to explicit approved rule IDs.
3. The SQLite write is transactional.
4. The independent test run passed 21 of 21 tests.
5. BR-065 is absent as required.
6. Only synthetic fixtures were used.

## 6. INFERRED Findings

1. Direct parcel-code input is a deliberate PoC simplification that preserves BR-060 without reproducing the three-field interaction.
2. English messages are a target presentation decision and do not change the verified rejection behavior.

These inferences are not promoted to business requirements.

## 7. UNKNOWN Items

1. Exact equivalence of lowercase keyboard handling in the original service-type prompt.
2. Error precedence when a request contains multiple invalid values.
3. Full legacy runtime behavior because the sanitized Clipper snapshot cannot build or execute completely.

No UNKNOWN item blocks the five approved rules.

## 8. Conflicts and Housekeeping

- **VERIFIED:** No behavioral conflict was found between approved reports and the implementation for BR-060 through BR-064.
- **VERIFIED, non-behavioral:** Four synthetic SQLite files from an earlier failed cleanup remain under `modernized/tests/OldToNew.IntegrationTests/bin/Release/net10.0/test-data/`. They predate this validation, are ignored build artifacts, and do not affect parity. Current tests clean up their own files.
- **RECOMMENDATION:** Remove generated `bin/` and `obj/` artifacts before repository publication, after Gate 4 and without altering source/tests.

## 9. Final Verdict

**VERIFIED PASS — Gate 4 APPROVED on 2026-08-29**

- Approved rules passed: 5 of 5
- Failed rules: 0
- Accepted target-system differences: 2
- Blocking UNKNOWN items: 0
- Verified implementation discrepancies: 0
- Automated tests: 21 passed, 0 failed, 0 skipped

No implementation fix is required. Only synthetic data was used.
