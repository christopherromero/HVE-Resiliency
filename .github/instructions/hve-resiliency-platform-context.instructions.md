---
description: Application Platform context and evidence-only rules for resiliency research prompts
applyTo: '.github/prompts/researcher/hve-resiliency-researcher-*.prompt.md, .github/prompts/researcher/service/hve-resiliency-researcher-*.prompt.md'
---

# Application Platform Context

Apply this context to all Application Platform resiliency research prompts.

* {customerName} operates applications in Azure
* Validating readiness for zone failure within West US 2
* Validating readiness for full regional failover between West US and West US 2 as part of the target active/active deployment
* Scope is the current repository within the Application Platform
* HVE Task Researcher rules: evidence only, no remediation, no code examples
* All findings must cite file and line-level evidence
* Classify every finding using the priority framework: P0 (Blocking/Critical), P1 (High Priority), P2 (Improvement/Best Practice), P3 (Non-Blocking Code Consistency)
* Output research artifacts to `.copilot-tracking/research/` and use the repository name as the prefix for all output files (e.g., `<repo-name>-research-output.md`).

## Evidence Accuracy

This is the highest-priority rule for all research output. A finding that violates any bullet below is invalid and must be removed or corrected before the artifact is delivered. All file paths and code or configuration excerpts cited in research output must be verifiable in the repository at the time of research. Do not paraphrase, summarize, or fabricate.

* Every file path cited must exist in the repository. Verify the path before including it in a finding.
* Every line number cited must match the current file contents. Cite the exact line or line range where the referenced content appears.
* Any code, configuration, string literal, or identifier reproduced in the output must be verbatim (character-for-character, including case, quoting, and whitespace) from the cited file. No paraphrasing, no reformatting, no pseudocode.
* If the exact contents cannot be reproduced verbatim, do not include a snippet. Cite `<file>:<line>` only.
* Do not describe code behavior in a way that implies contents not present in the file. Every claim about a file must be traceable to a specific line or line range in that file.

## Priority Definitions

* P0: Critical / Blocking. Causes outage, data loss, duplicate charges, or inability to fail over safely during zone or regional failure.
* P1: Required, Non-Blocking. Does not fully block failover but materially increases application risk, data risk, or customer impact during failure.
* P2: Improvement / Best Practice. Does not materially impact correctness during failover but weakens resilience posture or operational clarity.
* P3: Non-Blocking Code Consistency. Captures maintainability, readability, duplication, or inconsistent pattern issues that are non-blocking.

## Service Exclusion Rule

* After Prompts 1a and 1b complete, dependencies classified in Section 2 (Checked But Not Present) and Section 3 (Not Applicable) are excluded from analysis in Prompts 2-7 and service-specific prompts (8-19)
* Prompts 2-7 and service-specific prompts (8-19) analyze only dependencies confirmed as used in Section 1 of the Prompt 1a and 1b outputs

## Excluded Evidence Sources

Local developer override files are not production configuration and MUST NOT be treated as evidence. Do not cite them in findings, dependency inventories, region/zone assumptions, or any research output.

* Excluded filename patterns (case-insensitive), including all files matching:
  * `*-local.yml`, `*-local.yaml`
  * `*-local.json`
  * `*-local.properties`
  * `*-local.conf`
  * Common examples: `application-local.yml`, `application-local.yaml`, `application-local.properties`, `bootstrap-local.yml`, `appsettings-local.json`
* Scope: any file matching the patterns above in any directory of the repository (e.g., `src/main/resources/`, `config/`, module subdirectories).
* If a value only appears in an excluded file, treat it as **not present** in the repository. Do not infer, quote, or paraphrase its contents.
* If a production-shaped configuration file (e.g., `application.yml`, `application-prod.yml`, `appsettings.json`) has a `*-local.*` sibling, analyze only the production-shaped file. The presence of the local override does not itself constitute a finding.
* This exclusion applies to all research prompts (0, 1a, 1b, 2-7, and service-specific 8-19) and to the consolidation prompt.

## Next Step Suggestions

After completing each research prompt output, end the response with a next-step suggestion the user can click. Format as:

> **Next step:** Run `/clear`, then `/command-name`

Follow this sequence:

| Current Prompt                      | Next Step                                                                                                               |
|-------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `/hve-resiliency-researcher-0`            | `/hve-resiliency-researcher-1a`                                                                                               |
| `/hve-resiliency-researcher-1a`           | `/hve-resiliency-researcher-1b` (review Section 1 results first)                                                              |
| `/hve-resiliency-researcher-1b`           | `/hve-resiliency-researcher-2` (review Section 1 results from 1a and 1b; Sections 2-3 are excluded from here on)              |
| `/hve-resiliency-researcher-2`            | `/hve-resiliency-researcher-3`                                                                                                |
| `/hve-resiliency-researcher-3`            | `/hve-resiliency-researcher-4`                                                                                                |
| `/hve-resiliency-researcher-4`            | `/hve-resiliency-researcher-5`                                                                                                |
| `/hve-resiliency-researcher-5`            | `/hve-resiliency-researcher-6`                                                                                                |
| `/hve-resiliency-researcher-6`            | `/hve-resiliency-researcher-7-logging`                                                                                        |
| `/hve-resiliency-researcher-7-logging`    | First applicable service-specific prompt from Phase 2, or `/hve-resiliency-researcher-consolidate` if none apply              |
| Service-specific prompts (8-19)     | Next applicable service prompt for a Prompt 1 Section 1 dependency, or `/hve-resiliency-researcher-consolidate` when complete  |
| `/hve-resiliency-researcher-consolidate`  | `/hve-resiliency-planner-0`                                                                                                   |
