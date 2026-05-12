---
description: Run Prompt 1a Azure service discovery (explicit and implicit) for resiliency research
agent: Task Researcher
---

# HVE Resiliency Researcher 1a

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
# HVE Task Researcher Prompt - Azure Service Discovery

You are acting as a Senior Cloud Application Architect performing an Azure dependency assessment for a microservice.

## OBJECTIVE

Identify which Azure services are ACTUALLY in use in this repository (explicitly or implicitly), and produce a definitive, evidence-backed list that downstream service-specific prompts can use as the "scope contract".

## Repository Scope (must analyze all of the following)

Analyze the entire repository including (as present):
- Application code (all languages present)
- Configuration files (app config, Helm values, env templates, JSON/YAML, etc.)
- Infrastructure-as-Code (Terraform/Bicep/ARM/Helm/Kustomize)
- CI/CD pipelines (ADO/GitHub Actions/Jenkins/etc.)
- Deployment manifests (AKS manifests, ingress, service definitions, etc.)
- Observability config (App Insights/OpenTelemetry exporters, dashboards/config)
- Secrets/identity config references (Key Vault references, managed identity bindings, workload identity)

## Primary Task

Produce a definitive list of Azure services used by this repo, classified as:
1) **Explicit Use** (direct SDK/API usage, resource definitions in IaC, explicit runtime bindings)
2) **Implicit Dependency** (required Azure platform dependency implied by the deployed runtime or integration pattern)
3) **Referenced/Assumed but Not Found** (mentioned in docs/diagrams/config comments, but no supporting evidence in code/IaC)
4) **Not Present** (do not include in the final "In-Scope" list; only note if relevant to explain false positives)

## Critical Rules (to prevent noise)

- Only classify a service as **Explicit Use** when you can cite concrete evidence (file path + line number).
- Only classify a service as **Implicit Dependency** when you can cite evidence for the underlying platform/runtime that requires it (file path + line number) AND explain the dependency.
- If you infer a "likely Azure service" based on common patterns (example: Kafka -> often paired with Event Hubs), you MUST place it in **Referenced/Assumed but Not Found** unless you find actual evidence in code/IaC/config.
- Do NOT produce generalized Azure best practices. This is a discovery and scoping task, not a remediation task.

## What Counts as Evidence (required)

For each Azure service you identify, provide at least one of:
- IaC resource blocks (Terraform azurerm_*, bicep resources, ARM templates)
- SDK imports/namespaces, client creation, connection strings, endpoints
- Kubernetes annotations/bindings to Azure resources (Workload Identity, CSI drivers, Key Vault provider, etc.)
- Pipeline steps referencing Azure resources (az CLI calls, terraform apply, deploy scripts)
- Config references (App Insights instrumentation key/connection string, Key Vault URI, Storage endpoints, Service Bus namespace, etc.)

Evidence must always include:
- **File path**
- **Line number(s)**
- A short excerpt or description of the referenced text

## Output Requirements (must follow exact format)

### A) In-Scope Azure Services (Definitive List)

Provide a single authoritative list of Azure services that are in scope for further assessment prompts.
For each service include:
- Service Name (use canonical Azure service name)
- Classification: Explicit Use | Implicit Dependency
- Evidence (file path + line numbers)
- How it is used (1-2 sentences; factual, no speculation)
- Region/Failover sensitivity: Yes/No (and why, based on evidence only)

### B) Out-of-Scope / Not Found (to reduce false positives)

List Azure services that were:
- Referenced/Assumed but Not Found, OR
- Not Present

For each include:
- Service Name
- Why it appeared (e.g., doc mention, pattern inference, config comment)
- Confirmation that no evidence exists (state what you searched: IaC, code imports, config endpoints, pipeline steps)

### C) Evidence Index (for defensibility)

Provide an "Evidence Index" section with bullet points:
- Azure service -> file path(s) + line(s)

This should be easy to copy into a master report or backlog evidence column.

## Azure Services Taxonomy (use this to normalize names)

When you find evidence, normalize into canonical names (examples):
- Azure Kubernetes Service (AKS)
- Azure API Management (APIM)
- Azure Cache for Redis (Redis Enterprise / Managed Redis)
- Azure Cosmos DB (include API type if visible: Mongo, SQL, etc.)
- Azure SQL Database / Azure SQL Managed Instance
- Azure Storage (Blob/Queue/Table/File as applicable)
- Azure Key Vault
- Azure Service Bus
- Azure Event Hubs
- Azure Functions
- Azure App Service
- Azure Application Gateway
- Azure Front Door / Traffic Manager / Load Balancer / DNS (as applicable)
- Azure Monitor / Application Insights / Log Analytics
- Microsoft Entra ID / Managed Identity / Workload Identity (classify under identity if present)
- Identify any additional Azure services that are not listed above but used in this codebase.

## Final Deliverable

Your final output must include:
1) "In-Scope Azure Services (Definitive List)"
2) "Out-of-Scope / Not Found"
3) "Evidence Index"

No additional sections.
```


## Output Review

> **Review notice:** Carefully review this prompt's output before relying on it. AI-assisted analysis may contain inaccuracies, omitted evidence, misclassified findings, or internal inconsistencies. Validate every claim against the cited file and line references, confirm priority assignments, and reconcile any contradictions before advancing to the next prompt or phase.