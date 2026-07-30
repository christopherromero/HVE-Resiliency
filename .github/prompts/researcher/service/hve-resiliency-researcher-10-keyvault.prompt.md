---
description: Azure Key Vault region-resiliency repository review
agent: Task Researcher
---

# HVE Resiliency Researcher — Azure Key Vault Region Resiliency

## Objective

Perform an evidence-first source repository review for Azure Key Vault region resiliency across West US 2 and West US.

This is a research prompt only. Do not propose code changes, implementation snippets, refactoring plans, or remediation steps. Produce only verified findings, evidence gaps, and assessment constraints.

## Target Architecture Assumptions

Use these assumptions only as evaluation criteria. Do not treat them as repository evidence.

- The target architecture uses two independent Azure Key Vaults: one in West US 2 and one in West US.
- Azure Key Vault does not provide customer-controlled automatic failover between these two independent vaults.
- Private Endpoints are regional and must not be assumed to fail over.
- Applications and deployment pipelines are responsible for selecting the correct vault, retrying transient failures, using fallback behavior when explicitly implemented, and keeping secrets, keys, and certificates consistent across both vaults.

## Required Scope Gate

Before deep analysis, determine whether the repository contains runtime, configuration, IaC, deployment, or pipeline evidence of Azure Key Vault usage.

Search only for Key Vault indicators such as:
- vault.azure.net
- KeyVault, Key Vault, Azure.Security.KeyVault, SecretClient, KeyClient, CertificateClient
- managed identity references used to access vaults
- secret, key, or certificate references whose source is Azure Key Vault
- azurerm_key_vault, Microsoft.KeyVault/vaults, private endpoint resources for Key Vault
- pipeline tasks or scripts that create, update, rotate, sync, back up, or restore Key Vault objects

If no direct Key Vault evidence is found:
- Output only “Scope Gate: No confirmed Azure Key Vault usage found.”
- List the exact search patterns used.
- Do not create P0/P1/P2/P3 findings.
- Do not perform absence-proof repository-wide analysis.

## Evidence Rules

Create a finding only when direct file-and-line evidence proves all three:
1. The repository uses or configures Azure Key Vault.
2. The observed behavior affects West US 2, West US, zone failure, regional failover, private endpoint reachability, vault consistency, or GLB/backend health eligibility.
3. The failure impact is supported by code, configuration, IaC, deployment, pipeline, or test evidence.

If any of the three are missing, record the item under “Evidence Gaps” or “Assessment Constraints,” not as a P0–P3 finding.

Every confirmed finding must include:
- File path and line number.
- Exact observed behavior.
- Why the evidence is relevant to regional failover or zone resiliency.
- Existing mitigation evidence, if present.
- Constraint or limitation evidence, if present.

Never invent files, line numbers, services, regions, owners, failover behavior, synchronization logic, private endpoint behavior, or health-probe behavior.

## Bounded Validation Checklist

Inspect only files found by the scope gate and directly related references.

Validate:

1. Vault selection and regional binding
   - Are West US 2 and West US vault URIs/config values represented?
   - Is vault selection runtime-configurable per region, deployment slot, or environment?
   - Are region-specific vault endpoints hard-coded in code or deployment assets?

2. Secret, key, and certificate consistency
   - Is there repository evidence that both regional vaults receive equivalent secrets, keys, and certificates?
   - Are rotations, renewals, version pinning, and pipeline writes region-aware?
   - Are writes prevented or controlled during outage scenarios to avoid drift?

3. Application behavior during Key Vault failure
   - Are retry policies present for transient Key Vault failures?
   - Is exponential backoff or SDK retry behavior configured or relied upon?
   - Is fallback to the alternate vault explicitly implemented?
   - Are startup failures, cached secrets, stale credentials, or missing secret behavior handled?

4. Private Endpoint and DNS behavior
   - Are Key Vault private endpoints defined regionally?
   - Does the repo incorrectly assume private endpoints or private DNS fail over automatically?
   - Are both regional app deployments able to reach their region-local Key Vault endpoint?

5. GLB/backend health alignment
   - Only evaluate if the repo contains health probe, readiness, dependency health, or GLB routing evidence.
   - Determine whether backend health reflects Key Vault reachability when Key Vault is required for runtime operation.
   - Do not create GLB findings without repository evidence tying health behavior to Key Vault dependency state.

6. Azure platform limitation awareness
   - Identify code/config/pipeline evidence that assumes Azure Key Vault will perform customer-controlled failover, automatic writes, automatic cross-vault sync, or private endpoint failover.
   - Treat undocumented assumptions as evidence gaps unless directly shown in files.

## Severity Classification

Apply severity only to confirmed findings.

P0 — Failover-blocking risk:
Use only when the evidence shows the application or deployment cannot function in a regional failover because Key Vault access, vault selection, private endpoint reachability, health routing, or required secret/key/certificate availability blocks failover. P0 requires direct evidence that the second region provides no effective failover benefit until fixed.

P1 — Multi-region resiliency gap:
Use when the evidence shows degraded or unreliable failover behavior, but operation is possible through a workaround, manual action, cached data, retry, or lower-blast-radius mitigation. Examples include incomplete retry/fallback behavior, manual-only vault synchronization, or health behavior that degrades failover confidence but does not fully block operation.

P2 — Resiliency best practice / improvement:
Use for valid resiliency improvements that do not block failover readiness and do not directly prove a regional outage failure.

P3 — Maintainability / consistency:
Use for naming, cleanup, documentation, consistency, or code hygiene issues with no functional failover impact.

Do not assign P0 or P1 to:
- Evidence gaps.
- External ownership assumptions.
- Missing documentation alone.
- Generic security/code-quality best practices.
- Findings that behave the same in single-region and multi-region operation unless a failover-specific impact is proven.

## Output Format

Return sections in this exact order.

### 1. Scope Gate Result
- Key Vault usage confirmed: Yes/No
- Evidence files reviewed:
- Search patterns used:
- Analysis stopped early: Yes/No and why

### 2. Confirmed Findings
Return at most:
- All confirmed P0 and P1 root-cause findings.
- Up to five P2/P3 grouped findings if they are relevant.
Deduplicate repeated instances by root cause.

For each finding:

- Finding ID:
- Issue Description:
- Risk Level:
- Code Location:
- Evidence:
- Why this affects West US 2 / West US region resiliency:
- Impact if unchanged:
- Existing mitigations present:
- Constraints / limitations:
- Confidence: High / Medium / Low

### 3. Evidence Gaps
List missing evidence that prevents classification. Do not assign severity.

### 4. Assessment Constraints
List repository limitations, unavailable files, generated code exclusions, or external systems that could not be validated.

### 5. Next Step
End with:
> **Next step:** Run /clear, then continue with the next applicable service-specific resiliency prompt or consolidation prompt.