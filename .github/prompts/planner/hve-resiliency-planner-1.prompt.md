---
description: Run Task Planner Prompt 1 to create the executive master resiliency report from HVE research
---

# Application HVE Planner 1 Executive Report

Use [Application Task Planner Context](../../instructions/hve-resiliency-planner-context.instructions.md).

---

Run `/hve-resiliency-planner-0` first to lock in evidence constraints.

```text
Using the attached HVE research artifact, create <repo-name>-Master.md.

Include:
- Overview Summary (1-2 paragraphs): briefly describe the process used (HVE evidence-only research then Task Planner synthesis) and the overall findings/themes for this repo.
- Application summary (what this code does)
- Actual dependency map (Azure + non-Azure)
- Resiliency gaps vs {customerName} failover model
- External provider considerations
- Open questions explicitly marked
- Priority Legend (P0/P1/P2/P3) as a dedicated section near the top
- Prioritized findings and remediation plan (every finding must have a priority)
- Findings must be grouped and ordered: P0 first, then P1, then P2, then P3

Do not introduce findings not present in the research.

Use this Priority Legend:
- P0 - Blocking/Critical Risk
- P1 - High Priority
- P2 - Improvement/Best Practice (Non-Blocking)
- P3 - Non-Blocking Code Consistency (Best Practices / Maintainability)

OUTPUT FORMAT for <repo-name>-Master.md (use this exact section order):
1) Title: <repo-name> - Executive / Master Resiliency Report
2) Overview Summary (1-2 paragraphs)
3) Priority Legend
4) Application Summary
5) Architecture and Dependency Map
6) Prioritized Findings (grouped and ordered P0 then P1 then P2 then P3) using a table with columns:
   - Finding ID (e.g., F-001)
   - Priority (P0/P1/P2/P3)
   - Title
   - What is true (summary of the research finding)
   - Why it matters (impact during zone loss or failover between West US and West US 2 in the target active/active deployment)
   - Evidence references (file+line citations or research reference IDs)
   - Recommended remediation summary (1-3 bullets; no code here)
   - Owner suggestion (team/component)
7) Open Questions
8) External Provider Considerations
```
