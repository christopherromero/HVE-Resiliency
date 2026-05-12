# HVE Resiliency

Guided GitHub Copilot workflow for producing Azure resiliency assessments. The workflow covers zone failure within a primary region and regional failover to a secondary region, and emits evidence-only findings classified by P0-P3 priority.

This repository packages the prompts, instructions, and skill needed to drive the workflow end-to-end inside VS Code with GitHub Copilot Chat.

## Quick start

1. Open this repository in VS Code with GitHub Copilot Chat enabled.
2. In Chat, run `/hve-resiliency-research`.
3. Choose an execution mode when prompted:
    - **Mode A (Interactive).** One prompt per turn, `/clear` between prompts.
    - **Mode B (Autonomous).** Each prompt runs as an isolated subagent.
4. Follow the phase sequence: Core Research → Service Research → Consolidation → Planning → Assessment.

### Why `/clear` between prompts?

The `/clear` command resets Copilot's context between phases. Each phase should start fresh; the artifacts (research doc, plan) carry context forward, not the chat history. This avoids context degradation from accumulated prior turns and keeps each step reproducible from files on disk.

Mode B gets the same isolation by running each prompt as a fresh subagent. See HVE Core's Context Engineering docs for the full explanation.

See [.github/skills/hve-resiliency-research/SKILL.md](.github/skills/hve-resiliency-research/SKILL.md) for the authoritative workflow definition.

## Repository layout

| Path | Purpose |
|------|---------|
| [.github/skills/hve-resiliency-research/](.github/skills/hve-resiliency-research/) | Skill that orchestrates the full research workflow. |
| [.github/prompts/researcher/](.github/prompts/researcher/) | Phase 1 (core) and Phase 2 (per-service) research prompts, plus the consolidation prompt. |
| [.github/prompts/planner/](.github/prompts/planner/) | Phase 4 planning prompts. |
| [.github/prompts/assessment-builder/](.github/prompts/assessment-builder/) | Phase 5 assessment authoring prompts. |
| [.github/instructions/](.github/instructions/) | Platform context and evidence-only rules applied to researcher and planner prompts. |
| [Microsoft-Assessment/](Microsoft-Assessment/) | Workflow overview and a worked example assessment. |

## Workflow phases

| Phase | Prompts | Notes |
|-------|---------|-------|
| 1. Core Research | `researcher-0` … `researcher-7-logging` | Sequential. Mode-aware. |
| 2. Service Research | `researcher/service/*` (8-19, filtered to applicable services) | Mode B allows up to 3 concurrent subagents. |
| 3. Consolidation | `researcher-consolidate` | User-gated. |
| 4. Planning | `planner-0`, `planner-1`, `planner-0`, `planner-2` | User-gated, `/clear` between steps. |
| 5. Assessment | `assessment-builder-0` … `assessment-builder-3` | User-gated, `/clear` between steps. |

A worked example output lives at [Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md](Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md). A visual overview of the workflow evolution is in [Microsoft-Assessment/resiliency-researcher-workflow.md](Microsoft-Assessment/resiliency-researcher-workflow.md).

## HVE at Microsoft

HVE (Highly Velocity Engineering) is a Microsoft engineering practice and toolset. Related Microsoft resources:

- [microsoft/hve-core](https://github.com/microsoft/hve-core): Shared instructions, skills, agents, and conventions used across HVE repositories.
- [HVE Essentials VS Code extension](https://marketplace.visualstudio.com/items?itemName=ise-hve.hve-essentials): Bundles `hve-core` prompts, instructions, and skills into VS Code.
- [Microsoft Industry Solutions Engineering (ISE)](https://www.microsoft.com/en-us/industry/microsoft-industry-solutions-engineering): The Microsoft engineering org behind HVE.
- [Azure Well-Architected Framework Reliability pillar](https://learn.microsoft.com/azure/well-architected/reliability/): Foundational reliability guidance referenced by the resiliency prompts.
- [Azure reliability documentation](https://learn.microsoft.com/azure/reliability/): Per-service availability zone and regional failover reference content.

## Contributing

Prompts, instructions, agents, and skills in this repository follow the conventions in [microsoft/hve-core](https://github.com/microsoft/hve-core). When editing files under `.github/prompts/`, `.github/instructions/`, or `.github/skills/`, follow the prompt-builder and markdown instructions inherited from `hve-core`.
