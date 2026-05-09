; Create via-only Duplicate Drill Hole DRC test cases in the open board.

(defun dh_log_line (fp text)
  (fprintf fp "%s\n" text)
)

(defun dh_make_round_padstack (name drill_diameter plating)
  (let (drill pad_list pad)
    (setq drill
      (make_axlPadStackDrill
        ?holeType 'CIRCLE_DRILL
        ?drillDiameter drill_diameter
        ?plating plating
        ?figure 'CIRCLE
        ?figureSize (plus drill_diameter 10.0):(plus drill_diameter 10.0)
      )
    )
    (setq pad_list nil)
    (setq pad
      (make_axlPadStackPad
        ?layer "TOP"
        ?type 'REGULAR
        ?figure 'CIRCLE
        ?figureSize (plus drill_diameter 20.0):(plus drill_diameter 20.0)
      )
    )
    (setq pad_list (cons pad pad_list))
    (setq pad
      (make_axlPadStackPad
        ?layer "DEFAULT_INTERNAL"
        ?type 'REGULAR
        ?figure 'CIRCLE
        ?figureSize (plus drill_diameter 18.0):(plus drill_diameter 18.0)
      )
    )
    (setq pad_list (cons pad pad_list))
    (setq pad
      (make_axlPadStackPad
        ?layer "BOTTOM"
        ?type 'REGULAR
        ?figure 'CIRCLE
        ?figureSize (plus drill_diameter 20.0):(plus drill_diameter 20.0)
      )
    )
    (setq pad_list (cons pad pad_list))
    (axlDBCreatePadStack name drill pad_list t)
  )
)

(defun dh_make_slot_padstack (name slot_width slot_height plating)
  (let (drill pad_list pad_size)
    (setq pad_size (plus slot_height 20.0))
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
    (setq pad_list
      (cons
        (make_axlPadStackPad
          ?layer "TOP"
          ?type 'REGULAR
          ?figure 'OBLONG_X
          ?figureSize pad_size:(plus slot_width 20.0)
        )
        pad_list
      )
    )
    (setq pad_list
      (cons
        (make_axlPadStackPad
          ?layer "DEFAULT_INTERNAL"
          ?type 'REGULAR
          ?figure 'OBLONG_X
          ?figureSize pad_size:(plus slot_width 20.0)
        )
        pad_list
      )
    )
    (setq pad_list
      (cons
        (make_axlPadStackPad
          ?layer "BOTTOM"
          ?type 'REGULAR
          ?figure 'OBLONG_X
          ?figureSize pad_size:(plus slot_width 20.0)
        )
        pad_list
      )
    )
    (axlDBCreatePadStack name drill pad_list t)
  )
)

(defun dh_create_padstacks ()
  (dh_make_round_padstack "DH_RND_PTH_10" 10.0 'PLATED)
  (dh_make_round_padstack "DH_RND_PTH_10_ALT" 10.0 'PLATED)
  (dh_make_round_padstack "DH_RND_PTH_20" 20.0 'PLATED)
  (dh_make_round_padstack "DH_RND_NPTH_10" 10.0 'NON_PLATED)
  (dh_make_slot_padstack "DH_SLOT_PTH_10X30" 10.0 30.0 'PLATED)
)

(defun dh_create_nets ()
  (axlDBCreateNet "NET_A")
  (axlDBCreateNet "NET_B")
)

(defun dh_enable_duplicate_drill_hole ()
  (axlCNSDesignModeSet 'Duplicate_Drill_Hole 'on)
)

(defun dh_create_via_pair (fp case_id pad_a pad_b net_a net_b x y dx dy expected notes)
  (let (via_a via_b bx by)
    (setq bx (plus x dx))
    (setq by (plus y dy))
    (setq via_a (axlDBCreateVia pad_a x:y net_a))
    (setq via_b (axlDBCreateVia pad_b bx:by net_b))
    (fprintf fp "%s,%s,%s,%L,%L,%g,%g,%g,%g,%s,%s\n"
      case_id pad_a pad_b via_a via_b x y bx by expected notes)
    (list via_a via_b)
  )
)

(defun dh_auto_via_cases_main (save_path log_path)
  (let (fp)
    (setq fp (outfile log_path))
    (when fp
      (dh_log_line fp "case_id,padstack_a,padstack_b,via_a,via_b,x_a_mil,y_a_mil,x_b_mil,y_b_mil,expected_dh_initial,notes")
      (dh_create_padstacks)
      (dh_create_nets)
      (dh_enable_duplicate_drill_hole)

      ; Positive control: same XY, same span, same padstack.
      (dh_create_via_pair fp "TC001" "DH_RND_PTH_10" "DH_RND_PTH_10" "NET_A" "NET_A" 1000.0 1000.0 0.0 0.0 "YES" "same_xy_same_padstack_same_net")

      ; Different padstack, same drill.
      (dh_create_via_pair fp "TC005" "DH_RND_PTH_10" "DH_RND_PTH_10_ALT" "NET_A" "NET_A" 1500.0 1000.0 0.0 0.0 "YES" "different_padstack_name_same_drill")

      ; Different hole diameter.
      (dh_create_via_pair fp "TC006" "DH_RND_PTH_10" "DH_RND_PTH_20" "NET_A" "NET_A" 2000.0 1000.0 0.0 0.0 "YES" "different_hole_diameter")

      ; Different plating.
      (dh_create_via_pair fp "TC007" "DH_RND_PTH_10" "DH_RND_NPTH_10" "NET_A" nil 2500.0 1000.0 0.0 0.0 "TBD" "pth_vs_npth_via_standalone")

      ; Round drill vs slot, and slot vs slot.
      (dh_create_via_pair fp "TC008" "DH_RND_PTH_10" "DH_SLOT_PTH_10X30" "NET_A" nil 2600.0 1000.0 0.0 0.0 "TBD" "round_vs_slot_same_origin")
      (dh_create_via_pair fp "TC009" "DH_SLOT_PTH_10X30" "DH_SLOT_PTH_10X30" nil nil 2700.0 1000.0 0.0 0.0 "TBD" "slot_vs_slot_same_origin")

      ; Different nets.
      (dh_create_via_pair fp "TC012" "DH_RND_PTH_10" "DH_RND_PTH_10" "NET_A" "NET_B" 3000.0 1000.0 0.0 0.0 "YES" "different_nets")

      ; One no-net.
      (dh_create_via_pair fp "TC013" "DH_RND_PTH_10" "DH_RND_PTH_10" "NET_A" nil 3500.0 1000.0 0.0 0.0 "TBD" "one_no_net")

      ; Coordinate tolerance sweep. Current probe reports 0.01 mil display accuracy.
      (dh_create_via_pair fp "TC014" "DH_RND_PTH_10" "DH_RND_PTH_10" "NET_A" "NET_A" 1000.0 1500.0 0.000001 0.0 "NO" "dx_0_000001_mil")
      (dh_create_via_pair fp "TC015" "DH_RND_PTH_10" "DH_RND_PTH_10" "NET_A" "NET_A" 1500.0 1500.0 0.00001 0.0 "NO" "dx_0_00001_mil")
      (dh_create_via_pair fp "TC016" "DH_RND_PTH_10" "DH_RND_PTH_10" "NET_A" "NET_A" 2000.0 1500.0 0.0001 0.0 "NO" "dx_0_0001_mil")
      (dh_create_via_pair fp "TC017" "DH_RND_PTH_10" "DH_RND_PTH_10" "NET_A" "NET_A" 2500.0 1500.0 0.001 0.0 "NO" "dx_0_001_mil")
      (dh_create_via_pair fp "TC018" "DH_RND_PTH_10" "DH_RND_PTH_10" "NET_A" "NET_A" 3000.0 1500.0 0.01 0.0 "NO" "dx_0_01_mil")
      (dh_create_via_pair fp "TC019" "DH_RND_PTH_10" "DH_RND_PTH_10" "NET_A" "NET_A" 3500.0 1500.0 0.0 0.01 "NO" "dy_0_01_mil")

      (close fp)
    )
    (axlSaveDesign ?design save_path ?noConfirm t)
    t
  )
)
