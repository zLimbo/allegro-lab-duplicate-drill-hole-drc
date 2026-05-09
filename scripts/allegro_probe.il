; Minimal non-graphical Allegro SKILL probe.

(defun dh_probe_main (out_path)
  (let (fp design units)
    (setq fp (outfile out_path))
    (when fp
      (fprintf fp "probe_started\n")
      (setq design (axlDBGetDesign))
      (fprintf fp "design=%L\n" design)
      (when design
        (fprintf fp "design_type=%L\n" design->designType)
        (fprintf fp "name=%L\n" design->name)
      )
      (setq units (axlDBGetDesignUnits))
      (fprintf fp "units=%L\n" units)
      (fprintf fp "probe_done\n")
      (close fp)
    )
    t
  )
)
