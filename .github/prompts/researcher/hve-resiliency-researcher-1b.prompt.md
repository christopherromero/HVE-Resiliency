---
description: Run Prompt 1b external dependency inventory for resiliency research
agent: Task Researcher
---

# HVE Resiliency Researcher 1b

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
# HVE Task Researcher Prompt — External Dependency Inventory

You are acting as a Senior Cloud Application Architect performing an external dependency assessment for a microservice.

## OBJECTIVE

Identify external (non-Azure) service dependencies with clear separation between what is actually used, what was checked but not present, what is assumed or implicitly used, and what is not applicable to this repository.

## Instructions

Explicitly analyze the repository for non-Azure and external dependencies referenced in:
- Application code
- Configuration files
- Infrastructure-as-code (Bicep, ARM, Terraform, Helm, etc.)
- Deployment pipelines (GitHub Actions, Azure DevOps, scripts)

## Additional Required Check: Dependency Health Checks and GLB Health Signaling

For every non-Azure and external dependency used (critical and non-critical), verify whether the codebase performs a health check that represents the service's real readiness, and whether that health status is surfaced to the Global Load Balancer (GLB) via application health endpoints/probes (or any explicit GLB health reporting mechanism). Evidence required (file path + line number) for both the check and the reporting path.

Acceptable evidence sources include (cite exact locations): health endpoints (e.g., /health, /ready, /live), readiness/liveness probe config, dependency-check middleware, startup validation code, background dependency monitors, metrics/telemetry emitted for dependency health, and any routing/traffic-manager integration or configuration that connects those signals to GLB decisions.

## Evidence Rules

Base findings ONLY on verifiable evidence.
- Cite the exact files and line numbers where evidence is found.
- Do not infer usage without evidence.

## Output Requirements (must follow exact format)

### Section 1 — Used External Dependencies (Evidence Confirmed)

List only dependencies that are explicitly referenced.

For each non-Azure and external dependency include:
- Service / Dependency name
- Evidence (file path + line number)
- Brief description of how it is used
- Whether it materially impacts zone or region failover (Yes/No + description of why this could impact zone or region failover)
- Existing mitigations present (if any): retries/timeouts/fallbacks/feature flags/runbooks, with evidence (file path + line number)
- Health check present for this dependency? (Yes/No + evidence)
- How health is determined (e.g., ping/query/auth call/SDK check/timeouts) + evidence
- Is dependency health surfaced to GLB health evaluation? (Yes/No/Unclear + evidence of the wiring)
- What GLB probes (or upstream probes) hit (endpoint/path/port) and what conditions cause unhealthy vs healthy, as expressed in config/code + evidence
- Constraints/limitations (if any): dependency/platform capabilities or configuration/operational constraints that shape failover behavior, with evidence (file path + line number) when present

### Section 2 — Checked but Not Present

List non-Azure and external dependencies that were explicitly evaluated because they are commonly expected or architecturally relevant, but for which NO evidence was found in the repository.

For each non-Azure and external dependency include:
- Service / Dependency name
- Reason it was evaluated (e.g., common pattern, failover relevance)
- Explicit statement: "No references found in code, config, IaC, or pipelines"

### Section 3 — Not Applicable

List non-Azure and external dependency categories that are clearly not applicable to this application based on its architecture or scope.

For each item include:
- Service / Category name
- Reason it does not apply (e.g., no messaging, no streaming, no batch jobs)

## Rules

- Do NOT list non-Azure or external dependencies in more than one section.
- Do NOT include inferred or assumed usage in Section 1.
- If no evidence exists, it must appear only in Section 2 or Section 3.
- Be precise, defensive, and audit-ready.
```
