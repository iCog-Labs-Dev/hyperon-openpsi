!(bind! uniRand (py-atom numpy.random.uniform))
(= (fuzzy_equal $x $t $a)
   ( / 1 (+ 1 (* $a (* (- $x $t) (- $x $t)))))
)


(= (fuzzy_within $x $min_val $max_val $a)
    (if (< $x $min_val)
                (fuzzy_equal $x $min_val $a) ; x < min value
                (let $rand (uniRand) 
                    (if (> $x $max_val) 
                        (+ 0.999 (* $rand 0.001)) ; x > max value
                        (+ 0.99 (* $rand 0.01)) ; min value < x < max value

                    )
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

; Define abs
;(: abs (-> $a $a))
;(= (abs $x) (if (< $x 0) (* -1 $x) $x))

;; Define approximately equal
(: approxEq (-> $a $a $a Bool))
(= (approxEq $x $y $epsilon) (<= (abs-math (- $x $y)) $epsilon))


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




(= (get-outgoing $atom $space $type)
   (collapse 
     (match $space ($type ($source $atom)) (match $space ($type ($atom $source)) ($type ($atom $source))))
     )
   )

(= (get-outgoing $atom $space)
   (collapse 
     (match $space ($type ($source $atom)) (match $space ($type ($atom $source))))
     )
   )

(= (out ($type $s $t))
   $t
   )

(= (get-incoming-by-type $space $atom $type)
   (collapse 
     (union 
      (match $space ($type $atom $target) $target)
      (match $space ($type $source $atom) $source)
      )
    )
   )

(= (get-incoming $atom $space)
   (collapse 
     (union 
      (match $space ($type $atom $target) ($type $atom $target))
      (match $space ($type $source $atom) ($type $source $atom))
      )
     )
   )


