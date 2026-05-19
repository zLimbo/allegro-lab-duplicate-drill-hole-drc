# Allegro 25.1 Validation

Run date: 2026-05-13

Cadence tool path:

```text
C:\Cadence\SPB_25.1\tools\bin
```

Observed Allegro version:

```text
Allegro PCB Venture 25.1 S030 Windows SPB 64-bit Edition
```

## Scope

This run validates whether the existing 24.1 Duplicate Drill Hole lab cases and conclusions still hold in Allegro 25.1.

The 25.1 run used the Cadence 25.1 demo board template:

```text
C:\Cadence\SPB_25.1\share\pcb\examples\board_design\Cadence_Demo.brd
```

## Generated Files

Main showcase:

- `allegro/dh_duplicate_drill_showcase_25_1.brd`
- `allegro/dh_duplicate_drill_showcase_25_1.drc_only.brd`
- `reports/dh_duplicate_drill_showcase_25_1.drc.rpt`
- `results/dh_duplicate_drill_showcase_25_1.parsed_dh.csv`
- `results/dh_duplicate_drill_showcase_25_1.parsed_all.csv`
- `results/dh_showcase_objects_25_1.csv`

Item-item interaction:

- `allegro/dh_item_item_interaction.dh_only_25_1.brd`
- `allegro/dh_item_item_interaction.dh_only_25_1.drc_only.brd`
- `reports/dh_item_item_interaction.dh_only_25_1.drc.rpt`
- `results/dh_item_item_interaction.dh_only_25_1.parsed_dh.csv`
- `results/dh_item_item_interaction.dh_only_25_1.parsed_all.csv`
- `results/dh_item_item_interaction.dh_only_25_1.objects.csv`
- `allegro/dh_item_item_interaction.plus_item_item_25_1.brd`
- `allegro/dh_item_item_interaction.plus_item_item_25_1.drc_only.brd`
- `reports/dh_item_item_interaction.plus_item_item_25_1.drc.rpt`
- `results/dh_item_item_interaction.plus_item_item_25_1.parsed_dh.csv`
- `results/dh_item_item_interaction.plus_item_item_25_1.parsed_all.csv`
- `results/dh_item_item_interaction.plus_item_item_25_1.objects.csv`

Replay scripts:

- `scripts/dh_showcase_board_25_1.scr`
- `scripts/dh_item_item_interaction_dh_only_25_1.scr`
- `scripts/dh_item_item_interaction_plus_25_1.scr`

## Results

Main showcase:

- 25.1 detailed DRC rows: 47
- 25.1 `Duplicate Drill Hole` rows: 47
- Compared against 24.1, the DH marker-location multiset is identical.
- Compared against 24.1, the full detailed pair rows are identical when keyed by constraint name, marker location, element 1, and element 2.

Item-item `dh_only` board:

- 25.1 detailed DRC rows: 4
- 25.1 `Duplicate Drill Hole` rows: 4
- Compared against 24.1, the DH marker-location multiset is identical.
- Constraint counts are identical.

Item-item `plus_item_item` board:

- 25.1 detailed DRC rows: 28
- 25.1 `Duplicate Drill Hole` rows: 4
- 25.1 `Thru Via to Thru Via Spacing` rows: 18
- 25.1 `Pad/Pad Direct Connect` rows: 6
- Compared against 24.1, the DH marker-location multiset is identical.
- Constraint counts are identical.

## Difference Observed

The only observed difference is the marker location for the six `Pad/Pad Direct Connect` rows in the item-item `plus_item_item` board.

In 24.1, those six rows were reported at:

```text
(294.300 240.000)
```

In 25.1, the same six rows, with the same subclasses and same element pair, are reported at:

```text
(294.000 240.000)
```

The involved pair is unchanged:

```text
Via "Dhii_Rnd_025_Pad090  (294.000 240.000) (Dhii_A)"
Via "Dhii_Rnd_025_Pad090  (294.300 240.000) (Dhii_A)"
```

This appears to be a marker placement/report-location difference for `Pad/Pad Direct Connect`, not a change in Duplicate Drill Hole behavior.

## Conclusion

The existing Duplicate Drill Hole conclusions still hold in Allegro PCB Venture 25.1 S030 for the tested cases.

The current boundary model remains valid:

```text
report DH when:
  via/padstack instance XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
```

The tested non-factors also remain non-factors in 25.1: padstack name, copper pad size, copper pad shape, drill diameter, plating, round/slot style, slot size, slot X/Y orientation, object type, net name, and no-net status.

The drill-offset and multi-drill interpretations also remain valid for the tested generated cases. The item-item DRC conclusion also remains valid: Duplicate Drill Hole does not suppress different-net via-via spacing, and `Pad/Pad Direct Connect` remains separately reportable for the offset same-net overlap control.
