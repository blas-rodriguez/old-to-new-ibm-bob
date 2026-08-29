# Manual Post-Budget Provenance

**Date:** 2026-08-29  
**Scope:** Manual continuation OTN-30 through OTN-62  
**Status:** Gate 4 APPROVED; OTN-60 through OTN-62 COMPLETE

## Reason for Manual Continuation

The hackathon-provisioned IBM Bob instance reached its fixed 40-Bobcoin budget during the final OTN-25 consistency pass. Hackathon support confirmed that the allocation cannot be replenished and advised continuing remaining work manually while distinguishing Bob-assisted and manual contributions.

## Attribution

- **IBM Bob:** OTN-00 through OTN-25 analysis and consolidation, including the Phase 2 parallel-agent workflow and its saved session evidence.
- **Manual post-budget work:** final OTN-25 terminology corrections; OTN-30/OTN-31 architecture and ranking; Gate-3-approved OTN-40/OTN-41/OTN-42 implementation and tests.
- **Independent manual validation:** OTN-50 ran in a separate read-only agent context, re-executed tests by explicit user authorization, and did not edit implementation source.
- **Manual post-budget submission work:** OTN-60 final report, OTN-61 demo script, and OTN-62 delivery checklist. These documents summarize existing evidence and do not claim that IBM Bob performed post-budget implementation or validation.

## Constraints Preserved

- Only Gate-2-approved findings are design inputs.
- `INFERRED` and `UNKNOWN` findings are not business requirements.
- No root-level PRG or DBF file may be modified, executed, reindexed, or rewritten.
- No production connection or non-synthetic fixture is permitted.
- Gate 3 approved only WF-004 with BR-060 through BR-064; BR-065 remains excluded.
- Gate 4 accepted two deliberate target-system differences: direct entry of the composed parcel code and modern English messages with rule identifiers. No implementation correction was required.
- All proof-of-concept source, generated SQLite data, and build outputs remain under `modernized/`.
