# Target Architecture Diagram

**Task ID:** OTN-30  
**Role:** Manual modernization-architect role (non-Bob, post-budget)  
**Date:** 2026-08-29  
**Status:** COMPLETE — implementation awaits Gate 3

```mermaid
flowchart TB
    USER["Demo user"] --> VIEW["Avalonia Views"]

    subgraph PRESENTATION["Presentation"]
        VIEW --> VM["ViewModels"]
        VM --> DTO["Requests / Results"]
    end

    subgraph APPLICATION["Application"]
        DTO --> USECASE["Selected workflow use case"]
        USECASE --> PORTS["Repository + transaction ports"]
    end

    subgraph DOMAIN["Domain"]
        USECASE --> RULES["Gate-3-approved rules only"]
        RULES --> ENTITIES["Entities and value objects"]
    end

    subgraph INFRA["Infrastructure"]
        PORTS --> REPOS["SQLite repositories"]
        REPOS --> TX["Atomic transaction"]
        TX --> SQLITE[("SQLite synthetic demo database")]
        MIG["Schema migrations"] --> SQLITE
        FIX["Deterministic synthetic fixtures"] --> SQLITE
    end

    subgraph TESTS["Verification"]
        UNIT["Rule unit tests"] --> RULES
        INT["SQLite integration tests"] --> REPOS
        TRACE["Rule-to-test traceability"] --> UNIT
        TRACE --> INT
    end

    LEGACY["Root PRG / DBF evidence\nread-only and never executed"] -. "documented evidence only" .-> TRACE
    LEGACY -. "no runtime dependency" .-> APPLICATION
```

## Architecture Statements

- **TARGET DECISION:** Avalonia owns interaction only; business rules remain in the domain/application layers.
- **TARGET DECISION:** SQLite foreign keys, unique indexes, and transactions replace application-only integrity and non-atomic writes identified in MR-054/MR-055.
- **TARGET DECISION:** Tests reference approved rule IDs and do not derive new behavior from convention.
- **VERIFIED constraint:** Root PRG and DBF files remain read-only evidence and are not runtime inputs.
- **UNKNOWN:** Production deployment, identity, concurrency scale, and data-migration requirements remain outside this PoC.

Only synthetic fixtures are permitted in the target database and screenshots.

