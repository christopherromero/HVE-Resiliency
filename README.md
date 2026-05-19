# HVE Resiliency

## Table of Contents

* [Overview](#overview)
* [What this skill solves](#what-this-skill-solves)
* [When to use this skill](#when-to-use-this-skill)
* [What this skill does NOT do](#what-this-skill-does-not-do)
* [Customization and extensibility](#customization-and-extensibility)
* [Finding prioritization (P0–P3)](#finding-prioritization-p0p3)
* [What you get as output](#what-you-get-as-output)
* [Quick start](#quick-start)
* [Workflow phases](#workflow-phases)
* [Repository layout](#repository-layout)
* [Token consumption estimates](#token-consption-estimates)
* [Alignment with Microsoft frameworks](#alignment-with-microsoft-frameworks)
* [HVE at Microsoft](#hve-at-microsoft)
* [Contributing](#contributing)

---

## Overview

HVE Resiliency is an **AI-assisted analysis framework** that evaluates application source code and infrastructure (IaC) to identify resiliency gaps and generate a **prioritized remediation plan (P0–P3)**.

Unlike traditional architecture reviews, this framework:

- Works directly on **source code and infrastructure definitions**
- Produces **evidence-based findings with file and line references**
- Translates findings into **actionable, backlog-ready remediation plans**
- Focuses on **real failure scenarios** (zone failure and regional failover)

It is designed for engineering teams building or operating systems in Azure, especially those targeting **high availability and multi-region resiliency**.

---

## What this skill solves

Manual resiliency assessments are often:

- Inconsistent across teams and engagements
- Time-consuming to repeat as code evolves
- Focused on infrastructure, ignoring code-level risks
- Difficult to translate into actionable backlog work

This skill standardizes and automates resiliency analysis across repositories.

### Expected impact

Using this framework, teams can:

- ✅ Reduce assessment time (hours instead of days)
- ✅ Increase consistency across projects
- ✅ Identify **code-level failure paths** not visible in architecture diagrams
- ✅ Maintain full traceability from finding → code → remediation
- ✅ Generate **prioritized, backlog-ready actions**

---

## When to use this skill

Use this skill when:

- Preparing a system for **production readiness**
- Validating resiliency before a **major release**
- Migrating to **multi-region or active/active architectures**
- Converting resiliency risks into **engineering backlog items**
- Performing **code-level resiliency analysis**

### Typical use cases

- Pre go-live validation
- Architecture and resiliency reviews
- Cloud migration readiness
- Continuous resiliency checks
- Engineering quality improvements

---

## What this skill does NOT do

This skill is intended for **design-time and code-level analysis**.

It does **not**:

- Execute or simulate failover scenarios
- Perform chaos engineering or load testing
- Automatically fix issues in the codebase
- Analyze runtime telemetry or production behavior
- Replace engineering review or decision-making

A qualified engineer must validate all findings before implementation.

---

## Customization and extensibility

This skill is **designed to be adapted** to different projects, architectures, and customer requirements.

The default behavior is driven by a predefined **platform and engagement context**, including:

- Resiliency definition and classification rules
- Priority model (P0–P3)
- Failover assumptions (e.g., active/active, GLB-driven routing)
- Architectural constraints and system topology
- Reporting structure and output expectations

👉 You can review the default context here:  
[View planner context instructions](https://github.com/christopherromero/HVE-Resiliency/edit/main/.github/instructions/hve-resiliency-planner-context.instructions.md)

---

### Why customization matters

Different teams and projects may have:

- Different target architectures (e.g., active/passive vs active/active)
- Different failover mechanisms (e.g., no GLB, custom routing)
- Different platform constraints (e.g., hybrid, non-Azure environments)
- Different engagement models (e.g., code ownership, implementation support)
- Different definitions of resiliency and acceptable risk

Without customization, findings may be:
- Misaligned with system goals
- Incorrectly prioritized
- Overly prescriptive or not actionable

---

### What can be customized

Teams can adapt the skill by modifying the instructions under: .github/instructions/

Key areas that can be customized:

#### 1. Engagement context
Define the scenario being analyzed:

- Current vs target architecture
- Failover model (active/passive, active/active, blue/green, etc.)
- Scope (single service, platform, multi-repo)
- Constraints (e.g., no write access, customer-owned code)

#### 2. Resiliency definition
Adjust what qualifies as a resiliency finding:

- Failure scenarios (zone, region, dependency, network)
- Critical system behaviors
- Acceptable vs unacceptable degradation

#### 3. Priority model (P0–P3)
Modify priority criteria to match business impact:

- What is considered "blocking"
- Acceptable workarounds
- Business-critical vs non-critical flows

#### 4. Architectural assumptions
Override default system assumptions:

- Load balancing strategy
- Dependency deployment model (single-region vs multi-region)
- Configuration patterns (region-aware vs abstracted endpoints)

#### 5. Output expectations
Customize how results are delivered:

- Report structure
- Level of technical depth
- Alignment with internal standards or frameworks
- Backlog formatting (ADO, GitHub Issues, etc.)

---

### How to customize

1. Copy or modify the relevant instruction files: .github/instructions/hve-resiliency-planner-context.instructions.md
.github/instructions/hve-resiliency-platform-context.instructions.md

2. Update the context to match your project:

- Replace architecture assumptions
- Adjust resiliency definition
- Update constraints and scope
- Modify prioritization rules if needed

3. Re-run the workflow: /hve-resiliency-research
The agents will automatically pick up the updated context and apply it to all findings and recommendations.

---

### Example customization scenarios

| Scenario | Customization focus |
|----------|-------------------|
| Active/passive deployment | Change failover assumptions and P0 criteria |
| Hybrid or on-prem systems | Adjust platform context and dependencies |
| Regulated environments | Tighten priority rules and reporting requirements |
| Platform teams vs product teams | Modify output format and level of detail |
| Early-stage systems | Relax strict resiliency thresholds |

---

### Key principle

> This framework is **context-driven, not static**.

The quality and relevance of findings depend heavily on how well the context reflects:

- The system architecture
- The failure scenarios that matter
- The business goals of the project

Teams are encouraged to **treat the instruction files as part of the product**, evolving them as the system and requirements change.

---

## Finding prioritization (P0–P3)

Findings are classified based on their potential impact:

| Priority | Description |
|----------|------------|
| **P0 (Critical)** | Risk of full system failure or data loss |
| **P1 (High)** | Significant service degradation or partial outage |
| **P2 (Medium)** | Resiliency gaps affecting recovery or stability |
| **P3 (Low)** | Improvements or optimizations |

This prioritization enables teams to focus on **failover-blocking risks first**.

---

## What you get as output

After running the workflow, you will obtain:

- 📄 Evidence-based research artifacts (file + line references)
- 📊 Consolidated resiliency findings
- 🧩 Prioritized remediation plan (P0–P3)
- 📘 Developer guidance for issue resolution
- ✅ Backlog-ready resiliency assessment aligned with Microsoft frameworks

Example:  
[View sample assessment](Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md)

---

## Quick start

1. Install the [HVE Core VS Code extension](https://marketplace.visualstudio.com/items?itemName=ise-hve-essentials.hve-core) so the `Task Researcher` and `Task Planner` agents are available in Copilot Chat.
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

## Workflow phases

The framework follows an application-centric, evidence-first flow built on HVE Core's `Task Researcher` and `Task Planner` agents:

1. **Source code and IaC** in the target repository serve as primary evidence.
2. **Task Researcher** runs Phase 1-2 prompts to produce per-area research artifacts (architecture, dependencies, failure paths, per-service findings), citing file and line for every claim.
3. **Phase 3 consolidation** merges those artifacts into a single evidence document, deduplicating findings and normalizing terminology.
4. **Task Planner** reads the consolidated document under evidence-lock-in rules and produces a prioritized P0-P3 plan plus a code-level resiliency assessment.
5. **Outputs** include forensic research artifacts, a Master plan and Developer Guide, and a backlog-ready assessment report with Microsoft Standards Alignment.


| Phase | Prompts | Notes |
|-------|---------|-------|
| 1. Core Research | `researcher-0` … `researcher-7-logging` | Sequential. Mode-aware. |
| 2. Service Research | `researcher/service/*` (8-19, filtered to applicable services) | Mode B allows up to 3 concurrent subagents. |
| 3. Consolidation | `researcher-consolidate` | User-gated. |
| 4. Planning | `planner-0`, `planner-1`, `planner-0`, `planner-2` | User-gated, `/clear` between steps. |
| 5. Assessment | `assessment-builder-0` … `assessment-builder-3` | User-gated, `/clear` between steps. |

A worked example output lives at [Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md](Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md). For per-phase descriptions and the workflow evolution diagrams, see [docs/resiliency-researcher-workflow.md](docs/resiliency-researcher-workflow.md).

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

## HVE at Microsoft

HVE (Hypervelocity Engineering) is a Microsoft engineering practice and toolset. Related Microsoft resources:

- [microsoft/hve-core](https://github.com/microsoft/hve-core): Shared instructions, skills, agents, and conventions used across HVE repositories.
- [HVE Essentials VS Code extension](https://marketplace.visualstudio.com/items?itemName=ise-hve.hve-essentials): Bundles `hve-core` prompts, instructions, and skills into VS Code.
- [Microsoft Industry Solutions Engineering (ISE)](https://www.microsoft.com/en-us/industry/microsoft-industry-solutions-engineering): The Microsoft engineering org behind HVE.
- [Azure Well-Architected Framework Reliability pillar](https://learn.microsoft.com/azure/well-architected/reliability/): Foundational reliability guidance referenced by the resiliency prompts.
- [Azure reliability documentation](https://learn.microsoft.com/azure/reliability/): Per-service availability zone and regional failover reference content.

## Contributing

Prompts, instructions, agents, and skills in this repository follow the conventions in [microsoft/hve-core](https://github.com/microsoft/hve-core). When editing files under `.github/prompts/`, `.github/instructions/`, or `.github/skills/`, follow the prompt-builder and markdown instructions inherited from `hve-core`.
