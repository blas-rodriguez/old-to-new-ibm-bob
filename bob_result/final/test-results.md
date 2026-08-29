# OTN-50 Independent Test Results

**Task ID:** OTN-50  
**Persona:** independent-validator  
**Date:** 2026-08-29  
**Execution:** Manual post-Bob-budget independent validation  
**Workflow:** WF-004 — New Inhumation  
**Approved scope:** BR-060, BR-061, BR-062, BR-063, BR-064  
**Result:** VERIFIED PASS

## 1. Authorized Command

Executed from `C:\LEGACY_SISTEM\modernized`:

```powershell
dotnet test OldToNew.sln --no-build --configuration Release
```

- **VERIFIED:** This was the only executable command used by the independent validator.
- **VERIFIED:** No restore, build, format, application launch, legacy execution, or production connection was performed.

## 2. Current Independent Run

| Test assembly | Passed | Failed | Skipped | Total | Runner duration |
|---|---:|---:|---:|---:|---:|
| `OldToNew.Domain.Tests.dll` | 17 | 0 | 0 | 17 | 76 ms |
| `OldToNew.IntegrationTests.dll` | 4 | 0 | 0 | 4 | 277 ms |
| **Total** | **21** | **0** | **0** | **21** | — |

- Process exit code: `0`
- Tool-observed command wall time: approximately `3.45 s`
- Pass rate: `100%`
- Failed tests: none
- Skipped tests: none

These results independently reproduce the earlier OTN-42 result in `bob_result/logs/otn-40-42-build-test.md`.

## 3. Rule-to-Test Traceability

| Rule | Automated evidence | Result |
|---|---|---|
| BR-060 | `BR_060_rejects_a_missing_parcel`; persistence-result mapping theory | **PASS** |
| BR-061 | `BR_061_rejects_duplicate_parcel_level_and_sublevel`; repeated happy-path insert; persistence-result mapping theory | **PASS** |
| BR-062 | `BR_062_rejects_a_gap_without_leaving_a_partial_row`; persistence-result mapping theory | **PASS** |
| BR-063 | Accepted-value and rejected-value theories in `IntermentRuleTests` | **PASS** |
| BR-064 | Boundary-value and out-of-range theories in `IntermentRuleTests` | **PASS** |

## 4. Test-Case Count

The 17 domain/application cases consist of:

- BR-064 accepted boundaries: 2
- BR-064 rejected ranges: 4
- BR-063 accepted inputs: 4
- BR-063 rejected inputs: 3
- BR-060/061/062 persistence-result mappings: 3
- Successful create result: 1

The four integration cases consist of:

- Missing parcel: 1
- Duplicate interment: 1
- Sequential sublevel with no partial write: 1
- Successful first sublevel followed by duplicate rejection: 1

Total: 21 tests.

## 5. VERIFIED Findings

1. The independent command exited successfully.
2. All 21 discovered tests passed.
3. No test failed or was skipped.
4. Every approved rule has automated coverage.
5. Integration tests use fresh local synthetic SQLite databases.
6. Fixtures contain visibly fictitious names, documents, parcels, and catalogs.
7. SHA-256 comparison confirmed no implementation source/project file changed during validation.

## 6. INFERRED Finding

The suite provides strong confidence for the five approved rules but is not evidence of parity for excluded behavior or the complete legacy system. This inference is not promoted to a requirement.

## 7. UNKNOWN Items

- Full-system runtime parity remains UNKNOWN because the sanitized Clipper installation cannot be built or executed.
- Multi-error precedence is not specified by approved requirements and is not a parity requirement.

## 8. Failures and Root Cause

None.

## 9. Housekeeping Observation

Four synthetic SQLite files from an earlier implementation test cycle remain in the Release `test-data` directory. The independent run cleaned its own database and was unaffected. These are generated, synthetic, ignored artifacts—not production data or a rule failure.

## 10. Final Result

**VERIFIED PASS — 21 passed, 0 failed, 0 skipped (100%).**

No implementation change is required for BR-060 through BR-064. Only synthetic data was used.

