---
description: HVE Azure service discovery scope contract
agent: Task Researcher
---

# HVE Researcher 1a - Azure Scope Contract

## Role

Identify Azure services actually used by this repository. This prompt creates the Azure scope contract for downstream HVE service and resiliency prompts.

## Required Input

Read first:

`.copilot-tracking/research/repository-evidence-index.md`

If the evidence index is missing or malformed, stop and output:

`Azure scope contract not generated: repository-evidence-index.md is missing or malformed. Run Prompt 0 first.`

## Source Rule

Use only candidate files listed in the evidence index under:

- Configuration, Region, Endpoint, and Identity Index
- Dependency Evidence Index
- Health, Readiness, Telemetry, and GLB Signal Paths
- Shared / Platform / Generated / External Boundaries

Do not rescan the entire repository.

## Objective

Produce a definitive, evidence-backed list of Azure services in scope for further assessment.

Classify each service as:

- Explicit Use
- Implicit Dependency
- Referenced/Assumed but Not Found
- Not Present

## Evidence Rules

Classify a service as Explicit Use only with direct file/line evidence.

Classify a service as Implicit Dependency only when file/line evidence proves the underlying runtime or platform that requires it.

Do not infer Azure services from common patterns. If suspected but not proven, place the service under Referenced/Assumed but Not Found.

Do not assign P0/P1/P2/P3.
Do not recommend fixes.

## Output File

Write:

`.copilot-tracking/research/azure-scope-contract.md`

## Output Schema

# Azure Scope Contract

## 1. Scope Gate Result

- Evidence index used:
- Azure evidence confirmed: Yes/No
- Analysis stopped early: Yes/No
- Reason if stopped early:

## 2. In-Scope Azure Services

| Service Name | Classification | Evidence | How it is used | Region/Failover sensitivity |
|---|---|---|---|---|

## 3. Referenced or Assumed but Not Found

| Service Name | Why it appeared | Files/patterns checked | Evidence result |
|---|---|---|---|

## 4. Not Present / False Positives

| Service Name | Reason checked | Evidence result |
|---|---|---|

## 5. Azure Evidence Index

| Service | Evidence ID | File | Lines |
|---|---|---|---|

## Stop Condition

End with:

Next step: Run /clear, then continue with Prompt 1b or Prompt 2 after both scope contracts are complete.