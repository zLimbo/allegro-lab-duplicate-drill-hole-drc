; Build a visual Duplicate Drill Hole DRC showcase board.
; Opens on a copied Cadence demo multilayer board.

(defun dhs_text (txt x y)
  (let (orient)
    (setq orient
      (make_axlTextOrientation
        ?textBlock "4"
        ?rotation 0.0
        ?mirrored nil
        ?justify "center"
      )
    )
    (axlDBCreateText txt x:y orient "BOARD GEOMETRY/DIMENSION" nil)
  )
)

(defun dhs_text_left (txt x y)
  (let (orient)
    (setq orient
      (make_axlTextOrientation
        ?textBlock "3"
        ?rotation 0.0
        ?mirrored nil
        ?justify "left"
      )
    )
    (axlDBCreateText txt x:y orient "BOARD GEOMETRY/DIMENSION" nil)
  )
)

(defun dhs_disable_other_drc ()
  (axlCNSSpacingModeSet 'all 'off)
  (axlCNSSameNetModeSet 'all 'off)
  (axlCNSPhysicalModeSet 'all 'off)
  (axlCNSAssemblyModeSet 'all 'off)
  (axlCNSEcsetModeSet 'all 'off)
  (axlCNSDesignModeSet 'all 'off)
  (axlCNSDesignModeSet 'Duplicate_Drill_Hole 'on)
)

(defun dhs_clear_route_restrictions ()
  (let (layers)
    (setq layers
      (list
        "ROUTE KEEPIN/ALL"
        "ROUTE KEEPIN/TOP"
        "ROUTE KEEPIN/GND"
        "ROUTE KEEPIN/INNER1"
        "ROUTE KEEPIN/INNER2"
        "ROUTE KEEPIN/POWER"
        "ROUTE KEEPIN/BOTTOM"
        "ROUTE KEEPOUT/ALL"
        "ROUTE KEEPOUT/TOP"
        "ROUTE KEEPOUT/GND"
        "ROUTE KEEPOUT/INNER1"
        "ROUTE KEEPOUT/INNER2"
        "ROUTE KEEPOUT/POWER"
        "ROUTE KEEPOUT/BOTTOM"
      )
    )
    (axlDeleteByLayer layers 'fixed)
  )
)

(defun dhs_make_round_padstack (name drill_diameter plating)
  (let (drill pad_list pad_size)
    (setq pad_size (plus drill_diameter 0.25))
    (setq drill
      (make_axlPadStackDrill
        ?holeType 'CIRCLE_DRILL
        ?drillDiameter drill_diameter
        ?plating plating
        ?figure 'CIRCLE
        ?figureSize pad_size:pad_size
      )
    )
    (setq pad_list nil)
    (setq pad_list (cons (make_axlPadStackPad ?layer "TOP" ?type 'REGULAR ?figure 'CIRCLE ?figureSize pad_size:pad_size) pad_list))
    (setq pad_list (cons (make_axlPadStackPad ?layer "DEFAULT_INTERNAL" ?type 'REGULAR ?figure 'CIRCLE ?figureSize pad_size:pad_size) pad_list))
    (setq pad_list (cons (make_axlPadStackPad ?layer "BOTTOM" ?type 'REGULAR ?figure 'CIRCLE ?figureSize pad_size:pad_size) pad_list))
    (axlDBCreatePadStack name drill pad_list t)
  )
)

(defun dhs_make_custom_padstack (name drill_diameter plating top_figure top_x top_y inner_figure inner_x inner_y bottom_figure bottom_x bottom_y)
  (let (drill pad_list drill_pad)
    (setq drill_pad (plus drill_diameter 0.25))
    (setq drill
      (make_axlPadStackDrill
        ?holeType 'CIRCLE_DRILL
        ?drillDiameter drill_diameter
        ?plating plating
        ?figure 'CIRCLE
        ?figureSize drill_pad:drill_pad
      )
    )
    (setq pad_list nil)
    (setq pad_list (cons (make_axlPadStackPad ?layer "TOP" ?type 'REGULAR ?figure top_figure ?figureSize top_x:top_y) pad_list))
    (setq pad_list (cons (make_axlPadStackPad ?layer "DEFAULT_INTERNAL" ?type 'REGULAR ?figure inner_figure ?figureSize inner_x:inner_y) pad_list))
    (setq pad_list (cons (make_axlPadStackPad ?layer "BOTTOM" ?type 'REGULAR ?figure bottom_figure ?figureSize bottom_x:bottom_y) pad_list))
    (axlDBCreatePadStack name drill pad_list t)
  )
)

(defun dhs_make_slot_padstack (name slot_width slot_height plating)
  (let (drill pad_list pad_x pad_y)
    (setq pad_x (plus slot_height 0.25))
    (setq pad_y (plus slot_width 0.25))
    (setq drill
      (make_axlPadStackDrill
        ?holeType 'OVAL_SLOT
        ?slotSize (list slot_width slot_height)
        ?plating plating
        ?figure 'OBLONG_X
        ?figureSize slot_height:slot_width
      )
    )
    (setq pad_list nil)
    (setq pad_list (cons (make_axlPadStackPad ?layer "TOP" ?type 'REGULAR ?figure 'OBLONG_X ?figureSize pad_x:pad_y) pad_list))
    (setq pad_list (cons (make_axlPadStackPad ?layer "DEFAULT_INTERNAL" ?type 'REGULAR ?figure 'OBLONG_X ?figureSize pad_x:pad_y) pad_list))
    (setq pad_list (cons (make_axlPadStackPad ?layer "BOTTOM" ?type 'REGULAR ?figure 'OBLONG_X ?figureSize pad_x:pad_y) pad_list))
    (axlDBCreatePadStack name drill pad_list t)
  )
)

(defun dhs_make_bb_padstack (name start_layer end_layer drill_diameter)
  (let (drill pad_list pad_size)
    (setq pad_size (plus drill_diameter 0.25))
    (setq drill
      (make_axlPadStackDrill
        ?usage "bbvia"
        ?holeType 'CIRCLE_DRILL
        ?drillDiameter drill_diameter
        ?plating 'PLATED
        ?spanLockCount t
        ?figure 'CIRCLE
        ?figureSize pad_size:pad_size
      )
    )
    (setq pad_list nil)
    (setq pad_list (cons (make_axlPadStackPad ?layer start_layer ?type 'REGULAR ?figure 'CIRCLE ?figureSize pad_size:pad_size) pad_list))
    (setq pad_list (cons (make_axlPadStackPad ?layer end_layer ?type 'REGULAR ?figure 'CIRCLE ?figureSize pad_size:pad_size) pad_list))
    (axlDBCreatePadStack name drill pad_list t)
  )
)

(defun dhs_setup_padstacks ()
  (dhs_make_round_padstack "DHS_RND_PTH_025" 0.25 'PLATED)
  (dhs_make_round_padstack "DHS_RND_PTH_025_ALT" 0.25 'PLATED)
  (dhs_make_custom_padstack "DHS_PAD_SMALL_SAME_DRILL" 0.25 'PLATED 'CIRCLE 0.38 0.38 'CIRCLE 0.38 0.38 'CIRCLE 0.38 0.38)
  (dhs_make_custom_padstack "DHS_PAD_LARGE_SAME_DRILL" 0.25 'PLATED 'CIRCLE 0.90 0.90 'CIRCLE 0.90 0.90 'CIRCLE 0.90 0.90)
  (dhs_make_custom_padstack "DHS_PAD_SQUARE_SAME_DRILL" 0.25 'PLATED 'SQUARE 0.70 0.70 'SQUARE 0.70 0.70 'SQUARE 0.70 0.70)
  (dhs_make_custom_padstack "DHS_PAD_OBLONG_SAME_DRILL" 0.25 'PLATED 'OBLONG_X 0.95 0.45 'OBLONG_X 0.95 0.45 'OBLONG_X 0.95 0.45)
  (dhs_make_custom_padstack "DHS_PAD_TOP_SMALL_BOT_LARGE" 0.25 'PLATED 'CIRCLE 0.38 0.38 'CIRCLE 0.60 0.60 'CIRCLE 0.90 0.90)
  (dhs_make_custom_padstack "DHS_PAD_TOP_LARGE_BOT_SMALL" 0.25 'PLATED 'CIRCLE 0.90 0.90 'CIRCLE 0.60 0.60 'CIRCLE 0.38 0.38)
  (dhs_make_round_padstack "DHS_RND_PTH_010" 0.10 'PLATED)
  (dhs_make_round_padstack "DHS_RND_PTH_050" 0.50 'PLATED)
  (dhs_make_round_padstack "DHS_RND_NPTH_025" 0.25 'NON_PLATED)
  (dhs_make_slot_padstack "DHS_SLOT_PTH_025X075" 0.25 0.75 'PLATED)
  (dhs_make_slot_padstack "DHS_SLOT_PTH_035X075" 0.35 0.75 'PLATED)
  (dhs_make_bb_padstack "DHS_TOP_GND" "TOP" "GND" 0.25)
  (dhs_make_bb_padstack "DHS_TOP_INNER1" "TOP" "INNER1" 0.25)
  (dhs_make_bb_padstack "DHS_INNER1_BOTTOM" "INNER1" "BOTTOM" 0.25)
  (dhs_make_bb_padstack "DHS_GND_INNER2" "GND" "INNER2" 0.25)
  (dhs_make_bb_padstack "DHS_INNER2_BOTTOM" "INNER2" "BOTTOM" 0.25)
  (dhs_make_bb_padstack "DHS_GND_POWER" "GND" "POWER" 0.25)
  (dhs_make_bb_padstack "DHS_POWER_BOTTOM" "POWER" "BOTTOM" 0.25)
)

(defun dhs_net (name)
  (axlDBCreateNet name)
)

(defun dhs_cell_xy (col row)
  (list (plus 170.0 (times col 52.0)) (difference 240.0 (times row 38.0)))
)

(defun dhs_via_pair (fp cell_id col row pad_a pad_b net_a net_b label)
  (let (xy x y via_a via_b)
    (setq xy (dhs_cell_xy col row))
    (setq x (car xy))
    (setq y (cadr xy))
    (setq via_a (axlDBCreateVia pad_a x:y net_a))
    (setq via_b (axlDBCreateVia pad_b x:y net_b))
    (dhs_text cell_id x (plus y 8.0))
    (dhs_text label x (plus y 5.0))
    (fprintf fp "%s,%g,%g,%s,%s,%L,%L,%s\n" cell_id x y pad_a pad_b via_a via_b label)
    (list via_a via_b)
  )
)

(defun dhs_offset_pair (fp cell_id col row dx dy label)
  (let (xy x y via_a via_b)
    (setq xy (dhs_cell_xy col row))
    (setq x (car xy))
    (setq y (cadr xy))
    (setq via_a (axlDBCreateVia "DHS_RND_PTH_025" x:y "DHS_A"))
    (setq via_b (axlDBCreateVia "DHS_RND_PTH_025" (plus x dx):(plus y dy) "DHS_A"))
    (dhs_text cell_id x (plus y 8.0))
    (dhs_text label x (plus y 5.0))
    (fprintf fp "%s,%g,%g,DHS_RND_PTH_025,DHS_RND_PTH_025,%L,%L,%s\n" cell_id x y via_a via_b label)
    (list via_a via_b)
  )
)

(defun dhs_via_triple (fp cell_id col row label)
  (let (xy x y via_a via_b via_c)
    (setq xy (dhs_cell_xy col row))
    (setq x (car xy))
    (setq y (cadr xy))
    (setq via_a (axlDBCreateVia "DHS_RND_PTH_025" x:y "DHS_A"))
    (setq via_b (axlDBCreateVia "DHS_RND_PTH_025_ALT" x:y "DHS_A"))
    (setq via_c (axlDBCreateVia "DHS_RND_PTH_050" x:y "DHS_B"))
    (dhs_text cell_id x (plus y 8.0))
    (dhs_text label x (plus y 5.0))
    (fprintf fp "%s,%g,%g,TRIPLE_VIA,DHS_RND_PTH_025+ALT+050,%L,%L;%L,%s\n" cell_id x y via_a via_b via_c label)
    (list via_a via_b via_c)
  )
)

(defun dhs_find_thru_pin ()
  (let (design comps comp pins pin found)
    (setq design (axlDBGetDesign))
    (setq comps design->components)
    (setq found nil)
    (foreach comp comps
      (unless found
        (setq pins comp->pins)
        (foreach pin pins
          (unless found
            (when (and pin->definition pin->definition->isThrough)
              (setq found pin)
            )
          )
        )
      )
    )
    found
  )
)

(defun dhs_pin_via_case (fp cell_id col row label)
  (let (xy x y sym pins pin via netname)
    (setq xy (dhs_cell_xy col row))
    (setq x (car xy))
    (setq y (cadr xy))
    ; Prefer a normal package pin so the showcase cell does not add mechanical-spacing DRCs.
    (setq sym (car (axlDBCreateSymbol (list "DIP14_3" "PACKAGE") (difference x 7.62):(plus y 15.24))))
    (unless sym
      (setq sym (car (axlDBCreateSymbol (list "mtg156" "MECHANICAL") x:y)))
    )
    (when sym
      (setq pins sym->pins)
      (setq pin (car pins))
      (when pin
        (setq netname nil)
        (when pin->net
          (setq netname pin->net->name)
        )
        (setq via (axlDBCreateVia "VIA" pin->xy netname))
        (dhs_text cell_id (car pin->xy) (plus (cadr pin->xy) 8.0))
        (dhs_text label (car pin->xy) (plus (cadr pin->xy) 5.0))
        (fprintf fp "%s,%g,%g,PIN,VIA,%L,%L,%s\n" cell_id (car pin->xy) (cadr pin->xy) pin via label)
      )
    )
  )
)

(defun dhs_pin_via_case_net (fp cell_id col row via_net label)
  (let (xy x y sym pins pin via)
    (setq xy (dhs_cell_xy col row))
    (setq x (car xy))
    (setq y (cadr xy))
    (setq sym (car (axlDBCreateSymbol (list "DIP14_3" "PACKAGE") (difference x 7.62):(plus y 15.24))))
    (when sym
      (setq pins sym->pins)
      (setq pin (car pins))
      (when pin
        (setq via (axlDBCreateVia "VIA" pin->xy via_net))
        (dhs_text cell_id (car pin->xy) (plus (cadr pin->xy) 8.0))
        (dhs_text label (car pin->xy) (plus (cadr pin->xy) 5.0))
        (fprintf fp "%s,%g,%g,PIN,VIA,%L,%L,%s\n" cell_id (car pin->xy) (cadr pin->xy) pin via label)
      )
    )
  )
)

(defun dhs_real_pin_via_case (fp cell_id col row label)
  (let (xy x y pin via netname)
    (setq pin (dhs_find_thru_pin))
    (setq xy (dhs_cell_xy col row))
    (setq x (car xy))
    (setq y (cadr xy))
    (when pin
      (setq netname nil)
      (when pin->net
        (setq netname pin->net->name)
      )
      (setq via (axlDBCreateVia "VIA" pin->xy netname))
      (dhs_text cell_id (car pin->xy) (plus (cadr pin->xy) 8.0))
      (dhs_text label (car pin->xy) (plus (cadr pin->xy) 5.0))
      (fprintf fp "%s,%g,%g,REAL_PIN,VIA,%L,%L,%s\n" cell_id (car pin->xy) (cadr pin->xy) pin via label)
    )
  )
)

(defun dhs_header ()
  (dhs_text_left "Duplicate Drill Hole DRC Showcase - only Duplicate_Drill_Hole mode enabled" 148.0 268.0)
  (dhs_text_left "Grid labels show case type. Open DRC report/markers to inspect pairs." 148.0 262.0)
  (dhs_text_left "Important: exact span equality is NOT required; overlapping drill spans can report." 148.0 256.0)
)

(defun dhs_main (save_path log_path)
  (let (fp)
    (axlUnfixAll)
    (dhs_clear_route_restrictions)
    (dhs_disable_other_drc)
    (dhs_setup_padstacks)
    (dhs_net "DHS_A")
    (dhs_net "DHS_B")
    (dhs_header)
    (setq fp (outfile log_path))
    (when fp
      (fprintf fp "cell_id,x,y,obj_a,obj_b,dbid_a,dbid_b,label\n")
      (dhs_via_pair fp "R0C0" 0 0 "DHS_RND_PTH_025" "DHS_RND_PTH_025" "DHS_A" "DHS_A" "via-via same")
      (dhs_pin_via_case fp "R0C1" 1 0 "via-pin real pin")
      (dhs_via_pair fp "R0C2" 2 0 "DHS_RND_PTH_025" "DHS_RND_PTH_025_ALT" "DHS_A" "DHS_A" "diff padstack")
      (dhs_via_pair fp "R0C3" 3 0 "DHS_RND_PTH_025" "DHS_RND_PTH_050" "DHS_A" "DHS_A" "diff hole dia")
      (dhs_via_pair fp "R0C4" 4 0 "DHS_RND_PTH_025" "DHS_RND_NPTH_025" "DHS_A" nil "PTH vs NPTH")

      (dhs_via_pair fp "R1C0" 0 1 "DHS_RND_PTH_025" "DHS_RND_PTH_025" "DHS_A" "DHS_B" "diff nets")
      (dhs_via_pair fp "R1C1" 1 1 "DHS_RND_PTH_025" "DHS_RND_PTH_025" "DHS_A" nil "one no-net")
      (dhs_via_pair fp "R1C2" 2 1 "DHS_RND_PTH_025" "DHS_SLOT_PTH_025X075" "DHS_A" nil "round vs slot")
      (dhs_via_pair fp "R1C3" 3 1 "DHS_SLOT_PTH_025X075" "DHS_SLOT_PTH_025X075" nil nil "slot-slot")
      (dhs_offset_pair fp "R1C4" 4 1 0.01 0.0 "NO DH: XY offset")

      (dhs_via_pair fp "R2C0" 0 2 "DHS_TOP_GND" "DHS_TOP_GND" "DHS_A" "DHS_A" "same bb span")
      (dhs_via_pair fp "R2C1" 1 2 "DHS_RND_PTH_025" "DHS_TOP_GND" "DHS_A" "DHS_A" "thru vs bb overlap")
      (dhs_via_pair fp "R2C2" 2 2 "DHS_TOP_GND" "DHS_TOP_INNER1" "DHS_A" "DHS_A" "overlap spans")
      (dhs_via_pair fp "R2C3" 3 2 "DHS_TOP_INNER1" "DHS_INNER1_BOTTOM" "DHS_A" "DHS_A" "NO DH: endpoint")
      (dhs_offset_pair fp "R2C4" 4 2 0.0 0.01 "NO DH: Y offset")

      (dhs_via_triple fp "R3C0" 0 3 "3 vias same XY")
      (dhs_offset_pair fp "R3C1" 1 3 0.001 0.0 "probe: X+0.001")
      (dhs_offset_pair fp "R3C2" 2 3 0.0001 0.0 "probe: X+0.0001")
      (dhs_via_pair fp "R3C3" 3 3 "DHS_RND_NPTH_025" "DHS_RND_NPTH_025" nil nil "NPTH-NPTH")
      (dhs_via_pair fp "R3C4" 4 3 "DHS_SLOT_PTH_025X075" "DHS_SLOT_PTH_035X075" nil nil "diff slot size")

      (dhs_via_pair fp "R4C0" 0 4 "DHS_TOP_GND" "DHS_INNER2_BOTTOM" "DHS_A" "DHS_A" "NO DH: disjoint span")
      (dhs_via_pair fp "R4C1" 1 4 "DHS_TOP_GND" "DHS_GND_INNER2" "DHS_A" "DHS_A" "touch at GND")
      (dhs_via_pair fp "R4C2" 2 4 "DHS_GND_INNER2" "DHS_INNER2_BOTTOM" "DHS_A" "DHS_A" "touch at INNER2")
      (dhs_via_pair fp "R4C3" 3 4 "DHS_GND_POWER" "DHS_INNER2_BOTTOM" "DHS_A" "DHS_A" "span overlap")
      (dhs_via_pair fp "R4C4" 4 4 "DHS_TOP_INNER1" "DHS_POWER_BOTTOM" "DHS_A" "DHS_A" "NO DH: split span")

      (dhs_pin_via_case_net fp "R5C0" 0 5 "DHS_A" "pin-via diff net")
      (dhs_pin_via_case_net fp "R5C1" 1 5 nil "pin-via no-net via")
      (dhs_via_pair fp "R5C2" 2 5 "DHS_RND_PTH_010" "DHS_RND_PTH_050" "DHS_A" "DHS_A" "tiny vs large drill")
      (dhs_via_pair fp "R5C3" 3 5 "DHS_RND_PTH_025" "DHS_RND_PTH_025" nil nil "both no-net vias")
      (dhs_via_pair fp "R5C4" 4 5 "DHS_RND_PTH_025" "DHS_POWER_BOTTOM" "DHS_A" "DHS_A" "thru vs lower bb")

      (dhs_via_pair fp "R6C0" 0 6 "DHS_PAD_SMALL_SAME_DRILL" "DHS_PAD_LARGE_SAME_DRILL" "DHS_A" "DHS_A" "same drill diff pad size")
      (dhs_via_pair fp "R6C1" 1 6 "DHS_RND_PTH_025" "DHS_PAD_LARGE_SAME_DRILL" "DHS_A" "DHS_A" "std vs large pad")
      (dhs_via_pair fp "R6C2" 2 6 "DHS_RND_PTH_025" "DHS_PAD_SMALL_SAME_DRILL" "DHS_A" "DHS_A" "std vs small pad")
      (dhs_via_pair fp "R6C3" 3 6 "DHS_PAD_SQUARE_SAME_DRILL" "DHS_RND_PTH_025" "DHS_A" "DHS_A" "round vs square pad")
      (dhs_via_pair fp "R6C4" 4 6 "DHS_PAD_OBLONG_SAME_DRILL" "DHS_RND_PTH_025" "DHS_A" "DHS_A" "round vs oblong pad")

      (dhs_via_pair fp "R7C0" 0 7 "DHS_PAD_SQUARE_SAME_DRILL" "DHS_PAD_OBLONG_SAME_DRILL" "DHS_A" "DHS_A" "square vs oblong pad")
      (dhs_via_pair fp "R7C1" 1 7 "DHS_PAD_TOP_SMALL_BOT_LARGE" "DHS_PAD_TOP_LARGE_BOT_SMALL" "DHS_A" "DHS_A" "layer pad swap")
      (dhs_via_pair fp "R7C2" 2 7 "DHS_PAD_SMALL_SAME_DRILL" "DHS_PAD_LARGE_SAME_DRILL" "DHS_A" "DHS_B" "diff pad size diff net")
      (dhs_via_pair fp "R7C3" 3 7 "DHS_PAD_SQUARE_SAME_DRILL" "DHS_PAD_OBLONG_SAME_DRILL" nil nil "pad shape no-net")
      (dhs_offset_pair fp "R7C4" 4 7 0.001 0.0 "pad control X+0.001")
      (dhs_real_pin_via_case fp "PIN-A" 0 3 "real pin-via")
      (close fp)
    )
    (dhs_clear_route_restrictions)
    (dhs_disable_other_drc)
    (axlSaveDesign ?design save_path ?noConfirm t)
    t
  )
)
