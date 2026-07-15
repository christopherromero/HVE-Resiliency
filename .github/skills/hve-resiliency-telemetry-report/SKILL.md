---
name: hve-resiliency-telemetry-report
description: Use for generating an executive ROI and telemetry report from an HVE Resiliency workflow run, comparing agent-assisted research, planning, and assessment phases against a manual baseline to quantify time savings, cost, and quality.
---

# HVE Resiliency Telemetry Report

Use this skill when you need an executive-facing ROI report for a completed `hve-resiliency-research` workflow run. It turns the telemetry from the researcher, planner, and assessment phases into a data-driven report for leadership, finance, and technical decision-makers.

Use [Resiliency Research Platform Context](../../instructions/hve-resiliency-platform-context.instructions.md) for terminology and priority definitions.

## Activation Guidance

Auto-load this skill only for requests that explicitly mention one or more of the following: a resiliency telemetry report, a resiliency ROI report, agent ROI for a resiliency run, cost-benefit analysis of the resiliency workflow, or the `/hve-resiliency-telemetry-report` command. Do not auto-load for general reporting, unrelated cost questions, or the research workflow itself.

## When to Use

Use this skill after a resiliency workflow run when you need to:

* Quantify time saved versus a manual resiliency assessment.
* Report the credit and token cost of the run to a sponsor.
* Present quality and reliability evidence for the agent-produced assessment.
* Project ROI across a portfolio of repositories scheduled for assessment.

Do not use this skill to run the assessment itself. Run [`hve-resiliency-research`](../hve-resiliency-research/SKILL.md) first to produce the artifacts this skill reports on.

## Prerequisites

* A completed `hve-resiliency-research` run for the target repository, with:
  * Research artifacts under `.copilot-tracking/research/`.
  * Planning artifacts under `.copilot-tracking/plans/` (`<repo-name>-Master.md`, `<repo-name>-Developer-Guide.md`).
  * A final assessment at `Microsoft-Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`.
* A completed [token usage tracker](../../../docs/token-usage-tracker.md) with the Session Cost (credits) recorded from the VS Code Session Info panel at the end of each stage (research, planning, assessment). Session Cost is the only value the report needs.
* A manual baseline (measured or estimated) for the same scope of work.

## Data Source Map

This skill reads from where the resiliency workflow actually writes, not from a sandbox folder. The three telemetry buckets map to the workflow phases as follows.

| Telemetry bucket | Workflow phase | Primary source |
|---|---|---|
| Task Researcher | Phases 1-3 (research, service research, consolidation) | `.copilot-tracking/research/` artifacts; Session Cost credits from the token tracker |
| Task Planner | Phase 4 (planner-0, planner-1, planner-2) | `.copilot-tracking/plans/<repo-name>-Master.md` and `<repo-name>-Developer-Guide.md`; Session Cost credits from the token tracker |
| Assessment Builder | Phase 5 (assessment-builder-0 through 3) | `Microsoft-Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`; Session Cost credits from the token tracker |

This workflow ends at the assessment report. It has no implementation phase: remediation is driven downstream by the exported findings (work items), which engineers implement outside this workflow. This skill therefore reports on research, planning, and assessment only. Downstream remediation effort is out of scope and, if needed, belongs in a separate baseline comparison.

Cost comes from the [token usage tracker](../../../docs/token-usage-tracker.md): the single value the human records is the Session Cost (credits) from the Session Info panel at the end of each stage. We do not estimate tokens from artifact word counts because that only sees the final documents and misses the system prompt, tool definitions, tool results, retries, and repeated context re-reads, so it systematically undercounts real cost.

## Workflow

1. Confirm the target repository and locate its assessment artifacts and the filled token tracker.
2. Gather telemetry per phase using the [collection guide](collection-guide.md). Aggregate the token tracker rows into the three buckets in the Data Source Map.
3. Record or estimate the manual baseline for the same scope.
4. Fill the JSON template in the [collection guide](collection-guide.md). Mark every estimated field.
5. Provide the completed JSON to the [report prompt](report-prompt.md) to generate the report.
6. Review the report, verify confidence markers on estimated data, and share the executive summary.

## Output

A markdown executive report with an executive summary, methodology and baseline, results dashboard, cost-benefit analysis, quality and reliability evidence, risk assessment, scaling outlook, and recommendations. Estimated metrics carry explicit confidence markers.

## Known Limitations

* Quality scores use the rubric defined in the [report prompt](report-prompt.md). Scores derived without a completed rubric are marked low confidence.
* Human oversight time (review, correction, re-prompting) is captured separately per phase and included in agent-side cost so ROI is not overstated.
* Cost comes from the token tracker's measured Session Cost credits. A credit-to-currency conversion is applied only when the operator supplies a rate; otherwise cost is reported in credits.

## Output Review

> **Review notice:** This report is AI-assisted and may contain inaccurate metrics, miscalculated ROI, or overstated benefits. A qualified engineer or finance reviewer must validate every headline metric against the source token tracker and baseline data before the report is shared or acted on.

## Attribution

This skill is part of the HVE Resiliency workflow and extends a completed assessment run into an executive ROI and telemetry report.
