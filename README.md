# Allegro Lab: Duplicate Drill Hole DRC

This repository is a local research project for characterizing Cadence Allegro's Duplicate Drill Hole DRC behavior.

- Attribute: `DUP_DRILL_HOLE_VMODE`
- DRC code / identifier: `DH`
- Tested Allegro version: `Allegro PCB Venture 24.1 S001 Windows SPB 64-bit Edition`
- Local Cadence tool path used during testing: `C:\Cadence\SPB_24.1\tools\bin`

The project has verified that Allegro can be driven through no-GUI/batch execution for this workflow:

```powershell
allegro.exe -expert -p . -nographic -s <script.scr> <board.brd>
dbdoctor.exe -drc_only -outfile <out.brd> <in.brd>
report.exe -v drc <board.brd> <report.rpt>
```

## Repository Contents

- `docs/test_plan.md`: original test plan and target decision boundaries.
- `docs/automation_strategy.md`: verified automation strategy and command chain.
- `docs/automated_verification_results.md`: Chinese final verification summary.
- `docs/showcase_case_analysis.md`: detailed per-case analysis for the generated showcase board.
- `matrix/duplicate_drill_hole_case_matrix.csv`: original case matrix.
- `matrix/padstack_requirements.csv`: padstack requirements.
- `scripts/dh_showcase_board.il`: Allegro SKILL script that generates the showcase board.
- `scripts/dh_showcase_board.scr`: Allegro replay script for board generation.
- `scripts/run_drc_report.ps1`: PowerShell wrapper for `dbdoctor` and `report`.
- `scripts/parse_drc_report.py`: parser for Duplicate Drill Hole entries in Allegro DRC reports.
- `allegro/dh_duplicate_drill_showcase.drc_only.brd`: showcase board with regenerated DRC markers.
- `reports/dh_duplicate_drill_showcase.drc.rpt`: exported DRC report for the showcase board.
- `results/dh_showcase_objects.csv`: generated object map and case labels.
- `results/dh_duplicate_drill_showcase.parsed_dh.csv`: parsed DH records.

## Regenerate The Showcase Board

```powershell
Copy-Item -LiteralPath 'C:\Cadence\SPB_24.1\share\pcb\examples\board_design\Cadence_Demo.brd' -Destination '.\allegro\dh_duplicate_drill_showcase.brd' -Force
cmd /c "call C:\Cadence\SPB_24.1\tools\bin\allegro_cmd.bat && allegro.exe -expert -p . -nographic -s scripts\dh_showcase_board.scr allegro\dh_duplicate_drill_showcase.brd"
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_duplicate_drill_showcase.brd -OutputBoardPath .\allegro\dh_duplicate_drill_showcase.drc_only.brd -ReportPath .\reports\dh_duplicate_drill_showcase.drc.rpt
python .\scripts\parse_drc_report.py .\reports\dh_duplicate_drill_showcase.drc.rpt --csv .\results\dh_duplicate_drill_showcase.parsed_dh.csv
```

## Current Boundary Model

The observed behavior is best modeled as:

```text
report DH when:
  effective drill XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
```

Observed non-factors once those two conditions hold include padstack name, copper pad size, copper pad shape, drill diameter, plating, round/slot style, slot size, object type, net name, and no-net status.

See `docs/showcase_case_analysis.md` for detailed per-case evidence.
