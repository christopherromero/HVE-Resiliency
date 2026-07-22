---
agent: Task Planner
description: "Appends Sections 4 (IaC Gap Analysis), 5 (Full Finding Matrix), and 6 (Microsoft Standards Alignment) to the Code-Level Resiliency Assessment report"
argument-hint: "serviceName=..."
---

# Resiliency Report Generator - Part D: IaC, Matrix, and Standards

Use [Resiliency Task Planner Context](../../../instructions/hve-resiliency-planner-context.instructions.md).

## Inputs

* ${input:serviceName}: (Required) Service name matching the repo name.

## Source Artifacts

Read **only** the following before generating. Keep context minimal.

* `Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md` - read the **entire** existing file. You need every H4 finding heading (`#### PX-NNN: Short Title`) to build the Full Finding Matrix and Standards Alignment. Also use Section 2 and Section 3 content to derive IaC cross-references.
* `.copilot-tracking/plans/` - locate `{serviceName}-Master.md`. Read the Architecture and Dependency Map section and the Open Questions section for IaC context.
* `helmcharts/env/prod/{serviceName}/values.yaml` - read in full for IaC Gap Analysis current values.
* `helmcharts/env/prod/{serviceName}/configmap.yaml` - read in full for IaC Gap Analysis current values.
* `helmcharts/templates/` - scan for deployment.yaml, hpa.yaml, ingress.yaml, serviceentry.yaml, service.yaml, serviceaccount.yaml to identify what IaC is available to review.

Do **not** read the Developer Guide or consolidated research for this prompt.

**Source fidelity exception (scoped repository read access):** for the final fidelity sweep only (see Validation Checklist), you may re-open the exact `file:line` locations already cited in the report's `**File:**` blocks and `**Issue:**` text, and run the targeted searches needed to confirm any stated count. This is a targeted set of file opens driven by what the report already cites, not a general repository scan.

## Critical Context

Use the classification rules from `hve-resiliency-planner-context.instructions.md` for all priority assignments.

All section headers, finding titles, and repo references must use `{serviceName}` (the repo name), not hardcoded service names.

## Region-Agnostic Language Rule

The generated report must use region-agnostic terms throughout. Never reference specific Azure region names.

## What to Generate

**Append** the following three sections to the existing `Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md` file. Do not overwrite or regenerate any existing content.

### Section 4 - IaC Gap Analysis

Use `# 4. IaC Gap Analysis` as the heading.

Begin with a short lead paragraph (2-4 sentences): what the IaC covers today, that it is single-region by construction, and that every multi-region decision falls to the operator and platform. State that the first table lists what the repo configures (grouped by domain) and the second lists capabilities the repo does not provide (grouped by owner), and that the `Findings` column traces each row to [Section 5](#5-full-finding-matrix). Do not enumerate a long "visible / not visible" inventory in prose; the two tables carry that split.

Follow with two tables.

**Available to Review** - what the repo configures today, one row per item, rows grouped and ordered by `Domain` (for example: Region topology & parameters, Data plane, Backing services, Observability, Identity, auth & health, Networking, Supply chain):

| Domain                       | Configuration                | Current value                       | Gap / risk                                      | Findings         |
|------------------------------|------------------------------|-------------------------------------|-------------------------------------------------|------------------|
| Domain group                 | Item                         | Value from values.yaml or configmap | Resiliency assessment of this choice            | PX-NNN, PX-NNN   |

Include entries for all infrastructure items visible in the repo that are relevant to resiliency: SQL connection settings, Cosmos DB endpoints, Key Vault references, storage accounts, APIM URLs, ServiceEntry configurations, HPA settings, probe endpoints, ingress hostnames, TLS certificates, thread pool sizes, secrets management (AKV2K8S CRDs), PDB presence, topology spread, graceful shutdown, and Dockerfile configuration. Put the finding IDs in the `Findings` column, not inline in the `Gap / risk` prose.

**Not Available (External Repos / Platform / Operator)** - capabilities the repo does not provide, one row per capability, with the `Owner` column set to `Operator`, `Platform`, or `External repo`:

| Capability                   | Owner                                | Needed for                          | Findings         |
|------------------------------|--------------------------------------|-------------------------------------|------------------|
| Item                         | Operator / Platform / External repo  | Why this matters for resiliency     | PX-NNN, PX-NNN   |

Include entries for: SQL Failover Group configuration, Cosmos DB multi-region write settings, ACR geo-replication, Azure Storage replication type, GLB probe configuration, AKV2K8S operator version in secondary cluster, DNS records for secondary ingress, APIM backend registration, network policies, SQL authentication method.

End with `[Back to Top](#top)`.

### Section 5 - Full Finding Matrix

Use `# 5. Full Finding Matrix` as the heading.

Build a complete table of **every finding** from Sections 2 and 3, sorted P0 → P1 → P2 → P3, and within each priority tier in ascending `PX-NNN` ID order (matching the order findings appear in Sections 2 and 3). Extract each finding's ID, priority, H3 group (Category), short description, and repo from the existing report content.

| ID                                                                   | Priority | Category           | Finding                              | Repo(s)         |
|----------------------------------------------------------------------|----------|--------------------|--------------------------------------|-----------------|
| [PX-NNN](#px-nnn-short-title-kebab-case)                             | **PX**   | Category           | Short description                    | {serviceName}   |

Rules:

* All IDs link to their H4 anchor. Anchor format: lowercase, hyphens, special chars removed (e.g., `#p0-001-sql-single-region-fqdn`).
* Include every finding from every section - P0 through P3, both Resiliency and Non-Resiliency.
* Category column uses the H3 group name the finding appears under.
* Repo(s) column always shows `{serviceName}`.

End with `[Back to Top](#top)`.

### Section 6 - Microsoft Standards Alignment

Use `# 6. Microsoft Standards Alignment` as the heading.

Build a table mapping Azure Well-Architected Framework (WAF) patterns and Azure reliability guidance to the findings in this report.

| Pattern                                                                   | Status                                             | Findings              |
|---------------------------------------------------------------------------|----------------------------------------------------|-----------------------|
| [Pattern Name](URL)                                                       | Not Implemented / Partial (reason) / Misconfigured / Not followed | PX-NNN, PX-NNN        |

Include patterns relevant to the findings discovered in this assessment. Common patterns for this type of service:

* [Health Endpoint Monitoring](https://learn.microsoft.com/en-us/azure/architecture/patterns/health-endpoint-monitoring) - relates to health probe findings
* [Retry Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/retry) - relates to retry/circuit breaker findings
* [Circuit Breaker Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker) - relates to circuit breaker findings
* [Queue-Based Load Leveling](https://learn.microsoft.com/en-us/azure/architecture/patterns/queue-based-load-leveling) - relates to failure queue findings
* [Deployment Stamps](https://learn.microsoft.com/en-us/azure/architecture/patterns/deployment-stamp) - relates to multi-region deployment findings
* [Geode Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/geodes) - relates to active/active deployment
* [Throttling Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling) - relates to rate limiting findings
* [Competing Consumers](https://learn.microsoft.com/en-us/azure/architecture/patterns/competing-consumers) - relates to scheduler leader election findings
* [Bulkhead Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/bulkhead) - relates to thread pool isolation findings
* [Compensating Transaction](https://learn.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction) - relates to transaction boundary findings
* [Azure SQL Failover Groups](https://learn.microsoft.com/en-us/azure/azure-sql/database/failover-group-sql-db) - relates to SQL failover findings
* [Azure Key Vault Best Practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices) - relates to Key Vault findings

Only include patterns that have at least one finding mapped to them. Status values:

* `Not Implemented` - the pattern is completely absent
* `Partial (reason)` - some elements exist but incomplete
* `Misconfigured` - the pattern is attempted but incorrectly configured
* `Not followed` - the pattern applies but guidance is not followed

End with `[Back to Top](#top)`.

## Validation Checklist

Before finalizing, confirm the **entire report** across all sections:

* Every H1 section has a working fragment link in the Table of Contents.
* Every finding has a unique `PX-NNN` ID; no duplicates.
* Finding counts in the Summary Findings Table (Section 1) match actual counts per section and priority.
* Every finding has `Resiliency Related` and `What does this solve` populated.
* Every `Resiliency Related: Yes` finding has `Resiliency Impact` populated.
* Every finding with code has two separate labeled blocks (current code under `**File:**` and `**Fix:**`), each with a language fence.
* All `Resiliency Related: Yes` findings appear under Resilient Focused Recommendations; `No` findings under Non-Resilient Focused Recommendations.
* All six H1 sections appear in the Table of Contents.
* Full Finding Matrix includes every finding from every section, with linked IDs.
* P3 findings use the full finding template format (same as P0-P2).
* All Back to Top links use `#top`.
* No hardcoded service names appear in H2, H3, or Repo(s) columns.
* No references to specific Azure region names appear anywhere in the report.
* IaC Gap Analysis has both tables: "Available to Review" (with `Domain` and `Findings` columns, rows grouped by domain) and "Not Available" (with `Owner` and `Findings` columns).
* Section 1 includes a `Themes at a Glance` table whose finding IDs link to their H4 anchors.
* Every finding's `**Notes:**` uses the labeled bullet structure (Cross-refs, Implementation, Validation, Guardrail) in that fixed order, applicable labels only.
* No em dashes or en dashes appear anywhere in the report; breaks use a spaced hyphen.

### Fidelity Re-verification (final sweep, source-grounded)

The checks above confirm the report is internally consistent, not that it is accurate. Builders 1 and 2 verify each block against source at generation time; this is a final backstop. Apply the Source Fidelity and Evidence Verification rule from the planner context across the whole report: re-open each cited `file:line` and confirm every `**File:**` block, every reused identifier, and every stated count matches the real source, and confirm no P0/P1 `**Fix:**` depends on a lower-priority finding. Also confirm that sibling findings sharing a file draw each `**File:**` block from its own distinct evidence rather than copying a sibling's. Correct any mismatch in place - this is a content fix, not formatting.

## Formatting Conventions

* Aligned pipe tables - all pipes vertically aligned across all rows.
* Prose follows the Report Prose Conventions in the planner context: no em dashes or en dashes (use a spaced hyphen), and avoid decorative "not X, but Y" antithesis.
* Blank lines before and after tables, code blocks, headings, and lists.
* `---` horizontal rules between major sections.
* All repo references use `{serviceName}`, never a hardcoded service name.
* No references to specific Azure region names.

## Output Location

**Append** to the existing file at:

`Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`

Do not overwrite the existing content. After appending, perform the validation checklist and fix any issues in the existing content.

## Completion

After completing this prompt, the full Code-Level Resiliency Assessment report is complete.

> **Report complete.** Review the final output at `Microsoft Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`.


## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.