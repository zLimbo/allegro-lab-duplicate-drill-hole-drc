; Create layer-span Duplicate Drill Hole DRC test cases in a multilayer board.

(defun dh_span_make_pad (layer size)
  (make_axlPadStackPad
    ?layer layer
    ?type 'REGULAR
    ?figure 'CIRCLE
    ?figureSize size:size
  )
)

(defun dh_span_make_thru_padstack (name drill_diameter)
  (let (drill pad_list pad_size)
    (setq pad_size (plus drill_diameter 0.25))
    (setq drill
      (make_axlPadStackDrill
        ?holeType 'CIRCLE_DRILL
        ?drillDiameter drill_diameter
        ?plating 'PLATED
        ?figure 'CIRCLE
        ?figureSize pad_size:pad_size
      )
    )
    (setq pad_list nil)
    (setq pad_list (cons (dh_span_make_pad "TOP" pad_size) pad_list))
    (setq pad_list (cons (dh_span_make_pad "DEFAULT_INTERNAL" pad_size) pad_list))
    (setq pad_list (cons (dh_span_make_pad "BOTTOM" pad_size) pad_list))
    (axlDBCreatePadStack name drill pad_list t)
  )
)

(defun dh_span_make_bb_padstack (name start_layer end_layer drill_diameter)
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
    (setq pad_list (cons (dh_span_make_pad start_layer pad_size) pad_list))
    (setq pad_list (cons (dh_span_make_pad end_layer pad_size) pad_list))
    (axlDBCreatePadStack name drill pad_list t)
  )
)

(defun dh_span_create_pair (fp case_id pad_a pad_b x y expected notes)
  (let (via_a via_b)
    (setq via_a (axlDBCreateVia pad_a x:y "NET_A"))
    (setq via_b (axlDBCreateVia pad_b x:y "NET_A"))
    (fprintf fp "%s,%s,%s,%L,%L,%g,%g,%s,%s\n"
      case_id pad_a pad_b via_a via_b x y expected notes)
    (list via_a via_b)
  )
)

(defun dh_auto_span_cases_main (save_path log_path)
  (let (fp)
    (setq fp (outfile log_path))
    (when fp
      (fprintf fp "case_id,padstack_a,padstack_b,via_a,via_b,x_mil_or_mm,y_mil_or_mm,expected_dh_initial,notes\n")
      (axlDBCreateNet "NET_A")
      (axlCNSDesignModeSet 'Duplicate_Drill_Hole 'on)

      (dh_span_make_thru_padstack "DH_SPAN_THRU" 0.25)
      (dh_span_make_bb_padstack "DH_SPAN_TOP_GND" "TOP" "GND" 0.25)
      (dh_span_make_bb_padstack "DH_SPAN_TOP_INNER1" "TOP" "INNER1" 0.25)
      (dh_span_make_bb_padstack "DH_SPAN_INNER1_BOTTOM" "INNER1" "BOTTOM" 0.25)

      (dh_span_create_pair fp "SP001" "DH_SPAN_THRU" "DH_SPAN_THRU" 540.0 260.0 "YES" "through_vs_through_same_xy")
      (dh_span_create_pair fp "SP002" "DH_SPAN_TOP_GND" "DH_SPAN_TOP_GND" 545.0 260.0 "YES" "top_gnd_vs_top_gnd_same_xy")
      (dh_span_create_pair fp "SP003" "DH_SPAN_THRU" "DH_SPAN_TOP_GND" 550.0 260.0 "NO" "through_vs_top_gnd_same_xy")
      (dh_span_create_pair fp "SP004" "DH_SPAN_TOP_GND" "DH_SPAN_TOP_INNER1" 555.0 260.0 "NO" "top_gnd_vs_top_inner1_same_xy")
      (dh_span_create_pair fp "SP005" "DH_SPAN_TOP_INNER1" "DH_SPAN_INNER1_BOTTOM" 560.0 260.0 "NO" "overlap_at_inner1_but_different_span")

      (close fp)
    )
    (axlSaveDesign ?design save_path ?noConfirm t)
    t
  )
)
