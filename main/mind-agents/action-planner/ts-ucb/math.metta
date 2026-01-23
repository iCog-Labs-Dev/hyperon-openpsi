
;; Math utilities for Metta
(: isBetween (-> Number Number Number Bool))
(= (isBetween $val $low $high) (and (>= $val $low) (<= $val $high)))

(: max (-> Number Number Number))
(= (max $x $y) (if (> $x $y) $x $y))

(: min (-> Number Number Number))
(= (min $x $y) (if (> $x $y) $y $x))

(: round (-> Number Number Number))
(= (round $num $sig) ((py-atom round) $num $sig))

(: getRandomInt (-> Number Number Number))
(= (getRandomInt $min $max) (
    (py-atom random.randint) $min $max
))

(: getRandom (-> Number))
(= (getRandom) (
    (py-atom random.random)
))

(: log (-> Number Number))
(= (log $value) (
    (py-atom math.log) $value
))

(: sqrt (-> Number Number))
(= (sqrt $num) (
    (py-atom math.sqrt) $num
))

(: exp (-> Number Number))
(= (exp $num) (
    (py-atom math.exp) $num
))

(: sampleEngine (-> Number Number Number Number Number Number))
(= (sampleEngine $alpha $beta $a $b $gamma) (
    let* (
        ($u1 (getRandom))
        ($u2 (getRandom))
        ($v (* $beta (log (/ $u1 (- 1 $u1)))))
        ($w (* $a (exp $v)))
        ($temp (log (/ $alpha (+ $b $w))))
        ($left (+ (* $alpha $temp) (* $gamma $v)))
        ($right (+ (log 4) (log (* (* $u1 $u1) $u2))))
    ) (if (>= $left $right)
        (round (/ $w (+ $b $w)) 4)
        (sampleEngine $alpha $beta $a $b $gamma)
    )
))

(: betaSample (-> Number Number Number))
(= (betaSample $a $b) (
    let* (
        ($alpha (+ $a $b))
        ($beta (if (<= (min $a $b) 1) (max (/ 1 $a) (/ 1 $b)) (sqrt (/ (- $alpha 2) (- (* 2 (* $a $b)) $alpha))))) 
        ($gamma (/ (+ $a 1) $beta))
    ) (sampleEngine $alpha $beta $a $b $gamma)
))


;for ts-ucb
;to find the index of min value from a list 
(: min_list_with_index (-> Expression (Number Number)))
(= (min_list_with_index $vals) (min_list_helper $vals 10000000000.0 -1 0))  ;; Removed extra 0

(: min_list_helper (-> Expression Number Number Number (Number Number)))
(= (min_list_helper $vals $current_min $current_index $idx) (
    if (== $vals ()) 
        ($current_min $current_index)
        (let* (
            (($head $tail) (decons-atom $vals))
            ($new_min (if (< $head $current_min) $head $current_min))
            ($new_index (if (< $head $current_min) $idx $current_index))
        ) (min_list_helper $tail $new_min $new_index (+ $idx 1)))
    )
)
; sum of a superposed list of numbers
(: sum_list (-> Expression Number))
(= (sum_list $vals) (
    if (== $vals ())
        0
        (let* (
            ($head (car-atom $vals))
            ($tail (cdr-atom $vals))
        )
            (+ $head (sum_list $tail))
        )
))