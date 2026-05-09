# Duplicate Drill Hole Showcase Case Analysis

Run date: 2026-05-09

Board:

- `allegro/dh_duplicate_drill_showcase.brd`
- `allegro/dh_duplicate_drill_showcase.drc_only.brd`

Reports and logs:

- `reports/dh_duplicate_drill_showcase.drc.rpt`
- `results/dh_duplicate_drill_showcase.parsed_dh.csv`
- `results/dh_showcase_objects.csv`

DRC setup:

- `Duplicate_Drill_Hole` design mode enabled.
- Route keepin/keepout objects removed from the copied demo board before and after placing the showcase objects.
- Other spacing/same-net/physical/assembly/ecset/design DRC modes were disabled in the generation script where available.

Observed report summary:

- Total DRC errors: 36
- Detailed DRC type: all 36 entries are `Duplicate Drill Hole`
- No Route Keepin, Route Keepout, Spacing, Physical, or Miscellaneous DRC entries remained in the exported report.

## Interpretation Rules Used In This Document

`Reported` means the exported DRC report contains a `Duplicate Drill Hole` entry at the case coordinate.

`Not reported` means no `Duplicate Drill Hole` entry was found at the case coordinate in the exported report.

For multi-object cases, Allegro reports pairwise markers. For example, three drill-bearing objects at one XY produced three DH entries at the same coordinate.

## Case Matrix

| Case | Location | Case Type | Objects | Reported | Analysis |
|---|---:|---|---|---|---|
| R0C0 | `(170, 240)` | Baseline via-via | Same round PTH via vs same round PTH via | Yes | Positive control. Same XY and same through span report DH. |
| R0C1 | `(222, 240)` | Package pin-via | Through package pin vs via | Yes | Object type does not suppress DH when the package pin drill and via drill share XY/span. |
| R0C2 | `(274, 240)` | Padstack name | Same drill, different padstack name | Yes | Padstack name identity is not part of the effective duplicate decision. |
| R0C3 | `(326, 240)` | Hole diameter | 0.25 drill vs 0.50 drill | Yes | Drill diameter mismatch does not suppress DH. |
| R0C4 | `(378, 240)` | Plating | PTH vs NPTH | Yes | Plating mismatch does not suppress DH. |
| R1C0 | `(170, 202)` | Net | Same via pair, different nets | Yes | Net mismatch does not suppress DH. |
| R1C1 | `(222, 202)` | Net | One via on net, one no-net | Yes | A no-net counterpart still participates in DH. |
| R1C2 | `(274, 202)` | Drill shape | Round drill via vs slot via | Yes | Round-vs-slot origin coincidence can report DH. |
| R1C3 | `(326, 202)` | Drill shape | Slot vs slot, same slot padstack | Yes | Duplicate slots report DH. |
| R1C4 | `(378, 202)` | XY negative control | Same via pair, `X+0.01` offset | No | A stored/displayed 0.01 unit X separation avoids DH in this board. |
| R2C0 | `(170, 164)` | Span | Same TOP-GND blind/buried span | Yes | Same blind/buried drill span reports DH. |
| R2C1 | `(222, 164)` | Span | Through via vs TOP-GND blind/buried via | Yes | Exact layer span equality is not required; overlapping Z span is enough. |
| R2C2 | `(274, 164)` | Span | TOP-GND vs TOP-INNER1 | Yes | Non-identical spans with positive overlap report DH. |
| R2C3 | `(326, 164)` | Span negative control | TOP-INNER1 vs INNER1-BOTTOM | No | Endpoint-only contact at INNER1 did not report. |
| R2C4 | `(378, 164)` | XY negative control | Same via pair, `Y+0.01` offset | No | A stored/displayed 0.01 unit Y separation avoids DH. |
| R3C0 | `(170, 126)` | Multiple objects | Three vias at same XY | Yes, 3 markers | Allegro reports all pairwise duplicate combinations. |
| R3C1 | `(222, 126)` | XY probe | Same via pair, `X+0.001` offset | No | In this 24.1 demo-board setup, this offset is large enough to avoid DH. |
| R3C2 | `(274, 126)` | XY probe | Same via pair, `X+0.0001` offset | Yes | This offset is quantized/stored as effectively same XY for DH. |
| R3C3 | `(326, 126)` | Plating/object | NPTH vs NPTH | Yes | NPTH holes participate in DH. |
| R3C4 | `(378, 126)` | Slot size | 0.25x0.75 slot vs 0.35x0.75 slot | Yes | Slot size mismatch does not suppress DH when origins/spans overlap. |
| R4C0 | `(170, 88)` | Span negative control | TOP-GND vs INNER2-BOTTOM | No | Disjoint Z spans do not report. |
| R4C1 | `(222, 88)` | Span boundary | TOP-GND vs GND-INNER2 | No | Endpoint-only contact at GND did not report. |
| R4C2 | `(274, 88)` | Span boundary | GND-INNER2 vs INNER2-BOTTOM | No | Endpoint-only contact at INNER2 did not report. |
| R4C3 | `(326, 88)` | Span | GND-POWER vs INNER2-BOTTOM | Yes | Positive Z overlap reports DH. |
| R4C4 | `(378, 88)` | Span negative control | TOP-INNER1 vs POWER-BOTTOM | No | Split/disjoint spans do not report. |
| R5C0 | `(170, 50)` | Package pin-via net | Package pin vs via on `DHS_A` | Yes | Pin-via reports even when the via net differs from the pin net. |
| R5C1 | `(222, 50)` | Package pin-via no-net | Package pin vs no-net via | Yes | A no-net via still reports against a package pin. |
| R5C2 | `(274, 50)` | Drill diameter extreme | 0.10 drill vs 0.50 drill | Yes | Large drill diameter mismatch still does not suppress DH. |
| R5C3 | `(326, 50)` | Net | Both vias no-net | Yes | Two no-net vias report DH. |
| R5C4 | `(378, 50)` | Span | Through via vs POWER-BOTTOM blind/buried via | Yes | Through span overlapping a lower blind/buried span reports DH. |
| R6C0 | `(170, 12)` | Pad size isolation | Same 0.25 drill, small round pad vs large round pad | Yes | Copper pad size does not suppress DH when drill origin/span match. |
| R6C1 | `(222, 12)` | Pad size isolation | Standard pad vs large round pad, same drill | Yes | Standard-vs-large pad difference does not suppress DH. |
| R6C2 | `(274, 12)` | Pad size isolation | Standard pad vs small round pad, same drill | Yes | Standard-vs-small pad difference does not suppress DH. |
| R6C3 | `(326, 12)` | Pad shape isolation | Square pad vs round pad, same drill | Yes | Copper pad shape does not suppress DH. |
| R6C4 | `(378, 12)` | Pad shape isolation | Oblong pad vs round pad, same drill | Yes | Oblong-vs-round copper pad shape does not suppress DH. |
| R7C0 | `(170, -26)` | Pad shape isolation | Square pad vs oblong pad, same drill | Yes | Copper pad shape mismatch alone does not suppress DH. |
| R7C1 | `(222, -26)` | Layer-specific pad geometry | TOP-small/BOTTOM-large vs TOP-large/BOTTOM-small, same drill | Yes | Per-layer copper pad differences do not suppress DH. |
| R7C2 | `(274, -26)` | Pad size + net | Small pad vs large pad, different nets | Yes | Pad size and net mismatch together do not suppress DH. |
| R7C3 | `(326, -26)` | Pad shape + no-net | Square pad vs oblong pad, both no-net | Yes | Pad shape mismatch and no-net status together do not suppress DH. |
| R7C4 | `(378, -26)` | XY negative control | Same via pair, `X+0.001` offset | No | Reconfirms that this offset avoids DH in the showcase board. |
| R8C0 | `(170, -64)` | Slot orientation | X-oriented slot vs Y-oriented slot, same origin | Yes | Slot orientation/figure direction does not suppress DH when origins/spans match. |
| R8C1 | `(222, -64)` | Slot body overlap | Same X-slot pair, second origin at `X+0.20` | No | Overlapping slot bodies did not report when drill origins differ. |
| R8C2 | `(274, -64)` | Slot endpoint/body probe | Same X-slot pair, second origin at `X+0.50` | No | Near-end or partial slot geometry overlap did not report without origin equality. |
| R8C3 | `(326, -64)` | Slot separation control | Same X-slot pair, second origin at `X+0.80` | No | Separated slot bodies do not report. |
| R8C4 | `(378, -64)` | Round in slot body | X-slot plus round drill at `X+0.20` | No | A round drill located inside the slot body did not report without origin equality. |
| R9C0 | `(170, -102)` | Round near slot end | X-slot plus round drill at `X+0.50` | No | Slot/round geometric contact near the slot end did not report without origin equality. |
| R9C1 | `(222, -102)` | Round in Y-slot body | Y-slot plus round drill at `Y+0.20` | No | The same origin rule held for a Y-oriented slot probe. |
| R9C2 | `(274, -102)` | Cross-slot offset | X-slot vs Y-slot, second origin at `X+0.20,Y+0.20` | No | Cross-slot body overlap did not report when origins differ. |
| R9C3 | `(326, -102)` | Cross-slot same origin | X-slot vs Y-slot, same origin | Yes | Cross-slot orientation mismatch still reports when origins/spans match. |
| R9C4 | `(378, -102)` | Cross-slot tiny offset | X-slot vs Y-slot, second origin at `X+0.001` | No | The same `0.001` stored-coordinate separation avoided DH for cross-slot drills. |
| PIN-A | `(79.128, 19.632)` | Demo-board real pin | Existing demo through pin `U37.4` vs via | Yes | A real design through pin and a via can report DH. |

## Pad-Geometry Conclusion

The new R6/R7 cases isolate copper pad geometry while keeping the drill diameter, plating, and through span constant. Allegro still reports DH for:

- Small round pad vs large round pad.
- Standard pad vs large/small custom pad.
- Round pad vs square pad.
- Round pad vs oblong pad.
- Square pad vs oblong pad.
- Per-layer pad geometry swaps.

Therefore, for implementing a Duplicate Drill Hole equivalent, copper pad size and copper pad shape should not be part of the duplicate key. They can be stored as diagnostic context, but the decision should be based on drill-bearing object coordinate and drill-span overlap.

## Drill-Shape Geometry Conclusion

The R8/R9 cases separate drill origin equality from drill-body geometric overlap:

- X-slot vs Y-slot at the same origin reports DH.
- X-slot vs Y-slot at the same origin reports even though the slot directions differ.
- Slot-vs-slot pairs with overlapping bodies but different origins did not report.
- Round drills placed inside or near a slot body did not report when the round drill origin differed from the slot origin.
- A `0.001` coordinate offset suppressed a cross-slot pair, matching the earlier round-via offset probe.

Therefore, the observed DH decision is not based on polygon/oval drill-shape intersection. For an Allegro-like implementation, treat slot drills by their effective drill origin and layer span; record shape, orientation, and size as diagnostic details, not as duplicate-key fields.

## Current Boundary Model

The observed behavior is best modeled as:

```text
report DH when:
  effective drill XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
```

Observed non-factors once those two conditions hold:

- Padstack name.
- Copper pad size.
- Copper pad shape.
- Drill diameter.
- Plating.
- Round vs slot drill style.
- Slot size.
- Slot orientation/figure direction.
- Object type among via, package pin, and real through pin.
- Net name, including no-net cases.

Observed suppressors:

- Stored XY separation large enough to remain distinct.
- Drill-body overlap without stored drill-origin equality.
- Disjoint drill layer spans.
- Endpoint-only layer-span contact.

## Residual Limits

- The exact internal coordinate quantum is not formally derived from Cadence documentation. Results should be described as database-coordinate behavior, not arbitrary floating-point equality.
- Slot orientation coverage now includes generated X/Y padstack figures, but arbitrary rotated slots from production libraries were not exhaustively swept.
- A company-library production mounting-hole symbol may still deserve a separate local-library case. The current coverage includes NPTH padstacks and package/real-pin objects.
- Results are from Cadence Allegro PCB Venture 24.1 S001 on this local setup and the copied Cadence demo board stackup.
