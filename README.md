# HVE Resiliency
## Overview

An HVE (Hypervelocity Engineering) agent-driven resiliency framework for Azure. It orchestrates the **Task Researcher** and **Task Planner** agents ([microsoft/hve-core](https://github.com/microsoft/hve-core) and bundled in the [HVE Essentials VS Code extension](https://marketplace.visualstudio.com/items?itemName=ise-hve.hve-essentials)) through a five-phase workflow that produces evidence-only research and a prioritized P0-P3 remediation plan with file- and line-level citations.

The framework targets two failure modes: zone failure within a region, and full regional failover in an active/active multi-region deployment where either region can take over for the other.

This repository packages the prompts, instructions, and skill needed to drive the workflow end-to-end inside VS Code with GitHub Copilot Chat. It does not own the Task Researcher or Task Planner agents themselves; those are maintained in `hve-core`. Guidance aligns with the [Azure Well-Architected Framework Reliability pillar](https://learn.microsoft.com/azure/well-architected/reliability/) and [Azure reliability documentation](https://learn.microsoft.com/azure/reliability/).

For a visual overview of how the workflow evolved and how its five phases fit together, see [docs/resiliency-researcher-workflow.md](docs/resiliency-researcher-workflow.md).

## Problem statement

Manual resiliency assessments tend to be:

- Inconsistent across teams and engagements
- Slow to repeat as code evolves
- Infrastructure-first rather than code-aware
- Disconnected from engineering backlogs

This framework addresses those gaps with standardized, AI-assisted workflows that produce a traceable evidence chain from research to a prioritized P0-P3 remediation plan, reviewed by a qualified engineer before delivery.


## Quick start

1. Install the [HVE Essentials VS Code extension](https://marketplace.visualstudio.com/items?itemName=ise-hve.hve-essentials) so the `Task Researcher` and `Task Planner` agents are available in Copilot Chat.
2. Open this repository (or the target codebase being assessed) in VS Code with GitHub Copilot Chat enabled.
3. In Chat, run `/hve-resiliency-research`.
4. Choose an execution mode when prompted:
    - **Mode A (Interactive).** One prompt per turn, `/clear` between prompts.
    - **Mode B (Autonomous).** Each prompt runs as an isolated subagent.
5. **Switch the active agent in Copilot Chat to match each phase**: select `Task Researcher` for Phases 1-3 (research and consolidation), and `Task Planner` for Phases 4-5 (planning and assessment). Each prompt's frontmatter declares the agent it expects; mismatched agents will produce off-spec output.
6. Follow the phase sequence: Core Research → Service Research → Consolidation → Planning → Assessment.

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
| [docs/](docs/) | Workflow overview and reference documentation. |
| [Microsoft-Assessment/](Microsoft-Assessment/) | Worked example assessment output. |

## Workflow phases

| Phase | Prompts | Notes |
|-------|---------|-------|
| 1. Core Research | `researcher-0` … `researcher-7-logging` | Sequential. Mode-aware. |
| 2. Service Research | `researcher/service/*` (8-19, filtered to applicable services) | Mode B allows up to 3 concurrent subagents. |
| 3. Consolidation | `researcher-consolidate` | User-gated. |
| 4. Planning | `planner-0`, `planner-1`, `planner-0`, `planner-2` | User-gated, `/clear` between steps. |
| 5. Assessment | `assessment-builder-0` … `assessment-builder-3` | User-gated, `/clear` between steps. |

A worked example output lives at [Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md](Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md). For per-phase descriptions and the workflow evolution diagrams, see [docs/resiliency-researcher-workflow.md](docs/resiliency-researcher-workflow.md).

## Token consumption estimates

Approximate token usage for a full end-to-end workflow run, sized by the *target* codebase being assessed (after exclusions like `node_modules`, `bin`, `obj`, and generated code). Phase 2 cost scales with the number of in-scope Azure services, not raw lines of code.

| Sizing dimension | Small | Medium | Large | Very Large |
|------------------|-------|--------|-------|------------|
| Example | Single microservice | 5-service platform | 15-20 service platform | Enterprise monorepo |
| In-scope files | <100 | 100-500 | 500-2,000 | 2,000+ |
| In-scope lines of code | <5K | 5K-30K | 30K-150K | 150K+ |
| In-scope Azure services | 1-3 | 4-7 | 7-10 | 10-12 |
| Total prompts run | ~21 | ~24 | ~27 | ~30 |
| Phase 1 input/prompt | 8K-15K | 20K-35K | 60K-120K | 150K-300K |
| Phase 2 input/prompt (per service) | 8K-15K | 12K-25K | 20K-40K | 30K-60K |
| Phase 3 consolidation input | 40K-70K | 70K-120K | 120K-200K | 180K-300K |
| Phase 4-5 input/prompt | 25K-50K | 35K-70K | 50K-90K | 70K-120K |
| Output tokens/prompt (typical) | 4K-15K | 5K-25K | 6K-30K | 8K-35K |
| **Total tokens, Mode A (`/clear`-gated)** | **~550K-950K** | **~1.0M-1.7M** | **~1.9M-3.2M** | **~3.1M-5.4M** |
| **Total tokens, Mode B (autonomous)** | **~700K-1.3M** | **~1.4M-2.4M** | **~2.7M-4.5M** | **~4.4M-7.5M** |

Mode B totals are 30-50% higher because the orchestrating agent retains conversation context across phases, even though each prompt runs as an isolated subagent. Estimates are per-prompt averages; individual prompts can spike 2-3x on unusually large source files or repos with deep tool-call iteration.

## Alignment with Microsoft frameworks

| Microsoft framework | How this framework aligns |
|---------------------|---------------------------|
| [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/) | Reliability pillar: availability, resiliency, and recovery. Phase 5 assessment maps every P0-P3 finding to WAF reliability patterns (see [`assessment-builder-3`](.github/prompts/assessment-builder/hve-resiliency-assessment-builder-3.prompt.md)). |
| [Azure Proactive Resiliency Library (APRL)](https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/) | Design-time and detection-time resiliency guidance for Azure services, used as a reference for per-service findings in Phase 2. |
| [Cloud Adoption Framework (CAF)](https://learn.microsoft.com/azure/cloud-adoption-framework/) | Application readiness for cloud scale and reliability, supporting the transition to active/active multi-region operation. |
| GitHub Copilot and HVE | Agent-based, standardized assessment and evidence generation via the Task Researcher and Task Planner agents from [microsoft/hve-core](https://github.com/microsoft/hve-core). |

## HVE at Microsoft

HVE (Hypervelocity Engineering) is a Microsoft engineering practice and toolset. Related Microsoft resources:

- [microsoft/hve-core](https://github.com/microsoft/hve-core): Shared instructions, skills, agents, and conventions used across HVE repositories.
- [HVE Essentials VS Code extension](https://marketplace.visualstudio.com/items?itemName=ise-hve.hve-essentials): Bundles `hve-core` prompts, instructions, and skills into VS Code.
- [Microsoft Industry Solutions Engineering (ISE)](https://www.microsoft.com/en-us/industry/microsoft-industry-solutions-engineering): The Microsoft engineering org behind HVE.
- [Azure Well-Architected Framework Reliability pillar](https://learn.microsoft.com/azure/well-architected/reliability/): Foundational reliability guidance referenced by the resiliency prompts.
- [Azure reliability documentation](https://learn.microsoft.com/azure/reliability/): Per-service availability zone and regional failover reference content.

## Contributing

Prompts, instructions, agents, and skills in this repository follow the conventions in [microsoft/hve-core](https://github.com/microsoft/hve-core). When editing files under `.github/prompts/`, `.github/instructions/`, or `.github/skills/`, follow the prompt-builder and markdown instructions inherited from `hve-core`.
