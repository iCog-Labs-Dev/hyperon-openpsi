; Demand Updater 
; Based on OpenPsi ben paper 

; util functions 
!(bind! exp (py-atom numpy.exp))
; fuzzy new 
; ti is the latest time stamp of observing object i and 
; ts is the current time stamp of the virtual world.
(= (fuzzy-new $ti $ts)
    (/ 2 (+ 1 (exp (* 0.002 (- $ts $ti)))))
)


; fuzzy near 
; function used to compute affilation demand level
; di - denotes the distance between friend i and the avatar itself
; dmax - is a distance threshold to decrease the impact of friends far away.
(=(fuzzy-near $di $dmax)
    (/ 1 (+ 1 (* 0.00015 (- $di $dmax))) )
)

; length of expression 
(= (length-exp $y)
    (if (== $y ()) 0
        (let $tail (cdr-atom $y) 
            ( + 1 (length-exp $tail)))
    )
)

; summation of fuzzy near 
(= (sum-fuzzy-near $lst $d-max)

    (if (== $lst ())               
        0
        (let*(
                ($a (car-atom $lst))
                ($c (cdr-atom $lst))
                ($b (fuzzy-near $a $d-max))
                ($d (sum-fuzzy-near $c $d-max))
            )
             ( + $b $d)
           )
    ) 
)


; summation of fuzzy new 
(= (sum-fuzzy-new $lst $d-max)

    (if (== $lst ())               
        0
        (let*(
                ($a (car-atom $lst))
                ($c (cdr-atom $lst))
                ($b (fuzzy-new $a $d-max))
                ($d (sum-fuzzy-new $c $d-max))
            )
             ( + $b $d)
           )
    ) 
)



; Certainity demand updater
(: CertaintyDemandUpdater (-> Expression Number  Number))
(= (CertaintyDemandUpdater $lst  $ts)

    (let* (
            ($summation (sum-fuzzy-new $lst $ts ))
            ($object-num (length-exp $lst))
        )
    (/ (+ $summation (random-float 0 1))
        (+ 1 (* (exp (* -0.05  $object-num)) (+ 1  $object-num)))))
        
)


; Affiliation Demand Updater 
(: AffiliationDemandUpdater (-> Expression  Number Number))
(= (AffiliationDemandUpdater  $lst  $d-max)
    (let* (
            ($summation (sum-fuzzy-near $lst $d-max ))
            ($friend-num (length-exp $lst))
        )
    (/ (+ $summation (random-float 0 1))
        (+ 1 (* (exp (* -0.1  $friend-num)) (+ 1  $friend-num))))
        
))



; Competence Demand Updater 
(: CompetenceDemandUpdater (-> Number Number  Number))
(= (CompetenceDemandUpdater $plan-done-number  $plan-failed-number)
    (/ $plan-done-number  (+ $plan-done-number (pow-math $plan-failed-number 1.5))  )
)

;               Test for demand updater 

; !(CertaintyDemandUpdater  (10 20 30  40 50) 25)
; !(AffiliationDemandUpdater  (10 20 30 ) 25)
; !(CompetenceDemandUpdater 12 34 )