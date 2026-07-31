---
description: Run Prompt 3 dependency survivability analysis for Application resiliency research
agent: Task Researcher
---

# Application HVE Researcher 3

Use [Application Platform Context](../../instructions/hve-resiliency-platform-context.instructions.md).

## Execution Precedence

This direct Prompt 3 contract overrides conflicting inherited Task Researcher, skill, and platform workflow behavior. Retain inherited artifact location, repository-prefix naming, file-line evidence, and P0-P3 definitions where they do not conflict with this contract.

Run only Prompt 3 evidence collection. Do not restart at Prompt 0 or run later research, planning, remediation, or implementation phases. Do not provide recommendations, alternatives, selected approaches, code examples, implementation guidance, or actionable next steps. Delegation is optional and bounded by this contract; a delegated action consumes the same counters as a parent action and cannot start another workflow.

## Eligibility Gate

Use only dependencies confirmed as used in Section 1 of the inherited Prompt 1a and Prompt 1b outputs. Do not infer, reconstruct, or substitute the prerequisite inventory from repository contents.

If a required prerequisite is missing, ambiguous, unusable, or contains no dependency eligible for Prompt 3, emit the report-level outcome `Blocked: missing prerequisite or ineligible` with the reason and qualifying artifact paths, then stop before repository or production discovery.

## Assessment Scope

Analyze each eligible Azure and non-Azure dependency used by this repository for survivability during both scenarios:

* Zone failure within West US 2
* Full regional failover from West US 2 to West US

Determine from code or configuration whether endpoints, credentials, or identities assume a single region and whether fallback or multi-region logic exists. For each Azure dependency, verify whether the application implements a dependency health check and reflects that health state in readiness or health endpoints that drive GLB routing decisions.

Do not add assessment areas beyond dependency survivability, regional assumptions, fallback or multi-region behavior, existing mitigations, constraints, and Azure dependency health-to-GLB linkage.

## Discovery Limits

Default to repository-only discovery. Initialize the prompt round counter and every per-dependency counter once. Counters are cumulative and never reset by round, source, dependency criterion, alias, environment, or delegation.

The entire prompt has at most two rounds:

1. Round 1 performs initial bounded discovery for all eligible dependencies and both failure modes.
2. Round 2 uses remaining counters only to close unresolved criteria identified in Round 1.

After Round 2, stop all discovery. Record each criterion still unresolved for that reason with exactly `Unknown: two-round prompt budget exhausted` in the report-level Unknown summary.

Each dependency has one cumulative discovery budget shared across parent and delegated work and across repository and approved production sources:

* Two searches
* Three smallest-relevant-range reads
* Two traversal hops
* One focused follow-up

A search is one tool invocation containing one search expression. A read is one opening of the smallest relevant file range; rereading counts again. A hop follows one evidenced reference from the current source to a directly related owner, caller, callee, configuration include, or runtime source. A focused follow-up is one targeted action for one unresolved criterion and also consumes its underlying search, read, or hop counter. Glob expansion and result pagination do not grant additional actions.

Before delegation, pass the dependency's remaining counters and current round. Merge consumed actions into the same ledger when delegation returns. Stop work on a dependency when a required action counter is exhausted; do not substitute another action type to bypass a limit.

## Production Discovery Contract

Production discovery is prohibited by default. Permit it only when the invocation supplies all of the following:

* Named production source
* Explicit approval to access that source
* Read-only access method
* Query limit
* Result limit
* Time window
* Follow-up limit

Supplied limits can narrow but cannot expand the prompt-wide or per-dependency budgets. Every production query, read, hop, or follow-up consumes the same `2/3/2/1` dependency counters used for repository discovery.

If production discovery is requested and approval is denied or any contract element is missing, make no production call. Emit `Blocked: production discovery contract denied or incomplete` with the missing or denied elements, then stop. Repository evidence never implies production approval.

## Evidence And Finding Controls

* Support every positive or negative finding claim with causal repository or approved production evidence. Repository citations include file path and line number. Production citations identify the approved source, bounded query or record reference, and time window without exposing secrets.
* Absence of evidence is not evidence of absence. When bounded sources are exhausted, place each unresolved existing criterion in the report-level Unknown summary and do not fabricate a citation or finding.
* Emit a finding row only for an evidenced dependency and failure-mode pair. Use distinct rows for distinct pairs; never merge West US 2 zone failure and West US 2-to-West US regional failover into one row.
* Keep report status, Unknown summaries, checked-without-finding dependencies, source limitations, counters, and blocked or non-finding states outside repeated finding rows. Never create a synthetic finding row for an Unknown or terminal state.
* Record required usage information only in the existing usage field. In the existing material-impact field, record Yes or No, one P0-P3 classification, and the evidence-backed impact rationale exactly once. Do not duplicate impact prose elsewhere in the row.
* Use only evidenced values in finding rows. For optional mitigation or constraint details not established within the budget, state that no value was evidenced within bounded discovery without claiming that none exists, and list the unresolved criterion in the report-level Unknown summary.
* Record missing health-to-GLB linkage as a finding only when evidence establishes the missing linkage. Otherwise, keep the criterion as a report-level Unknown.

## Repeated Finding Schema

For each finding include these fields exactly once and in this order. Do not add, remove, rename, or reorder fields:

* Evidence (file path + line number)
* Brief description of how it is used
* Whether it materially impacts zone or region failover (Yes/No + description of why this could impact zone or region failover)
* Existing mitigations present (if any): retries/timeouts/fallbacks/multi-region selection/failover logic, with evidence (file path + line number)
* Constraints/limitations (if any): dependency/platform capabilities or configuration/operational constraints that shape failover behavior, with evidence (file path + line number) when present
* For each Azure service dependency, explicitly verify whether the application implements a health check for that dependency and whether the resulting health state is reflected in the service's readiness/health endpoints that drive GLB routing decisions (cite file + line evidence). If no health-to-GLB linkage exists, record that as a finding with evidence.

## Report-Level Outcomes

Use exactly one outcome from this closed set. Apply the first matching outcome in precedence order and stop immediately when it becomes terminal:

1. `Blocked: missing prerequisite or ineligible`: The eligibility gate fails. Perform no discovery.
2. `Blocked: production discovery contract denied or incomplete`: Production discovery was requested but its contract is denied or incomplete. Perform no production call.
3. `Partial: exhausted with Unknowns`: Any eligible existing criterion remains unresolved after source, action, or two-round exhaustion. Stop and list each Unknown with dependency, failure mode, criterion, source scope, and exhaustion reason.
4. `Complete: bounded no evidence`: Every eligible criterion is resolved, no finding qualifies, and all checked-without-finding dependencies are listed. This outcome does not assert that unsearched evidence or runtime behavior is absent.
5. `Complete: findings`: Every eligible criterion is resolved and at least one evidenced finding row qualifies.

Before any finding rows, report the selected outcome, assessed scenarios, source limitations, per-dependency `search/read/hop/follow-up` counters, round count, Unknown summary or `None`, and checked-without-finding dependencies or `None`. For blocked outcomes, emit only this report-level envelope and no finding rows.

Return only the inherited research artifact path, selected outcome, and limitations. Add no workflow continuation or next-step suggestion.

---

Execute this Prompt 3 contract to its first terminal report-level outcome.