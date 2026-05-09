# Duplicate Drill Hole vs Item-Item DRC Lab

Last run: 2026-05-09

This is a separate lab direction from the main showcase. It tests whether
`Duplicate Drill Hole` suppresses or coexists with other DRC markers produced
for the same two board items.

## Scope

Focused item-item DRCs only:

- `Thru Via to Thru Via Spacing`
- Physical `allow_padconnect`, which is Allegro's exposed constraint name for
  `PAD_PAD_DIRECT_CONNECT` in this environment. The plus board sets it to
  `NOT_ALLOWED` and enables its DRC mode.

Non-item-to-item checks such as keepin/keepout spacing are intentionally not
part of this lab.

## Files

Boards:

- `allegro/dh_item_item_interaction.dh_only.brd`
- `allegro/dh_item_item_interaction.dh_only.drc_only.brd`
- `allegro/dh_item_item_interaction.plus_item_item.brd`
- `allegro/dh_item_item_interaction.plus_item_item.drc_only.brd`

Scripts:

- `scripts/dh_item_item_interaction.il`
- `scripts/dh_item_item_interaction_dh_only.scr`
- `scripts/dh_item_item_interaction_plus.scr`
- `scripts/parse_drc_report_all.py`

Reports and parsed output:

- `reports/dh_item_item_interaction.dh_only.drc.rpt`
- `reports/dh_item_item_interaction.plus_item_item.drc.rpt`
- `results/dh_item_item_interaction.dh_only.objects.csv`
- `results/dh_item_item_interaction.plus_item_item.objects.csv`
- `results/dh_item_item_interaction.dh_only.parsed_dh.csv`
- `results/dh_item_item_interaction.plus_item_item.parsed_dh.csv`
- `results/dh_item_item_interaction.dh_only.parsed_all.csv`
- `results/dh_item_item_interaction.plus_item_item.parsed_all.csv`

## Board Variants

Both boards are regenerated from a copied Cadence demo board, rather than by
editing an existing result board.

`dh_only` enables only:

- `Duplicate_Drill_Hole`

`plus_item_item` enables:

- `Duplicate_Drill_Hole`
- spacing mode `via_via`
- physical constraint `allow_padconnect = NOT_ALLOWED`
- physical mode `allow_padconnect`

The generated geometry is the same in both variants.

## Cases

| Case | Geometry | Intended conflict |
| --- | --- | --- |
| IIC01 | same-net round via pair, same XY | DH plus possible physical pad-connect DRC |
| IIC02 | different-net round via pair, same XY | DH plus different-net via-via spacing |
| IIC03 | no-net slot via pair, same XY | DH plus via-via spacing |
| IIC04 | different-net round via pair, X offset 0.30 mm, pads overlap | spacing-only control |
| IIC05 | same-net round via pair, X offset 0.30 mm, pads overlap | physical pad-connect control |
| IIC06 | different-net round via pair, X offset 1.20 mm | clean separated control |
| IIC07 | same-net round via pair, X offset 0.0001 mm | DH plus possible physical pad-connect DRC |

## Results

`dh_only` report:

- Total detailed DRC rows: 4
- `Duplicate Drill Hole`: 4
- No item-item spacing rows.

`plus_item_item` report:

- Total detailed DRC rows: 28
- `Duplicate Drill Hole`: 4
- `Pad/Pad Direct Connect`: 6
- `Thru Via to Thru Via Spacing`: 18

Observed per case:

| Case | DH | Item-item DRC | Interpretation |
| --- | --- | --- | --- |
| IIC01 | Yes | No | Exact same-XY same-net duplicate via reports DH only; no `Pad/Pad Direct Connect` row. |
| IIC02 | Yes | Yes, 6 layer rows | DH coexists with different-net via-via spacing for the same two vias. |
| IIC03 | Yes | Yes, 6 layer rows | DH coexists with no-net slot-via spacing for the same two vias. |
| IIC04 | No | Yes, 6 layer rows | Offset pads still produce spacing, but not DH. |
| IIC05 | No | Yes, 6 layer rows | Same-net offset vias trigger `Pad/Pad Direct Connect` when `allow_padconnect = NOT_ALLOWED`. |
| IIC06 | No | No | Separated control is clean. |
| IIC07 | Yes | No | Quantized same-net duplicate reports DH, but not `Pad/Pad Direct Connect`. |

## Conclusion

For the tested item-item spacing rule, `Duplicate Drill Hole` does not replace
or suppress the spacing marker. When both rules are enabled and the same two
items violate both DH and different-net via-via spacing, Allegro reports both:

- one `Duplicate Drill Hole` marker at the duplicate drill origin
- one `Thru Via to Thru Via Spacing` marker per affected layer

For Physical `Pad/Pad Direct Connect`, this lab now explicitly enables the
rule by setting `allow_padconnect = NOT_ALLOWED`. The rule reports on the
same-net offset via pair, proving the setup is active. However, the tested
same-net duplicate pairs did not also receive `Pad/Pad Direct Connect`
markers. Current interpretation: in this via-via setup, exact or effectively
duplicate drill origin pairs are classified as DH without also emitting the
pad-pad direct-connect marker, while visibly offset same-net pad overlap emits
`Pad/Pad Direct Connect` without DH.

## Reproduction

```powershell
Copy-Item -LiteralPath 'C:\Cadence\SPB_24.1\share\pcb\examples\board_design\Cadence_Demo.brd' -Destination '.\allegro\dh_item_item_interaction.dh_only.brd' -Force
Copy-Item -LiteralPath 'C:\Cadence\SPB_24.1\share\pcb\examples\board_design\Cadence_Demo.brd' -Destination '.\allegro\dh_item_item_interaction.plus_item_item.brd' -Force

cmd /c "call C:\Cadence\SPB_24.1\tools\bin\allegro_cmd.bat && allegro.exe -expert -p . -nographic -s scripts\dh_item_item_interaction_dh_only.scr allegro\dh_item_item_interaction.dh_only.brd"
cmd /c "call C:\Cadence\SPB_24.1\tools\bin\allegro_cmd.bat && allegro.exe -expert -p . -nographic -s scripts\dh_item_item_interaction_plus.scr allegro\dh_item_item_interaction.plus_item_item.brd"

powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_item_item_interaction.dh_only.brd -OutputBoardPath .\allegro\dh_item_item_interaction.dh_only.drc_only.brd -ReportPath .\reports\dh_item_item_interaction.dh_only.drc.rpt
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_item_item_interaction.plus_item_item.brd -OutputBoardPath .\allegro\dh_item_item_interaction.plus_item_item.drc_only.brd -ReportPath .\reports\dh_item_item_interaction.plus_item_item.drc.rpt

python .\scripts\parse_drc_report.py .\reports\dh_item_item_interaction.dh_only.drc.rpt --csv .\results\dh_item_item_interaction.dh_only.parsed_dh.csv
python .\scripts\parse_drc_report.py .\reports\dh_item_item_interaction.plus_item_item.drc.rpt --csv .\results\dh_item_item_interaction.plus_item_item.parsed_dh.csv
python .\scripts\parse_drc_report_all.py .\reports\dh_item_item_interaction.dh_only.drc.rpt --csv .\results\dh_item_item_interaction.dh_only.parsed_all.csv
python .\scripts\parse_drc_report_all.py .\reports\dh_item_item_interaction.plus_item_item.drc.rpt --csv .\results\dh_item_item_interaction.plus_item_item.parsed_all.csv
```
