---
title: Post-Assessment Report Runbook
description: Ordered checklist for reviewing and finalizing a resiliency assessment report
---

## Post-Assessment Report Creation Checklist

Complete these checks strictly in the listed order against the final assessment draft. If using an AI agent, be sure to use HVE Task Reviewer as the agent.

Run only one checklist item at a time. After an item changes the report, save the report and use that updated version as the input to the next item. Do not parallelize, skip, combine, or reorder items. Complete the linked prompt workflows inline at steps 7 and 10 before continuing to the next numbered item. If any item cannot be completed, stop and report that item and its blocking reason.

1. Confirm the target deployment model is correct: Active/Standby (West US 2 , West US multi-region architecture) or Active/Active (West US 2, West US  multi-region architecture).
2. Confirm the report contains no East US references.
3. Find and fix strange character encoding issues.
4. Remove references to 'F-XXX' findings. We are working with 'P-XXX'. The 'F-XXX' refers to findings in the Developer Guide and other researc. If we see them, it means the findings in the Developer Guid and other research was not processed correctly.
5. Check and exclude Jenkins findings or the Pivotal Cloud Foundations notes.
6. Check proper usage of resiliency and non-resiliency titles and that findings are in their correct place.
7. Minimize findings that require Platform changes. The Platform is already set up, and the assessment must focus on Application changes. We can note them in Notes sections, but try not to make findings for them.
8. Run the [duplicate finding detector](detect-assessment-duplicates.prompt.md), then remove confirmed duplicate findings before continuing.
9. Remove or consolidate out-of-scope findings.
10. Verify correct cited line numbers and File section code snippets are verbatim.
11. Run the [finding reordering prompt](reorder-assessment-findings.prompt.md) against the report produced by step 9, then save its reordered and renumbered result before continuing.
12. Check for and Remove exposed agent internals - i.e. Statements like “I searched,” “the agent found,” "reordered to" or “according to the prompt”, Don't remove "Prompt Suite Version:"
