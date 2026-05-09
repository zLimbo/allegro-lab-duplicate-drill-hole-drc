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

- Total DRC errors: 41
- Detailed DRC type: all 41 entries are `Duplicate Drill Hole`
- No Route Keepin, Route Keepout, Spacing, Physical, or Miscellaneous DRC entries remained in the exported report.

## Interpretation Rules Used In This Document

`Reported` means the exported DRC report contains a `Duplicate Drill Hole` entry at the case coordinate.

`Not reported` means no `Duplicate Drill Hole` entry was found at the case coordinate in the exported report.

For multi-object cases, Allegro reports pairwise markers. For example, three drill-bearing objects at one XY produced three DH entries at the same coordinate.

## Case Matrix

| Case | Location | Case Type | Objects | Reported | Analysis |
|---|---:|---|---|---|---|
| R0C0 | `(150, 240)` | Baseline via-via | Same round PTH via vs same round PTH via | Yes | Positive control. Same XY and same through span report DH. |
| R0C1 | `(186, 240)` | Package pin-via | Through package pin vs via | Yes | Object type does not suppress DH when the package pin drill and via drill share XY/span. |
| R0C2 | `(222, 240)` | Padstack name | Same drill, different padstack name | Yes | Padstack name identity is not part of the effective duplicate decision. |
| R0C3 | `(258, 240)` | Hole diameter | 0.25 drill vs 0.50 drill | Yes | Drill diameter mismatch does not suppress DH. |
| R0C4 | `(294, 240)` | Plating | PTH vs NPTH | Yes | Plating mismatch does not suppress DH. |
| R1C0 | `(330, 240)` | Net | Same via pair, different nets | Yes | Net mismatch does not suppress DH. |
| R1C1 | `(366, 240)` | Net | One via on net, one no-net | Yes | A no-net counterpart still participates in DH. |
| R1C2 | `(402, 240)` | Drill shape | Round drill via vs slot via | Yes | Round-vs-slot origin coincidence can report DH. |
| R1C3 | `(150, 208)` | Drill shape | Slot vs slot, same slot padstack | Yes | Duplicate slots report DH. |
| R1C4 | `(186, 208)` | XY negative control | Same via pair, `X+0.01` offset | No | A stored/displayed 0.01 unit X separation avoids DH in this board. |
| R2C0 | `(222, 208)` | Span | Same TOP-GND blind/buried span | Yes | Same blind/buried drill span reports DH. |
| R2C1 | `(258, 208)` | Span | Through via vs TOP-GND blind/buried via | Yes | Exact layer span equality is not required; overlapping Z span is enough. |
| R2C2 | `(294, 208)` | Span | TOP-GND vs TOP-INNER1 | Yes | Non-identical spans with positive overlap report DH. |
| R2C3 | `(330, 208)` | Span negative control | TOP-INNER1 vs INNER1-BOTTOM | No | Endpoint-only contact at INNER1 did not report. |
| R2C4 | `(366, 208)` | XY negative control | Same via pair, `Y+0.01` offset | No | A stored/displayed 0.01 unit Y separation avoids DH. |
| R3C0 | `(402, 208)` | Multiple objects | Three vias at same XY | Yes, 3 markers | Allegro reports all pairwise duplicate combinations. |
| R3C1 | `(150, 176)` | XY probe | Same via pair, `X+0.001` offset | No | In this 24.1 demo-board setup, this offset is large enough to avoid DH. |
| R3C2 | `(186, 176)` | XY probe | Same via pair, `X+0.0001` offset | Yes | This offset is quantized/stored as effectively same XY for DH. |
| R3C3 | `(222, 176)` | Plating/object | NPTH vs NPTH | Yes | NPTH holes participate in DH. |
| R3C4 | `(258, 176)` | Slot size | 0.25x0.75 slot vs 0.35x0.75 slot | Yes | Slot size mismatch does not suppress DH when origins/spans overlap. |
| R4C0 | `(294, 176)` | Span negative control | TOP-GND vs INNER2-BOTTOM | No | Disjoint Z spans do not report. |
| R4C1 | `(330, 176)` | Span boundary | TOP-GND vs GND-INNER2 | No | Endpoint-only contact at GND did not report. |
| R4C2 | `(366, 176)` | Span boundary | GND-INNER2 vs INNER2-BOTTOM | No | Endpoint-only contact at INNER2 did not report. |
| R4C3 | `(402, 176)` | Span | GND-POWER vs INNER2-BOTTOM | Yes | Positive Z overlap reports DH. |
| R4C4 | `(150, 144)` | Span negative control | TOP-INNER1 vs POWER-BOTTOM | No | Split/disjoint spans do not report. |
| R5C0 | `(186, 144)` | Package pin-via net | Package pin vs via on `DHS_A` | Yes | Pin-via reports even when the via net differs from the pin net. |
| R5C1 | `(222, 144)` | Package pin-via no-net | Package pin vs no-net via | Yes | A no-net via still reports against a package pin. |
| R5C2 | `(258, 144)` | Drill diameter extreme | 0.10 drill vs 0.50 drill | Yes | Large drill diameter mismatch still does not suppress DH. |
| R5C3 | `(294, 144)` | Net | Both vias no-net | Yes | Two no-net vias report DH. |
| R5C4 | `(330, 144)` | Span | Through via vs POWER-BOTTOM blind/buried via | Yes | Through span overlapping a lower blind/buried span reports DH. |
| R6C0 | `(366, 144)` | Pad size isolation | Same 0.25 drill, small round pad vs large round pad | Yes | Copper pad size does not suppress DH when drill origin/span match. |
| R6C1 | `(402, 144)` | Pad size isolation | Standard pad vs large round pad, same drill | Yes | Standard-vs-large pad difference does not suppress DH. |
| R6C2 | `(150, 112)` | Pad size isolation | Standard pad vs small round pad, same drill | Yes | Standard-vs-small pad difference does not suppress DH. |
| R6C3 | `(186, 112)` | Pad shape isolation | Square pad vs round pad, same drill | Yes | Copper pad shape does not suppress DH. |
| R6C4 | `(222, 112)` | Pad shape isolation | Oblong pad vs round pad, same drill | Yes | Oblong-vs-round copper pad shape does not suppress DH. |
| R7C0 | `(258, 112)` | Pad shape isolation | Square pad vs oblong pad, same drill | Yes | Copper pad shape mismatch alone does not suppress DH. |
| R7C1 | `(294, 112)` | Layer-specific pad geometry | TOP-small/BOTTOM-large vs TOP-large/BOTTOM-small, same drill | Yes | Per-layer copper pad differences do not suppress DH. |
| R7C2 | `(330, 112)` | Pad size + net | Small pad vs large pad, different nets | Yes | Pad size and net mismatch together do not suppress DH. |
| R7C3 | `(366, 112)` | Pad shape + no-net | Square pad vs oblong pad, both no-net | Yes | Pad shape mismatch and no-net status together do not suppress DH. |
| R7C4 | `(402, 112)` | XY negative control | Same via pair, `X+0.001` offset | No | Reconfirms that this offset avoids DH in the showcase board. |
| R8C0 | `(150, 80)` | Slot orientation | X-oriented slot vs Y-oriented slot, same origin | Yes | Slot orientation/figure direction does not suppress DH when origins/spans match. |
| R8C1 | `(186, 80)` | Slot body overlap | Same X-slot pair, second origin at `X+0.20` | No | Overlapping slot bodies did not report when drill origins differ. |
| R8C2 | `(222, 80)` | Slot endpoint/body probe | Same X-slot pair, second origin at `X+0.50` | No | Near-end or partial slot geometry overlap did not report without origin equality. |
| R8C3 | `(258, 80)` | Slot separation control | Same X-slot pair, second origin at `X+0.80` | No | Separated slot bodies do not report. |
| R8C4 | `(294, 80)` | Round in slot body | X-slot plus round drill at `X+0.20` | No | A round drill located inside the slot body did not report without origin equality. |
| R9C0 | `(330, 80)` | Round near slot end | X-slot plus round drill at `X+0.50` | No | Slot/round geometric contact near the slot end did not report without origin equality. |
| R9C1 | `(366, 80)` | Round in Y-slot body | Y-slot plus round drill at `Y+0.20` | No | The same origin rule held for a Y-oriented slot probe. |
| R9C2 | `(402, 80)` | Cross-slot offset | X-slot vs Y-slot, second origin at `X+0.20,Y+0.20` | No | Cross-slot body overlap did not report when origins differ. |
| R9C3 | `(150, 48)` | Cross-slot same origin | X-slot vs Y-slot, same origin | Yes | Cross-slot orientation mismatch still reports when origins/spans match. |
| R9C4 | `(186, 48)` | Cross-slot tiny offset | X-slot vs Y-slot, second origin at `X+0.001` | No | The same `0.001` stored-coordinate separation avoided DH for cross-slot drills. |
| R10C0 | `(222, 48)` | Multi-drill same pattern | 1x2 multi-drill via vs same 1x2 multi-drill via, same origin | Yes | Matching multi-drill pattern and origin reports one DH marker. |
| R10C1 | `(258, 48)` | Multi-drill vs single | 1x2 multi-drill via vs single round via at padstack origin | No | A single drill at the multi-drill padstack origin did not match either member hole. |
| R10C2 | `(294, 48)` | Multi-drill vs single | 1x2 multi-drill via vs single round via offset to the nominal right member hole | No | Single-vs-multi local hole alignment did not report. |
| R10C3 | `(330, 48)` | Multi-drill vs single | 1x2 multi-drill via vs single round via offset to the nominal left member hole | No | Single-vs-multi local hole alignment did not report. |
| R10C4 | `(366, 48)` | Multi-drill partial overlap | 1x2 multi-drill via vs same 1x2 multi-drill via shifted by one pitch | No | Partial multi-drill hole overlap did not report. |
| R10C5 | `(402, 48)` | Multi-drill offset control | 1x2 multi-drill via vs same 1x2 multi-drill via shifted by half pitch | No | Offset multi-drill patterns did not report. |
| R10C6 | `(150, 16)` | Multi-drill vs single | 2x2 multi-drill via vs single round via offset to a nominal corner member hole | No | Single-vs-multi local hole alignment did not report for a 2x2 pattern. |
| R10C7 | `(186, 16)` | Multi-drill pattern mismatch | 2x2 multi-drill via vs 1x2 multi-drill via, same origin | No | Same origin alone was not enough when multi-drill pattern shape differed. |
| M0 | `(222, 16)` | Multi-drill same pattern | 2x2 multi-drill via vs same 2x2 multi-drill via, same origin | Yes | Matching 2x2 multi-drill pattern and origin reports one DH marker. |
| M1 | `(258, 16)` | Multi-drill pitch mismatch | 1x2 pitch-0.50 multi-drill via vs 1x2 pitch-0.60 multi-drill via, same origin | No | Same origin and same row/column count did not report when pitch differed. |
| M2 | `(294, 16)` | Multi-drill partial overlap | 2x2 multi-drill via vs same 2x2 multi-drill via shifted by one X pitch | No | Partial overlap of a multi-drill array did not report. |
| M3 | `(330, 16)` | Multi-drill offset control | 2x2 multi-drill via vs same 2x2 multi-drill via shifted by half pitch in X/Y | No | Offset 2x2 multi-drill patterns did not report. |
| DO0 | `(150, 8)` | Drill offset | `+0.30` drill-offset padstack vs normal padstack at the same via origin | Yes | Same via/padstack instance origin reports even though the physical drill centers differ by the padstack drill offset. |
| DO1 | `(186, 8)` | Drill offset | `+0.30` drill-offset padstack vs normal padstack shifted `X+0.30` so physical drill centers align | No | Matching physical drill centers did not report when via/padstack instance origins differed. |
| DO2 | `(222, 8)` | Drill offset | Two `+0.30` drill-offset padstacks at the same via origin | Yes | Same via origin and same drill offset reports. |
| DO3 | `(258, 8)` | Drill offset | `+0.30` vs `-0.30` drill-offset padstacks with via origins separated by `X+0.60` so physical drill centers align | No | Matching physical drill centers did not report when via origins differed. |
| DO4 | `(294, 8)` | Drill offset | `+0.30` vs `-0.30` drill-offset padstacks at the same via origin | Yes | Same via origin reports even when opposite drill offsets put physical drill centers apart. |
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

## Drill Offset Conclusion

The DO0-DO4 cases use padstacks with `make_axlPadStackDrill(... ?offset ...)` so the physical drill center is offset from the via/padstack instance origin.

- Same via origin reported even when one padstack had `drillOffset +0.30` and the other had no drill offset.
- Same via origin reported for opposite `+0.30` and `-0.30` drill offsets, even though the physical drill centers differ.
- Via origins separated so that the physical drill centers align did not report.

Therefore, for these generated via padstacks, Allegro 24.1 Duplicate Drill Hole appears to key the XY comparison on the via/padstack instance origin, not the drill center after applying padstack `drillOffset`. This refines the earlier "effective drill origin" wording: for normal and slot cases this coincided with the apparent drill origin, but explicit `drillOffset` does not appear to move the DH comparison coordinate.

## Multi-Drill Array Conclusion

The R10/M cases cover Allegro padstacks with `multiDrillData`:

- Identical 1x2 multi-drill padstacks at the same padstack origin report one DH marker.
- Identical 2x2 multi-drill padstacks at the same padstack origin report one DH marker.
- Multi-drill vs single-drill did not report, even when the single via was offset to a nominal member-hole location.
- Identical multi-drill arrays shifted so that only a subset of member holes could overlap did not report.
- Same-origin multi-drill arrays with different pattern shape, or the same 1x2 shape but different pitch, did not report.

Therefore, current evidence suggests Allegro treats a multi-drill padstack as a pattern-level drill definition for DH. It does not appear to expand multi-drill padstacks into independent drill-hole points for single-vs-multi or partial-overlap duplicate checks.

## Current Boundary Model

The observed behavior is best modeled as:

```text
report DH when:
  via/padstack instance XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
  and
  for multi-drill padstacks, the multi-drill pattern definition also matches
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
- Multi-drill partial member-hole overlap without matching padstack origin/pattern.
- Multi-drill pattern mismatch, including pitch mismatch.
- Disjoint drill layer spans.
- Endpoint-only layer-span contact.

## Residual Limits

- The exact internal coordinate quantum is not formally derived from Cadence documentation. Results should be described as database-coordinate behavior, not arbitrary floating-point equality.
- Slot orientation coverage now includes generated X/Y padstack figures, but arbitrary rotated slots from production libraries were not exhaustively swept.
- Multi-drill coverage uses generated circular PTH multi-drill padstacks with 1x2 and 2x2 arrays; staggered arrays and mixed slot multi-drill definitions were not swept.
- A company-library production mounting-hole symbol may still deserve a separate local-library case. The current coverage includes NPTH padstacks and package/real-pin objects.
- Results are from Cadence Allegro PCB Venture 24.1 S001 on this local setup and the copied Cadence demo board stackup.
