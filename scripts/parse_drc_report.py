#!/usr/bin/env python3
"""Extract Duplicate Drill Hole DRC entries from Allegro text reports.

The Allegro DRC report format can vary by version and report settings. This
parser intentionally uses conservative heuristics:

- a line matches when it contains standalone DRC code "DH";
- or when it contains "Duplicate Drill Hole";
- nearby lines are kept as context so the operator can inspect object details.

If your local report uses a different format, adjust DH_PATTERNS and the
coordinate regex below after saving a representative report sample.
"""

from __future__ import annotations

import argparse
import csv
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


DH_PATTERNS = [
    re.compile(r"(?<![A-Za-z0-9_])DH(?![A-Za-z0-9_])", re.IGNORECASE),
    re.compile(r"Duplicate\s+Drill\s+Hole", re.IGNORECASE),
]

COORD_PATTERNS = [
    re.compile(
        r"\(?\s*(?P<x>-?\d+(?:\.\d+)?)\s*[, ]\s*(?P<y>-?\d+(?:\.\d+)?)\s*\)?"
    ),
    re.compile(
        r"X\s*[:=]\s*(?P<x>-?\d+(?:\.\d+)?).{0,20}?"
        r"Y\s*[:=]\s*(?P<y>-?\d+(?:\.\d+)?)",
        re.IGNORECASE,
    ),
]


@dataclass(frozen=True)
class DhEntry:
    report_file: str
    line_number: int
    code: str
    x: str
    y: str
    message: str
    context: str


def is_dh_line(line: str) -> bool:
    return any(pattern.search(line) for pattern in DH_PATTERNS)


def extract_coord(text: str) -> tuple[str, str]:
    for pattern in COORD_PATTERNS:
        match = pattern.search(text)
        if match:
            return match.group("x"), match.group("y")
    return "", ""


def normalize_context(lines: Iterable[str]) -> str:
    return " | ".join(line.strip() for line in lines if line.strip())


def parse_report(path: Path, context_radius: int = 2) -> list[DhEntry]:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    entries: list[DhEntry] = []
    in_detail_table = False

    for index, line in enumerate(lines):
        if line.strip().startswith("Constraint Name,DRC Marker Location"):
            in_detail_table = True
            continue
        if not in_detail_table:
            continue
        if not is_dh_line(line):
            continue

        start = max(0, index - context_radius)
        end = min(len(lines), index + context_radius + 1)
        context_lines = lines[start:end]
        context = normalize_context(context_lines)
        x, y = extract_coord(line)

        entries.append(
            DhEntry(
                report_file=str(path),
                line_number=index + 1,
                code="DH",
                x=x,
                y=y,
                message=line.strip(),
                context=context,
            )
        )

    return entries


def write_csv(entries: list[DhEntry], csv_path: Path) -> None:
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "report_file",
                "line_number",
                "code",
                "x",
                "y",
                "message",
                "context",
            ],
        )
        writer.writeheader()
        for entry in entries:
            writer.writerow(
                {
                    "report_file": entry.report_file,
                    "line_number": entry.line_number,
                    "code": entry.code,
                    "x": entry.x,
                    "y": entry.y,
                    "message": entry.message,
                    "context": entry.context,
                }
            )


def print_summary(entries: list[DhEntry]) -> None:
    print(f"DH entries: {len(entries)}")
    for entry in entries:
        coord = f" @ ({entry.x}, {entry.y})" if entry.x and entry.y else ""
        print(f"{entry.report_file}:{entry.line_number}: {entry.message}{coord}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extract Duplicate Drill Hole DRC entries from Allegro reports."
    )
    parser.add_argument(
        "reports",
        nargs="+",
        type=Path,
        help="One or more Allegro DRC report text files.",
    )
    parser.add_argument(
        "--csv",
        type=Path,
        help="Optional CSV output path for extracted DH entries.",
    )
    parser.add_argument(
        "--context-radius",
        type=int,
        default=2,
        help="Number of surrounding lines to retain around each match.",
    )
    args = parser.parse_args()

    all_entries: list[DhEntry] = []
    for report in args.reports:
        if not report.exists():
            raise SystemExit(f"Report not found: {report}")
        all_entries.extend(parse_report(report, args.context_radius))

    print_summary(all_entries)

    if args.csv:
        write_csv(all_entries, args.csv)
        print(f"Wrote CSV: {args.csv}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
