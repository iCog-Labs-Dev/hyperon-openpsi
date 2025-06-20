; Demand Updater - Based on OpenPsi ben paper 

; util functions 
!(bind! exp (py-atom numpy.exp))
!(bind! rand-float (py-atom numpy.random.rand))


; fuzzy new
; function used to compute certainty demand level
; ti is the latest time stamp of observing object i and 
; ts is the current time stamp of the virtual world.
(= (fuzzy-new $ti $ts)
    (let $x (exp (* 0.002 (- $ts $ti))) (/ 2 (+ 1 $x)))
)


; fuzzy near 
; function used to compute affilation demand level
; di - denotes the distance between friend i and the avatar itself
; dmax - is a distance threshold to decrease the impact of friends far away.
(=(fuzzy-near $di $dmax)
    (/ 1 (+ 1 (* 0.00015 (- $di $dmax))) )
)

; summation of fuzzy near 
(= (sum-fuzzy-near $lst $d-max)

    (let $fnear (collapse(fuzzy-near (superpose $lst) $d-max)) 
        (foldl-atom $fnear 0 $acc $x (+ $acc $x))
    )
)

; summation of fuzzy new 
(= (sum-fuzzy-new $lst $ts)

    (let $fnew (collapse(fuzzy-new (superpose $lst) $ts)) 
        (foldl-atom $fnew 0 $acc $x (+ $acc $x))
    )
)

; Certainity demand updater
(: CertaintyDemandUpdater (-> Expression Number  Number))
(= (CertaintyDemandUpdater $lst  $ts)

    (let* (
            ($summation (sum-fuzzy-new $lst $ts ))
            ($object-num (size-atom $lst))
            ($rand (rand-float))
            ($x (exp (* -0.05  $object-num)))
        )
    (/ (+ $summation $rand)
        (+ 1 (* $x (+ 1  $object-num)))))
        
)


; Affiliation Demand Updater 
(: AffiliationDemandUpdater (-> Expression  Number Number))
(= (AffiliationDemandUpdater  $lst  $d-max)
    (let* (
            ($summation (sum-fuzzy-near $lst $d-max ))
            ($friend-num (size-atom $lst))
            ($rand (rand-float))
            ($x (exp (* -0.1  $friend-num))) 
        )
    (/ (+ $summation $rand)
        (+ 1 (* $x (+ 1  $friend-num))))
        
))


; Competence Demand Updater 
(: CompetenceDemandUpdater (-> Number Number  Number))
(= (CompetenceDemandUpdater $plan-done-number  $plan-failed-number)
    (/ $plan-done-number  (+ $plan-done-number (pow-math $plan-failed-number 1.5))  )
)
