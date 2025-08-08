;; !(bind! uniRand (py-atom numpy.random.uniform))
;; !(register-module! ../../hyperon-openpsi)
;; !(import! &self hyperon-openpsi:mettalog:math-functions)
;; !(import! &self hyperon-openpsi:mettalog:general-helpers)
(: >= (-> Number Number Bool))
(= (>= $fir $sec) (if (or (> $fir $sec) (== $fir $sec)) True False))
(: <= (-> Number Number Bool))
(= (<= $fir $sec) (if (or (< $fir $sec) (== $fir $sec)) True False))

!(bind! &rand-gen (new-space))
!(add-atom &rand-gen 42)
(: series_summation (-> Number Number Number Number))
(= (series_summation $y $iter $accum)
    (if (< $iter 0)
        (* 2 $accum)
        (let* (
            ($l_val (/ 1 (+ (* 2 $iter) 1)))
            ($r_val  (pow-math $y (+ (* 2 $iter) 1)))
            ($term (* $l_val $r_val))
            ($accum' (+ $accum $term))
        )
            (series_summation $y (- $iter 1) $accum')
        )
    )
)

;; This function computes the x multiplicand which is independent of the logarithmic calculation.
(: x_multiplicand (-> Number Number))
(= (x_multiplicand $x) (/ (- $x 1) (+ $x 1)))

(= (ln $x)
    (if (< $x 0)
        (Error "The x value is an error")
        (let* (
            ($y (x_multiplicand $x))
            ($result (series_summation $y 100 0))
        )
            $result
        )
    )
)
;; based on the laws of logarithms
(= (log $x $base)
    (/ (ln $x) (ln $base))
)

;; An implementation of the linear congruential generator. This implementation takes seed values to generate a pseudo-random number
;; which is going to be used in the mettalog implementation.
(: linear-congruential-generator (-> Number Number Number Number Number))
(= (linear-congruential-generator $seed $a $c $m)
   (% (+ (* $seed $a) $c) $m))

(: rand-float (-> Number))
(= (rand-float)
   (let* (
          ($seed (get-atoms &rand-gen))
          ($_ (remove-atom &rand-gen $seed))
          ($next (linear-congruential-generator $seed 1664525 1013904223 42949672967296))
          ($_ (add-atom &rand-gen $next))
          )
            (/ $next 42949672967296) 
))
(: rand-float-range (-> Number Number Number))
(= (rand-float-range $min $max)
   (if (>= $min $max)
        (Error "The first argument should be less than the second argument")
        (let* (
               ($rand_res (rand-float))
               ($adder (* (- $max $min) $rand_res))
               ($res (+ $min $adder)
               
               )
            )
            $res
        )
    )
)
;;An implementation of the normal function based on the box-muller transform

(= (pseudo-normal' $mu $sigma)
    (let* (
       ($u1 (rand-float))
       ($u2 (rand-float))
       
       ($r (sqrt-math (* -2.0 (ln $u1))))
       ($theta (* (* 2.0 3.14159265) $u2))
       ($z (* $r (cos-math $theta)))

    )
        (+ $mu (* $sigma $z)) 
    )
)
(= (pseudo-normal)
    (pseudo-normal' 0 1)
)

(= (fuzzy_equal $x $t $a)
   ( / 1 (+ 1 (* $a (* (- $x $t) (- $x $t)))))
)


(= (fuzzy_within $x $min_val $max_val $a)
    (if (< $x $min_val)
                (fuzzy_equal $x $min_val $a) ; x < min value
                (let $rand (pseudo-normal) 
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


(: isInBetween (-> Number Number Number Bool))
(= (isInBetween $val $a $b) (if (and (>= $val $a) (<= $val $b)) True False))

(= (exists-In $space $atom)
  (case (get-metatype $atom)
  (
    (Expression (let $matchedAtoms (collapse (match $space $atom $atom)) (
      if (== $matchedAtoms ()) False True
    )
    ))
    (Symbol  ( let $res (collapse (get-type-space $space $atom)) (not (== (%Undefined%) $res)) ))
  )
  )
)
