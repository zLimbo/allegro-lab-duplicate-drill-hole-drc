; Build a focused lab for Duplicate Drill Hole interaction with item-item DRCs.

(defun dhii_text (txt x y)
  (let (orient)
    (setq orient
      (make_axlTextOrientation
        ?textBlock "3"
        ?rotation 0.0
        ?mirrored nil
        ?justify "center"
      )
    )
    (axlDBCreateText txt x:y orient "BOARD GEOMETRY/DIMENSION" nil)
  )
)

(defun dhii_text_left (txt x y)
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

(defun dhii_clear_route_restrictions ()
  (let (layers)
    (setq layers
      (list
        "ROUTE KEEPIN/ALL" "ROUTE KEEPIN/TOP" "ROUTE KEEPIN/BOTTOM"
        "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/TOP" "ROUTE KEEPOUT/BOTTOM"
      )
    )
    (axlDeleteByLayer layers 'fixed)
  )
)

(defun dhii_drc_modes (enable_item_item)
  (axlCNSSpacingModeSet 'all 'off)
  (axlCNSSameNetModeSet 'all 'off)
  (axlCNSPhysicalModeSet 'all 'off)
  (axlCNSAssemblyModeSet 'all 'off)
  (axlCNSEcsetModeSet 'all 'off)
  (axlCNSDesignModeSet 'all 'off)
  (axlCNSDesignModeSet 'Duplicate_Drill_Hole 'on)
  (when enable_item_item
    (axlCNSSpacingModeSet 'via_via 'on)
    (axlCNSSetPhysical nil nil 'allow_padconnect 'NOT_ALLOWED)
    (axlCNSPhysicalModeSet 'allow_padconnect 'on)
  )
)

(defun dhii_round_padstack (name drill_diameter pad_diameter)
  (let (drill pad_list)
    (setq drill
      (make_axlPadStackDrill
        ?holeType 'CIRCLE_DRILL
        ?drillDiameter drill_diameter
        ?plating 'PLATED
        ?figure 'CIRCLE
        ?figureSize drill_diameter:drill_diameter
      )
    )
    (setq pad_list nil)
    (setq pad_list (cons (make_axlPadStackPad ?layer "TOP" ?type 'REGULAR ?figure 'CIRCLE ?figureSize pad_diameter:pad_diameter) pad_list))
    (setq pad_list (cons (make_axlPadStackPad ?layer "DEFAULT_INTERNAL" ?type 'REGULAR ?figure 'CIRCLE ?figureSize pad_diameter:pad_diameter) pad_list))
    (setq pad_list (cons (make_axlPadStackPad ?layer "BOTTOM" ?type 'REGULAR ?figure 'CIRCLE ?figureSize pad_diameter:pad_diameter) pad_list))
    (axlDBCreatePadStack name drill pad_list t)
  )
)

(defun dhii_slot_padstack (name slot_width slot_height pad_x pad_y)
  (let (drill pad_list)
    (setq drill
      (make_axlPadStackDrill
        ?holeType 'OVAL_SLOT
        ?slotSize (list slot_width slot_height)
        ?plating 'PLATED
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

(defun dhii_setup_padstacks ()
  (dhii_round_padstack "DHII_RND_025_PAD055" 0.25 0.55)
  (dhii_round_padstack "DHII_RND_025_PAD090" 0.25 0.90)
  (dhii_slot_padstack "DHII_SLOT_025X075" 0.25 0.75 0.95 0.45)
)

(defun dhii_setup_nets ()
  (axlDBCreateNet "DHII_A")
  (axlDBCreateNet "DHII_B")
)

(defun dhii_case (fp case_id x y pad_a pad_b net_a net_b dx dy intent)
  (let (via_a via_b bx by)
    (setq bx (plus x dx))
    (setq by (plus y dy))
    (setq via_a (axlDBCreateVia pad_a x:y net_a))
    (setq via_b (axlDBCreateVia pad_b bx:by net_b))
    (dhii_text case_id x (plus y 8.0))
    (dhii_text intent x (plus y 5.0))
    (fprintf fp "%s,%g,%g,%g,%g,%s,%s,%L,%L,%s\n"
      case_id x y bx by pad_a pad_b via_a via_b intent)
  )
)

(defun dhii_header (enable_item_item)
  (dhii_text_left "Duplicate Drill Hole item-item interaction lab" 130.0 268.0)
  (if enable_item_item
    (dhii_text_left "Modes: Duplicate_Drill_Hole + via_via spacing + allow_padconnect physical" 130.0 262.0)
    (dhii_text_left "Modes: Duplicate_Drill_Hole only" 130.0 262.0)
  )
)

(defun dh_item_item_interaction_main (save_path log_path enable_item_item)
  (let (fp)
    (axlUnfixAll)
    (dhii_clear_route_restrictions)
    (dhii_drc_modes enable_item_item)
    (dhii_setup_padstacks)
    (dhii_setup_nets)
    (dhii_header enable_item_item)
    (setq fp (outfile log_path))
    (when fp
      (fprintf fp "case_id,x_a,y_a,x_b,y_b,padstack_a,padstack_b,dbid_a,dbid_b,intent\n")
      (dhii_case fp "IIC01" 150.0 240.0 "DHII_RND_025_PAD055" "DHII_RND_025_PAD055" "DHII_A" "DHII_A" 0.0 0.0 "same-net duplicate")
      (dhii_case fp "IIC02" 186.0 240.0 "DHII_RND_025_PAD055" "DHII_RND_025_PAD055" "DHII_A" "DHII_B" 0.0 0.0 "diff-net duplicate")
      (dhii_case fp "IIC03" 222.0 240.0 "DHII_SLOT_025X075" "DHII_SLOT_025X075" nil nil 0.0 0.0 "no-net slot duplicate")
      (dhii_case fp "IIC04" 258.0 240.0 "DHII_RND_025_PAD090" "DHII_RND_025_PAD090" "DHII_A" "DHII_B" 0.30 0.0 "diff-net pad overlap no DH")
      (dhii_case fp "IIC05" 294.0 240.0 "DHII_RND_025_PAD090" "DHII_RND_025_PAD090" "DHII_A" "DHII_A" 0.30 0.0 "same-net pad overlap no DH")
      (dhii_case fp "IIC06" 330.0 240.0 "DHII_RND_025_PAD055" "DHII_RND_025_PAD055" "DHII_A" "DHII_B" 1.20 0.0 "diff-net separated control")
      (dhii_case fp "IIC07" 366.0 240.0 "DHII_RND_025_PAD090" "DHII_RND_025_PAD090" "DHII_A" "DHII_A" 0.0001 0.0 "same-net quantized duplicate")
      (close fp)
    )
    (dhii_clear_route_restrictions)
    (dhii_drc_modes enable_item_item)
    (axlSaveDesign ?design save_path ?noConfirm t)
    t
  )
)
