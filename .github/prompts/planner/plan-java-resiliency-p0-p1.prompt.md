---
description: "Plans Java-only P0/P1 code changes from a Code-Level Resiliency Assessment, delegating to the HVE Task Planner"
agent: Task Planner
argument-hint: "[assessment=...] [findings=...] [chat={true|false}]"
---

# Plan Java Resiliency P0/P1 Changes

Reusable planner for any repository that has the HVE Task Planner and Task Implementor agents available. Reads a Code-Level Resiliency Assessment, filters to Java-only P0/P1 findings, and drives the HVE Task Planner to produce an implementation plan.

## Inputs

* ${input:assessment}: (Optional) Path to the Code-Level Resiliency Assessment document. This is the planner's source document — it plays the same role as the `research=` input in the HVE `/task-plan` prompt. Leave this empty by default: the planner discovers the assessment automatically per the Assessment Discovery section below. Only supply a path to override auto-discovery.
* ${input:findings}: (Optional) Specific finding IDs to plan (for example, `P0-001,P1-005`). Defaults to all in-scope Java findings discovered in the assessment.
* ${input:chat:true}: (Optional, defaults to true) Include conversation context for planning analysis.

## Assessment Discovery

When `${input:assessment}` is not provided, discover the Code-Level Resiliency Assessment automatically before planning:

1. Search the `Microsoft Assessment/` folder for files ending in `-Code-Level-Resiliency-Assessment.md`, using the glob `Microsoft Assessment/*-Code-Level-Resiliency-Assessment.md` (case-insensitive).
2. If exactly one file matches, select it and state the resolved path before planning.
3. If multiple files match, list the candidates with their paths and ask the user which to use.
4. If no file matches, report that no assessment was found in the `Microsoft Assessment/` folder and ask the user to provide a path via `${input:assessment}`.

## Requirements

1. Treat the assessment document as the authoritative source. For each candidate finding, read its full **Issue**, **What does this solve**, **Resiliency Impact**, **Recommended Fix**, **File**, and any code snippets before planning it. Do not infer fixes not stated in the assessment.
2. Scope planning to **Java code changes only** for **P0** and **P1** findings. Include a finding when its remediation modifies Java sources (`**/src/main/java/**`, `*.java`) or the build manifest dependencies (`pom.xml`, `build.gradle`, `build.gradle.kts`) required by that Java change.
3. Exclude findings whose remediation is limited to non-Java artifacts, per the Classification Guide below.
4. Build the in-scope inventory by discovery, not assumption: enumerate every P0 and P1 finding in the assessment, inspect each finding's **File** reference and **Recommended Fix**, and classify it as Java-in-scope or excluded using the Classification Guide. When `${input:findings}` is provided, restrict to those IDs (still Java-only, still P0/P1).
5. Preserve traceability: every implementation phase, step, and success criterion references its originating finding ID and the target Java file and line range from the assessment.
6. Treat all hard-coded numbers in the assessment (retry counts, timeouts, thread-pool sizes, circuit-breaker thresholds, intervals) as illustrative. Plan them as externalized configuration sourced from environment-specific configuration, not literals.
7. Group related findings into cohesive phases by shared file or component (for example, all reactive-blocking offload work, all DAO/persistence-integrity work, all connection-pool work, all custom health-indicator work). Mark a phase parallelizable only when it touches disjoint files and shares no build or state dependencies with other phases.
8. Record any finding that appears Java-adjacent but is ultimately excluded (config-only or infra-only) in the Planning Log under a "Deferred / Out-of-Scope" note with the reason, so the boundary is explicit and auditable. Note config-only findings that pair with an in-scope Java finding (for example, a health-check property paired with a custom health indicator) so the implementer sees the dependency.
9. Accept user-provided context, attached files, or conversation history as additional input alongside the assessment document.
10. Summarize planning outcomes, including the implementation plan files created and the findings deferred as out-of-scope.

## Classification Guide

Use the finding's **File** reference and **Recommended Fix** to classify:

| Signal | Classification |
| --- | --- |
| Fix edits `*.java` under `src/main/java/**` | Java — in scope |
| Fix adds a dependency to `pom.xml` / `build.gradle` required by a Java change | Java — in scope (dependency prerequisite) |
| Fix creates new Java classes (for example, `HealthIndicator`, config beans) | Java — in scope |
| Fix edits Helm/Kubernetes/Istio `*.yaml`, CI/CD workflows, or shell scripts | Excluded |
| Fix edits `application.properties` / `*.yml` / configmaps only, no Java change | Excluded (note if paired with a Java finding) |

## Required Protocol

1. Follow the Task Planner protocol (Context Assessment, Planning, Plan Validation, Completion) without redefining it. Treat the Assessment Discovery result as the planner's source document, supplementing rather than duplicating the planner's own Context Assessment step.
2. When `${input:chat}` is true (the default), incorporate the current conversation context and any attached files as additional planning input alongside the assessment. When false, plan solely from the assessment document and explicitly declared inputs.
3. Before planning, present the derived in-scope Java inventory (finding IDs, titles, target files) and the excluded list, so the scope boundary is confirmed.
4. Produce a single implementation plan set covering the in-scope inventory under `.copilot-tracking/`: one plan file, one details file, and one planning log. Use a task slug such as `java-resiliency-p0-p1` so the generated filenames stay predictable.
5. Do not implement code changes; produce planning artifacts only and hand off to the Task Implementor.
