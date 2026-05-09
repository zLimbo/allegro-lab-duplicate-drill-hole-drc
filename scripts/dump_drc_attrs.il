(defun dump_drc_attrs_main (out_path)
  (let (fp ds idx drc)
    (setq fp (outfile out_path))
    (setq ds (axlDBGetDesign))
    (setq idx 0)
    (when fp
      (foreach drc ds->drcs
        (setq idx (plus idx 1))
        (fprintf fp "DRC %d\n%L\n\n" idx drc->??)
      )
      (close fp)
    )
    t
  )
)
