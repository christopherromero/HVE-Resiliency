<!-- markdownlint-disable-file -->
# Task Research: pir.md Section 9 "The HVE Issue-Finding Process" Verification

Verify whether the claims in `docs/Assessment Prioritization/pir.md` Section 9 (lines 181-228) accurately describe the HVE framework (`microsoft/hve-core`, installed as `ise-hve-essentials.hve-core-3.2.2`).

## Task Implementation Requests

* Verify each substantive claim in pir.md Section 9 against the actual HVE framework files installed in the VS Code extension.
* Report any claims that are wrong, misleading, or unsupported, with file + line evidence.

## Scope and Success Criteria

* Scope: Section 9 only ("The HVE Issue-Finding Process"). Sections 1-8, 10, 11 are out of scope.
* Assumptions:
  * The "HVE framework" cited in pir.md is the `microsoft/hve-core` repo shipped via the `ise-hve-essentials.hve-core` VS Code extension (current installed version: 3.2.2).
  * Verification is against files inside that extension directory.
* Success Criteria:
  * Each Section 9 claim is mapped to a citation (file + line range or template section).
  * Discrepancies, if any, are itemized.

## Outline

* Section 9 makes claims about: (a) RPI workflow naming, (b) phase-state-in-files discipline, (c) Task Researcher mechanics, (d) Task Planner mechanics, (e) Plan Validator DR-/DD- structure and severity gating, (f) the HVE Research Document template, (g) the source files list.
* Each is verifiable directly from extension files.

## Research Executed

### File Analysis

* `c:\Users\chromer\.vscode\extensions\ise-hve-essentials.hve-core-3.2.2\readme.md` (lines 1-10)
  * "HVE Core RPI (Research, Plan, Implement, Review) workflow" - confirms the 4-letter expansion cited in pir.md.
  * "flagship RPI ... workflow for completing complex tasks through a structured four-phase process."
  * Note: the same readme later describes the rpi-agent as "Research -> Plan -> Implement -> Review -> Discover phases" (5 phases). The RPI acronym still covers only the first four; pir.md's citation is consistent with the readme's headline.

* `c:\Users\chromer\.vscode\extensions\ise-hve-essentials.hve-core-3.2.2\.github\agents\hve-core\task-researcher.agent.md`
  * Lines 23-32 (Core Principles): "Create and edit files only within `.copilot-tracking/research/`." - confirms pir.md "writes solely to `.copilot-tracking/research/`".
  * Lines 38-42: "This agent delegates all research to `Researcher Subagent` ... parallelize calls when topics are independent" - confirms pir.md "delegates all investigation to parallel `Researcher Subagent` instances".
  * Lines 75-76 (Success Criteria): "Document verified findings from actual tool usage" appears verbatim in Core Principles - confirms pir.md's quoted phrase "verified findings from actual tool usage".
  * Lines 88-96 (Required Phases / Phase 1 Research): three steps - Prepare Primary Research Document, Iterate Running Parallel Researcher Subagents, Consolidate Research Findings - matches pir.md "Research" phase description.
  * Lines 120-128 (Phase 2: Analysis and Completion): Identify and Evaluate Alternatives, Select Approach and Complete Document - matches pir.md "Analysis and Completion" description and the "Technical Scenario Analysis" with retained rejected alternatives.
  * Lines 152-178+ (Research Document Template): starts with `<!-- markdownlint-disable-file -->`, then sections - Task Implementation Requests, Scope and Success Criteria, Outline, Potential Next Research, Research Executed (File Analysis with workspace paths and line numbers, Code Search Results, External Research, Project Conventions), Key Discoveries (with sub-sections including Complete Examples and API and Schema Documentation), Technical Scenarios. All template element names cited in pir.md match.

* `c:\Users\chromer\.vscode\extensions\ise-hve-essentials.hve-core-3.2.2\.github\agents\hve-core\task-planner.agent.md`
  * Lines 22-31 (Core Principles): scope is `.copilot-tracking/plans/`, `.copilot-tracking/plans/logs/`, `.copilot-tracking/details/`, `.copilot-tracking/research/` - confirms pir.md "three outputs: a plan, a details file, and a Planning Log."
  * Lines 90-95 (Success Criteria): explicit list of plan file, details file, planning log file, and "Plan validation passing with no critical or major findings in the Planning Log" - confirms both the three-output claim and the severity gate.
  * Lines 122-126 (Required Phases): Phase 1 Context Assessment, Phase 2 Planning, Phase 3 Plan Validation, Phase 4 Completion - exact match to pir.md "four phases - Context Assessment, Planning, Plan Validation, and Completion."
  * Phase 3 Step 2: "Proceed to Phase 4 when validation passes with no critical or major findings remaining. Minor findings may be noted in the plan without blocking completion." - confirms pir.md "plan cannot complete while Critical or Major findings remain unresolved."

* `c:\Users\chromer\.vscode\extensions\ise-hve-essentials.hve-core-3.2.2\.github\agents\hve-core\subagents\plan-validator.agent.md`
  * Frontmatter description: "Validates implementation plans against research documents, updating the Planning Log Discrepancy Log section with severity-graded findings".
  * Planning Log section: "DR- prefixed entries identifying research items with no corresponding plan coverage" (Source, Reason, Impact fields) and "DD- prefixed entries identifying contradictions or divergences" (Research recommends, Plan implements, Rationale fields) - exact match to pir.md's DR- / DD- description and field names.
  * Required Steps Step 1.4: Critical / Major / Minor severity definitions - exact match to pir.md's "Critical / Major / Minor" grading.
  * Required Protocol Step 1: "All validation relies on reading and analysis only. Do not modify the implementation plan, implementation details, or research document." - confirms pir.md "read-only `Plan Validator` subagent".

* `c:\Users\chromer\.vscode\extensions\ise-hve-essentials.hve-core-3.2.2\.github\agents\hve-core\subagents\researcher-subagent.agent.md`
  * Confirms the existence of `Researcher Subagent` cited in the source files list at the end of pir.md Section 9.

* `c:\Users\chromer\.vscode\extensions\ise-hve-essentials.hve-core-3.2.2\.github\prompts\hve-core\rpi.prompt.md`
  * Confirms existence of `prompts/hve-core/rpi.prompt.md` cited at the end of pir.md Section 9.
  * Frontmatter: "Autonomous Research-Plan-Implement-Review-Discover workflow" - shows the full 5-phase form with Discover; pir.md's 4-letter "Research, Plan, Implement, Review" citation is from the readme, not this prompt. Both are accurate to their respective sources.

* `c:\Users\chromer\.vscode\extensions\ise-hve-essentials.hve-core-3.2.2\.github\prompts\hve-core\task-research.prompt.md` and `task-plan.prompt.md`
  * Both files exist in `prompts/hve-core/`, confirming the third source file path triplet at the end of pir.md Section 9.

### Code Search Results

* `RPI|Research, Plan|Plan, Implement|Implement, Review` across the extension - the only match for the headline four-word form is `readme.md` line 3 ("HVE Core RPI (Research, Plan, Implement, Review) workflow"). The rpi.prompt.md uses the five-element hyphenated form. This validates that pir.md's specific attribution to `readme.md` is correct.

### Project Conventions

* Verification followed evidence-only research discipline per `task-researcher.agent.md` Core Principles.

## Key Discoveries

### Per-Claim Verification Matrix

| Claim in pir.md Section 9 | Verdict | Source |
| --- | --- | --- |
| RPI = Research, Plan, Implement, Review (cited to `readme.md`) | True | `readme.md` line 3 |
| Each phase is a dedicated agent | True | readme.md "Included Artifacts > Chat Agents" (Task Researcher, Task Planner, Task Implementor, Task Reviewer) |
| State passes between phases through `.copilot-tracking/` files | True | task-researcher.agent.md (writes to `.copilot-tracking/research/`); task-planner.agent.md (writes to `.copilot-tracking/plans/`, `details/`, etc.) |
| Phases separated by `/clear` context reset | True | Researcher mode response template: "Clear your context by typing `/clear`." appears in the task-researcher agent's Ready for Planning handoff text |
| Task Researcher writes solely to `.copilot-tracking/research/` | True | task-researcher.agent.md Core Principles |
| Delegates investigation to parallel `Researcher Subagent` instances | True | task-researcher.agent.md "Subagent Delegation" and "parallelize calls when topics are independent" |
| Two internal phases: Research, Analysis and Completion | True | task-researcher.agent.md "Required Phases" - Phase 1 Research, Phase 2 Analysis and Completion |
| "verified findings from actual tool usage" (quoted) | True | task-researcher.agent.md Core Principles (verbatim) |
| Findings accumulate in an Evidence Log (`Research Executed` section) | True | task-researcher.agent.md Research Document Template has a `## Research Executed` section with File Analysis, Code Search Results, External Research, Project Conventions |
| Task Planner produces three outputs: plan, details file, Planning Log | True | task-planner.agent.md Success Criteria |
| Task Planner runs four phases: Context Assessment, Planning, Plan Validation, Completion | True | task-planner.agent.md "Required Phases" section headings |
| Plan Validator is read-only | True | plan-validator.agent.md Required Protocol Step 1 |
| DR- = missing coverage with Source/Reason/Impact fields | True | plan-validator.agent.md Planning Log section |
| DD- = divergence with "Research recommends / Plan implements / Rationale" fields | True | plan-validator.agent.md Planning Log section |
| Critical / Major / Minor severity grading | True | plan-validator.agent.md Step 1.4 |
| Plan cannot complete with Critical or Major findings unresolved | True | task-planner.agent.md Success Criteria and Phase 3 Step 2 |
| Research Document template content (Task Implementation Requests, Scope and Success Criteria, Outline, Potential Next Research, Research Executed [File Analysis with line numbers, Code Search Results, External Research with sources, Project Conventions], Key Discoveries, Technical Scenarios) | True | task-researcher.agent.md "Research Document Template" |
| Template starts with `markdownlint-disable-file` header | True | task-researcher.agent.md template (line containing `<!-- markdownlint-disable-file -->`) |
| Source file list at end of Section 9 (`task-researcher.agent.md`, `task-planner.agent.md`, `subagents/researcher-subagent.agent.md`, `subagents/plan-validator.agent.md`, `prompts/hve-core/{task-research,task-plan,rpi}.prompt.md`) all exist under `ise-hve-essentials.hve-core` | True | All seven paths confirmed by directory listing |

### Minor Nuances (not errors)

* **RPI vs RPID.** The `rpi.prompt.md` frontmatter actually describes a five-phase form ("Research-Plan-Implement-Review-Discover"). The readme.md headline still uses the four-letter "Research, Plan, Implement, Review" expansion, and the rpi-agent description in readme.md mentions Discover as an added phase. pir.md cites the readme's four-letter form and explicitly notes the engagement only used the first two phases, so the framing is consistent with the cited source. Not an error; a reader who only sees rpi.prompt.md might wonder where "Discover" went.

* **"Implement"/"Review" not used in this engagement.** Section 9 says "This assessment used the first two phases: Research ... and Plan." This is a statement about the OSPG engagement, not the HVE framework, and is consistent with the rest of pir.md which never references Task Implementor or Task Reviewer outputs.

## Technical Scenarios

### Section 9 Accuracy Assessment

Every substantive HVE-framework claim in Section 9 is supported by at least one file in `ise-hve-essentials.hve-core-3.2.2`. No errors were found. The source file list at the end of Section 9 lists seven paths, all of which exist.

**Preferred Approach:** Leave Section 9 as written. The text is accurate and the citations resolve. Optionally consider adding one parenthetical noting the rpi.prompt.md's five-element form to pre-empt confusion, but this is editorial polish, not a correctness fix.

#### Considered Alternatives

* Rewrite Section 9 to use the five-element "Research-Plan-Implement-Review-Discover" form. Rejected: pir.md explicitly cites the readme.md, and the readme's headline uses the four-element form; switching would create a citation mismatch.

## Potential Next Research

* Verify the `[HVE]` / `[OSPG]` / `[Hybrid]` provenance tags applied in Sections 1-8 of pir.md against the same source files. Reasoning: Section 9 is internally consistent, but the overall provenance argument depends on those tags being accurate across the whole document.
  * Reference: `docs/Assessment Prioritization/pir.md` Sections 2-8 and Section 10.

---

## Addendum: Rewriting Section 9 to Answer "How Does HVE Identify Findings?"

The user clarified the intent of Section 9: it should explain the *decision process* HVE follows when discovering, recording, and validating findings, not the inventory of agents and files. Below is the verified decision flow extracted from the same source files, followed by a proposed rewrite.

### What HVE Actually Decides (Verified Decision Flow)

HVE makes no resiliency decisions. Its decisions are workflow-shaped: *what to ask, where to look, when to stop, what to keep, what counts as covered.* OSPG provided the resiliency content that flowed through this generic decision pipeline.

**A. Task Researcher (orchestrator) decisions** - from `task-researcher.agent.md` lines 88-128:

1. **Question extraction.** "Extract research questions from the user request and conversation context." (line 92). The first move is always to convert the task into explicit questions, not to start searching.
2. **Source identification.** "Identify sources to investigate (codebase, external docs, repositories)." (line 93).
3. **Parallel dispatch.** "Parallelize calls when topics are independent" (line 42). The decision is per-topic independence, not per-tool.
4. **Gap check after each return.** "Assess whether research questions are sufficiently answered and identify remaining gaps. Repeat Step 2 if significant gaps remain." (lines 115-116). The loop continues until no gap is significant.
5. **Phase transition.** "Proceed to Phase 2 when research questions are sufficiently answered and alternatives can be evaluated." (line 117).
6. **Alternative evaluation.** "Identify viable implementation approaches with benefits, trade-offs, and complexity. Apply the Technical Scenario Analysis structure for each alternative evaluated." (lines 123-124).
7. **Selection.** "Select one approach using evidence-based criteria and record rationale." (line 130). Single-answer outcome.
8. **Pruning.** "Remove superseded content and keep the document organized around the selected approach while retaining evaluated alternatives." (line 132). Decisive over comprehensive.

**B. Researcher Subagent (worker) decisions** - from `researcher-subagent.agent.md` lines 28-46:

1. **Topic intake.** "Add the research topics and/or questions to the subagent research document." (line 31). The subagent is bound to the questions handed in; it does not redefine scope.
2. **Tool selection.** "Use search tools and read tools for local investigation. Use fetch web page, github repo, and mcp tools for external investigation when the scope requires it." (lines 35-36). Local first, external only when needed.
3. **Follow-on filter.** "Add follow-on questions only when they are directly relevant to the original research scope." (line 37).
4. **Stop condition.** "Stop researching when the original questions are answered: All provided topics and questions have answers or evidence in the subagent research document." (lines 39-41).
5. **Scope discipline.** "Do not pursue tangential threads beyond the original scope." (line 43). The single explicit refusal in the protocol.
6. **Escalation.** "Record any clarifying questions that cannot be answered through research." (line 42). Questions surface as a deliverable; they are not silently dropped.

**C. Plan Validator decisions (the "issue-finding" gate)** - from `plan-validator.agent.md`:

1. **Coverage matrix.** "Build a coverage matrix internally, mapping each research requirement to at least one plan step with status indicators (Covered, Partial, Missing)." (Step 1.1). Every research item is judged against the plan in three states.
2. **Missing-coverage rule.** Any research item with no corresponding plan step becomes a **DR-** entry with Source / Reason / Impact (Step 1.2 plus Planning Log section).
3. **Divergence rule.** Any plan step that contradicts a research recommendation becomes a **DD-** entry with Research recommends / Plan implements / Rationale (Step 2.1).
4. **Severity assignment.** "Critical: Missing core requirement that blocks implementation success. Major: Partial coverage where a requirement is acknowledged but incompletely planned. Minor: Nice-to-have or secondary item not addressed." (Step 1.4).
5. **Speculation filter.** "Identify unplanned items in the plan that lack research backing. Assess whether each is justified (a derived objective logically following from research) or speculative (no clear connection)." (Step 2.4). Plans cannot invent findings; this is the mechanical enforcement of the OSPG-hardened "do not add findings" freeze.
6. **Resolution gate.** "Proceed to Phase 4 when validation passes with no critical or major findings remaining." (task-planner.agent.md Phase 3 Step 2). Minor findings are tolerated; Critical and Major are blocking.

### What HVE Looks For First

The repeated, observable answer in the framework files is **questions, then sources, then evidence, then gaps**:

* The Task Researcher's first step is question extraction, not searching (`task-researcher.agent.md` line 92).
* The Researcher Subagent's intake is the question list, and its stop condition is "questions answered" (`researcher-subagent.agent.md` lines 31, 39-41).
* Every claim is required to be a "verified finding from actual tool usage" with file + line citation (`task-researcher.agent.md` Core Principles line 26; mandatory examples in Research Document Template).
* The Plan Validator looks first for *research items not covered* (DR-) before looking for *plan items that diverge* (DD-) — coverage before contradiction (`plan-validator.agent.md` Steps 1 and 2 ordering).

### Recurring Decision Pattern (the "engine")

Every loop in the framework follows the same four-step pattern:

1. **Pose** an explicit question (research question, coverage question, divergence question).
2. **Bound** the search by scope (topic, file set, original question list).
3. **Answer with evidence** (file + line, quoted research item, plan step reference).
4. **Re-check for gaps** and loop until no significant gap remains.

This pattern is the actual "issue-finding engine." It is content-agnostic, which is why OSPG could plug resiliency criteria into it without changing the framework.

### Proposed Rewrite of Section 9

The rewrite below keeps the same length budget as the current Section 9 but answers the user's three questions: *how* HVE identifies findings, *what* decisions it makes, *what* it looks for first. The agent inventory and file paths are demoted to a closing reference paragraph so the body of the section can lead with the decision flow.

````markdown
## 9. The HVE Issue-Finding Process

The sections above cover the OSPG-authored *classification* rules. This section describes the generic **[HVE]** decision process those rules plug into. HVE makes no resiliency decisions; it decides *what to ask, where to look, when to stop, what to keep, and what counts as covered.* OSPG supplied the questions and the criteria; HVE made the disciplined decisions that produced evidence-backed findings.

### What HVE Looks For First: Questions, Not Answers

Every HVE run begins by converting the task into an explicit question list. The Task Researcher's first step is "Extract research questions from the user request and conversation context" - not to search, not to scan code, but to enumerate what must be answered. Every subsequent decision in the workflow is judged against that list. The OSPG researcher prompts (core 0-7, service 8-19) are exactly that question list, pre-authored for the resiliency engagement.

### The Recurring Four-Step Decision Loop

Every HVE loop - orchestrator iteration, subagent investigation, plan validation - follows the same pattern:

1. **Pose** an explicit question.
2. **Bound** the search to the relevant scope (topic, file set, prior question list).
3. **Answer with evidence**: every substantive claim cites a file path and line range, sourced from actual tool usage.
4. **Re-check for gaps** and repeat until no significant gap remains.

This pattern is content-agnostic. OSPG plugged resiliency questions into step 1 and tightened the evidence requirement in step 3 to a hard per-finding gate; the loop itself is HVE.

### Orchestrator Decisions (Task Researcher)

The Task Researcher makes six decisions per iteration:

| Decision | Trigger | Outcome |
| --- | --- | --- |
| Extract research questions | New task or conversation context | Question list pinned in the primary research document |
| Identify sources | Question list | Codebase, external docs, or repos chosen per question |
| Parallelize | Topic independence | Independent topics fan out to parallel `Researcher Subagent` instances |
| Gap check | Subagent return | Either spawn more subagents or advance to alternatives |
| Evaluate alternatives | All questions answered | Each viable approach scored on benefits, trade-offs, complexity |
| Select and prune | Alternatives evaluated | One approach kept with rationale; rejected alternatives retained with reasons; superseded content removed |

The output is *decisive*, not *comprehensive*: one selected approach plus the rejected alternatives that justify the choice.

### Worker Decisions (Researcher Subagent)

The Researcher Subagent answers a bounded slice of the question list. Its decision rules are deliberately narrow:

- **Bound the scope.** The subagent is handed a topic list and does not redefine it.
- **Local before external.** Use codebase search and file reads first; reach for web fetch, GitHub, or MCP tools only "when the scope requires it."
- **Follow-on filter.** New questions are recorded only when "directly relevant to the original research scope."
- **Stop on evidence.** Stop when "all provided topics and questions have answers or evidence in the subagent research document."
- **Refuse drift.** "Do not pursue tangential threads beyond the original scope" is the single explicit prohibition in the protocol.
- **Escalate, do not invent.** Questions that cannot be answered through research are returned as clarifying questions, not guessed at.

This is what produces evidence-only findings: the subagent cannot speculate within scope and cannot widen scope to escape the evidence requirement.

### Validation Decisions (Plan Validator)

The Plan Validator is the gate that turns the research artifact into a locked input for planning. It makes three classes of decisions:

1. **Coverage first.** For every research item, mark it Covered, Partial, or Missing against the plan. Missing items become **DR-** entries (Source, Reason, Impact). This is checked *before* divergences.
2. **Divergence second.** For every plan step, check whether it contradicts a research recommendation. Contradictions become **DD-** entries (Research recommends, Plan implements, Rationale).
3. **Speculation filter.** For every plan item without research backing, decide whether it is a justified derived objective or a speculative addition. Speculative items are flagged; the plan cannot introduce findings the research did not surface. This is the mechanical enforcement of the OSPG-hardened "do not add findings" freeze.

Each finding is severity-graded **Critical / Major / Minor**. The plan cannot advance to completion while Critical or Major findings remain unresolved; Minor findings are noted but non-blocking. This is the loop that, in the OSPG pipeline, became planner-0's hardened freeze re-applied before each planner output.

### The Evidence Floor

Three rules combine to make the framework evidence-based rather than opinion-based, and they are visible in every loop above:

- "Document verified findings from actual tool usage rather than speculation."
- Every claim cites a workspace-relative file path with a line range, accumulated in the `Research Executed` section of the primary research document.
- Plans are validated against research, not against narrative; coverage is judged step-by-step against research items.

OSPG tightened the citation rule to a per-finding gate but did not need to invent it - the discipline was already the floor.

### Where OSPG Plugged Into HVE Decisions

| HVE decision | What OSPG supplied |
| --- | --- |
| Initial question list | The `ospg-hve-researcher-*` prompts (core 0-7, service 8-19) |
| Source identification | Service Exclusion Rule: analyze only confirmed Section-1 dependencies |
| Evidence rule | Tightened to mandatory file + line on every finding |
| Gap check criteria | Findings must carry a Resiliency Impact statement or fail the litmus test |
| Selection step | Each finding receives a provisional P0-P3 and Resiliency Yes/No |
| Consolidation | De-dup by Finding ID; final P0-P3 priorities applied |
| Plan validator gate | Planner-0 hardened freeze re-applied before each planner output |

**Source files (HVE framework):** `task-researcher.agent.md`, `task-planner.agent.md`, `subagents/researcher-subagent.agent.md`, `subagents/plan-validator.agent.md`, and `prompts/hve-core/{task-research,task-plan,rpi}.prompt.md` (all under `ise-hve-essentials.hve-core`).

[Back to Top](#top)
````

### Open Questions Before Applying the Rewrite

* The current Section 9 names the four-letter "RPI workflow - Research, Plan, Implement, Review" cited to the readme. The rewrite drops that framing in favor of decision flow. If the explicit RPI naming is load-bearing for the broader pir.md narrative (Sections 8 and 10), it should be kept as a one-sentence opener.
* The rewrite uses three tables. If pir.md is page-budgeted, two of them (Orchestrator Decisions, OSPG Plug-Ins) can be collapsed into prose without losing the answer.
* The Plan Validator description could be split into its own subsection if you want to mirror the existing "Phase 1 / Phase 2" subheading style. The proposed rewrite collapses it into a single decision-flow narrative because the user's question was about the *process*, not the *agent inventory*.

---

## Second Addendum: Plain-English Mechanism (the user's actual question)

The previous addendum was still abstract because it talked about "agents" and "decisions" as if they were a custom runtime. They are not. The user's question - *how does HVE identify findings?* - has a concrete, mechanical answer that fits in three sentences:

1. HVE is a folder of markdown files that ship with a VS Code extension. The microsoft/hve-core repo itself calls this out: "Hypervelocity Engineering **prompt library** for GitHub Copilot with convention-driven AI workflows and validated artifacts" (https://github.com/microsoft/hve-core).
2. When the user picks an "agent" in GitHub Copilot Chat, the contents of that agent's `.agent.md` markdown file become the system prompt for an LLM (Claude or GPT, whatever Copilot is using). The LLM has access to the standard Copilot tools: codebase search, file read, web fetch, the ability to start a subagent, and file write into specific allow-listed folders.
3. "Finding identification" is whatever the LLM produces when its system prompt is `task-researcher.agent.md` (or, in OSPG's case, that file plus the OSPG researcher prompts that get pulled in as additional instructions). There is no custom engine; the markdown is the engine.

### Verified Anatomy of an HVE "Agent"

`task-researcher.agent.md` (the file I read earlier) is a 200+ line markdown document. Its frontmatter declares `name: Task Researcher` and `description: Task research specialist for comprehensive project analysis`. That frontmatter is what shows up in the Copilot Chat agent picker. The body of the file - everything below the frontmatter - is the literal text that gets fed to the LLM as instructions when the user selects that agent. The "Core Principles," "Required Phases," "Research Document Template," and "Response Format" sections are not framework code; they are prose instructions to the model, and the model obeys them to the extent prompts ever get obeyed.

The same applies to:

* `task-planner.agent.md` - 250+ lines of markdown that becomes the system prompt when the user picks "Task Planner"
* `researcher-subagent.agent.md` - 67 lines that become the system prompt for a child LLM call started by `runSubagent` or `task` tool
* `plan-validator.agent.md` - the system prompt for the validator child call
* `prompts/hve-core/task-research.prompt.md` - a 4-requirement wrapper that, when invoked via `/task-research`, switches the chat to the Task Researcher agent

### How a "Finding" Actually Gets Made

For the OSPG engagement, every finding in the assessment was produced by this concrete sequence:

1. The user typed `/task-research` (or selected the Task Researcher agent) plus an OSPG researcher prompt name. Copilot loaded `task-researcher.agent.md` as the system prompt and added the OSPG prompt as the task description.
2. The LLM read those combined instructions. The HVE part told it: extract questions, identify sources, parallelize independent topics, delegate to subagents, every claim needs file + line, write the output to `.copilot-tracking/research/`. The OSPG part told it: the questions for this run are the resiliency questions in this prompt, tag each finding with a provisional P0-P3 and Resiliency Yes/No, do not author remediation.
3. The LLM called the `runSubagent` tool. That call started a new LLM call with `researcher-subagent.agent.md` as its system prompt and one of the OSPG questions as the task. The child LLM ran `grep_search`, `read_file`, `fetch_webpage`, etc., wrote to a subagent document, and returned a summary.
4. The parent LLM read the subagent document, folded findings into the primary research file, and either spawned more subagents or moved on.
5. The user typed `/clear`, then `/task-plan`. Copilot loaded `task-planner.agent.md` plus an OSPG planner prompt. The planner LLM read the locked research document, drafted plan + details + log, then called `runSubagent` again with `plan-validator.agent.md` to flag DR-/DD- gaps.
6. The same loop repeated for each OSPG planner prompt (0, 1, 2, 3) to produce the four deliverables.

Every step in this chain is just "an LLM reads a markdown file and writes a markdown file using the tools the platform provides." The discipline (evidence, scope, severity) comes entirely from the text inside those markdown files.

### The OSPG Plug-In, Stated Mechanically

OSPG didn't write code. OSPG wrote more markdown files in this repository's `.github/prompts/` and `.github/instructions/` folders. When the user invoked an OSPG prompt, Copilot loaded the same HVE agent file plus the OSPG prompt file plus any matching `.instructions.md` files (matched by `applyTo` glob). The combined text became the model's system prompt for that turn. That is the entire mechanism of "plugging into HVE."

### Citations Supporting the Plain-English Account

* `c:\Users\chromer\.vscode\extensions\ise-hve-essentials.hve-core-3.2.2\readme.md` line 1: "HVE Core RPI (Research, Plan, Implement, Review) workflow with Git commit, merge, setup, and pull request prompts."
* https://github.com/microsoft/hve-core (About section): "A refined collection of Hypervelocity Engineering components (instructions, prompts, agents, and skills)" and the repo description: "Hypervelocity Engineering prompt library for GitHub Copilot."
* Agent files have YAML frontmatter (`name:`, `description:`, `disable-model-invocation:`, `agents:`, `handoffs:`) that the host platform parses, but the body is plain markdown read as instructions. Confirmed by direct inspection of `task-researcher.agent.md`, `task-planner.agent.md`, `researcher-subagent.agent.md`, `plan-validator.agent.md`.
* The `disable-model-invocation: true` field in `task-researcher.agent.md` and `task-planner.agent.md` frontmatter exists precisely because these are agent definitions for Copilot to load on user selection, not autonomous services - the field tells Copilot not to auto-invoke the model from this file.

### Revised Section 9 (Plain-English Rewrite)

````markdown
## 9. The HVE Issue-Finding Process

The sections above cover the OSPG-authored classification rules. This section explains, in mechanical terms, how those rules actually got applied. HVE is not a custom engine. It is a folder of markdown files - the `microsoft/hve-core` repo, packaged as a VS Code extension - that GitHub Copilot loads as instructions for a general-purpose large language model. The repo's own description is "Hypervelocity Engineering prompt library for GitHub Copilot with convention-driven AI workflows and validated artifacts." Every finding in the assessment was produced by an LLM reading one of those markdown files and following its instructions.

### What "An HVE Agent" Actually Is

When the user selects "Task Researcher" in Copilot Chat, Copilot loads the file `task-researcher.agent.md` from the extension and uses its 200+ lines of markdown as the system prompt for that conversation. The frontmatter (`name`, `description`) tells Copilot how to display the agent in the picker; the body is the literal text the model is told to follow. Same for Task Planner (`task-planner.agent.md`), the Researcher Subagent (`researcher-subagent.agent.md`, started as a child LLM call by the `runSubagent` tool), and the Plan Validator (`plan-validator.agent.md`, the validation child call).

There is no compiled code, no runtime, no enforcement mechanism beyond what the LLM does when it reads the prompt. The "agents" are prompts.

### How a Finding Gets Made, Step by Step

For each OSPG researcher prompt in this engagement, one HVE pass looked like this:

1. **The user invokes a prompt.** Typing `/task-research` plus an OSPG researcher prompt name causes Copilot to load `task-researcher.agent.md` as the system prompt and the OSPG researcher prompt as the task description.
2. **The HVE markdown sets the rules.** That system prompt tells the LLM: extract explicit research questions, identify sources to search, parallelize independent topics by calling the `runSubagent` tool, accept only findings with file + line evidence, write the document to `.copilot-tracking/research/`, produce a Technical Scenario Analysis with one selected approach.
3. **The OSPG markdown sets the questions.** The OSPG researcher prompt supplies the actual resiliency questions for this run (single-region dependencies, GLB health probes, hard-coded region values, etc.), tightens the evidence rule to mandatory per finding, and tags each finding with a provisional P0-P3 and Resiliency Yes/No.
4. **The LLM calls tools.** The model runs codebase search, reads files, fetches web pages, and starts child LLM calls (subagents) by invoking the `runSubagent` tool. Each subagent receives `researcher-subagent.agent.md` as its system prompt and one OSPG question as its task. The child returns a summary; the parent folds it into the primary research document.
5. **The user resets context.** `/clear` discards the chat history. `/task-plan` plus an OSPG planner prompt loads `task-planner.agent.md` and the planner-0 prompt. The planner LLM reads the locked research document and produces plan, details, and Planning Log files.
6. **A validator child call grounds the plan.** The planner invokes the `runSubagent` tool with `plan-validator.agent.md` as the system prompt for a read-only child LLM call. That call compares the plan to the research, lists missing coverage as `DR-` entries and contradictions as `DD-` entries, and grades each Critical / Major / Minor. The parent plan cannot complete while Critical or Major entries remain.
7. **Repeat for each planner output.** The same loop runs again for planner-1, planner-2, planner-3 to produce the master report, the Developer Guide, and the final assessment.

Every step is just "an LLM reads a markdown file and writes a markdown file using the tools the IDE provides." The rigor comes from the *text inside the markdown files*, not from any code.

### What HVE's Markdown Looks for First

Reading `task-researcher.agent.md` plainly: the first instruction in the Required Phases section is "Extract research questions from the user request and conversation context." Not "search the codebase," not "look for X pattern." The first move is converting the task into an explicit question list. Every later instruction in the file - source identification, subagent dispatch, gap checking, alternative evaluation - is framed against that question list. The Researcher Subagent's prompt repeats the discipline: take the questions handed in, answer them with evidence, stop when answered, do not pursue tangential threads.

This is why the OSPG researcher prompts work the way they do. Each one is, literally, a pre-authored question list (resiliency questions for the core platform, then per-service questions for confirmed dependencies). HVE's contribution is the instructions for how the LLM should answer a question list rigorously; OSPG's contribution is the question list itself.

### The OSPG Plug-In, Stated Mechanically

OSPG did not write code. OSPG wrote more markdown files in this repository's `.github/prompts/` and `.github/instructions/` folders. When the user invoked an OSPG prompt, Copilot loaded the HVE agent file *plus* the OSPG prompt file *plus* any matching `.instructions.md` files (matched by an `applyTo` glob in the instruction file's frontmatter). All of that text became the model's system prompt for that turn. That is the entire mechanism by which OSPG "plugged into HVE."

The Plan Validator's `DR-`/`DD-` discipline became the OSPG planner-0 hardened freeze the same way: the OSPG planner-0 prompt added text on top of HVE's planner instructions saying "do not challenge, reinterpret, or add findings," and re-applied that text before each subsequent planner output.

### Where the Discipline Comes From (Concrete Mapping)

| Discipline visible in the assessment | The markdown text that produced it |
| --- | --- |
| File + line citation on every finding | `task-researcher.agent.md` Core Principles ("Document verified findings from actual tool usage rather than speculation") plus OSPG researcher prompts tightening this to mandatory per finding |
| Stop at scope, no tangents | `researcher-subagent.agent.md` Required Protocol ("Do not pursue tangential threads beyond the original scope") |
| Plan cannot add new findings | `plan-validator.agent.md` Step 2.4 (justified vs speculative) plus OSPG planner-0 freeze |
| Critical / Major blocks plan completion | `task-planner.agent.md` Phase 3 Step 2 ("Proceed to Phase 4 when validation passes with no critical or major findings remaining") |
| Selection over enumeration | `task-researcher.agent.md` Phase 2 Step 2 ("Select one approach using evidence-based criteria") |
| Resiliency questions, P0-P3 tagging | OSPG-authored `ospg-hve-researcher-*.prompt.md` files in this repo |

**Source files (HVE framework, all under `ise-hve-essentials.hve-core` and `microsoft/hve-core` on GitHub):** `agents/hve-core/task-researcher.agent.md`, `agents/hve-core/task-planner.agent.md`, `agents/hve-core/subagents/researcher-subagent.agent.md`, `agents/hve-core/subagents/plan-validator.agent.md`, `prompts/hve-core/{task-research,task-plan,rpi}.prompt.md`. The repo's own self-description ("prompt library for GitHub Copilot") is the most concise statement of what HVE is.

[Back to Top](#top)
````

### Why This Version Answers the User's Question

* It names the actual mechanism (markdown files loaded as LLM system prompts) instead of saying "agents make decisions."
* It walks through the literal sequence: user invokes a prompt → Copilot loads markdown → LLM reads it → LLM calls tools → LLM writes files.
* It explains "what HVE looks for first" by quoting the first instruction in the actual file rather than restating it abstractly.
* It defines the OSPG plug-in in the same mechanical vocabulary (more markdown files added to the system prompt).
* It cites the microsoft/hve-core repo's own self-description, which removes any ambiguity about whether HVE is "an engine."
