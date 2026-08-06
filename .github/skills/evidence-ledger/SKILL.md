---
name: evidence-ledger
description: Use when a multi-phase workflow reads source artifacts in one phase and quotes them in a later phase, to capture verbatim evidence at read time, transclude it downstream by stable ID, and verify citations deterministically instead of trusting model recall across context boundaries.
---

# Evidence Ledger

A workflow that observes artifacts in one phase and quotes them in another cannot rely on the model to carry the quotation. Context isolation between phases is deliberate, and it destroys everything that was not written to a file. This skill defines the file to write, how to reference it, and how to check it.

## When To Use

Apply this skill to any pipeline where all of the following hold:

* One phase reads source artifacts and a later phase produces output quoting them.
* The phases are separated by a context boundary such as a context clear, a subagent dispatch, or a separate session.
* The output is consumed as factual, for example an assessment, audit, security review, migration plan, or compliance report.

The failure mode it prevents is specific. When the intermediate artifact carries a path, a line number, and a prose description, and the final phase is instructed to show the current code, the only instruction-compliant action available is reconstruction from memory. The output cites a real file, reuses real identifiers, reads like a quotation, and does not match the repository.

## Three Primitives

```text
  capture  ->  reference  ->  verify
  (phase that reads)  (phases that write)  (deterministic gate)
```

* **Capture** happens at the moment of reading, by the phase holding the file open.
* **Reference** is transclusion by ID. Downstream phases never re-author quoted material.
* **Verify** is a script comparing recorded bytes to actual bytes. It never runs inside the model.

## Principles

* Evidence is captured at observation, never reconstructed later.
* Evidence is immutable and addressed by a stable ID.
* The cited range must equal the span of the captured snippet. A wider range cannot be falsified.
* Absence is typed evidence. It records the search performed and its null result, and it carries no line range.
* The observed state is pinned: a commit SHA for repositories, a URL with a retrieval timestamp for remote sources.
* Verification is deterministic and lives outside the model. Structural checklists do not detect fabricated citations.
* Redaction happens once, at capture, so every downstream artifact inherits it.
* Generation is permitted only on the proposal side. Observations are transcluded, proposals are authored.

## Step 1: Pin The State

Before the first read, record the commit the workflow is observing:

```powershell
git rev-parse HEAD
```

Every later phase quotes the same SHA. Without it, verified citations decay the moment someone commits, and a passing verifier proves nothing.

## Step 2: Capture

The reading phase writes `.copilot-tracking/research/<scope>-evidence.json`. Validate it against `schema/evidence-ledger.schema.json`.

```json
{
  "version": "1.0",
  "capturedAt": "2026-07-26T14:02:11Z",
  "source": { "type": "git", "repo": "example-service", "commit": "9f2c1ab" },
  "entries": [
    {
      "id": "EV-001",
      "kind": "present",
      "path": "src/main/java/com/example/OrderClient.java",
      "startLine": 41,
      "endLine": 43,
      "lang": "java",
      "snippet": "    public Mono<Order> fetch(String id) {\n        return client.get().uri(uri).retrieve().bodyToMono(Order.class);\n    }"
    },
    {
      "id": "EV-002",
      "kind": "absent",
      "path": "src/main/resources/application.yml",
      "search": {
        "tool": "grep",
        "query": "resilience4j",
        "scope": "src",
        "result": "no matches"
      },
      "note": "No circuit breaker configuration present anywhere under src."
    },
    {
      "id": "EV-003",
      "kind": "external",
      "owner": "platform-infra/helm-values",
      "note": "Replica count and pod anti-affinity live in the deployment repository, not this workspace."
    }
  ]
}
```

Capture rules:

* Store exact bytes. Do not reindent, wrap, elide, or summarize.
* `endLine` must equal `startLine` plus the snippet line count minus one.
* Never widen a range to cover a general area. Cite the lines you quoted, and add a second entry if you need a second location.
* Use `absent` when the finding is that something is missing. An absence claim with a line range is a contradiction, and models resolve contradictions by inventing a plausible range.
* Use `external` for artifacts owned outside the workspace, and `remote` for fetched URLs.
* Detect secrets while capturing and record a `redactions` entry rather than storing the value.

## Step 3: Reference

Downstream phases mark each quoted block with its ID:

````markdown
**File:** src/main/java/com/example/OrderClient.java:41-43

<!-- evidence: EV-001 -->
```java
    public Mono<Order> fetch(String id) {
        return client.get().uri(uri).retrieve().bodyToMono(Order.class);
    }
```
````

Reference rules:

* If no ledger entry exists, the finding carries no quoted block. This is the constraint that makes fabrication structurally impossible rather than merely discouraged.
* Multiple findings that touch the same location reuse the same ID. Contradictions between findings become visible instead of hiding behind two differently reconstructed quotations.
* Proposed fixes are authored freely, but every path, symbol, property, endpoint, or dependency they name must appear in the ledger or be explicitly declared as introduced by the fix.

## Step 4: Verify

Run the verifier at the end of every phase that adds or consumes citations:

```powershell
./.github/skills/evidence-ledger/scripts/Test-EvidenceLedger.ps1 `
    -LedgerPath .copilot-tracking/research/example-evidence.json `
    -ReportPath .github/Example-Assessment.md
```

It exits non-zero on any failure and checks that files exist, ranges are in bounds, range width equals snippet span, snippets match the file byte for byte, absent entries carry no range and still return nothing, external and remote entries carry their required provenance, and every evidence-marked block in the report matches its entry exactly.

On failure, flag the finding as unverified and stop. Do not instruct an agent to correct the quotation to match the file. Real codebases are full of near-identical constructs such as repeated log statements, delegating DAO methods, and duplicated pipeline stages, and a fix-forward instruction resolves by snapping the citation to the wrong occurrence, which converts a detectable defect into an undetectable one.

## Adopting In An Existing Workflow

Three changes:

1. In the phase that reads artifacts, add: write every cited observation to the evidence ledger at read time, following the `evidence-ledger` skill.
2. In the phases that write output, replace any instruction resembling "pull the code from the previous artifact" with: transclude the ledger entry by ID; do not author current-state code.
3. At each phase gate, add: run `Test-EvidenceLedger.ps1`; a non-zero exit blocks the phase.

If the workflow forbids code in early phases to keep researchers from proposing solutions, restate the rule rather than deleting it. The intent is to prevent premature remediation, not to prevent recording what the source says. Phrase it as: research must not propose code, and research must capture verbatim source excerpts as evidence.

Keep any independent citation audit already in place. Once the ledger is adopted, that audit should return zero findings, which turns it into a regression test for the pipeline itself.

## Files

* `schema/evidence-ledger.schema.json` is the record contract.
* `scripts/Test-EvidenceLedger.ps1` is the deterministic verifier.
* `.github/instructions/evidence-citation.instructions.md` binds these rules to prompt, agent, instructions, and skill authoring.
