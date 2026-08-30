# IBM Bob Task and Session Evidence

This directory contains the public-safe task/session captures used to document
IBM Bob's role in the Old to New modernization workflow. The captures were
created from the official hackathon-provisioned IBM Bob instance. They show
task structure, bounded personas, parallel analysis, source-based findings, and
the point at which the fixed 40-Bobcoin allocation was exhausted.

The first twelve captures below are IBM Bob task/session evidence. The final
two files use a `manual-` prefix because they document work completed manually
after the Bobcoin limit; they are not presented as IBM Bob output.

## IBM Bob Evidence

| Task or phase | Session capture | Related textual output |
|---|---|---|
| OTN-01 — initialization and personas | [otn-01-project-initialization.png](otn-01-project-initialization.png) | [Project initialization](../bob_result/final/project-initialization.md) |
| OTN-10 — privacy and security gate | [otn-10-security-review.png](otn-10-security-review.png) | [Security review](../bob_result/agents/00-security-review.md) |
| OTN-20 — source inventory | [otn-20-source-inventory.png](otn-20-source-inventory.png) | [Source inventory](../bob_result/agents/01-source-inventory.md) |
| OTN-21 — data model | [otn-21-data-model.png](otn-21-data-model.png) | [Data model](../bob_result/agents/02-data-model.md) |
| OTN-22 — business rules | [otn-22-business-rules.png](otn-22-business-rules.png) | [Business rules](../bob_result/agents/03-business-rules.md) |
| OTN-23 — workflow reconstruction | [otn-23-workflow-reconstructor.png](otn-23-workflow-reconstructor.png) | [Workflows](../bob_result/agents/04-workflows.md) |
| OTN-24 — migration risks | [otn-24-migration-risk.png](otn-24-migration-risk.png) | [Migration risks](../bob_result/agents/05-migration-risks.md) |
| OTN-20–24 — parallel-agent overview | [otn-20-24-parallel-analysis-overview.png](otn-20-24-parallel-analysis-overview.png) | [Analysis summary](../bob_result/final/analysis-summary.md) |
| OTN-20–24 — task summary | [otn-20-24-task-summary.png](otn-20-24-task-summary.png) | [Analysis summary](../bob_result/final/analysis-summary.md) |
| OTN-20–24 — evidence correction overview | [otn-20-24-correction-overview.png](otn-20-24-correction-overview.png) | [Manual correction provenance](../bob_result/logs/manual-post-budget-correction.md) |
| OTN-20–24 — final report review | [otn-20-24-final-review.png](otn-20-24-final-review.png) | [Final consolidated reports](../bob_result/final/legacy-system-overview.md) |
| OTN-25 — budget boundary | [otn-25-budget-exceeded.png](otn-25-budget-exceeded.png) | [Post-budget provenance](../bob_result/logs/manual-phase3-provenance.md) |

## Clearly Labeled Manual Evidence

| Manual phase | Capture | Related textual output |
|---|---|---|
| OTN-40/41/42 — running proof of concept | [manual-otn-41-poc-running.png](manual-otn-41-poc-running.png) | [Build and test record](../bob_result/logs/otn-40-42-build-test.md) |
| OTN-50 — independent validation | [manual-otn-50-validation.png](manual-otn-50-validation.png) | [Validation report](../bob_result/final/validation-report.md) |

## Attribution Boundary

IBM Bob performed initialization, the security gate, five specialized parallel
legacy analyses, and the OTN-25 consolidation work shown above. Its fixed
40-Bobcoin allocation was exhausted during the final OTN-25 consistency pass.
One terminology-only correction and all subsequent architecture,
implementation, testing, independent validation, and submission preparation
were completed manually outside IBM Bob and are explicitly labeled as
post-budget work. IBM watsonx services were not used.

All captures were reviewed for public sharing. They contain no production data,
private customer information, personal email address, or account credential.
Only synthetic data was used in this repository.
