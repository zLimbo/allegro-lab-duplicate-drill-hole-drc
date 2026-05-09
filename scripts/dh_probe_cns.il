; Probe constraint modes to locate Duplicate Drill Hole controls.

(defun dh_probe_cns_main (out_path)
  (let (fp modes same_modes)
    (setq fp (outfile out_path))
    (when fp
      (fprintf fp "axlCNSDesignModeGet_nil=%L\n" (errset (axlCNSDesignModeGet nil) t))
      (fprintf fp "axlCNSSpacingModeGet_nil=%L\n" (errset (axlCNSSpacingModeGet nil) t))
      (fprintf fp "axlCNSSameNetModeGet_nil=%L\n" (errset (axlCNSSameNetModeGet nil) t))
      (fprintf fp "dup_attr_get=%L\n" (errset (axlCNSDesignModeGet 'DUP_DRILL_HOLE_VMODE) t))
      (fprintf fp "dup_attr_on_set=%L\n" (errset (axlCNSDesignModeSet 'DUP_DRILL_HOLE_VMODE 'on) t))
      (fprintf fp "dup_attr_after=%L\n" (errset (axlCNSDesignModeGet 'DUP_DRILL_HOLE_VMODE) t))
      (close fp)
    )
    (axlSaveDesign ?design "allegro/dh_auto_via_cases.cns_probe.brd" ?noConfirm t)
    t
  )
)
