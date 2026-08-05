---
name: hve-resiliency-planner-java-p0-p1
description: "Plans application-owned P0/P1 changes from a Code-Level Resiliency Assessment, excluding infrastructure files, delegating to the HVE Task Planner"
agent: "Task Planner"
argument-hint: "[assessment=...] [findings=...] [chat={true|false}]"
---

# Plan Application-Owned Resiliency P0/P1 Changes

Reads a Code-Level Resiliency Assessment, selects the P0 and P1 findings the application team can fix inside its own deliverable, and drives the HVE Task Planner to produce an implementation plan.

The boundary is the deliverable, not the language: application sources, the build manifest, and repository-carried configuration are in scope. Container images, Kubernetes and Helm assets, service mesh policy, CI/CD pipelines, and cloud-platform settings belong to a separate infrastructure workstream.

## Inputs

* `${input:assessment}`: (Optional) Path to the assessment. Leave empty to auto-discover; supply a path only to override.
* `${input:findings}`: (Optional) Specific finding IDs, for example `P0-001,P1-005`. Defaults to every in-scope finding.
* `${input:chat:true}`: (Optional, default true) Treat conversation context and attached files as additional planning input. When false, plan solely from the assessment.

## Assessment Discovery

When `${input:assessment}` is empty, glob `Microsoft-Assessment/*-Code-Level-Resiliency-Assessment.md` (case-insensitive). State the resolved path on a single match, ask the user to choose on several, and ask for a path when none match.

## Classification

Classify every P0 and P1 finding by its **File** reference and **Recommended Fix**:

| Target of the fix | Classification |
| --- | --- |
| `*.java` under `src/main/java/**`, including new classes | In scope |
| Configuration under `src/main/resources/**` (`application*.yml`, `application*.properties`, `bootstrap*.yml`) | In scope |
| Dependencies in `pom.xml`, `build.gradle`, `build.gradle.kts` | In scope |
| `Dockerfile`, base images, image tags | Infrastructure |
| Kubernetes, Helm, or Istio manifests, including externally rendered configmaps | Infrastructure |
| CI/CD pipelines (`.github/workflows/**`, `Actionsfile/*`, `Jenkinsfile`) or shell scripts | Infrastructure |
| Cloud-platform changes (geo-replication, DNS aliases, load-balancer probe wiring) | Infrastructure |
| Any other artifact outside application sources, configuration, and the build manifest | Infrastructure |

A finding matching both sides is partially in scope: plan the application-owned part and defer the rest under the same finding ID. Exclude a finding outright only when no part of its fix lands in an application-owned artifact.

Never edit an infrastructure artifact, and never plan a step that depends on one changing first. When the assessment's Recommended Fix pairs an application change with an infrastructure change, plan only the application half and record the other half as deferred.

Prefer configuration over code. When the framework already supports the remediation through properties, use them; write new code only for what configuration cannot express.

## Requirements

1. Treat the assessment as authoritative. Read each candidate finding's **Issue**, **What does this solve**, **Resiliency Impact**, **Recommended Fix**, **File**, and code snippets before planning it. Do not invent fixes the assessment does not state.
2. Derive the inventory by inspecting every P0 and P1 finding, not by assumption. Restrict to `${input:findings}` when supplied.
3. Trace every phase, step, and success criterion to its finding ID and the target file and line range.
4. Treat hard-coded numbers in the assessment (retry counts, timeouts, pool sizes, thresholds, intervals) as illustrative. Plan them as externalized configuration.
5. Group findings into phases by shared file or component. Mark a phase parallelizable only when it touches disjoint files and shares no build or state dependency.
6. Annotate every change site per the Annotations section, and carry a per-phase success criterion that the annotations are present.
7. Record deferred work in the Planning Log under "Deferred / Out-of-Scope", naming the infrastructure artifact responsible. For partially planned findings, state the residual risk so the plan does not read as full remediation.

## Annotations

Every change site carries a comment naming the finding it remediates, so the diff is auditable against the assessment.

* `Resiliency finding` is a fixed marker string; audit tooling greps for it. Use finding IDs verbatim from the assessment headings.
* Include the finding's short title. Keep each annotation on one line under 120 characters, truncating the title at a clause boundary.
* Annotate each change site once. Repeat the same annotation when one finding spans several sites; list several IDs in one comment when one site covers several findings.
* For a deletion with no surviving statement, annotate the enclosing declaration and state the removal, for example `// Resiliency finding P1-XXX: swallowed exception handler removed; the original failure now propagates.`
* Do not annotate unchanged code or test code, and do not restate the assessment's Issue or Recommended Fix text.

Placement by target:

| Target | Placement | Example |
| --- | --- | --- |
| New type or method | Javadoc above the declaration | `/** Resiliency finding P0-XXX: <short title from the assessment>. */` |
| Declaration that already has Javadoc | Final line inside the existing block, never a second block | `* Resiliency finding P0-XXX: <short title from the assessment>.` |
| Modified statement or block | Line comment immediately above | `// Resiliency finding P0-XXX: <short title from the assessment>.` |
| Build-manifest dependency | Line comment on the dependency | `// Resiliency finding P1-XXX: <short title from the assessment>.` |
| Configuration key | Line comment immediately above the key | `# Resiliency finding P0-XXX: <short title from the assessment>.` |

## Protocol

1. Follow the Task Planner protocol (Context Assessment, Planning, Plan Validation, Completion) without redefining it. The discovered assessment is the planner's source document.
2. Before planning, present the in-scope inventory (finding IDs, titles, target files, and whether each is code, configuration, or both) alongside the excluded list with the infrastructure artifact that excluded each one, so the boundary is confirmed.
3. Produce one plan set under `.copilot-tracking/` — plan file, details file, planning log — using the task slug `app-resiliency-p0-p1`.
4. In the details file, record each finding's exact annotation text and the declaration or statement it sits above, so the Task Implementor emits it without re-deriving it.
5. Plan a final verification step that greps the diff for `Resiliency finding` and reconciles the IDs found against the inventory. It fails on a missing ID, an ID outside the inventory, or an annotation in a file the plan does not change.
6. Produce planning artifacts only. Do not implement code changes; hand off to the Task Implementor.