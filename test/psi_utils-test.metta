!(register-module! ../../hyperon-openpsi) ;to load Relative path for current page
!(register-module! ../utils)
!(import! &self hyperon-openpsi:utils:psi_utils)


;; To Test Truth Value with TVMean Function 
!(assertEqual (BooleanTrue (TVMean (Bl True))) (BooleanTrue 1))
!(assertEqual (BooleanFalse (TVMean (Bl False))) (BooleanFalse 0))
!(assertEqual (ProbabilityValue (TVMean (Pr 0.75))) (ProbabilityValue 0.75))


;; Test TVMean function with STV (Simple Truth Value)

           ;; STV parameters are (strength, confidence) 
!(assertEqual (STVLowStrength (TVMean (STV 0.1 0.9))) (STVLowStrength 0.14))
!(assertEqual (STVMedStrength (TVMean (STV 0.5 0.5))) (STVMedStrength 0.5))
!(assertEqual (STVHighStrength (TVMean (STV 0.8 0.7))) (STVHighStrength 0.71))
!(assertEqual (STVZeroStrength (TVMean (STV 0.0 1.0))) (STVZeroStrength 4.999999995e-10))
!(assertEqual (STVFullStrength (TVMean (STV 1.0 1.0)))  (STVFullStrength 0.9999999995))


;; Compare TVMean with TVMode for STV
!(assertEqual (STVMode (TVMode (STV 0.7 0.8))) (STVMode 0.7))
!(assertEqual (STVMean (TVMean (STV 0.7 0.8))) (STVMean 0.6599999999999999))


;; Test with extreme values
!(assertEqual (STVZeroConfidence1 (TVMean (STV 0.0 0.0))) (STVZeroConfidence1 0.5))
!(assertEqual (STVZeroConfidence2 (TVMean (STV 1.0 0.0))) (STVZeroConfidence2 0.5))
!(assertEqual (STVZeroConfidence3 (TVMean (STV 0.5 0.0))) (STVZeroConfidence3 0.5))