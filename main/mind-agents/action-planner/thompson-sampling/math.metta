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

(: sample-engine (-> Number Number Number Number Number Number))
(= (sample-engine $alpha $beta $a $b $gamma) (
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
        (sample-engine $alpha $beta $a $b $gamma)
    )
))

(: beta-sample (-> Number Number Number))
(= (beta-sample $a $b) (
    let* (
        ($alpha (+ $a $b))
        ($beta (if (<= (min $a $b) 1) (max (/ 1 $a) (/ 1 $b)) (sqrt (/ (- $alpha 2) (- (* 2 (* $a $b)) $alpha))))) 
        ($gamma (/ (+ $a 1) $beta))
    ) (sample-engine $alpha $beta $a $b $gamma)
))