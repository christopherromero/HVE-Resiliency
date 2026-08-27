---
description: "Detects duplicate and consolidation-candidate findings in a resiliency assessment"
argument-hint: "assessmentFile=path/to/assessment.md"
---

# Detect Duplicate Assessment Findings

You are reviewing a resiliency assessment document. Detect findings that
describe the same underlying root cause but appear as separate entries, often
labeled as cross-lens repeats or restated under different framings.

Input file: ${input:assessmentFile}

## Method

Follow these steps deterministically:

1. Parse every finding heading (H4 like `#### P0-001: ...`,
   `#### P1-007: ...`). For each finding, extract:
   * ID (e.g. P0-006)
   * Priority tier (P0 / P1 / P2 / P3)
   * Category / section header it lives under (nearest preceding H2 or H3)
   * `**File:**` reference line (e.g. `src/main/resources/bootstrap.yml:L8`),
     including `path:L8-L12` and `path:8-12` forms
   * The exact code snippet shown under the `**File:**` block
   * The `**Recommended Fix:**` body
   * The `**Notes:**` block, which often self-declares repeats with phrases like
     "same underlying condition as", "repeat of", "consolidation of",
     "fix once, both close", or "restated under the ... lens", and dependency
     phrases like "prerequisite", "corresponding ... change", "requires the
     ... refactor", or "variant of"
2. Cluster findings that share any of these signals:
   * Identical file path and overlapping line range
   * Identical or near-identical evidence code snippet
   * Notes explicitly cross-reference another finding ID as the same condition
   * Same category, same named resource or code element, and the same
     remediation contract in `**Recommended Fix:**`
3. Verify every cluster with the same file and overlapping lines or with
   identical or near-identical evidence code. Form transitive clusters when A
   matches B and B matches C. Treat each unmatched finding as a singleton
   cluster so the metrics remain complete.
4. Separately identify consolidation candidates that are not verified
   duplicates. A candidate must have the same remediation contract and either:
   * Evidence from non-overlapping locations in the same enclosing call chain,
     such as a method and its caller or two branches of one method
   * Notes that link the findings through dependency or decomposition language,
     including "prerequisite", "corresponding ... change", "requires the ...
     refactor", or "variant of"
5. Assign each consolidation candidate one disposition:
   * `Consolidate` when one implementation change satisfies the recommended fix
     for every finding and none has distinct remediation, acceptance criteria,
     or ownership
   * `Keep separate` when any finding requires an independent implementation
     change, validation step, acceptance criterion, or remediation owner
   * `Needs review` only when the assessment lacks enough evidence to apply
     either rule above
6. For each duplicate cluster produce:
   * Cluster name (short, e.g. "Config Server URL default")
   * Repeat count
   * Comma-separated finding IDs
   * The single underlying evidence (file:line or code element)
   * Whether the assessment acknowledges the repeat, quoting Notes exactly
7. Compute:
   * Total findings
   * Unique root issues, including singleton clusters
   * Duplication percentage: `(total - unique root issues) / total * 100`
   * Largest cluster and its size

## Rules

* Do not invent clusters. Every grouping must be justified by a signal in
  Step 2 and verified as required by Step 3.
* Do not collapse findings that share only a category but differ in evidence
  or remediation.
* Do not place consolidation candidates in verified duplicate clusters or use
  them to reduce the unique-root-issue count.
* Make a disposition from the assessment evidence whenever Step 5 is
  conclusive. Do not defer a candidate for human review merely because its
  evidence locations differ.
* Trust self-declared repeats in Notes as authoritative intent, but verify them
  through shared location or code evidence. Report unsupported declarations
  separately instead of clustering them.
* If a finding explicitly consolidates others, place it in their verified
  cluster and mark it as the canonical ID.
* Analyze only the evidence contained in the assessment. Do not edit files or
  correct citations against the live repository.

## Deliverables

1. A Markdown table:

   | Cluster | Repeat Count | Finding IDs | Underlying Evidence | Self-declared repeat? |
   |---------|--------------|-------------|---------------------|-----------------------|

2. One line in this exact form:

   `N findings collapse to M unique root issues (X% duplication).`

3. The top five largest duplicate clusters with each exact self-declaration
   phrase from Notes, or `None` when no phrase exists.
4. Any self-declared repeat that could not be verified, with the exact Notes
   phrase and reason.
5. A separate Markdown table for consolidation candidates, or `None` when no
   candidates exist:

   | Candidate Group | Finding IDs | Related Locations | Disposition | Evidence for Disposition |
   |-----------------|-------------|-------------------|-------------|--------------------------|

   Quote any dependency or decomposition phrase from Notes exactly. Explain
   the enclosing call-chain relationship and disposition using only evidence
   stated in the assessment. List only `Needs review` rows again under a
   `Human Review Required` heading. Write `None` when no rows need review.
