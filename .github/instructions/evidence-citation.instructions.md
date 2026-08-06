---
description: "Required citation rules for any multi-phase workflow that quotes source artifacts across context boundaries"
applyTo: '**/*.prompt.md, **/*.agent.md, **/*.instructions.md, **/SKILL.md'
---

# Evidence Citation Instructions

Any workflow that reads source artifacts in one phase and quotes them in a later phase must separate observation from generation. These rules apply to prompts, agents, instructions, and skills that produce reports, assessments, reviews, audits, or plans containing quoted material.

## Workflow Compliance Contract

Any prompt, agent, or skill matched by this instruction file MUST behave as follows when producing quoted material from source artifacts. This contract is machine-enforceable; the verifier script exists so compliance is not left to model discretion.

1. **Pin the observed state before the first read.** Record the SHA under the ledger's `source.commit` field:

   ```powershell
   git rev-parse HEAD
   ```

2. **Capture at the moment of reading.** Append an evidence entry to `.copilot-tracking/research/<scope>-evidence.json` matching `.github/skills/evidence-ledger/schema/evidence-ledger.schema.json`. Store exact bytes; `endLine` MUST equal `startLine + (snippet line count - 1)`. Use `kind: "absent"` (no line range) for null-result findings.

3. **Transclude by ID when producing output.** Every quoted code block MUST be preceded immediately by an HTML comment marker of the form:

   ```markdown
   <!-- evidence: EV-014 -->
   ```

   If no ledger entry exists for a finding, the finding MUST NOT carry a quoted code block. Author prose describing the observation, or omit the finding. Reconstructing quoted material from memory or from prose descriptions in prior artifacts is prohibited.

4. **Run the deterministic verifier at every phase gate.** Non-zero exit MUST block phase completion:

   ```powershell
   ./.github/skills/evidence-ledger/scripts/Test-EvidenceLedger.ps1 `
       -LedgerPath .copilot-tracking/research/<scope>-evidence.json `
       -ReportPath <path-to-emitted-report>.md
   ```

   On mismatch, flag the finding as unverified and stop. Do not instruct any agent to "correct the quote to match the file." Sources commonly contain near-identical constructs, and fix-forward silently snaps the citation to the wrong occurrence.

5. **Halt on missing entries.** If a downstream phase cannot resolve an evidence ID, the ledger has failed, not the artifact. Report the missing ID and stop. Do not synthesize a replacement.

## The Failure This Prevents

Multi-phase workflows isolate context between phases, either through explicit context clearing or through isolated subagent dispatch. Context isolation is what lets a workflow scale past a single window, and it is also an amnesia event: whatever the earlier phase saw is gone unless it was written to a file.

When a later phase is asked to show "the current code" and the artifact it inherits carries only a file path, a line number, and a prose description, reconstruction from memory is the only instruction-compliant path available. The result reads as a quotation, cites a real file, reuses real identifiers, and does not exist in the repository.

## Core Rules

* **Observation and generation are separate operations.** A phase that generates content must not also be the phase that establishes what the source says.
* **Capture once, at the point of observation.** The phase that opens an artifact records what it saw, verbatim, into an evidence ledger.
* **Reference, never re-author.** Downstream phases transclude ledger entries by ID. They must not write, reformat, re-indent, abbreviate, elide, or "clean up" quoted material.
* **Pin the observed state.** Every ledger records the commit SHA, content hash, or retrieval timestamp the observation was made against.
* **Absence is evidence with a different shape.** A claim that something is missing must record the search performed and its null result. It must never carry a line range.
* **Verification is deterministic and external.** A script compares the ledger to the artifacts. Models must not be asked to self-certify citation accuracy.
* **Redact at capture.** Secret detection runs when the snippet is recorded, so every downstream artifact inherits the redaction.

## Rules for Phases That Read Artifacts

Record an evidence entry at the moment of reading. Do not defer capture to a summarization step.

* Store the exact bytes of the cited range, not a paraphrase and not a description.
* The cited line range must equal the span of the stored snippet. A range wider than the snippet is unfalsifiable.
* Do not describe evidence in prose as a substitute for capturing it. Prose descriptions do not survive a context boundary.
* When the claim is that an artifact, symbol, setting, or dependency is absent, record the search command or query and its null result under an `absent` entry.
* When the evidence lives outside the workspace, record it as `external` with the owning repository or team, or as `remote` with the URL and retrieval timestamp.

## Rules for Phases That Produce Reports

* A quoted block showing current state must come from a ledger entry. If no entry exists, the finding cannot carry a quoted block.
* Mark each quoted block with its entry ID so verification can be automated, for example `<!-- evidence: EV-014 -->` immediately above the fence.
* Authored content is permitted only on the proposal side: recommended fixes, target-state examples, and analysis. Never on the observation side.
* Every path, symbol, property key, endpoint, or dependency named in a proposed fix must either appear in the ledger or be declared as introduced by that fix.
* When the same source location supports several findings, all of them reference the same entry ID. Do not restate the quotation.

## Rules for Verification Steps

* Validation checklists that only inspect document structure do not detect fabricated citations. Structural checks and evidence checks are separate concerns.
* Run the deterministic verifier at the end of every phase that adds or consumes citations.
* On mismatch, flag the finding as unverified and stop. Never instruct an agent to "correct the quote to match the file." Sources commonly contain near-identical constructs, and a fix-forward instruction resolves by silently snapping the citation to the wrong occurrence.
* Keep independent adversarial review in place. Once the ledger is in use it should return zero defects, which makes it a regression test for the pipeline.

## Adoption

See the `evidence-ledger` skill for the ledger schema, capture procedure, and verifier script.
