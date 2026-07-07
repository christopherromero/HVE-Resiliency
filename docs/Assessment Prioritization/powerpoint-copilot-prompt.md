# PowerPoint Copilot Prompt: Prioritization Process Context Slide

Paste the prompt below into PowerPoint Copilot ("Create slide") after attaching `pir.md` (from this folder) as the source document. The output is a single context-setting slide for the customer that explains, at a high level, how the 122 findings in the OSPG-PaymentTokenVault assessment were prioritized. Specifics live in pir.md and the assessment itself; this slide only sets the frame.

---

## Prompt

Create a single PowerPoint slide titled "How We Prioritized the Findings" for the customer reviewing the OSPG-PaymentTokenVault resiliency assessment. The slide sets context only; it should be brief and not attempt to explain the rules in detail. Do not use em dashes; use space-hyphen-space ( - ) instead.

Describe the three-stage process that produced the prioritized findings:

1. **Stage 1 - HVE (automated research).** A prompt library called HVE (`microsoft/hve-core`), used through GitHub Copilot in VS Code, runs a disciplined research workflow over the codebase and produces evidence-backed findings with file and line citations.
2. **Stage 2 - Our prompts (classification and prioritization).** Resiliency-specific prompts we authored apply the Litmus Test (does single-region to active/active introduce or change this issue?), the Four Rules, and the P0 through P3 priority criteria to tag each finding.
3. **Stage 3 - Human in the loop (verification).** We review every finding and its assigned priority. In past engagements this step has changed both findings and priorities; the automated stages are inputs to our judgment, not the final word.

Layout: one slide only. Prefer a three-column layout (one column per stage) with a short headline at the top and a one-line closing note that detailed rules and the decision tree are in the companion document. At most three short bullets per stage. Plain language suitable for technical leadership. Do not include the Litmus Test full text, the Four Rules text, the P0 through P3 definitions, or the decision tree on this slide; those are intentionally deferred to follow-up.

