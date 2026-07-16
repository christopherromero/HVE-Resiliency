---
description: "Generates an executive ROI and telemetry report from a completed HVE Resiliency workflow run"
argument-hint: "[telemetryJson=...]"
---

# HVE Resiliency Telemetry Report

Run this prompt to turn telemetry from a completed `hve-resiliency-research` run into an executive ROI and telemetry report.

This prompt delegates to the [`hve-resiliency-telemetry-report`](../../skills/hve-resiliency-telemetry-report/SKILL.md) skill. Follow the skill's [report prompt](../../skills/hve-resiliency-telemetry-report/report-prompt.md) for the schema, calculation rules, and output format, and its [collection guide](../../skills/hve-resiliency-telemetry-report/collection-guide.md) for where each value comes from.

## Inputs

* ${input:telemetryJson}: (Optional) Completed telemetry JSON matching the schema in the skill's report prompt. If omitted, help the user gather it from the collection guide first.

## Required Steps

1. Confirm a completed run exists: research under `.copilot-tracking/research/`, plans under `.copilot-tracking/plans/`, the final report under `Microsoft-Assessment/`, and a filled [token usage tracker](../../../docs/token-usage-tracker.md) with the per-stage Session Cost (credits).
2. If `telemetryJson` was not provided, walk the user through the [collection guide](../../skills/hve-resiliency-telemetry-report/collection-guide.md) to assemble it. Aggregate the token tracker rows into the three buckets: `task_researcher` (Phases 1-3), `task_planner` (Phase 4), and `assessment_builder` (Phase 5).
3. Generate the eight-section report by applying the [report prompt](../../skills/hve-resiliency-telemetry-report/report-prompt.md) rules to the JSON.
4. Mark every estimated metric with its confidence indicator.
5. Return the report plus a one-page executive summary.

## Rules

* This workflow has no implementation phase. Downstream remediation is driven by the exported findings and is out of scope for this report.
* Cost comes from the token tracker's measured Session Cost credits. Do not estimate tokens from artifact word counts: that misses the system prompt, tool definitions, tool results, and context re-reads, and understates real cost.
* Include human oversight time in agent-side cost so ROI is not overstated.
* Do not use em dashes in the generated report. Use a hyphen or restructure the sentence.
* A qualified engineer or finance reviewer must validate every headline metric before the report is shared.
