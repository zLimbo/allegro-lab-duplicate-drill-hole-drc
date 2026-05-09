# Session Handoff: Duplicate Drill Hole DRC Lab

Last updated: 2026-05-09

Repository:

- Local path: `D:\pcb\Duplicate Drill Hole DRC`
- GitHub: `https://github.com/zLimbo/allegro-lab-duplicate-drill-hole-drc`
- Latest pushed commit at handoff: `Add multi-drill parameter cases`

Cadence environment used:

```text
C:\Cadence\SPB_24.1\tools\bin
Allegro PCB Venture 24.1 S001 Windows SPB 64-bit Edition
```

## Current State

The lab is fully scriptable in Allegro no-gui/batch mode. It generates a showcase board, runs Duplicate Drill Hole DRC, exports a report, parses DH records, and documents the observed boundaries.

Main generated board:

- `allegro/dh_duplicate_drill_showcase.brd`
- `allegro/dh_duplicate_drill_showcase.drc_only.brd`

Main evidence files:

- `reports/dh_duplicate_drill_showcase.drc.rpt`
- `results/dh_duplicate_drill_showcase.parsed_dh.csv`
- `results/dh_showcase_objects.csv`
- `docs/showcase_case_analysis.md`
- `docs/lab_results.md`

The current showcase contains 81 array cases plus one real demo-board through pin-via control. The latest DRC report contains 47 detailed entries, all `Duplicate Drill Hole`.

The board array has been packed to 8 visual columns. The generated board also turns on the main text/silkscreen visibility layers before saving:

- `BOARD GEOMETRY/NOTES`
- `REF DES/SILKSCREEN_TOP`
- `REF DES/SILKSCREEN_BOTTOM`
- `PACKAGE GEOMETRY/SILKSCREEN_TOP`
- `PACKAGE GEOMETRY/SILKSCREEN_BOTTOM`

## Reproduction Commands

From the repository root:

```powershell
Copy-Item -LiteralPath 'C:\Cadence\SPB_24.1\share\pcb\examples\board_design\Cadence_Demo.brd' -Destination '.\allegro\dh_duplicate_drill_showcase.brd' -Force
cmd /c "call C:\Cadence\SPB_24.1\tools\bin\allegro_cmd.bat && allegro.exe -expert -p . -nographic -s scripts\dh_showcase_board.scr allegro\dh_duplicate_drill_showcase.brd"
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_duplicate_drill_showcase.brd -OutputBoardPath .\allegro\dh_duplicate_drill_showcase.drc_only.brd -ReportPath .\reports\dh_duplicate_drill_showcase.drc.rpt
python .\scripts\parse_drc_report.py .\reports\dh_duplicate_drill_showcase.drc.rpt --csv .\results\dh_duplicate_drill_showcase.parsed_dh.csv
```

If the default `python` is not suitable, the previous runs used:

```powershell
& 'C:\Users\z\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' .\scripts\parse_drc_report.py .\reports\dh_duplicate_drill_showcase.drc.rpt --csv .\results\dh_duplicate_drill_showcase.parsed_dh.csv
```

## Core Observed Rule

The original hypothesis, "DH only reports when XY and layer span are exactly identical", is only partially correct.

Current best model:

```text
report DH when:
  via/padstack instance XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
  and
  for multi-drill padstacks, the compared multi-drill parameters are compatible
```

Important span finding:

- Exact layer-span equality is not required.
- Positive Z overlap is enough.
- Endpoint-only contact did not report.
- Disjoint spans did not report.

Important XY finding:

- `X+0.001` separation avoided DH in the showcase board.
- `X+0.0001` was stored/quantized as effectively same XY and did report.
- Treat this as Allegro database-coordinate behavior, not generic floating-point equality.

Important drill-offset finding:

- Padstacks created with `make_axlPadStackDrill(... ?offset ...)` did not move the DH XY comparison point.
- Same via/padstack instance origin reported DH even when drill offsets made the physical drill centers different.
- Different via origins did not report even when opposing/compensating drill offsets aligned the physical drill centers.
- Current wording should prefer `via/padstack instance origin` over broad `effective drill origin` for the DH XY key.

## Non-Factors For Single-Drill Cases

Once effective XY matches and spans positively overlap, the following did not suppress DH:

- padstack name
- copper pad size
- copper pad shape
- per-layer copper pad geometry
- drill diameter
- plating, including PTH vs NPTH
- round vs slot style
- slot size
- slot X/Y orientation
- object type among via, generated package pin, and real demo through pin
- net mismatch
- one object no-net
- both objects no-net

## Slot / Drill Shape Findings

Slot cases distinguish drill origin equality from drill-body geometry overlap.

Observed:

- X-slot vs Y-slot at the same origin reported.
- Slot-vs-slot with overlapping bodies but different origins did not report.
- Round drill placed inside or near a slot body did not report if the round drill origin differed from the slot origin.
- Cross-slot `X+0.001` offset did not report.

Conclusion:

- Do not implement DH by drill polygon/oval intersection.
- Use the via/padstack instance-origin keyed XY comparison and layer-span relationship.
- Keep shape/orientation/size as diagnostic metadata.

## Multi-Drill Findings

Current multi-drill cases use generated circular PTH padstacks with `multiDrillData`.

Reported:

- 1x2 multi-drill vs identical 1x2 multi-drill at the same padstack origin.
- 2x2 multi-drill vs identical 2x2 multi-drill at the same padstack origin.
- 1x2 multi-drill vs a separate padstack name with identical rows/columns/clearance/drill diameter.
- 2x2 staggered multi-drill vs identical 2x2 staggered multi-drill.
- 2x2 non-staggered vs 2x2 staggered when rows/columns/clearance/drill diameter matched.
- 1x2 diameter-0.25 multi-drill vs identical 1x2 diameter-0.25 multi-drill.
- 1x2 and 2x2 cases where drill diameter and clearance differed but the derived member-center pitch matched.

Not reported:

- multi-drill vs single drill at the padstack origin
- multi-drill vs single drill offset to a derived-pitch member-hole center
- identical multi-drill arrays shifted so only a subset of member holes could overlap, including derived-pitch partial overlap
- 2x2 vs 1x2 at the same padstack origin
- 1x2 vs 1x3 at the same padstack origin
- 1x2 vs 2x1 at the same padstack origin
- 1x2 clearance-X 0.50 vs 1x2 clearance-X 0.60 at the same padstack origin
- 2x2 clearance-Y 0.50 vs 2x2 clearance-Y 0.60 at the same padstack origin
- 1x2 drill diameter 0.20 vs 1x2 drill diameter 0.25 at the same clearance and origin, because derived pitch differed

Current interpretation:

- Allegro appears to treat a multi-drill padstack as a parameter-level drill definition for DH.
- It does not appear to expand multi-drill definitions into independent member-hole points for single-vs-multi or partial-overlap duplicate checks.
- Same origin alone is not sufficient for multi-drill; rows/columns, row/column orientation, and derived member-center pitch compatibility matter.
- Drill diameter and spacing/clearance are not independent suppressors in the tested circular cases; compensating them to preserve derived pitch still reports DH.
- In the tested generated 2x2 circular case, the `staggered` flag difference did not suppress DH.

## Key Source Files

- `scripts/dh_showcase_board.il`: main SKILL generator for the showcase board.
- `scripts/dh_showcase_board.scr`: loads and runs the generator.
- `scripts/run_drc_report.ps1`: runs `dbdoctor -drc_only` and `report -v drc`.
- `scripts/parse_drc_report.py`: extracts DH report rows to CSV.
- `docs/showcase_case_analysis.md`: detailed case matrix and per-case interpretation.
- `docs/lab_results.md`: unified lab results and implementation recommendation.
- `README.md`: bilingual project overview with language switcher.

## Useful Git Context

Recent commits:

```text
b3de623 Add multi-drill boundary cases
31b443f Add slot geometry boundary cases
d0aca5d Add README language switcher
a565f70 Add Chinese README section
275dddd Localize verification results and translate README
```

The repo-local SSH setting was used successfully:

```text
core.sshCommand=ssh -i C:/Users/z/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new
```

## Open Follow-Up Ideas

Useful next lab directions:

- A new independent item-item interaction lab now exists in
  `docs/item_item_interaction_lab.md`. Current finding: Duplicate Drill Hole
  coexists with `Thru Via to Thru Via Spacing` for the same two vias; it does
  not cover or suppress that item-item spacing DRC in the tested setup.
  Physical `Pad/Pad Direct Connect` is enabled with
  `allow_padconnect = NOT_ALLOWED`; it reports for same-net offset via overlap,
  but not for the tested same-net duplicate-drill pairs.
- Multi-drill definitions involving slot holes, if Allegro supports them in the required mode.
- Mixed plating multi-drill edge cases, if API/library constraints allow.
- Production-library mechanical mounting-hole symbols.
- Additional object types such as testpoints, mounting holes from company symbols, or imported library pins.
- More coordinate-quantization probes between `0.001` and `0.0001`.
- Version comparison against another Allegro/SPB release if available.
- A small independent Python model implementing the current rule and comparing expected vs parsed report results.

## Suggested First Prompt For The Next Session

```text
We are continuing the Allegro Duplicate Drill Hole DRC lab in D:\pcb\Duplicate Drill Hole DRC.
Please read docs/session_handoff.md first, then inspect git status and the latest generated results.
The current goal is to continue from the pushed commit b3de623 without redoing earlier conclusions.
```
