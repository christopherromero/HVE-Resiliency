---
description: HVE repository evidence index builder
agent: Task Researcher
---

# HVE Researcher 0 - Repository Evidence Index Builder

## Role

Create a reusable evidence index for this repository. This is the only broad repository discovery pass.

Do not assign P0/P1/P2/P3.
Do not create findings.
Do not recommend fixes.
Do not perform service-specific deep analysis.

## Objective

Map repository evidence needed by downstream HVE prompts:

- Repository structure and execution model
- Azure candidate evidence
- Non-Azure candidate evidence
- Region, zone, endpoint, identity, and configuration evidence
- State, write, cache, message, and idempotency paths
- Health, readiness, telemetry, and GLB signal paths
- Shared libraries, platform utilities, generated clients, and ownership boundaries
- Evidence gaps

## Runtime Guardrails

- Open files only as needed to produce candidate file/line evidence.
- Do not prove broad absence across the whole repository.
- If a surface is not present, record an Evidence Gap.
- Do not continue searching after enough candidate evidence has been indexed for downstream prompts.

## Evidence Rules

Every evidence row must include:

- Evidence ID
- File path
- Line number or line range
- Evidence type
- What the evidence proves
- Which downstream prompt should consume it

Never invent files, line numbers, dependencies, regions, endpoints, owners, or failover behavior.

## Output File

Write:

`.copilot-tracking/research/repository-evidence-index.md`

## Output Schema

# Repository Evidence Index

## 1. Repository Map

| Area | Candidate files | Why relevant | Downstream consumer |
|---|---|---|---|

## 2. Entry Points and Execution Model

| Evidence ID | File | Lines | Type | What it proves |
|---|---|---:|---|---|

## 3. Configuration, Region, Endpoint, and Identity Index

| Evidence ID | File | Lines | Key / Endpoint / Region / Identity | What it proves | Downstream consumer |
|---|---|---:|---|---|---|

## 4. Dependency Evidence Index

| Evidence ID | File | Lines | Dependency | Azure / Non-Azure / Shared | What it proves | Downstream consumer |
|---|---|---:|---|---|---|---|

## 5. State, Write, Message, Cache, and Idempotency Paths

| Evidence ID | File | Lines | Path type | Data-loss / duplicate / replay relevance |
|---|---|---:|---|---|

## 6. Health, Readiness, Telemetry, and GLB Signal Paths

| Evidence ID | File | Lines | Health signal | Routing relevance |
|---|---|---:|---|---|

## 7. Shared / Platform / Generated / External Boundaries

| Boundary | Evidence | Owner visible? | Constraint |
|---|---|---|---|

## 8. Evidence Gaps

| Gap | Files or patterns checked | Why it matters | Downstream owner |
|---|---|---|---|

## Stop Condition

End with:

Next step: Run /clear, then run Prompt 1a and Prompt 1b using this evidence index.