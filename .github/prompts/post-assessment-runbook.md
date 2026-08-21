---
title: Post-Assessment Report Runbook
description: Ordered checklist for reviewing and finalizing a resiliency assessment report
---

## Post-Assessment Report Creation Checklist

Complete these checks in order against the final assessment draft:

1. Confirm the target deployment model is correct: Active-Active or Active-Standby.
2. Confirm the report contains no East US references.
3. Find and fix strange character encoding issues.
4. Check and exclude Jenkins findings or the Pivotal Cloud Foundations notes.
5. Check proper usage of resiliency and non-resiliency titles and that findings are in their correct place.
6. Find and remove duplicate findings with the [duplicate finding detector](detect-assessment-duplicates.prompt.md).
7. Remove or consolidate out-of-scope findings.
8. Verify correct cited line numbers and File section code snippets are verbatim.
9. Fix finding order and numbering with the [finding reordering prompt](reorder-assessment-findings.prompt.md).
10. Check for and Remove exposed agent internals - i.e. Statements like “I searched,” “the agent found,” "reordered to" or “according to the prompt”, Don't remove "Prompt Suite Version:"
