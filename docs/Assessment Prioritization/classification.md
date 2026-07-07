# Priority Classification — Decision Tree Diagrams

**OSPG Digital Payments — OSPG-PaymentTokenVault**

**Companion to:** OSPG-PaymentTokenVault-Priority-Classification-Decision-Tree.md

**Purpose:** Visual decision trees for the P0 / P1 / P2 / P3 priority classification and Resiliency vs Non-Resiliency categorization used across the assessment. Refer to the companion document for the written criteria, rules, and source authority.

**Provenance:** The classification logic shown in Diagrams 1 and 2 is **[OSPG]**-authored (the engagement-specific prompts and instructions). The pipeline in Diagram 3 is a **[Hybrid]**: the research → consolidate → plan workflow shell and `/clear` resets come from the **[HVE]** framework (`microsoft/hve-core`), while the priorities, resiliency split, and finding IDs flowing through it are **[OSPG]**. See the companion document, Section 9, for the full attribution.

**Version:** 1.0.0

---

<a id="top"></a>

## Table of Contents

1. [Classification Decision Tree](#1-classification-decision-tree)
2. [Resiliency vs Non-Resiliency Determination](#2-resiliency-vs-non-resiliency-determination)
3. [Classification Pipeline](#3-classification-pipeline)

---

## 1. Classification Decision Tree

**Provenance: [OSPG].** The exact algorithm applied to every finding to assign a P0–P3 priority.

> [!NOTE]
> **Rule 2 (referenced at Q5) — "resiliency wording is required."** A finding that fails the Litmus Test (Q1 = NO) gets one chance to enter the resiliency bucket: if its impact can be *credibly* stated as *"If you don't fix [X], then during a [failure scenario], [Y impact] occurs, which affects the resiliency of [client goal Z],"* it is reframed and promoted to **P1**. The reframe must be honest — a stretched or manufactured resiliency angle is not allowed — and it only ever raises a finding to P1, never P0.

```mermaid
flowchart TD
    START([New finding identified]) --> Q1{Q1 — Litmus Test:
Does single-region to active/active
introduce or change this issue?}

    Q1 -- YES --> Q2{Q2 — Does this fix block
failover from working at all?}
    Q1 -- NO --> Q5{Q5 — Can impact be credibly
reframed in resiliency terms?
Rule 2}

    Q2 -- YES --> P0A[P0 — Failover-Blocking Risk]
    Q2 -- NO --> Q3{Q3 — Does this issue only
manifest during a failure event?}

    Q3 -- NO --> P1A[P1 — Multi-Region Resiliency Gap]
    Q3 -- YES --> Q4{Q4 — Is there a
procedural workaround?}

    Q4 -- YES --> P1B[P1 — Multi-Region Resiliency Gap]
    Q4 -- NO --> P0B[P0 — Failover-Blocking Risk]

    Q5 -- YES --> P1C[P1 — reword impact statement,
move to resiliency bucket]
    Q5 -- NO --> Q6{Q6 — Does the finding have
functional or operational impact?}

    Q6 -- YES --> P2A[P2 — Code Quality / Best Practice]
    Q6 -- NO --> P3A[P3 — Noted for Completeness]

    P0A --> RYES[[Resiliency Related: YES]]
    P0B --> RYES
    P1A --> RYES
    P1B --> RYES
    P1C --> RYES
    P2A --> RNO[[Resiliency Related: NO]]
    P3A --> RNO

    classDef p0 fill:#c0392b,color:#fff,stroke:#7b241c;
    classDef p1 fill:#e67e22,color:#fff,stroke:#a04000;
    classDef p2 fill:#f1c40f,color:#000,stroke:#b7950b;
    classDef p3 fill:#7f8c8d,color:#fff,stroke:#515a5a;
    class P0A,P0B p0;
    class P1A,P1B,P1C p1;
    class P2A p2;
    class P3A p3;
```

[Back to Top](#top)

---

## 2. Resiliency vs Non-Resiliency Determination

**Provenance: [OSPG].** The `Resiliency Related: Yes / No` field decides whether a finding appears in Section 2 (Resilient Focused Recommendations) or Section 3 (Non-Resilient Focused Recommendations).

```mermaid
flowchart LR
    F([Finding]) --> L{Passes Litmus Test
OR reframed via Rule 2?}
    L -- YES --> Y[Resiliency Related: YES
Section 2
requires Resiliency Impact statement
eligible for P0/P1/P2/P3]
    L -- NO --> N[Resiliency Related: NO
Section 3
uses plain Impact statement
capped at P2/P3]

    classDef yes fill:#1e8449,color:#fff,stroke:#145a32;
    classDef no fill:#5d6d7e,color:#fff,stroke:#34495e;
    class Y yes;
    class N no;
```

[Back to Top](#top)

---

## 3. Classification Pipeline

**Provenance: [Hybrid] — [HVE] workflow shell, [OSPG] content.** Where priorities are decided, finalized, locked, and rendered. Planning phases cannot reclassify or add findings.

```mermaid
flowchart LR
    R0[Researcher 0 / 0a
context frame] --> R1[1a / 1b
service discovery + scope]
    R1 --> RC[Prompts 2-7
core analysis]
    RC --> SVC[Service prompts 8-19
confirmed dependencies only]
    SVC --> CON[Consolidate
de-dup + Findings Index
PRIORITIES FINALIZED]
    CON --> LOCK[planner-0
evidence lock-in]
    LOCK --> M[planner-1
Master report, F-### IDs]
    M --> DG[planner-2
Developer Guide]
    DG --> ASMT[planner-3
Assessment: PX-NNN IDs,
Resiliency vs Non-Resiliency split,
Summary Findings Table]

    classDef decide fill:#2874a6,color:#fff,stroke:#1b4f72;
    classDef lock fill:#7d3c98,color:#fff,stroke:#512e5f;
    classDef render fill:#117a65,color:#fff,stroke:#0b5345;
    class CON decide;
    class LOCK lock;
    class M,DG,ASMT render;
```

[Back to Top](#top)
 