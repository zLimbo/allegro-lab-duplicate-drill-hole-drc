# Automated Verification Results

Run date: 2026-05-08

Cadence executable path:

`C:\Cadence\SPB_24.1\tools\bin`

Observed Allegro version:

`Allegro PCB Venture 24.1 S001 Windows SPB 64-bit Edition`

## Automation Path

The tests were run through Allegro no-gui/batch execution:

1. `allegro.exe -expert -p . -nographic -s <script.scr> <board.brd>`
2. SKILL generated padstacks, vias, slot vias, bbvias, and a via over a real through pin.
3. SKILL enabled the design mode `Duplicate_Drill_Hole`.
4. `dbdoctor.exe -drc_only` regenerated DRC on board copies.
5. `report.exe -v drc` exported DRC reports.
6. `scripts/parse_drc_report.py` extracted `Duplicate Drill Hole` records.

## Generated Boards and Reports

- `allegro/dh_auto_via_cases.brd`
- `allegro/dh_auto_via_cases.drc_only.brd`
- `reports/dh_auto_via_cases.drc.rpt`
- `results/dh_auto_via_cases.parsed_dh.csv`
- `allegro/dh_auto_span_cases.brd`
- `allegro/dh_auto_span_cases.drc_only.brd`
- `reports/dh_auto_span_cases.drc.rpt`
- `results/dh_auto_span_cases.parsed_dh.csv`
- `allegro/dh_pin_probe.brd`
- `allegro/dh_pin_probe.drc_only.brd`
- `reports/dh_pin_probe.drc.rpt`
- `results/dh_pin_probe.parsed_dh.csv`
- `results/automated_verification_summary.csv`

## Main Findings

The initial hypothesis is only partly true.

For XY, the DRC appears to use stored database coordinates. In the 2-layer mil board, `0.000001`, `0.00001`, `0.0001`, and `0.001 mil` offsets were stored/displayed at the same `0.01 mil` coordinate and reported DH. A `0.01 mil` X or Y offset did not report DH.

For layer span, exact span equality is not required. A through via and a TOP-GND bbvia at the same XY reported DH. TOP-GND and TOP-INNER1 bbvias at the same XY also reported DH. TOP-INNER1 and INNER1-BOTTOM bbvias did not report DH in this test, suggesting endpoint-only contact at a layer boundary is not enough, while overlapping drill segments are enough.

Padstack name, drill diameter, plating, net, round-vs-slot shape, slot-vs-slot, and via-vs-real-through-pin object type did not suppress DH when the effective drill overlap condition was met.

## Remaining Gap

A dedicated mounting-hole mechanical symbol case was not separately created. The NPTH case and the real through-pin case cover plating and pin/via object-type behavior, but a production-style mechanical mounting hole can be added as a follow-up if its local library symbol is available or if we generate a mechanical symbol flow.
