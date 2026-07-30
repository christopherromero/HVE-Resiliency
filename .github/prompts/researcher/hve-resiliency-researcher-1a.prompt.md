---
description: Discover Azure services from repository evidence
agent: "Task Researcher"
---

# HVE Researcher 1a

Use [platform context](../../instructions/hve-resiliency-platform-context.instructions.md) for its rules.

## Objective

Produce an evidence-only Azure scope contract. Direct invocation overrides other workflow, delegation, output, and next-step rules; retain referenced evidence rules. Do not run another resiliency prompt. Investigate directly; only when mandatory, use one non-delegating Researcher Subagent for Steps 1-3.

## Scope And Matrix

Inventory every repository file once, including extensionless operations. Exclude outputs, caches, editor metadata, tests, `.copilot-tracking/**`, reports/research/assessments, prompt artifacts, certificates, binaries, wrappers, and vendored dependencies. Keep `.github/workflows/**`; docs only trigger. Follow one reference into excluded operational text.

Resolve this bounded negative matrix:

* Compute: Azure Kubernetes Service (AKS), Azure Functions, Azure App Service
* Edge: Azure API Management, Application Gateway, Front Door, Traffic Manager, Load Balancer, DNS
* Data: Cosmos DB, Azure SQL Database/Managed Instance, Azure Storage by subtype, Azure Managed Redis
* Messaging: Azure Service Bus, Azure Event Hubs
* Identity/configuration: Entra ID, Managed/Workload Identity, Key Vault, App Configuration
* Observability: Azure Monitor, Application Insights, Log Analytics
* Delivery: Azure Container Registry

Add positively evidenced services. Use specific nonduplicative names; never claim universal absence.

## Evidence Rules

Explicit Use requires an IaC resource/Azure ID, configured Azure client, pipeline target, or Azure endpoint, connection string, annotation, or runtime binding. Imports, dependencies, comments, docs, protocols, and names need a second binding signal; otherwise place them in B with the trigger.

Implicit Dependency requires an Azure binding, necessity, no evidenced substitute, and a file-line chain. Kubernetes does not prove AKS, MongoDB Cosmos DB, or Kafka Event Hubs. Keep unresolved Azure hostnames neutral without product evidence. `Not Present` requires bounded row-indicator checks.

## Required Steps

### Step 1: Inventory Sources

Verify availability without execution probes. Use one deterministic inventory method and one verified fallback at most. Build, filter, classify, and reuse one path-only manifest.

### Step 2: Discover Signals

Split into disjoint classes. Scan each once using one verified bounded scanner for Azure IDs/types, hosts, SDK/clients, configuration/identity/telemetry/deployment, `azurecr.io`, and registry server/image/login signals.

Sanitize each signal in memory before any record, package, envelope, hash input, log, or response. Across all URI schemes and key/value forms, remove URI userinfo/embedded credentials, sensitive query values, connection-string assignments, Authorization header values, tokens, passwords, keys, SAS, and signatures; retain only safe scheme/host/path-family indicators. Fail closed on scan/mask/audit error or uncertainty. Audit each masked value before record/ID/hash creation and the serialized in-memory package before write/atomic commit; failure commits nothing and stops incomplete. Then group per class by canonical path, line, and family; deduplicate/sort, compute and validate counts, hashes, tuple IDs, and envelope in memory, and atomically commit one package. Return only its envelope; on response loss reread without rescanning. Suppress incidental output/raw bodies.

### Step 3: Reconcile And Verify

Map each stable ID to a canonical candidate, neutral Azure-host trigger, false positive, or semantic gap. Analyze each owner once. Maintain only source-coverage and candidate/signal tables; include every ID and terminal disposition, then render C from candidate/signal state.

### Step 4: Audit And Render

Audit each claim against its file-line citation; correct, narrow, or gap it. Run one no-change queue review.

## Required Protocol

Run Steps 1-4 once; do not re-enumerate. Limits: one manifest; disjoint scans cover it; one proven missed-class/family correction; one owner analysis; two indirections per branch; one queue review. Discard failed temporaries. Fallback only if no class package committed; never rescan one. Reconcile committed packages by counts, set hashes, IDs, and dispositions. Any mismatch, clipping, lost ID, read failure, incomplete manifest, unreconciled signal, or mask/audit failure is incomplete, never a gap, negative, or saturation.

## Output Contract

Output exactly A-C below; no other content, remediation, advice, or examples.

### A) In-Scope Azure Services (Definitive List)

Include only Explicit Use/Implicit Dependency. Give canonical name, class, file-line evidence, factual use, and Region/Failover sensitivity (Yes/No/Unclear with evidence-only rationale); `Unclear` requires an evidence gap.

### B) Out-of-Scope / Not Found (to reduce false positives)

Include every weak trigger and bounded negative. State shared scope/limits once; per service give canonical result, trigger/reason, checked indicator families, and any gap or neutral-host label.

### C) Evidence Index (for defensibility)

Index A/B evidence by file-line; for bounded negatives list checked scope/indicators.
