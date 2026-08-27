---
name: hve-resiliency-eval
description: Use to evaluate the outputs of the HVE resiliency orchestration pipeline (per-phase research artifacts, the consolidated research document, and the final Code-Level Resiliency Assessment report) with an evidence-re-verifying worker/checker that emits pass/fail findings and a weighted numeric rubric score.
---

# HVE Resiliency Evaluation

Use this skill to grade what the resiliency orchestration pipeline produced. It is a quality gate, not a producer: it never edits, repairs, or extends an artifact, and it never lowers the evidence-only contract it audits against.

**Rubric Version:** 1.0

The evaluation is a **worker/checker with an embedded numeric rubric**. A fresh checker independently re-verifies each cited piece of evidence against the workspace source, emits discrete pass/fail findings against the same contracts the orchestrators enforce, and rolls those findings into a weighted per-dimension score. You get both an actionable defect list and a trendable number.

## Activation Guidance

Auto-load this skill for requests to evaluate, grade, score, audit, or QA the output of the resiliency research or planning pipeline, or when asked whether a consolidated research document or a Code-Level Resiliency Assessment report meets the contract.

## Automated Evaluation (Recommended)

For a one-invocation run, select **Resiliency Eval Orchestrator v1.0** from the agent picker. It dispatches the checker to a fresh subagent (so the evaluation is not biased by the context that produced the artifact), aggregates the findings, and writes the evaluation report. The manual path below is the one-artifact-at-a-time equivalent.

## Contract Sources (Authoritative)

This skill does not restate the pipeline contracts. Every check below cites the file that owns the rule. Read these once before evaluating, and re-read the exact rule when a check fires:

* [Application Platform Context](../../instructions/hve-resiliency-platform-context.instructions.md) - evidence-only rules, status and failure semantics, P0-P3 legend, categorization decision tree, Service Exclusion Rule, Database-to-Kafka Pairing Standard.
* [Consolidation Shared Contract](../../instructions/hve-resiliency-consolidation-shared.instructions.md) - line-number integrity, sanitization, required finding schema, section-to-source mapping, ID allocation, consolidated document structure.
* [Resiliency Task Planner Context](../../instructions/hve-resiliency-planner-context.instructions.md) - evidence fidelity contract, region-agnostic output rule, litmus test, four rules, engagement framing.
* [hve-resiliency-research skill](../hve-resiliency-research/SKILL.md) - phase ordering, required and applicable prompt sets, artifact locations.
* [Post-Assessment Report Runbook](../../prompts/post-assessment-runbook.md) - the 12-item final-report hygiene checklist the assessment tier (T3) automates: deployment model, encoding, `PX-NNN` scheme, scope exclusions, platform-to-P3, ordering, agent-internals.

The evaluation reproduces no contract text as its own rule. When a contract source and this skill appear to conflict, the contract source wins and the checker records the divergence as a finding.

## Evaluable Artifact Tiers

| Tier | Artifact | Location | Governing contract |
|------|----------|----------|--------------------|
| T1 | Per-phase research artifacts (researcher `0`-`17`, Prompt 5 fragments) | `.copilot-tracking/research/` | Platform Context |
| T2 | Consolidated research document + manifest sidecar | `.copilot-tracking/research/` | Consolidation Shared Contract |
| T3 | Final Code-Level Resiliency Assessment report | `Microsoft-Assessment/` | Planner Context |

Evaluate only the tiers requested. When a tier is requested but its artifact is absent, record the tier as `Not evaluated: artifact missing` and continue; a missing input artifact is a checker finding, never a checker failure.

## Checker Discipline

The checker earns a passing score for a finding only by re-verifying it, never by trusting the artifact's own assertion:

* Re-open every cited `path:Lx-Ly` in the workspace and confirm the range exists.
* Compare any quoted or described code against the source bytes; a paraphrase is a failure even when the meaning is preserved.
* Never estimate, merge, or recalculate line numbers. Copy them verbatim when reporting a finding, exactly as the audited artifact and the source file show them.
* Sanitize before writing: never reproduce a secret value in the evaluation report. Record only the secret type, path, and line.
* Read each contract source and each audited artifact once with a full-range read; batch independent reads.

## Evaluation Dimensions and Weights

Each dimension scores 0-100. The overall score is the weighted sum. Weights total 100.

| Dimension | Weight | What it measures |
|-----------|-------:|------------------|
| D1 Evidence and Code Fidelity | 30 | Citations exist, resolve to real ranges, and quoted code is verbatim. |
| D2 Contract Compliance | 25 | Evidence-only prohibitions, sanitization, status semantics, region-agnostic output, resiliency framing, deployment model. |
| D3 Classification Correctness | 20 | P0-P3 assigned and consistent with the decision tree; Kafka strategy, exclusion, and platform-to-P3 rules honored. |
| D4 Schema, Structure, and Report Hygiene | 15 | Required finding schema, document structure, ID scheme, index integrity, and final-report hygiene (encoding, ordering, agent-internals). |
| D5 Completeness and Coverage | 10 | Required and applicable prompts present, dedup applied, out-of-scope excluded, full traceability into the report. |

## Check Catalog

Each check yields `Pass`, `Warn`, or `Fail`. A `Fail` carries a severity: `Critical`, `Major`, or `Minor`. Cite the artifact location and the governing contract for every non-pass result.

### D1 Evidence and Code Fidelity

* EF-1 (T1, T2, T3): Every substantive finding cites file and line-level evidence in `path:Lx-Ly` form. Missing citation on a rendered finding is `Critical`.
* EF-2 (T1, T2, T3): Each cited path exists and each cited line range is valid in the workspace. An unresolvable citation is `Major`; a fabricated path is `Critical`.
* EF-3 (T1, T2, T3): Quoted or described code matches the source bytes verbatim. Any paraphrase of referenced code is `Critical`.
* EF-4 (T3): `**File:**` and `**Fix:**` code in the report matches the Developer Guide capture, and citations stay synchronized across the Full Finding Matrix, IaC Gap Analysis, and Microsoft Standards Alignment sections. A desynchronized citation is `Major`.

### D2 Contract Compliance

* CC-1 (T1, T2): Research artifacts contain no remediation, recommendations, selected approaches, code examples, or advisory language. Any remediation content in a research tier is `Critical`.
* CC-2 (T1, T2, T3): No raw secret value appears; potential secrets are reduced to type, path, line, and redacted identity. A leaked secret value is `Critical`.
* CC-3 (T1, T2): Terminal status is exactly one of `Complete`, `Incomplete`, or `Blocked`, and `Blocked` is used only for a genuinely missing or invalid prior-step input, never for repository content. A content-based block is `Major`.
* CC-4 (T3): Generated report output contains no `East US`, `eastus`, or East-region variant. Any East reference in generated output is `Major`.
* CC-5 (T3): Every finding in the resiliency bucket states a resiliency impact in the Rule 2 framing rather than a "your logic is broken" framing, and sits in the correct section (Section 2 Resilient versus Section 3 Non-Resilient) per the litmus test. A miscategorized or misplaced finding is `Major`.
* CC-6 (T3): The report introduces no finding absent from the consolidated research. An invented finding is `Critical`.
* CC-7 (T3): The report's stated deployment model matches the agreed topology input (Active/Active or Active/Standby) consistently wherever the model is named. A contradictory or wrong model statement is `Major`. (Runbook item 1.)

### D3 Classification Correctness

* CL-1 (T1, T2, T3): Every rendered finding carries a P0, P1, P2, or P3 priority. A missing priority is `Major`.
* CL-2 (T1, T2, T3): The assigned priority is consistent with the categorization decision tree in the governing contract. A defensible-but-arguable priority is `Warn`; a clearly wrong priority is `Major`.
* CL-3 (T1, T2, T3): P2 and P3 items are framed as code-quality or completeness, not prioritized above P0/P1 resiliency risks. A misprioritized P2/P3 is `Major`.
* CL-4 (T1, T2): The Kafka strategy is taken from the provided value, never inferred from the database model, and any database-to-strategy mismatch is recorded as a gate observation rather than a code finding. An inferred strategy is `Critical`.
* CL-5 (T1, T2): Only Section 1 confirmed dependencies are analyzed downstream; nothing classified solely in Section 2 or 3 is carried forward. A carried-forward excluded dependency is `Major`.
* CL-6 (T3): Strictly platform-recommended changes are classified P3 whether or not they are resiliency-framed; a platform change embedded in a finding that also recommends an application fix is noted in that finding's Notes rather than driving its priority. A platform-only change prioritized above P3 is `Major`. (Runbook item 7.)

### D4 Schema, Structure, and Report Hygiene

* SC-1 (T2): Every rendered finding uses the required finding schema with all required fields present. A missing required field is `Major`.
* SC-2 (T2): Consolidated finding IDs use the authoritative `F-00X` scheme with no duplicates, and no unreconciled section-scoped `F-<section>-00X` IDs remain after finalize. A duplicate or unreconciled ID is `Major`.
* SC-3 (T2, T3): The consolidated document carries Sections 1-9, and the report carries its six top-level sections (1 Assessment Overview, 2 Resilient Focused Recommendations, 3 Non-Resilient Focused Recommendations, 4 IaC Gap Analysis, 5 Full Finding Matrix, 6 Microsoft Standards Alignment) with a Table of Contents. A missing top-level section is `Major`.
* SC-4 (T2): The Section 9 index matches the findings rendered in Sections 2.1 and 3-8. An index that omits or invents an ID is `Major`.
* SC-5 (T3): Report finding IDs use the `PX-NNN` scheme (`P0-NNN` through `P3-NNN`); no research or Developer Guide `F-XXX` ID appears in the final report, and each source `F-NNN` maps to a single stable `PX-NNN` across every section and cross-reference. Any `F-XXX` leakage or inconsistent mapping is `Major`. (Runbook item 4.)
* SC-6 (T3): Findings are ordered P0 then P1 then P2 then P3, with global-load-balancer health-probe findings first within P0, and `PX-NNN` numbered sequentially with no gaps. An ordering or numbering break is `Major`. (Runbook item 11.)
* SC-7 (T3): The report contains no character-encoding corruption (mojibake, replacement characters, or broken multi-byte sequences). Encoding corruption is `Minor`, or `Major` when it lands inside a `**File:**` or `**Fix:**` code block. (Runbook item 3.)
* SC-8 (T3): The report exposes no agent internals or process narration (for example "I searched", "the agent found", "reordered to", "according to the prompt"); the `Prompt Suite Version:` line is allowed. Any exposed internal is `Major`. (Runbook item 12.)

### D5 Completeness and Coverage

* CV-1 (T2): Required prompt IDs `0`, `1a`, `1b`, `2`-`6` are represented in the consolidation coverage snapshot. A missing required input is `Major`.
* CV-2 (T2): Every Section 1 confirmed dependency has its applicable service prompt (`9`-`17`) represented, and no inapplicable service is included. A missing applicable service is `Major`; an included inapplicable service is `Minor`.
* CV-3 (T3): Every consolidated finding traces into the report's Full Finding Matrix; none is silently dropped. A dropped finding is `Major`.
* CV-4 (T2, T3): Index-level dedup was applied and no two rendered findings are semantic duplicates. A residual duplicate is `Minor`.
* CV-5 (T3): Out-of-scope items are excluded or consolidated, not rendered as in-scope report findings. This includes CI/CD platform artifacts such as Jenkins and Pivotal Cloud Foundry (PCF) notes and findings owned by another repository. An out-of-scope item rendered as an in-scope finding is `Major`. (Runbook items 5 and 9.)

## Post-Assessment Runbook Coverage

The assessment tier (T3) automates the [Post-Assessment Report Runbook](../../prompts/post-assessment-runbook.md), which is otherwise a manual `HVE Task Reviewer` pass. Each runbook item maps to a check above:

| Runbook item | Check |
|--------------|-------|
| 1. Deployment model correct | CC-7 |
| 2. No East US references | CC-4 |
| 3. Encoding issues | SC-7 |
| 4. No `F-XXX` in the report (use `PX-NNN`) | SC-5 |
| 5. Jenkins / PCF excluded | CV-5 |
| 6. Resiliency vs Non-Resiliency placement | CC-5 |
| 7. Platform-only changes to P3 | CL-6 |
| 8. Duplicate findings removed | CV-4 |
| 9. Out-of-scope removed or consolidated | CV-5 |
| 10. Cited line numbers and `File:` snippets verbatim | EF-2, EF-3, EF-4 |
| 11. Findings reordered and renumbered | SC-6 |
| 12. No exposed agent internals | SC-8 |

The evaluation reports these as findings; it never edits the report. Route remediation to the runbook's own tools: a CV-4 duplicate to [detect-assessment-duplicates](../../prompts/detect-assessment-duplicates.prompt.md) then manual removal, and an SC-6 ordering or numbering break to [reorder-assessment-findings](../../prompts/reorder-assessment-findings.prompt.md). All other T3 findings route back to the planner step (`3a`-`3d`) that produced the affected section.

## Scoring Model

1. Start each dimension at 100.
2. Deduct per non-pass check in that dimension: `Critical` -100, `Major` -20, `Minor` or `Warn` -5. Floor each dimension at 0.
3. Overall score = round( sum( dimension_score x weight ) / 100 ).
4. Apply the gate: if any check anywhere is `Critical`, the overall band is `Fail` regardless of the numeric score. Report the number and the gated band together.

### Bands

| Band | Numeric | Meaning |
|------|---------|---------|
| Ship | 90-100 | Meets the contract; no rework required. |
| Ship with minor fixes | 75-89 | Minor findings only; safe to hand off with a fix list. |
| Needs rework | 60-74 | Material findings; return to the producing step. |
| Fail | below 60, or any `Critical` | Contract breach; rerun the producing step before use. |

## Per-Step Blind Local Checker

The evaluation runs at two granularities. This section defines the per-step gate the orchestrators invoke; the phase-boundary and end-of-run evaluation uses the full catalog above.

### Blindness

Producer subagents (researcher, consolidate, and planner prompts) never learn that a checker exists. They never receive the rubric, the dimension weights, the check IDs, or any checker output. This keeps producers optimizing for the contract rather than for the score. A producer that knew the rubric would teach to the test.

The checker is a separate subagent dispatched by the orchestrator with only the audited artifact and the Contract Sources. Checker results stay out-of-band in the orchestrator; they are never fed back into the producer's context as checker feedback.

### Local Check Subset

Only checks evaluable from a single artifact plus the source it cites run per step. These are the fail-fast checks that stop a defective early artifact from poisoning every downstream step:

* EF-1, EF-2, EF-3 - citation presence, resolution, and verbatim-code re-verification.
* CC-1 - evidence-only prohibition (research tiers).
* CC-2 - secret sanitization.
* CC-3 - status and blocking semantics.
* CL-1 - priority present on every rendered finding.
* SC-1 - required finding-schema fields present.
* SC-5, SC-7, SC-8 (T3 report appends only) - `F-XXX` leakage, encoding corruption, and exposed agent internals, each evaluable from the report artifact alone and worth catching before the next append compounds it.

The cross-artifact checks (CC-4, CC-5, CC-6, CC-7, CL-2 through CL-6 where they need frozen scope, SC-2, SC-3, SC-4, SC-6, EF-4, and every CV check) do not run per step. They require downstream artifacts, the frozen manifest, or the assembled report, so they run only at the phase-boundary and end-of-run evaluation. A per-step gate that skipped them would report a false pass, so the per-step result is explicitly labeled `local-only`.

### Gate Policy

The orchestrator applies this policy at each producing step:

1. Dispatch the producer subagent and wait for its artifact.
2. Dispatch a blind checker subagent scoped to the Local Check Subset for that artifact.
3. If the checker reports no `Critical` local finding, proceed to the next step.
4. If the checker reports a `Critical` local finding, rerun the producer exactly once. Pass only the contract-grounded defect (the failing artifact location and the governing contract rule it violates), never the rubric, the score, or the fact that a checker ran.
5. If the second attempt still reports a `Critical` local finding, stop and surface the artifact, the defect, and the governing contract to the operator. Do not proceed to dependent steps.

Record every per-step checker result (pass, auto-rerun, or paused) so the phase-boundary evaluation can fold them into the numeric rollup.

### Gate Cadence

The orchestrator chooses how often the local gate fires. The default cadence gates at stage and wave boundaries - the points where a defect would poison downstream steps - to keep dispatch cost bounded. A thorough cadence gates after every individual producing step. Under either cadence the phase-boundary and end-of-run evaluation always runs the full catalog, so no artifact ships ungraded.

## Output Contract

Write the evaluation to `.copilot-tracking/eval/`, using the repository name as the prefix and creating the folder if it does not exist. Use one file per tier group so each phase's grade persists independently:

* Research and consolidated tiers (T1, T2) -> `<repo-name>-research-eval.md`.
* Assessment tier (T3) -> `<repo-name>-assessment-eval.md`.

An invocation writes only the file or files for the tiers it evaluated and never overwrites a tier group it did not evaluate. Each report is report-only: it recommends the producing step to rerun but never edits the audited artifact.

Structure the report as:

* Header: repository name, rubric version, evaluated tiers, evaluated artifact paths, timestamp.
* Verdict: overall numeric score, gated band, and a one-line summary per tier.
* Dimension scorecard: a table of the five dimensions with per-dimension score and weight.
* Findings: one row per non-pass check with check ID, tier, severity, artifact location, governing contract citation, and the re-verified evidence.
* Remediation routing: for each `Critical` or `Major` finding, name the producing step to rerun (a specific researcher, consolidate, or planner prompt).

## Manual Workflow

Run this when driving the evaluation yourself instead of using the agent.

1. Identify the requested tiers and locate their artifacts under `.copilot-tracking/research/` and `Microsoft-Assessment/`.
2. Read the four Contract Sources in one parallel block.
3. For each tier, run the applicable checks in the Check Catalog, re-verifying every citation against the workspace source per Checker Discipline.
4. Score each dimension, compute the overall score, and apply the gate.
5. Write the evaluation report per the Output Contract.

## Execution Rules

* Evaluate only; never edit, repair, or extend an audited artifact.
* Re-verify every citation; never pass a finding on the artifact's assertion alone.
* Never reproduce a secret value in the evaluation report.
* Cite the governing contract source for every non-pass result.
* A missing input artifact is a finding, not a checker failure.
