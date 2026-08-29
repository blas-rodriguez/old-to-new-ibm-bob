# OTN-40 through OTN-42 Build and Test Log

**Date:** 2026-08-29  
**Execution:** Manual post-Bob-budget implementation  
**Workflow:** WF-004 New Inhumation  
**Approved rules:** BR-060, BR-061, BR-062, BR-063, BR-064  
**Excluded:** BR-065 and every other workflow/rule

## Environment

- .NET SDK: 10.0.400
- Target framework: `net10.0`
- Avalonia packages: 12.1.1
- Microsoft.Data.Sqlite: 10.0.11
- Runtime: Windows x64

## OTN-40 — Solution and Data Layer

- Created `modernized/OldToNew.sln` with six projects:
  - Domain
  - Application
  - SQLite infrastructure
  - Avalonia desktop
  - Domain tests
  - Integration tests
- Added a deterministic synthetic SQLite schema and seed.
- SQLite file is created below the desktop build output, never in the legacy root.
- Enabled foreign keys, a composite unique constraint, and transactional writes.

## OTN-41 — WF-004 Vertical Slice

- Added synthetic parcel lookup.
- Added an Avalonia interment-entry screen.
- Added explicit results carrying approved rule IDs.
- Persisted a single interment atomically after the approved checks succeed.
- UI and runtime contain clear `SYNTHETIC DATA ONLY` notices.

## OTN-42 — Rule Traceability

| Rule | Automated coverage |
|---|---|
| BR-060 | Missing-parcel integration test and application result mapping |
| BR-061 | Seeded duplicate integration test and unique constraint |
| BR-062 | Missing-prior test, rollback check, then sequential success |
| BR-063 | Accepted `S`/`T` and rejected unapproved values |
| BR-064 | Accepted boundary values and rejected out-of-range level/sublevel values |

## Commands and Final Results

```powershell
dotnet restore OldToNew.sln
dotnet format OldToNew.sln --verify-no-changes --no-restore --verbosity minimal
dotnet build OldToNew.sln --no-restore --configuration Release
dotnet test OldToNew.sln --no-build --configuration Release
```

| Check | Result | Measured elapsed time |
|---|---|---:|
| Restore | Exit 0 | 2.83 s |
| Format verification | Exit 0 | 12.28 s |
| Release build | Exit 0; 0 warnings; 0 errors | 4.01 s |
| Test run | Exit 0; 21 passed; 0 failed; 0 skipped | 3.47 s |
| Hidden startup smoke check | Process remained running for 4 s; stopped after verification | 4 s observation |

Test breakdown: 17 domain/application tests and 4 SQLite integration tests.

## Correction History

The first build/test cycle exposed two implementation issues:

1. A namespace collision between `OldToNew.Application` and `Avalonia.Application`.
2. SQLite connection pooling retained integration-test files during cleanup.

Both were corrected (`Avalonia.Application` was fully qualified and pooling was disabled for these local deterministic databases). The final clean results above were produced after the corrections.

## Safety and Provenance

- No root PRG or DBF file was read by the modernized application, modified, executed, reindexed, or rewritten.
- No production connection or external runtime service is present.
- Package restoration downloaded public dependencies only; no workspace content was uploaded.
- All database values used by the application and tests are visibly synthetic.
- These implementation results are manual post-budget work and are not attributed to IBM Bob.

