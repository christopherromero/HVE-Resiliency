<!-- markdownlint-disable-file -->
# Review Log: Resiliency Eval Skill + Phase-Gate Integration

## Metadata

- Review date: 2026-08-27
- Scope: working-tree audit (nothing committed) of the evaluation capability and its pipeline wiring
- Reviewer mode: HVE Task Reviewer (customization-file audit; no `.copilot-tracking/` plan or changes log exists for this session)

### Artifacts under review

| Change | Path | Type |
|--------|------|------|
| New skill | `.github/skills/hve-resiliency-eval/SKILL.md` | Added |
| New agent | `.github/agents/hve-resiliency-eval-orchestrator.agent.md` | Added |
| Research orchestrator | `.github/agents/hve-resiliency-research-orchestrator.agent.md` | Modified |
| Planning orchestrator | `.github/agents/hve-resiliency-planning-orchestrator.agent.md` | Modified |
| Planner context | `.github/instructions/hve-resiliency-planner-context.instructions.md` | Modified |
| Planner 3d prompt | `.github/prompts/planner/hve-resiliency-planner-3d.prompt.md` | Modified |
| README | `README.md` | Modified |

## Summary

| Severity | Count |
|----------|------:|
| Critical | 0 |
| Major | 1 |
| Minor | 3 |
| Observation | 1 |

Overall status: Ship with minor fixes. The skill is well grounded: every contract citation I spot-checked resolves accurately, frontmatter/tool conventions match the existing orchestrators, and all relative links resolve. One cross-file naming/collision issue is worth fixing before use.

## Verified correct

- Contract grounding: `F-00X` authoritative scheme, `F-<section>-00X` fill-time IDs, "Sections 1-9" consolidated structure, and the six report section names all match `hve-resiliency-consolidation-shared.instructions.md` and `planner-3.prompt.md` / `planner-3a.prompt.md`.
- SC-6 GLB health-probe-first-in-P0 ordering matches `reorder-assessment-findings.prompt.md`.
- CC-3 status semantics (`Complete` / `Incomplete` / `Blocked`, block only for a broken pipeline) match `hve-resiliency-platform-context.instructions.md` L21-30.
- Runbook 12-item -> check mapping table is complete and each mapping is correct against `post-assessment-runbook.md`.
- Cross-referenced remediation prompts exist: `detect-assessment-duplicates.prompt.md`, `reorder-assessment-findings.prompt.md`.
- New eval agent frontmatter (`user-invocable`, `disable-model-invocation`, `agents`, tool aliases) matches the research/planning orchestrator pattern recorded in repo memory.
- planner-context "Special Case: Platform-Recommended Changes" and "Scope Exclusions", plus the five planner-3d hygiene bullets, correctly mirror checks CL-6 / CV-5 / SC-5 / SC-7 / SC-8 (produce-clean matches grade-for).

## Resolution (applied 2026-08-27)

- F1 + F2 + F4 fixed: two tier-qualified eval files, both using `<repo-name>` - `<repo>-research-eval.md` (T1/T2) and `<repo>-assessment-eval.md` (T3). Skill Output Contract rewritten to write only evaluated tier files and never overwrite others; research orchestrator, planning orchestrator, and eval orchestrator updated (planning's `{serviceName}` token replaced).
- F5 addressed: added `${input:checkerGate:stage}` to both orchestrators. Default `stage` cadence gates only at stage/wave boundaries; `step` opt-in gates every producing step. Phase-boundary full evaluation always runs, so an eval is produced regardless. Skill gained a "Gate Cadence" note.
- F3 left unchanged pending operator decision (see below).

## Findings

### F1 (Major) - Phase-boundary eval reports collide on a single filename

All three writers target the same output file:

- `SKILL.md` L190: `<repo-name>-resiliency-eval.md`
- research orchestrator L132: `.copilot-tracking/eval/<repo-name>-resiliency-eval.md` (T2 research phase gate)
- planning orchestrator L112: `.copilot-tracking/eval/{serviceName}-resiliency-eval.md` (T3 assessment phase gate)
- eval orchestrator L87: `<repo-name>-resiliency-eval.md` (standalone)

Because the filename is not tier-qualified, the planning-phase (T3) evaluation overwrites the research-phase (T2) evaluation, and a later standalone run overwrites both. This works against the stated session goal that "each phase produces AND self-grades": the research grade is lost the moment planning runs, and the "trendable number" cannot be trended across phases. Recommend tier-qualified names (for example `<repo>-research-eval.md` / `<repo>-assessment-eval.md`) or an explicit rolling/append report, and update the skill Output Contract to match.

### F2 (Minor) - Inconsistent placeholder token for the eval filename

The planning orchestrator uses `{serviceName}` while the research orchestrator, eval orchestrator, and skill use `<repo-name>`. Even after F1 is resolved, standardize on one token so the paths are unambiguous. (The planner prompts use `{serviceName}` elsewhere, so if that is the intended token, align the other three writers to it - and the skill's "using the repository name as the prefix" wording.)

### F3 (Minor) - CC-6 provenance may be one link too high in the chain

CC-6 (T3) fails the report for "any finding absent from the consolidated research." The planner actually derives report findings from `{serviceName}-Master.md` and the Developer Guide capture (see `planner-3a.prompt.md` L18, `planner-3d.prompt.md` L16, and EF-4's "Developer Guide capture"), which are themselves downstream of the consolidated doc. A finding that legitimately originates in the Developer Guide but is not literally in the consolidated document could be a CC-6 false positive ("invented"). Confirm the intended provenance anchor for CC-6 (consolidated doc vs. Master/Developer Guide) and word the check to match the real source of truth.

### F4 (Minor) - Output Contract still says "one evaluation report per invocation"

`SKILL.md` L190 assumes a single invocation, but the phase-gate embedding now invokes the evaluation twice per full pipeline run (research Step 5, planning Step 4) plus optional standalone. The Output Contract should acknowledge multiple invocations and how their reports coexist (ties into F1).

### F5 (Observation) - Blind-checker gate roughly doubles subagent dispatch count

Every producing step/wave in the research orchestrator now dispatches an extra blind checker subagent (sequential spine + fan-out wave + consolidation stages). This is a deliberate fail-fast tradeoff, but given the repo's active token-optimization focus (`docs/proposal-token-optimization-strategy.md`, `docs/token-usage-tracker.md`), confirm the added dispatch cost is acceptable. Not a correctness issue.

## Validation commands

Markdown-only change set; no build/test pipeline applies. `get_errors` was not run against `.md` customization files (no compiler diagnostics). Manual link/citation resolution was performed via workspace search and confirmed above.

## Follow-up

Discovered during review:

1. Resolve F1 (filename collision) - highest priority; blocks the "self-grade per phase" goal.
2. Standardize the placeholder token (F2).
3. Re-word or confirm CC-6 provenance (F3).
4. Update the Output Contract for multiple invocations (F4).
5. Confirm the blind-checker dispatch cost is acceptable (F5).

Deferred from scope: none.
