#!/usr/bin/env python3
"""Extract all detailed DRC rows from an Allegro text report."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path


FIELDNAMES = [
    "report_file",
    "constraint_name",
    "marker_location",
    "drc_subclass",
    "required_value",
    "actual_value",
    "constraint_source",
    "constraint_source_type",
    "element_1",
    "element_2",
]


def parse_report(path: Path) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    in_detail_table = False

    with path.open(newline="", encoding="utf-8", errors="replace") as handle:
        reader = csv.reader(handle)
        for row in reader:
            if row and row[0].strip() == "Constraint Name":
                in_detail_table = True
                continue
            if not in_detail_table or not row:
                continue
            if len(row) < 9:
                continue
            rows.append(
                {
                    "report_file": str(path),
                    "constraint_name": row[0].strip(),
                    "marker_location": row[1].strip(),
                    "drc_subclass": row[2].strip(),
                    "required_value": row[3].strip(),
                    "actual_value": row[4].strip(),
                    "constraint_source": row[5].strip(),
                    "constraint_source_type": row[6].strip(),
                    "element_1": row[7].strip(),
                    "element_2": row[8].strip(),
                }
            )

    return rows


def write_csv(rows: list[dict[str, str]], csv_path: Path) -> None:
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDNAMES)
        writer.writeheader()
        writer.writerows(rows)


def print_summary(rows: list[dict[str, str]]) -> None:
    counts: dict[str, int] = {}
    for row in rows:
        key = row["constraint_name"]
        counts[key] = counts.get(key, 0) + 1

    print(f"Detailed DRC rows: {len(rows)}")
    for key in sorted(counts):
        print(f"{counts[key]} x {key}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extract all detailed DRC rows from Allegro reports."
    )
    parser.add_argument("report", type=Path)
    parser.add_argument("--csv", type=Path)
    args = parser.parse_args()

    if not args.report.exists():
        raise SystemExit(f"Report not found: {args.report}")

    rows = parse_report(args.report)
    print_summary(rows)
    if args.csv:
        write_csv(rows, args.csv)
        print(f"Wrote CSV: {args.csv}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
