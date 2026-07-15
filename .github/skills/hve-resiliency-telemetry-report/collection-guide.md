# Telemetry Collection Guide

This guide is for the human operator gathering telemetry from a completed `hve-resiliency-research` run. It tells you where each value lives and how to fill the JSON that the [report prompt](report-prompt.md) consumes.

The three telemetry buckets map to workflow phases as follows. This workflow ends at the assessment report; it has no implementation phase, because remediation is driven downstream by the exported findings and is out of scope for this report.

| Bucket                 | Phase      | Where the artifacts are                                                    |
| ---------------------- | ---------- | -------------------------------------------------------------------------- |
| `task_researcher`    | Phases 1-3 | `.copilot-tracking/research/`                                            |
| `task_planner`       | Phase 4    | `.copilot-tracking/plans/`                                               |
| `assessment_builder` | Phase 5    | `Microsoft-Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md` |

## Step 1: Confirm the run is complete

Before collecting, confirm all artifacts exist:

* Research outputs under `.copilot-tracking/research/`, one per Phase 1 prompt plus the applicable Phase 2 service prompts and the consolidated `YYYY-MM-DD-<repo-name>-research.md`.
* Planning outputs `.copilot-tracking/plans/<repo-name>-Master.md` and `.copilot-tracking/plans/<repo-name>-Developer-Guide.md`.
* The final report `Microsoft-Assessment/{serviceName}-Code-Level-Resiliency-Assessment.md`.
* The [token usage tracker](../../../docs/token-usage-tracker.md), filled in with the Session Info panel readings you recorded after each prompt during the run.

If any are missing, the run did not complete. Re-run the missing phase before reporting.

## Step 2: Record the Session Cost (credits)

The only number you need for cost is the **Session Cost (credits)** shown in the VS Code Copilot Chat Session Info panel. Record it in the [token usage tracker](../../../docs/token-usage-tracker.md). You can ignore the other columns in the tracker unless you want extra detail.

You need one reading at the end of each stage: after research (Phases 1-3), after planning (Phase 4), and after the assessment (Phase 5). That is three readings for the whole run.

We use this measured number instead of estimating tokens from artifact word counts because word-counting only sees the final documents and misses the system prompt, tool definitions, tool results, retries, and repeated context re-reads, so it undercounts real cost and makes the agent look cheaper than it was.

> **Important:** The Session Cost keeps counting up across `/clear`, so clearing between prompts does not lose it. It resets to zero only when you start a brand-new chat session, and once it resets the number is gone. Write down the Session Cost before you end or restart the chat.

Session Cost is cumulative, so each stage's cost is the difference between its reading and the previous stage's reading. Example, if the Session Cost reads 456.9 at the end of research, 690.0 at the end of planning, and 910.0 at the end of assessment:

* `task_researcher.session_cost_credits` = 456.9
* `task_planner.session_cost_credits` = 690.0 - 456.9 = 233.1
* `assessment_builder.session_cost_credits` = 910.0 - 690.0 = 220.0

## Step 3: Capture timing per phase

Capture timing from your session notes or the file timestamps of the artifacts each phase produced.

For each bucket record:

* `active_minutes` = time actually spent driving that phase (running prompts, reviewing between prompts in Mode A).
* `calendar_span_minutes` = elapsed wall-clock time from the first prompt of the phase to the last, including any breaks.
* `paused_minutes` = `calendar_span_minutes - active_minutes`.
* `pause_events` = count of distinct breaks, including `/clear` gaps and overnight pauses.

If you only have the calendar span, set `active_minutes` equal to it, set `paused_minutes` to 0, and mark timing as estimated. Do not imply that elapsed span equals active work time when pauses occurred.

## Step 4: Capture task counts, quality, errors, and oversight

* `tasks_completed` for the researcher bucket = number of research artifacts produced (Phase 1 prompts plus applicable Phase 2 service prompts plus consolidation).
* `tasks_completed` for the planner bucket = number of planning documents produced (Master and Developer Guide).
* `tasks_completed` for the assessment builder bucket = number of finding records in the final assessment, counted from finding headers of the form `#### Pn-###:`.
* `quality_score` = score from the rubric in the [report prompt](report-prompt.md). If you did not score against the rubric, leave it null and it will be marked low confidence.
* `errors` = count of retries, off-spec outputs, or corrections you had to make during that phase.
* `human_oversight_minutes` = time you spent reviewing, correcting, and re-prompting that phase. This is included in agent-side cost so ROI is not overstated.

## Step 5: Record the manual baseline

If you have measured baseline data from a comparable manual resiliency assessment, use it. Otherwise estimate with these guidelines and mark confidence accordingly.

| Task type                  | Typical team      | Duration (hours) | Quality (%) | Confidence |
| -------------------------- | ----------------- | ---------------- | ----------- | ---------- |
| Assessment (analysis only) | 1 senior engineer | 20-40            | 90          | High       |
| Single-service deep dive   | 1-2 engineers     | 40-80            | 85          | Medium     |
| Multi-service assessment   | 2-3 engineers     | 100-200          | 85          | Medium     |
| Portfolio assessment       | 3-5 engineers     | 300-600          | 80          | Low        |

Cost is `total_hours * hourly_rate * (1 + rework_rate)`. Typical rework rate is 10-15 percent for a well-scoped assessment.

## Step 6: Fill the JSON template

```json
{
  "session_metadata": {
    "session_id": "session-YYYY-MM-DD-001",
    "date": "YYYY-MM-DD",
    "repository": "",
    "service_name": "",
    "execution_mode": "Mode A or Mode B",
    "model": "",
    "task_count": 0,
    "agents_involved": ["Task Researcher", "Task Planner", "Assessment Builder"]
  },
  "agent_execution": {
    "task_researcher": {
      "active_minutes": 0,
      "calendar_span_minutes": 0,
      "paused_minutes": 0,
      "pause_events": 0,
      "human_oversight_minutes": 0,
      "session_cost_credits": 0,
      "tasks_completed": 0,
      "quality_score": null,
      "errors": 0,
      "notes": ""
    },
    "task_planner": {
      "active_minutes": 0,
      "calendar_span_minutes": 0,
      "paused_minutes": 0,
      "pause_events": 0,
      "human_oversight_minutes": 0,
      "session_cost_credits": 0,
      "tasks_completed": 0,
      "quality_score": null,
      "errors": 0,
      "notes": ""
    },
    "assessment_builder": {
      "active_minutes": 0,
      "calendar_span_minutes": 0,
      "paused_minutes": 0,
      "pause_events": 0,
      "human_oversight_minutes": 0,
      "session_cost_credits": 0,
      "tasks_completed": 0,
      "quality_score": null,
      "errors": 0,
      "notes": ""
    }
  },
  "manual_baseline": {
    "total_time_hours": 0,
    "quality_score": 0,
    "rework_rate_percent": 0,
    "cost_estimate": 0,
    "hourly_rate": 0,
    "confidence": "High | Medium | Low",
    "approach": ""
  },
  "cost_model": {
    "credit_to_usd": null,
    "model_name": ""
  },
  "business_context": {
    "organization": "",
    "project_name": "",
    "task_type": "resiliency assessment",
    "scalability_horizon": 0
  }
}
```

## Step 7: Generate the report

Provide the completed JSON to the [report prompt](report-prompt.md). Review the output, verify confidence markers on any estimated fields, and correct any headline metric that does not reconcile with the source tracker before sharing.
