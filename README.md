# HVE Resiliency

## Table of Contents

* [Overview](#overview)
* [Setup](#setup)
* [Assessment process](#assessment-process)
* [Documentation](#documentation)
* [Customization and extensibility](#customization-and-extensibility)
* [Workflow phases](#workflow-phases)
* [Repository layout](#repository-layout)
* [Token consumption estimates](#token-consumption-estimates)
* [Alignment with Microsoft frameworks](#alignment-with-microsoft-frameworks)
* [HVE at Microsoft](#hve-at-microsoft)
* [Contributing](#contributing)

---

## Overview

HVE Resiliency is an **AI-assisted analysis framework** that evaluates application source code and infrastructure (IaC) to identify resiliency gaps and generate a **prioritized assessment report and remediation plan (P0–P3)**.

It is designed for engineering teams building or operating systems in Azure, especially those targeting **high availability and multi-region resiliency**.

The framework includes one workflow skill and two orchestrator agents:

- **Complete Workflow:**
  - `hve-resiliency-research` defines the complete workflow.
- **Orchestration:**
  - **Resiliency Research Orchestrator v1.0** runs Phases 1-3.
  - **Resiliency Planning Orchestrator v1.0** runs Phases 4-5.

[View a sample assessment](Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md).



---

## Setup
1. Install the [HVE Core VS Code extension](https://marketplace.visualstudio.com/items?itemName=ise-hve-essentials.hve-core) so the shared `Researcher Subagent` worker (used by the orchestrator agents) and the HVE agents are available in Copilot Chat.
2. Install this framework into the **root** of the codebase you want to assess. From your target repo's root:

   ```powershell
   # PowerShell (Windows / macOS / Linux)
   irm https://raw.githubusercontent.com/christopherromero/HVE-Resiliency/feature/orchestration/install.ps1 | iex
   ```

   The installer copies `.github/skills/`, `.github/prompts/`, `.github/agents/`,  and `.github/instructions/` into your `.github/` folder. Reload VS Code (**Developer: Reload Window**) so Copilot Chat re-indexes the new files, then commit the `.github/` additions so the rest of your team gets the same workflow.
3. Reload VS Code so the new agents appear in the picker: **Developer: Reload Window**.

---

## Assessment Process


1. Review the Confluence document and discovery recording to understand the overall application architecture.
2. Create a branch from `master` using the naming convention `fb-RegionalResiliency-MMDDYY`.
3. Confirm the application topology with the architect: Active-Passive (Standby) or Active-Active.
4. If Kafka applies, confirm its topology with the architect: Active-Active or Active-Passive (Standby). Provide the agreed topology when the research orchestrator requests it. Do not infer Kafka topology from the database architecture.
5. Run the following initial repository prompt to establish the workload considerations that must be verified in the final report:

    ```text
    Analyze this repository and provide:

    * Workload type (API, backend job, event-driven service, and so on)
    * Application flow and key components and dependencies
    * Solution and architecture structure
    * Key changes required to deploy the workload from single-region to
       multi-region, covering application state, database, Kafka or messaging,
       cache, external dependencies, networking, and configuration

    Provide only a concise checklist of potential multi-region changes for
    later verification. Do not make any code changes.
    ```

6. Confirm that the latest version of this prompt repository is installed in the application repository.
7. [Run the **Resiliency Research Orchestrator v1.0**](#run-it-with-the-orchestrators-recommended) for Phases 1-3. Monitor its stage results for incomplete or blocked prompts, verification failures, abnormal errors, or network issues. Report unusual behavior to the architect and record the duration of each major stage.
8. Review the consolidated research artifact, then run the **Resiliency Planning Orchestrator v1.0** for Phases 4-5.
9. Review the generated report for duplicate findings. Optionally invoke `/detect-assessment-duplicates` manually. Remove only confirmed duplicates while preserving finding IDs and cross-references.
10. Validate code references, ordering dependencies, file paths, and line numbers. Correct any mismatches.
11. Verify that the final report matches the application and Kafka topologies confirmed by the architect. Keep the application description concise and accessible to a non-specialist audience.
12. Perform a final sanity check and compare report coverage with the workload considerations identified by the initial repository prompt.
13. Submit the report for SME review.




### Run it with the orchestrators (Recommended)

The recommended path uses two **orchestrator agents**. The research orchestrator runs Phases 1-3, and the planning orchestrator runs Phases 4-5. Each agent dispatches individual prompts to fresh subagents, sequences dependencies, and parallelizes independent work. Select the agent in the picker, then send a plain message rather than a slash command.

**Research (Phases 1-3):**

1. In Copilot Chat, open the **agent picker** at the top of the chat panel and select **Resiliency Research Orchestrator v1.0**.
2. Send exactly:

   ```text
   Run the resiliency research pipeline for this repository.
   Target deployment topology: <ACTIVE-ACTIVE or ACTIVE-STANDBY>.
   ```

   It runs discovery, analysis, verification, and consolidation, then writes the results to `.copilot-tracking/research/`. It pauses only when input or intervention is required.

**Planning (Phases 4-5):**

1. Switch the **agent picker** to **Resiliency Planning Orchestrator v1.0** (start a new chat when switching agents).
2. Send exactly:

   ```text
   Run the resiliency planning pipeline from the consolidated research.
   Target deployment topology: <ACTIVE-ACTIVE or ACTIVE-STANDBY>.
   ```

   It consumes the completed consolidated research and produces the executive Master report, Developer Guide, and final **Code-Level Resiliency Assessment** under `Microsoft-Assessment/`. Planning and assessment prompts run sequentially because each output depends on the preceding artifact.

Replace `Active-Active` with `Active-Standby` when that is the agreed target deployment topology.

### Manual alternative (one prompt at a time)

Prefer to drive each step yourself? Run `/hve-resiliency-research` in Chat and follow the numbered prompt sequence in the skill. A context reset between prompts is optional - see below.

> [!NOTE] `/clear` is optional for manual prompts and unnecessary with the orchestrator agents.

See [.github/skills/hve-resiliency-research/SKILL.md](.github/skills/hve-resiliency-research/SKILL.md) for the authoritative workflow definition.

---

## Documentation

Start here before running the framework end-to-end. These two guides are the primary references for everything in this repo:

| Guide                                                                             | Read this when you want to                                                                                                                                                 |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **[Resiliency Researcher Workflow](docs/resiliency-researcher-workflow.md)** | Understand the five-phase research-to-assessment workflow, per-phase prompt sequence, mode selection (interactive vs autonomous), and the workflow evolution diagrams.     |

The authoritative workflow definition is [.github/skills/hve-resiliency-research/SKILL.md](.github/skills/hve-resiliency-research/SKILL.md).

---

## Customization and extensibility

The [platform context](.github/instructions/hve-resiliency-platform-context.instructions.md), [planner context](.github/instructions/hve-resiliency-planner-context.instructions.md), and prompts can be customized for your architecture and use case.

---

## Workflow phases

| Phase | Prompts | Orchestration |
| ----- | ------- | ------------- |
| 1. Core Research | `researcher-0`, `-1a`, and `-1b`; then `-2` through `-6` | Discovery is sequential. Independent analyses run concurrently after scope is frozen. Prompt 5 runs its scaffold, parallel fills, verify, and finalize sub-pipeline. |
| 2. Service Research | Applicable prompts `researcher/service/9` through `17` | Runs concurrently with the Phase 1 analysis fan-out, filtered to dependencies confirmed by Prompts 1a and 1b. |
| 3. Consolidation | `consolidate-0-scaffold` through `consolidate-9-finalize` | Scaffold first, section fills in parallel, verification in parallel, then final assembly. |
| 4. Planning | `planner-0`, `planner-1`, `planner-0`, `planner-2` | Runs sequentially in fresh subagent contexts. |
| 5. Assessment | `planner-3a` through `planner-3d` | Runs sequentially because each prompt appends to the same report. |

A worked example output lives at [Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md](Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md). Per-phase descriptions, workflow evolution diagrams, and the post-Phase-5 backlog import flow are covered in the guides linked from [Documentation](#documentation).

The standalone `detect-assessment-duplicates` and `reorder-assessment-findings` prompts run only when invoked manually. They are not part of planning orchestration.

## Repository layout

| Path | Purpose |
| ---- | ------- |
| [.github/agents/](.github/agents/) | Research and planning orchestrators |
| [.github/prompts/](.github/prompts/) | Research, consolidation, planning, assessment, and audit prompts |
| [.github/skills/hve-resiliency-research/](.github/skills/hve-resiliency-research/) | Manual workflow definition |
| [.github/instructions/](.github/instructions/) | Platform context and evidence rules |
| [docs/](docs/) and [Microsoft-Assessment/](Microsoft-Assessment/) | Guides and example outputs |
| [install.ps1](install.ps1) and [install.sh](install.sh) | Framework installers |

## Token consumption estimates

(COMING SOON)

## Alignment with Microsoft frameworks

| Microsoft framework                                                                                        | How this framework aligns                                                                                                                                                                                                                             |
| ---------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)                     | Reliability pillar: availability, resiliency, and recovery. Phase 5 assessment maps every P0-P3 finding to WAF reliability patterns (see [`planner-3d`](.github/prompts/planner/hve-resiliency-planner-3d.prompt.md)). |
| [Azure Proactive Resiliency Library (APRL)](https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/) | Design-time and detection-time resiliency guidance for Azure services, used as a reference for per-service findings in Phase 2.                                                                                                                       |
| [Cloud Adoption Framework (CAF)](https://learn.microsoft.com/azure/cloud-adoption-framework/)               | Application readiness for cloud scale and reliability, supporting the transition to active/active multi-region operation.                                                                                                                             |

## HVE at Microsoft

HVE (Hypervelocity Engineering) is a Microsoft engineering practice and toolset. Related Microsoft resources:

- [microsoft/hve-core](https://github.com/microsoft/hve-core): Shared instructions, skills, agents, and conventions used across HVE repositories.
- [HVE Essentials VS Code extension](https://marketplace.visualstudio.com/items?itemName=ise-hve.hve-essentials): Bundles `hve-core` prompts, instructions, and skills into VS Code.
- [Microsoft Industry Solutions Engineering (ISE)](https://www.microsoft.com/en-us/industry/microsoft-industry-solutions-engineering): The Microsoft engineering org behind HVE.
- [Azure Well-Architected Framework Reliability pillar](https://learn.microsoft.com/azure/well-architected/reliability/): Foundational reliability guidance referenced by the resiliency prompts.
- [Azure reliability documentation](https://learn.microsoft.com/azure/reliability/): Per-service availability zone and regional failover reference content.

## Contributing

Prompts, instructions, agents, and skills in this repository follow the conventions in [microsoft/hve-core](https://github.com/microsoft/hve-core). When editing files under `.github/prompts/`, `.github/instructions/`, or `.github/skills/`, follow the prompt-builder and markdown instructions inherited from `hve-core`.
