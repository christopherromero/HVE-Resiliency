---
name: hve-resiliency-planner-java-p0-p1
description: "Plans Java-only P0/P1 code changes from a Code-Level Resiliency Assessment, delegating to the HVE Task Planner"
agent: "Task Planner"
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

1. Search the `Microsoft-Assessment/` folder for files ending in `-Code-Level-Resiliency-Assessment.md`, using the glob `Microsoft-Assessment/*-Code-Level-Resiliency-Assessment.md` (case-insensitive).
2. If exactly one file matches, select it and state the resolved path before planning.
3. If multiple files match, list the candidates with their paths and ask the user which to use.
4. If no file matches, report that no assessment was found in the `Microsoft-Assessment/` folder and ask the user to provide a path via `${input:assessment}`.

## Requirements

1. Treat the assessment document as the authoritative source. For each candidate finding, read its full **Issue**, **What does this solve**, **Resiliency Impact**, **Recommended Fix**, **File**, and any code snippets before planning it. Do not infer fixes not stated in the assessment.
2. Scope planning to **Java code changes only** for **P0** and **P1** findings. Include a finding when its remediation modifies Java sources (`**/src/main/java/**`, `*.java`) or the build manifest dependencies (`pom.xml`, `build.gradle`, `build.gradle.kts`) required by that Java change.
3. Exclude findings whose remediation is limited to non-Java artifacts, per the Classification Guide below.
4. Build the in-scope inventory by discovery, not assumption: enumerate every P0 and P1 finding in the assessment, inspect each finding's **File** reference and **Recommended Fix**, and classify it as Java-in-scope or excluded using the Classification Guide. When `${input:findings}` is provided, restrict to those IDs (still Java-only, still P0/P1).
5. Preserve traceability: every implementation phase, step, and success criterion references its originating finding ID and the target Java file and line range from the assessment.
6. Require in-source finding annotations: every planned Java edit carries a code comment naming the finding ID it remediates, per the Finding Annotation Comments section below. Each step states the exact annotation text to emit, and each phase carries a success criterion that the annotation is present at every changed site.
7. Treat all hard-coded numbers in the assessment (retry counts, timeouts, thread-pool sizes, circuit-breaker thresholds, intervals) as illustrative. Plan them as externalized configuration sourced from environment-specific configuration, not literals.
8. Group related findings into cohesive phases by shared file or component (for example, all reactive-blocking offload work, all DAO/persistence-integrity work, all connection-pool work, all custom health-indicator work). Mark a phase parallelizable only when it touches disjoint files and shares no build or state dependencies with other phases.
9. Record any finding that appears Java-adjacent but is ultimately excluded (config-only or infra-only) in the Planning Log under a "Deferred / Out-of-Scope" note with the reason, so the boundary is explicit and auditable. Note config-only findings that pair with an in-scope Java finding (for example, a health-check property paired with a custom health indicator) so the implementer sees the dependency.
10. Accept user-provided context, attached files, or conversation history as additional input alongside the assessment document.
11. Summarize planning outcomes, including the implementation plan files created and the findings deferred as out-of-scope.

## Classification Guide

Use the finding's **File** reference and **Recommended Fix** to classify:

| Signal | Classification |
| --- | --- |
| Fix edits `*.java` under `src/main/java/**` | Java — in scope |
| Fix adds a dependency to `pom.xml` / `build.gradle` required by a Java change | Java — in scope (dependency prerequisite) |
| Fix creates new Java classes (for example, `HealthIndicator`, config beans) | Java — in scope |
| Fix edits Helm/Kubernetes/Istio `*.yaml`, CI/CD workflows, or shell scripts | Excluded |
| Fix edits `application.properties` / `*.yml` / configmaps only, no Java change | Excluded (note if paired with a Java finding) |

## Finding Annotation Comments

Every planned change site carries a comment naming the finding it remediates, so the resulting diff is auditable against the assessment.

Rules:

* `Resiliency finding` is a fixed marker string. Do not reword it; audit tooling greps for it.
* Use the finding ID verbatim from the assessment heading (for example, `P0-005`, `P1-012`). Never invent, renumber, or abbreviate an ID.
* Annotate each distinct change site once: a new class or method, a modified method body, or a changed build-manifest dependency.
* Include the finding's short title from the assessment heading so the comment is readable without opening the assessment.
* When one change site remediates several findings, list every applicable ID in a single comment rather than repeating the comment.
* When one finding has several change sites across different files, repeat the same annotation at each site. Traceability is per-site, not per-finding.
* When the fix is a deletion with no surviving statement to sit above, annotate the enclosing method declaration and state the removal, for example `// Resiliency finding P1-008: appCode coercion removed; the downstream outcome is returned verbatim.`
* When the target declaration already has Javadoc, add the annotation as a final line inside the existing block. Never stack a second Javadoc block above one that already exists.
* Keep each annotation to a single line under 120 characters. Truncate the assessment title at a clause boundary rather than wrapping; the finding ID carries the precise reference.
* Do not annotate code the plan does not change, and do not restate the assessment's full Issue or Recommended Fix text in the comment.
* Do not annotate test code. Tests name the finding in their method names; a second marker adds churn without new traceability.

Formats to specify in the plan:

* New Java type or method — Javadoc above the declaration:

	```java
	/**
	 * Resiliency finding P0-007: No dependency health is surfaced to any probe endpoint.
	 */
	```

* Existing Java type or method that already carries Javadoc — a final line inside the existing block:

	```java
	/**
	 * Existing description of the method.
	 *
	 * Resiliency finding P0-007: No dependency health is surfaced to any probe endpoint.
	 */
	```

* Modified Java statement or block — single-line comment immediately above the change:

	```java
	// Resiliency finding P0-013: The provider call chain has no operator timeout or deadline.
	```

* Build-manifest dependency added for a Java change — single-line comment on the dependency:

	```groovy
	// Resiliency finding P0-005 (dependency prerequisite): Federated identity chain runs per request with no timeout.
	```

## Required Protocol

1. Follow the Task Planner protocol (Context Assessment, Planning, Plan Validation, Completion) without redefining it. Treat the Assessment Discovery result as the planner's source document, supplementing rather than duplicating the planner's own Context Assessment step.
2. When `${input:chat}` is true (the default), incorporate the current conversation context and any attached files as additional planning input alongside the assessment. When false, plan solely from the assessment document and explicitly declared inputs.
3. Before planning, present the derived in-scope Java inventory (finding IDs, titles, target files) and the excluded list, so the scope boundary is confirmed.
4. Produce a single implementation plan set covering the in-scope inventory under `.copilot-tracking/`: one plan file, one details file, and one planning log. Use a task slug such as `java-resiliency-p0-p1` so the generated filenames stay predictable.
5. Carry the annotation requirement into the details file: for each in-scope finding, record the exact annotation text and the declaration or statement it sits above, so the Task Implementor emits it without re-deriving it.
6. Plan a final verification step that greps the diff for the `Resiliency finding` marker and reconciles the set of finding IDs found against the in-scope inventory. It fails on any missing ID, any ID not in the inventory, and any annotation on a file the plan does not change.
7. Do not implement code changes; produce planning artifacts only and hand off to the Task Implementor.