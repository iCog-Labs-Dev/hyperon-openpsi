;  substitute all 0.2 by (random-float 0 1)

; Demand satisfaction: Sd(L, min_l, max_l, a)
(: satisfaction (-> Number Number Number Number Number))
(= (satisfaction $L $min_l $max_l $a)
   (if (< $L $min_l)
       (fuzzy_equal $L $min_l $a)
       (if (> $L $max_l)
           (+ 0.9 (* 0.1 0.2))
           (+ 0.8 (* 0.2 0.2)))))

; Update min_l based on satisfaction
(= (update_min_l $min_l $satisfaction $b $d)
   (if (> $satisfaction 0.8)
       (+ (* $b $min_l) $d)
       (* $b $min_l)))

; Update max_l based on satisfaction
(= (update_max_l $max_l $satisfaction $b $d)
   (if (> $satisfaction 0.8)
       (+ (* $b $max_l) $d)
       (* $b $max_l)))

; Calculate certainty demand level
(: calc_certainty (-> (List Number) Number Number))
(= (calc_certainty $ti_list $ts)
   (let* (
      ($object_num (size-atom $ti_list))
      ($h(foldl-atom $ti_list 0 $acc $x (+ $acc (fuzzy_new $x $ts))))
      )
        (/ (+ $h 
              0.2)
           (* (+ 1 (pow-math 2.71828 (* -0.05 $object_num)))
              (+ $object_num 1)))))

; Calculate competence demand level
(: calc_competence (-> Number Number Number))
(= (calc_competence $ns $nf)
   (/ $ns (+ $ns (pow-math $nf (/ 3 2)))))

; Calculate affiliation demand level
(= (calc_affiliation $di_list $dmax)
   (let* (
         ( $friend_num (size-atom $di_list))
         ;($fuzzy_)
            ($acc (foldl-atom $di_list 0 $acc $x (+ $acc (fuzzy_near $x $dmax))))
         )
         
         (/ (+  0.2 $acc)
           (* (+ 1 (pow-math 2.71828 (* -0.1 $friend_num)))
              (+ $friend_num 1)))
         
         )
)
!(fuzzy_near 10 20)
!(foldl-atom (1 2 3 4) 0 $acc $x (+ $acc $x))
!(calc_affiliation (50 100 150) 200); Main demand updater function
;(: demand_updater (-> String Number Number Number Number Number (List Number) Number (List Number) Number Number))
(= (demand_updater $demand $L $min_l $max_l $b $d $ti_list $ts $di_list $dmax)
   (let* (($satisfaction (if-equal $demand certainty
                           (calc_certainty $ti_list $ts)
                           (if-equal $demand competence
                                     (calc_competence $L 0)
                                     (if-equal $demand affiliation
                                               (calc_affiliation $di_list $dmax)
                                               (satisfaction $L $min_l $max_l 150)))))
          ($new_min_l (update_min_l $min_l $satisfaction $b $d))
          ($new_max_l (update_max_l $max_l $satisfaction $b $d)))
         (new-state ($demand $satisfaction $new_min_l $new_max_l))))

