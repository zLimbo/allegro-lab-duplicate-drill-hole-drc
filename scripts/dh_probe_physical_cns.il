; Probe physical constraint modes.

(defun dh_probe_physical_cns_main (out_path)
  (let (fp)
    (setq fp (outfile out_path))
    (when fp
      (fprintf fp "axlCNSPhysicalModeGet_nil=%L\n" (errset (axlCNSPhysicalModeGet nil) t))
      (fprintf fp "padpad_connect_get=%L\n" (errset (axlCNSPhysicalModeGet 'padpad_connect) t))
      (fprintf fp "Padpad_Connect_get=%L\n" (errset (axlCNSPhysicalModeGet 'Padpad_Connect) t))
      (fprintf fp "Pad_Pad_Connect_get=%L\n" (errset (axlCNSPhysicalModeGet 'Pad_Pad_Connect) t))
      (close fp)
    )
    t
  )
)
