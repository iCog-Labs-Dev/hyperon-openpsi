;!(bind! uniRand (py-atom numpy.random.uniform))
; Fuzzy logic function: fuzzy_equal(x, t, a) = 1 / (1 + a * (x - t)^2)

; Fuzzy logic function: fuzzy_new(ti, ts) = 2 / (1 + exp(0.002 * (ts - ti)))
(= (fuzzy_new $ti $ts)
   (/ 2 (+ 1 (pow-math 2.71828 (* 0.002 (- $ts $ti))))))

; Fuzzy logic function: fuzzy_near(di, dmax) = 1 / (1 + 0.00015 * (di - dmax))
(= (fuzzy_near $di $dmax)
   (/ 1 (+ 1 (* 0.00015 (- $di $dmax)))))


(= (fuzzy_equal $x $t $a)
   ( / 1 (+ 1 (* $a (* (- $x $t) (- $x $t)))))
)


(= (fuzzy_within $x $min_val $max_val $a)
    (if (< $x $max_val)
                (fuzzy_equal $x $min_val $a)
                (if (> $x $max_val)
                        (+ 0.999 (* uniRand 0.001))
                        (+ 0.99 (* uniRand 0.01))

                )
        )
)

(= (fuzzy_less_than $x $t $a)
    (if (> $x $t)
        (fuzzy_equal $x $t $a)
        1
    )
)

(= (fuzzy_greater_than $x $t $a)
    (if (< $x $t)
        (fuzzy_equal $x $t $a)
        1
    )
)


;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; The code below is borrowed from the hyperon-pln's implementation
;; of the TruthValue. 
;; The complete implementation can be found in the hyperon-pln's TruthValue.metta file . 


;; Constants for beta distribution prior
(: prior-alpha (-> Number))
(= (prior-alpha) 0.5)
(: prior-beta (-> Number))
(= (prior-beta) 0.5)

;; Define max
(: max (-> $a $a $a))
(= (max $x $y) (if (> $x $y) $x $y))

;; Maximum supported count
(: max-count (-> Number))
(= (max-count) 1e9)

;; Define approximately equal
(: approxEq (-> $a $a $a Bool))
(= (approxEq $x $y $epsilon) (<= (abs (- $x $y)) $epsilon))

;; Define abs
(: abs (-> $a $a))
(= (abs $x) (if (< $x 0) (* -1 $x) $x))

;; Define <=
(: <= (-> $a $a Bool))
(= (<= $x $y) (or (< $x $y) (== $x $y)))

;; Lookahead constant
(: lookahead (-> Number))
(= (lookahead) 1.0)

;; Truth Value type and constructors
(: TruthValue Type)
(: Bl (-> Bool TruthValue))
(: Pr (-> Number TruthValue))
(: STV (-> Number Number TruthValue))




;; Convert count to confidence
(: count->confidence (-> Number Number))
(= (count->confidence $cnt) (/ $cnt (+ $cnt (lookahead))))

;; Convert confidence to count
(: confidence->count (-> Number Number))
(= (confidence->count $conf) (if (approxEq 1.0 $conf 1e-9)
                                 (max-count)
                                 (/ (* $conf (lookahead)) (- 1.0 $conf))))

;; Return the TVMode of a truth value
(: TVMode (-> TruthValue Number))
(= (TVMode (Bl True)) 1.0)
(= (TVMode (Bl False)) 0.0)
(= (TVMode (Pr $pr)) $pr)
(= (TVMode (STV $pr $_)) $pr)

;; Return the count of a truth value
(: count (-> TruthValue Number))
(= (count (Bl $_)) (max-count))
(= (count (Pr $_)) (max-count))
(= (count (STV $_ $conf)) (confidence->count $conf))

;; Return the positive count of a truth value
(: pos-count (-> TruthValue Number))
(= (pos-count $tv) (* (TVMode $tv) (count $tv)))

;; Return the negative count of a truth value
(: neg-count (-> TruthValue Number))
(= (neg-count $tv) (* (- 1 (TVMode $tv)) (count $tv)))

;; Return the posterior alpha of a truth value
(: post-alpha (-> TruthValue Number))
(= (post-alpha $tv) (+ (prior-alpha) (pos-count $tv)))

;; Return the posterior beta of a truth value
(: post-beta (-> TruthValue Number))
(= (post-beta $tv) (+ (prior-beta) (neg-count $tv)))

;; Return the first order probability TVMean of the second order
;; distribution associated to a truth value.
(: TVMean (-> TruthValue Number))
(= (TVMean (Bl True)) 1.0)
(= (TVMean (Bl False)) 0.0)
(= (TVMean (Pr $pr)) $pr)
(= (TVMean (STV $pr $conf))
   (let* (($a (post-alpha (STV $pr $conf)))
          ($b (post-beta (STV $pr $conf))))
     (/ $a (+ $a $b))))




;; I've used these tests to see if it actually outputs without any error.But I didn't compare the results with other implementations yet . 
!(UniformRandom : uniRand)
!(FuzzyEqual (fuzzy_equal 4 2.0 3))
!(FuzzyWithin (fuzzy_within 2.0 1.0 3.0 3))
!(FuzzyLessThan (fuzzy_less_than 2.0 3.0 3))
!(FuzzyGreaterThan (fuzzy_greater_than 2.0 3.0 3))
;; Test TVMean function with different truth value types
!(BooleanTrue (TVMean (Bl True)))                 ;; Should return 1.0
!(BooleanFalse (TVMean (Bl False)))              ;; Should return 0.0
!(ProbabilityValue (TVMean (Pr 0.75)))           ;; Should return 0.75

;; Test TVMean function with STV (Simple Truth Value)
;; STV parameters are (strength, confidence)
!(STVLowStrength (TVMean (STV 0.1 0.9)))         ;; Should return approximately 0.14
!(STVMedStrength (TVMean (STV 0.5 0.5)))         ;; Should return approximately 0.5
!(STVHighStrength (TVMean (STV 0.8 0.7)))        ;; Should return approximately 0.77
!(STVZeroStrength (TVMean (STV 0.0 1.0)))        ;; Should return approximately 0.0
!(STVFullStrength (TVMean (STV 1.0 1.0)))        ;; Should return approximately 1.0

;; Compare TVMean with TVMode for STV
!(STVMode (TVMode (STV 0.7 0.8)))                ;; Returns 0.7 (the strength parameter)
!(STVMean (TVMean (STV 0.7 0.8)))                ;; Returns a value that considers both strength and confidence

;; Test with extreme values
!(STVZeroConfidence1 (TVMean (STV 0.0 0.0)))     ;; Very low confidence case
!(STVZeroConfidence2 (TVMean (STV 1.0 0.0)))     ;; Very low confidence case
!(STVZeroConfidence3 (TVMean (STV 0.5 0.0)))     ;; Very low confidence case

