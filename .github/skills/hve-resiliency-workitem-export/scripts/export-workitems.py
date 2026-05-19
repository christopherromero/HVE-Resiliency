#!/usr/bin/env python3
"""Export resiliency findings from assessment markdown to ADO/Jira CSV."""

from __future__ import annotations

import argparse
import csv
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional

FINDING_HEADER_RE = re.compile(r"^####\s+(P[0-3]-\d+):\s*(.+)$", re.MULTILINE)


@dataclass
class Finding:
    finding_id: str
    title: str
    priority_code: str
    resiliency_related: str
    issue: str
    recommended_fix: str
    file_ref: str


def _extract_field(block: str, label: str, next_labels: List[str]) -> str:
    next_pattern = "|".join(re.escape(item) for item in next_labels)
    pattern = re.compile(
        rf"\*\*{re.escape(label)}:\*\*\s*(.*?)(?=\n\*\*(?:{next_pattern}):\*\*|\n---|\Z)",
        re.DOTALL,
    )
    match = pattern.search(block)
    if not match:
        return ""
    value = match.group(1).strip()
    # Preserve line breaks; collapse only horizontal whitespace within lines
    lines = [re.sub(r"[ \t]+", " ", line).rstrip() for line in value.split("\n")]
    # Collapse multiple consecutive blank lines into one
    collapsed: List[str] = []
    prev_blank = False
    for line in lines:
        is_blank = not line.strip()
        if is_blank and prev_blank:
            continue
        collapsed.append(line)
        prev_blank = is_blank
    return "\n".join(collapsed).strip()


def parse_findings(markdown: str) -> List[Finding]:
    matches = list(FINDING_HEADER_RE.finditer(markdown))
    findings: List[Finding] = []

    for index, match in enumerate(matches):
        start = match.start()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(markdown)
        block = markdown[start:end]

        finding_id = match.group(1).strip()
        title = match.group(2).strip()
        priority_code = finding_id.split("-")[0]

        priority_line_match = re.search(r"\*\*Priority:\*\*\s*(.+)", block)
        if priority_line_match:
            priority_text = re.sub(r"\s+", " ", priority_line_match.group(1).strip())
        else:
            priority_text = priority_code

        resiliency_related = _extract_field(
            block,
            "Resiliency Related",
            ["Issue", "What does this solve", "Resiliency Impact", "Recommended Fix", "File"],
        )
        issue = _extract_field(
            block,
            "Issue",
            ["What does this solve", "Resiliency Impact", "Recommended Fix", "File"],
        )
        recommended_fix = _extract_field(
            block,
            "Recommended Fix",
            ["File", "Notes", "MSFT Reference"],
        )
        file_ref = _extract_field(
            block,
            "File",
            ["Fix", "Notes", "MSFT Reference"],
        )

        findings.append(
            Finding(
                finding_id=finding_id,
                title=title,
                priority_code=priority_code,
                resiliency_related=resiliency_related or "Unknown",
                issue=issue,
                recommended_fix=recommended_fix,
                file_ref=file_ref,
            )
        )

    return findings


def to_ado_rows(findings: List[Finding]) -> List[Dict[str, str]]:
    priority_map = {"P0": "1", "P1": "2", "P2": "3", "P3": "4"}
    severity_map = {
        "P0": "1 - Critical",
        "P1": "2 - High",
        "P2": "3 - Medium",
        "P3": "4 - Low",
    }

    rows: List[Dict[str, str]] = []
    for finding in findings:
        description = (
            f"Finding ID: {finding.finding_id}\n\n"
            f"Resiliency Related: {finding.resiliency_related}\n\n"
            f"Issue: {finding.issue}\n\n"
            f"Evidence: {finding.file_ref}\n\n"
            f"Recommended Fix: {finding.recommended_fix}"
        )
        rows.append(
            {
                "Title": f"[{finding.finding_id}] {finding.title}",
                "Work Item Type": "Product Backlog Item",
                "Priority": priority_map.get(finding.priority_code, "3"),
                "Severity": severity_map.get(finding.priority_code, "3 - Medium"),
                "Description": description,
                "Tags": f"resiliency;assessment;{finding.priority_code.lower()}",
                "Acceptance Criteria": "Validated in code and IaC. Evidence links updated."
            }
        )

    return rows


def to_jira_rows(findings: List[Finding]) -> List[Dict[str, str]]:
    priority_map = {"P0": "Highest", "P1": "High", "P2": "Medium", "P3": "Low"}

    rows: List[Dict[str, str]] = []
    for finding in findings:
        description = (
            f"*Finding ID:* {finding.finding_id}\n\n"
            f"*Resiliency Related:* {finding.resiliency_related}\n\n"
            f"*Issue:* {finding.issue}\n\n"
            f"*Evidence:* {finding.file_ref}\n\n"
            f"*Recommended Fix:* {finding.recommended_fix}"
        )

        issue_type = "Bug" if finding.priority_code in {"P0", "P1"} else "Task"
        rows.append(
            {
                "Summary": f"[{finding.finding_id}] {finding.title}",
                "Issue Type": issue_type,
                "Priority": priority_map.get(finding.priority_code, "Medium"),
                "Description": description,
                "Labels": f"resiliency,assessment,{finding.priority_code.lower()}",
                "Components": "Reliability",
            }
        )

    return rows


def prompt_tool_choice(current: Optional[str]) -> str:
    if current:
        return current.lower()

    print("Choose target tool:")
    print("1) ADO")
    print("2) Jira")
    choice = input("Enter 1 or 2: ").strip()
    if choice == "1":
        return "ado"
    if choice == "2":
        return "jira"
    raise ValueError("Invalid choice. Enter 1 for ADO or 2 for Jira.")


def write_csv(rows: List[Dict[str, str]], output_path: Path) -> None:
    if not rows:
        raise ValueError("No findings found to export.")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8", newline="") as file_handle:
        writer = csv.DictWriter(file_handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export assessment findings to ADO or Jira CSV format."
    )
    parser.add_argument(
        "--assessment-path",
        default="Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md",
        help="Path to the assessment markdown file.",
    )
    parser.add_argument(
        "--tool",
        choices=["ado", "jira"],
        help="Target backlog system.",
    )
    parser.add_argument(
        "--output-path",
        help="Output CSV path. Defaults to .copilot-tracking/workitems/<name>-<tool>-workitems.csv",
    )

    args = parser.parse_args()
    selected_tool = prompt_tool_choice(args.tool)

    assessment_path = Path(args.assessment_path)
    if not assessment_path.exists():
        raise FileNotFoundError(f"Assessment file not found: {assessment_path}")

    markdown = assessment_path.read_text(encoding="utf-8")
    findings = parse_findings(markdown)
    if selected_tool == "ado":
        rows = to_ado_rows(findings)
    else:
        rows = to_jira_rows(findings)

    if args.output_path:
        output_path = Path(args.output_path)
    else:
        assessment_stem = assessment_path.stem.lower().replace(" ", "-")
        output_path = Path(
            f".copilot-tracking/workitems/{assessment_stem}-{selected_tool}-workitems.csv"
        )

    write_csv(rows, output_path)
    print(f"Export complete: {output_path}")
    print(f"Rows exported: {len(rows)}")


if __name__ == "__main__":
    main()
