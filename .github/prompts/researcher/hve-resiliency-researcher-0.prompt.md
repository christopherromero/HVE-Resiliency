---
description: Run Prompt 0 repository context frame for application resiliency research
agent: Task Researcher
---

# Application Resiliency Researcher 0

Use [Application Platform Context](../../instructions/hve-resiliency-platform-context.instructions.md).

```text
Research this repository as part of the Application within the {customerName} platform.

{customerName} operates applications in Azure and is validating readiness for:
- Zone failure within West US 2
- Full regional failover from West US 2 to West US

First analyze the application architecture for this code base.
Then focus exclusively on identifying current implementation behavior, application flow, assumptions, constraints, what are the risks, why this is a risk to application resiliency during a zone or region failover, and what are the impacts if not changed.

Analyze region, zone, and application failover risk for each gap/finding:
- P0 — Blocking/Critical Risk
- P1 — High Priority (Potential for Blocking)
- P2 — Improvement/Best Practice (Non-Blocking)
- P3 — Non-Blocking Code Consistency (Best Practices / Maintainability)
- Provide an explanation why each issue is rated at that level
- Identify the area in the code where the issue is located (file + line #)

- Provide an application walk through and high-level architecture for this microservice
- Capture existing mitigations already present (retries/timeouts/fallbacks/feature flags/runbooks), with evidence (file + line).
Capture constraints/limitations that affect failover (platform constraints, dependency capabilities, configuration constraints, operational constraints), with evidence (file + line) when present.
Do not recommend changes.
```
