# Old to New — Submission Checklist

**Task ID:** OTN-62  
**Execution:** Manual post-Bob-budget submission preparation  
**Date:** 2026-08-29  
**Status:** PACKAGE CONTENT COMPLETE — publication and form submission pending

## 1. Submission Fields

- [ ] Confirm final project title: **Old to New**.
- [ ] Confirm team name and final registered team members on the competition platform.
- [ ] Create and paste the public repository URL: **[PENDING]**.
- [ ] Upload/publish the demo video and paste the public URL: **[PENDING]**.
- [ ] Verify the competition form's current deadline and timezone immediately before submission.
- [ ] Submit through the registered team's official entry, then save confirmation evidence.

Support stated a deadline of **August 30, 2026 at 10:00 AM ET** (approximately **11:00 AM in America/Buenos_Aires**). Treat the competition platform as authoritative and recheck it before final submission.

## 2. Required Written Content

- [x] English final report: `bob_result/final/final-hackathon-report.md`.
- [x] Problem statement under 500 words: “Submission-Ready Problem Statement” in the final report.
- [x] Solution statement under 500 words: “Submission-Ready Solution Statement” in the final report.
- [x] IBM Bob usage statement: “Bob Usage Statement” in the final report.
- [x] IBM Bob and post-budget manual work are explicitly separated.
- [x] IBM watsonx is accurately disclosed as **not used**.
- [x] No fabricated productivity/time-saved claim is present.
- [x] Technical results cite repository evidence and approved rule IDs.

## 3. Prototype and Repository

- [x] Working prototype is under `modernized/` only.
- [x] `modernized/README.md` contains build, test, and run commands.
- [x] WF-004 is the only migrated workflow.
- [x] Only BR-060 through BR-064 are implemented as approved legacy behavior.
- [x] BR-065 is explicitly excluded.
- [x] Release build recorded with 0 warnings and 0 errors.
- [x] 21/21 automated tests pass.
- [x] Independent OTN-50 validation passed 5/5 approved rules.
- [x] Gate 4 accepted the two deliberate target-system differences.
- [x] No production or network runtime connection exists.
- [x] All fixtures are visibly synthetic.
- [ ] Initialize a source-control repository; none exists in this workspace yet.
- [ ] Review the staged file list before publishing.
- [ ] Confirm generated `bin/`, `obj/`, and SQLite `.db` files are not committed.
- [ ] Confirm `_resguardo_privado/` is not present or staged.

Recommended pre-publication commands from the workspace root:

```powershell
git init
git status --short
git check-ignore -v modernized/tests/OldToNew.IntegrationTests/bin/Release/net10.0/test-data/*.db
```

Do not assemble a public ZIP by copying the entire folder blindly. Four old synthetic SQLite files exist under ignored `bin/` output, and generated `obj/` metadata contains local build-machine paths. Git will exclude both directories through `modernized/.gitignore`, but a manual ZIP may include them.

## 4. Reproducibility Check

Run from `modernized/` before recording or publishing:

```powershell
dotnet restore OldToNew.sln
dotnet format OldToNew.sln --verify-no-changes --no-restore --verbosity minimal
dotnet build OldToNew.sln --no-restore --configuration Release
dotnet test OldToNew.sln --no-build --configuration Release
dotnet run --project src/OldToNew.Desktop/OldToNew.Desktop.csproj
```

- [ ] Re-run commands on the final publishable tree.
- [ ] Confirm 0 build warnings and 0 build errors.
- [ ] Confirm 21 passed, 0 failed, 0 skipped.
- [ ] Confirm the app opens and displays `SYNTHETIC DATA ONLY`.
- [ ] Confirm the three demo scenarios in `demo-script.md` behave as recorded.

## 5. Bob Task/Session Evidence

All 14 current PNG files were visually reviewed on 2026-08-29. No personal email, account identifier, production value, or private Slack content is visible. `DEMO00`, visible in security evidence, is explicitly synthetic.

| Evidence | Present | Privacy reviewed | Purpose |
|---|---|---|---|
| `bob_sessions/otn-01-project-initialization.png` | Yes | Yes | Initialization and task setup |
| `bob_sessions/otn-10-security-review.png` | Yes | Yes | Safety gate |
| `bob_sessions/otn-20-source-inventory.png` | Yes | Yes | Source inventory task |
| `bob_sessions/otn-21-data-model.png` | Yes | Yes | Data model task |
| `bob_sessions/otn-22-business-rules.png` | Yes | Yes | Business rules task |
| `bob_sessions/otn-23-workflow-reconstructor.png` | Yes | Yes | Workflow reconstruction task |
| `bob_sessions/otn-24-migration-risk.png` | Yes | Yes | Migration risk task |
| `bob_sessions/otn-20-24-parallel-analysis-overview.png` | Yes | Yes | Parallel-task overview |
| `bob_sessions/otn-20-24-task-summary.png` | Yes | Yes | Phase 2 task summary |
| `bob_sessions/otn-20-24-correction-overview.png` | Yes | Yes | Evidence-quality correction pass |
| `bob_sessions/otn-20-24-final-review.png` | Yes | Yes | Final Phase 2 review |
| `bob_sessions/otn-25-budget-exceeded.png` | Yes | Yes | Honest budget-limit provenance |
| `bob_sessions/manual-otn-41-poc-running.png` | Yes | Yes | Manual post-budget running PoC |
| `bob_sessions/manual-otn-50-validation.png` | Yes | Yes | Manual post-budget validation scenario |

- [x] Every Bob-attributed major phase has task/session evidence.
- [x] The OTN-25 budget interruption is disclosed instead of hidden.
- [x] Manual screenshots use a `manual-` prefix.
- [ ] Optionally capture a final public-safe 21/21 terminal result if the video needs clearer test evidence.

## 6. Three-Minute Video

- [x] English timed script exists at `bob_result/final/demo-script.md`.
- [x] Script target is under the three-minute maximum.
- [x] More than 90 seconds are allocated to the running solution and its tests.
- [x] IBM Bob Agent mode, task structure, parallel roles, and source understanding are shown.
- [x] The working PoC, rule messages, tests, and measurable results are shown.
- [x] Bob-assisted and manual post-budget contributions are stated aloud.
- [ ] Record at 1080p or higher.
- [ ] Keep the final cut at or below 3:00.
- [ ] Verify audio clarity and readable zoom.
- [ ] Verify no account settings, email, Slack, or private browser tab appears.
- [ ] Upload publicly and test the link in a private/incognito browser window.

## 7. Privacy and Safety Audit

- [x] Root contains 25 PRGs and 22 DBFs, all retained as read-only evidence.
- [x] No NTX/CDX index file is present or required for the PoC.
- [x] No `_resguardo_privado/`, `backup/`, `original/`, or `production/` directory was present during the final audit.
- [x] No ZIP, RAR, 7z, BAK, dump, or SQL backup was present during the final audit.
- [x] No real person, company, address, credential, account, or production identifier is used in generated content.
- [x] No production connection is configured or permitted.
- [x] Screenshot pixel content was reviewed, not merely filenames.
- [ ] Re-run the same privacy check after creating the public repository and before submission.

## 8. Attribution Matrix

| Work | Attribution to publish |
|---|---|
| OTN-00/01 initialization | IBM Bob |
| OTN-10 safety review | IBM Bob |
| OTN-20 through OTN-24 parallel analyses | IBM Bob |
| OTN-25 consolidation | IBM Bob; final terminology-only correction manual after budget exhaustion |
| OTN-30/31 architecture and selection | Manual post-budget, outside IBM Bob |
| OTN-40/41/42 implementation and tests | Manual post-budget, outside IBM Bob |
| OTN-50 independent validation | Manual post-budget, separate read-only agent context |
| OTN-60/61/62 submission package | Manual post-budget, outside IBM Bob |
| IBM watsonx | Not used |

- [x] No post-budget work is attributed to IBM Bob.
- [x] No external/personal Bob quota is claimed.
- [x] The fixed 40-Bobcoin limit is disclosed factually.

## 9. Final Submission Review

- [ ] Replace every `[PENDING]` URL field.
- [ ] Open every public link without being signed in.
- [ ] Confirm the repository license/visibility required by the competition.
- [ ] Confirm the final report and form use English.
- [ ] Confirm problem and solution text each remain below 500 words after any form edits.
- [ ] Confirm video duration and required live-demonstration duration.
- [ ] Confirm the repository contains `bob_sessions/` evidence.
- [ ] Confirm no generated/private file appears in the public commit.
- [ ] Submit before the platform deadline.
- [ ] Save a screenshot or receipt of successful submission.

## Final Status

The technical package is ready. Submission is blocked only by user-owned publication steps: creating the public repository, recording/uploading the video, inserting the URLs, and submitting the competition form.

Only synthetic data was used.
