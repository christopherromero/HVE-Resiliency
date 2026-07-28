---
name: hve-resiliency-research
description: Use for application resiliency research covering zone failure in West US 2 and regional failover from West US 2 to West US with the task-researcher workflow, evidence-only outputs, and P0-P3 priority classification.
---

# HVE Resiliency Research

Use this skill when you need the full resiliency research sequence for this repository.

Use [Resiliency Research Platform Context](../../instructions/hve-resiliency-platform-context.instructions.md).

## Activation Guidance

Auto-load this skill for requests related to resiliency, Azure zone survivability, or regional failover research.

## Activation Behavior

When this skill is activated (via `/hve-resiliency-research` or by matching the activation guidance), the agent MUST immediately begin executing the Required Workflow starting at Phase 1, Prompt 0. Do not prompt the user for which prompt to run. Do not skip to service-specific prompts (7-18) without completing Prompts 0-6 first.

## Required Workflow

Phases are strictly sequential. Each phase must complete before the next phase begins.

### Phase 1: Core Research (Prompts 0-7) — Start Here

Phase 1 is mandatory and sequential. Always begin with Prompt 0.

1. Run `/hve-resiliency-researcher-0` first to establish the repository context frame.
2. Review the resulting research artifact in `.copilot-tracking/research/`.
3. Run `/clear` before each next prompt.
4. Run `/hve-resiliency-researcher-1`.
5. Review the Prompt 1 output. Note which dependencies are confirmed as used (Section 1). Dependencies in Section 2 and Section 3 are excluded from all subsequent prompts.
6. Run `/clear`.
7. Run `/hve-resiliency-researcher-2`.
8. Run `/clear`.
9. Run `/hve-resiliency-researcher-3`.
10. Run `/clear`.
11. Run `/hve-resiliency-researcher-4`.
12. Run `/clear`.
13. Run `/hve-resiliency-researcher-5`.
14. Run `/clear`.
15. Run `/hve-resiliency-researcher-6` when shared dependency risk analysis is needed.
16. Run `/clear`.
17. Run `/hve-resiliency-researcher-7-logging` (Logging).

### Phase 2: Service-Specific Research (Prompts 8-19, Circumstantial)

Phase 2 runs only after Phase 1 is complete. Run only the prompts matching dependencies confirmed in Prompt 1 Section 1. Skip services not found. Recommend applicable prompts based on Prompt 1 results.

18. Run `/clear`.
19. Run `/hve-resiliency-researcher-8-appgw` (App Gateway)
20. Run `/clear`.
21. Run `/hve-resiliency-researcher-9-functions` (Azure Functions)
22. Run `/clear`.
23. Run `/hve-resiliency-researcher-10-keyvault` (Key Vault)
24. Run `/clear`.
25. Run `/hve-resiliency-researcher-11-aks-istio` (AKS and Istio)
26. Run `/clear`.
27. Run `/hve-resiliency-researcher-12-cosmosdb` (Cosmos DB)
28. Run `/clear`.
29. Run `/hve-resiliency-researcher-13-sql` (SQL Server)
30. Run `/clear`.
31. Run `/hve-resiliency-researcher-14-redis` (Redis)
32. Run `/clear`.
33. Run `/hve-resiliency-researcher-15-storage` (Azure Storage)
34. Run `/clear`.
35. Determine whether Cosmos DB and/or Azure SQL were confirmed in the Prompt 1 Section 1 dependency inventory, then run the matching Kafka prompt per the Database-to-Kafka Pairing Standard (see [Resiliency Research Platform Context](../../instructions/hve-resiliency-platform-context.instructions.md)):
    * Cosmos DB confirmed, Azure SQL not confirmed -> Run `/hve-resiliency-researcher-16-kafka-active-active`
    * Azure SQL confirmed, with or without Cosmos DB -> Run `/hve-resiliency-researcher-16-kafka-active-standby-confluent`
    * Neither confirmed -> Ask the user which Kafka topology the application uses before proceeding
36. Run `/clear`.
37. Run `/hve-resiliency-researcher-17-networking` (Networking)
38. Run `/clear`.
39. Run `/hve-resiliency-researcher-18-entraid` (Entra ID)
40. Run `/clear`.
41. Run `/hve-resiliency-researcher-19-apim` (APIM)

### Phase 3: Consolidation

42. Run `/clear`.
43. Run `/hve-resiliency-researcher-consolidate` to merge all research outputs from Prompts 0-7 and any service-specific prompts into a single consolidated research document.
44. Review the consolidated report at `.copilot-tracking/research/`.

### Phase 4: Planning

45. Run `/clear`.
46. Run `/hve-resiliency-planner-0` to lock in evidence constraints from the consolidated research.
47. Run `/hve-resiliency-planner-1` to create the Executive / Master Resiliency Report.
48. Run `/clear`.
49. Run `/hve-resiliency-planner-0` again to re-establish evidence lock-in.
50. Run `/hve-resiliency-planner-2` to create the Developer Guide with code-level remediation.

### Phase 5: Code-Level Resiliency Assessment Report

51. Run `/clear`.
52. Run `/hve-resiliency-planner-3a` to create the report header, Table of Contents, and Assessment Overview (Section 1).
53. Run `/clear`.
54. Run `/hve-resiliency-planner-3b` to append P0 and P1 Resilient Focused Recommendations (Section 2, partial).
55. Run `/clear`.
56. Run `/hve-resiliency-planner-3c` to append P2/P3 resiliency findings and Non-Resilient Focused Recommendations (Sections 2 completion + Section 3).
57. Run `/clear`.
58. Run `/hve-resiliency-planner-3d` to append IaC Gap Analysis, Full Finding Matrix, and Microsoft Standards Alignment (Sections 4-6) with final validation.
59. Review the completed report at `Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`.

## Execution Rules

* Keep research findings (Phases 1-3) evidence-only and forensic
* Do not include remediation recommendations in research phases
* Do not include code examples in research phases
* Classify every finding using P0 / P1 / P2 / P3 priorities
* Cite file and line-level evidence for every substantive claim
* Write each research output to `.copilot-tracking/research/` and use the repository name as the prefix for all output files (e.g., `<repo-name>-research-output.md`).
* Planning outputs (Phase 4) may include remediation and code examples

## Priority Definitions

* P0: Critical / Blocking. Causes outage, data loss, duplicate charges, or inability to fail over safely.
* P1: Required, Non-Blocking. Materially increases application risk, data risk, or customer impact during failure.
* P2: Improvement / Best Practice. Does not materially impact correctness but weakens resilience posture.
* P3: Non-Blocking Code Consistency. Maintainability, readability, duplication, or inconsistent patterns that are non-blocking.

## Service Exclusion Rule

* After Prompt 1 completes, dependencies in Section 2 (Checked But Not Present) and Section 3 (Not Applicable) are dropped from scope
* Prompts 2-6, service-specific prompts (7-18), and the consolidation report analyze only Section 1 dependencies (evidence-confirmed)
* In Phase 2, run only the service-specific prompts for dependencies found in Section 1

## Deliverable Templates

Use these templates as the expected output shape per prompt.

### Prompt 0 Deliverable Template

```text
# Prompt 0 Research Output

## Scope
- Repository and bounded focus area

## Observed Implementation Behavior
- Finding
  - Priority: P0 / P1 / P2 / P3
  - Evidence: <file path>:<line>
  - Existing mitigations: <if any, with evidence>
  - Constraints/limitations: <if any, with evidence>

## Application Flow
- Finding
  - Priority: P0 / P1 / P2 / P3
  - Evidence: <file path>:<line>
  - Existing mitigations: <if any, with evidence>

## Assumptions and Constraints
- Finding
  - Priority: P0 / P1 / P2 / P3
  - Evidence: <file path>:<line>
  - Constraints/limitations: <if any, with evidence>
```

### Prompt 1 Deliverable Template

```text
# Prompt 1 Research Output

## SECTION 1 - USED DEPENDENCIES (EVIDENCE CONFIRMED)
- Service / Dependency name:
- Type (Azure service or Non-Azure):
- Evidence (file path + line number):
- Brief description of how it is used:
- Whether it materially impacts zone or region failover (Yes/No + why):
- Existing mitigations present (if any): with evidence (file path + line number)
- Health check present for this dependency? (Yes/No + evidence)
- How health is determined: + evidence
- Is dependency health surfaced to GLB health evaluation? (Yes/No/Unclear + evidence)
- What GLB probes hit (endpoint/path/port) and conditions: + evidence
- Constraints/limitations (if any): with evidence (file path + line number)

## SECTION 2 - CHECKED BUT NOT PRESENT
- Service / Dependency name:
- Reason it was evaluated:
- Explicit statement: No references found in code, config, IaC, or pipelines

## SECTION 3 - NOT APPLICABLE
- Service / Category name:
- Reason it does not apply:
```

### Prompt 2 Deliverable Template

```text
# Prompt 2 Research Output

## Region and Zone Assumptions
- Assumption:
- Priority: P0 / P1 / P2 / P3
- Failover relevance (West US 2 to West US):
- Evidence: <file path>:<line>
- Existing mitigations present (if any): with evidence
- Constraints/limitations (if any): with evidence
```

### Prompt 3 Deliverable Template

```text
# Prompt 3 Research Output

## Dependency Survivability Findings
- Service:
- Priority: P0 / P1 / P2 / P3
- Region assumption in endpoint/credential/identity:
- Fallback or multi-region logic present:
- Health check present / health-to-GLB linkage:
- Evidence: <file path>:<line>
- Existing mitigations present (if any): with evidence
- Constraints/limitations (if any): with evidence
```

### Prompt 4 Deliverable Template

```text
# Prompt 4 Research Output

## State and Data Characteristics
- Characteristic:
- Priority: P0 / P1 / P2 / P3
- Evidence: <file path>:<line>
- Existing mitigations present (if any): with evidence
- Constraints/limitations (if any): with evidence

## Data Loss Potential (Facts Only)
- Where loss could occur:
- Failure condition (zone loss/regional failover/partial outage):
- Writes/messages/records at risk:
- Priority: P0 / P1 / P2 / P3
- Evidence: <file path>:<line>
- Existing mitigations present (if any): with evidence

## Failover Risk Observations
- Observation:
- Priority: P0 / P1 / P2 / P3
- Evidence: <file path>:<line>
- Existing mitigations present (if any): with evidence
- Constraints/limitations (if any): with evidence
```

### Prompt 5 Deliverable Template

```text
# Prompt 5 Research Output

- Failure mode:
- Priority: P0 / P1 / P2 / P3
- Triggering dependency + failure type (timeout/DNS/auth/partial outage):
- Code path / entrypoint:
- Observed behavior (startup fail/degrade/data loss/blocking):
- User/customer-visible impact:
- Business impact:
- Blast radius:
- Data loss potential:
- Data consistency risk:
- Detection signals:
- Existing mitigations present (evidence):
- Constraints/limitations (evidence):
- Manual ops workaround (references):
- Evidence citations (files + line numbers):
```

### Prompt 6 Deliverable Template

```text
# Prompt 6 Research Output

## Shared and Cross-Repository Dependencies
- Dependency:
- Priority: P0 / P1 / P2 / P3
- Ownership boundary:
- Zone or region failover risk implication:
- Evidence: <file path>:<line>
- Existing mitigations present (if any): with evidence
- Constraints/limitations (if any): with evidence
```

### Service-Specific Prompts (7-18) Deliverable Template

```text
# Prompt N Research Output — <Service Name>

(repeat per issue)
- Issue Description:
- Risk Level (P0/P1/P2/P3):
- Code location (file + line number):
- Why this is a risk to app, zone or region failover:
- Impact(s) if this is not changed:
- Existing mitigations present (evidence):
- Constraints/limitations (evidence):
- Remediation guidance: None (HVE Task Researcher role is evidence-only)
```

### Consolidated Report Deliverable Template

```text
# HVE Task Research — <repo-name>

Assessment Scope:
- Repository: <repo-name>
- Focus: Zone survivability and regional failover
- Regions Evaluated: West US 2 → West US
- Assessment Date: YYYY-MM-DD
- Generated By: HVE Task Researcher

## 1. Repository Context

## 2. Dependency Inventory
### 2.1 Used Dependencies (Evidence Found)
### 2.2 Checked but Not Present
### 2.3 Not Applicable Dependency Categories

## 3. Region and Zone Assumptions
(Per-finding template: Finding ID, Priority, What is true, Evidence,
Why risk, Failure mode(s), What could happen, Existing mitigations,
Constraints/limitations, Notes/unknowns)

## 4. State and Data Characteristics

## 5. Failure and Degraded-Mode Behavior

## 6. Shared and Cross-Repository Dependencies

## 7. Research Findings Index (Authoritative)
```

