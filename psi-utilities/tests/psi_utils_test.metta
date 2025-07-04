!(register-module! ../../../hyperon-openpsi) ;to load Relative path for current page
!(register-module! ../../psi-utilities)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)


;; Here generete Alway Constant Value when alpha or beta call
!(assertEqual (prior-alpha) 0.5)
!(assertEqual (prior-beta) 0.5)

;; Absolute Value always positive value
!(assertEqual (abs-math 50) 50)      ;;Positive is also positive
!(assertEqual (abs-math -70) 70)     ;;Negative should change to positive


;; Show maximum Value between two number
!(assertEqual (max 2 8) 8)              ;;with integar value
!(assertEqual (max 0.92 0.9267) 0.9267) ;; with in float value
!(assertEqual (max -20 -50) -20)        ;; with in negative value


;; Define approximately equal
!(assertEqual (approxEq 1e6 1e6 0.001) True) ;;with large Number
!(assertEqual (approxEq 1e-7 0.0 1e-8) False) ;;large Number

!(assertEqual (approxEq 1.001 1.0 0.01) True) ;;Symmetry test
!(assertEqual (approxEq 1.0 1.001 0.01) True) ;;Symmetry test

!(assertEqual (approxEq 0.5 0.5 0.001) True) ;;with in equal value

;; Defined Lessthan or Equal sign
!(assertEqual (<= 60 50) False) 
!(assertEqual (<= -90 90) True)
!(assertEqual (<= 50 50) True)

;; Lookahead constant
!(assertEqual (lookahead) 1.0) ;; always constant (should 1.0) 

;; Convert count to confidence
!(assertEqual (count->confidence 1.0) 0.5)
!(assertEqual (count->confidence 1e6) 0.999999000001)        ;;Large count value
!(assertEqual (count->confidence 0.01) 0.009900990099009901) ;;Small count Value


;; Convert confidence to count
!(assertEqual (confidence->count 1.0) 1000000000.0)         ;;edge case (max-count)
!(assertEqual (confidence->count 1e6) -1.000001000001)        ;;Large confidence value
!(assertEqual (confidence->count 0.01) 0.010101010101010102) ;;Small confidence Value


;; Return the count of a truth value
!(assertEqual (count (Bl True)) 1e9)  ;;bool True
!(assertEqual (count (Bl False)) 1e9)  ;;bool False
!(assertEqual (count (Pr 0.7)) 1e9)     ;;Probabilistic truth value 
!(assertEqual (count (STV 0.8 0.5)) (/ (* 0.5 1.0) (- 1.0 0.5))) ;; = 1.0

!(assertEqual (pos-count (Bl True)) 1e9)        ;; Bl True → mode = 1.0, count = 1e9
!(assertEqual (pos-count (Bl False)) 0.0)        ;; Bl False → mode = 0.0, count = 1e9
!(assertEqual (pos-count (Pr 0.75)) 750000000.0)   ;;Pr 0.75 → mode = 0.75, count = 1e9
!(assertEqual (pos-count (STV 0.6 0.5)) 0.6)        ;;mode = 0.6 conf = 0.5 → count = confidence->count(0.5) = 1.0 Then: pos-count = 0.6 * 1.0 = 0.6

!(assertEqual (neg-count (Bl True)) 0.0)                ;; Bl True → neg-count = 0
!(assertEqual (neg-count (Bl False)) 1e9)               ;; Bl False → neg-count = 1e9
!(assertEqual (neg-count (Pr 0.75)) 250000000.0)        ;; Pr 0.75 → neg-count = (1 - 0.75) * 1e9 = 0.25e9
!(assertEqual (neg-count (STV 0.8 0.5)) 0.19999999999999996) ;; STV 0.8 0.5 → count = 1.0, neg-count = (1 - 0.8) * 1.0 = 0.19999999999999996

!(assertEqual (post-alpha (Bl True)) 1000000000.5)      ;; Bl True → pos-count = 1e9, prior-alpha = 0.5 → post-alpha = 1e9 + 0.5
!(assertEqual (post-alpha (Pr 0.7)) 700000000.5)        ;; Pr 0.7 → pos-count = 0.7 * 1e9 = 0.7e9 → post-alpha = 0.7e9 + 0.5
!(assertEqual (post-alpha (STV 0.6 0.5)) 1.1)           ;; STV 0.6 0.5 → count = 1.0 → pos-count = 0.6, prior-alpha = 0.5 → post-alpha = 1.1

!(assertEqual (post-beta (Bl False)) 1000000000.5)      ;; Bl False → neg-count = 1e9, prior-beta = 0.5 → post-beta = 1e9 + 0.5
!(assertEqual (post-beta (Pr 0.3)) 700000000.5)         ;; Pr 0.3 → neg-count = 0.7 * 1e9 = 0.7e9 → post-beta = 0.7e9 + 0.5
!(assertEqual (post-beta (STV 0.6 0.5)) 0.9)            ;; STV 0.6 0.5 → count = 1.0 → neg-count = 0.4, prior-beta = 0.5 → post-beta = 0.9


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

