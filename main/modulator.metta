(: Modulator Type)
(: modulator (-> Symbol Number Modulator))


!(bind! &modulator-space (new-space)) ;; a relation-space for adding links between categories and rules



(: insert-modulators (-> Atom empty))
(= (insert-modulators $space) (add-reduct $space (superpose (
        (modulator arousal 0.5)
        (modulator positive-valence 0.5)
        (modulator negative-valence 0.5)
        (modulator selection-threshold 0.5)
        (modulator securing-threshold 0.5)
        (modulator goal-directedness 0.5)
    
))))

(: fetch-modulator (-> hyperon::space::DynSpace Symbol Expression))
(= (fetch-modulator $space $name)
    (collapse (match $space (modulator $name $x) (modulator $name $x)))
)
(: fetch-modulator-val (-> hyperon::space::DynSpace Symbol Number))
(= (fetch-modulator-val $space $name)
    (let ($x $y $z) (fetch-modulator $space $name) $z)
)
(: normalize-value (-> Number Number))
(= (normalize-value $num)
    (if(and (<= $num 7) (>= $num 1))
        (/ $num 7.0)
        (ERROR (provide unique values))
    )
)
(: isInBetween (-> Number Number Number Bool))
(= (isInBetween $val $a $b) (if (and (>= $val $a) (<= $val $b)) True False))


(= (add-modulator $space (modulator $name $value))
    (if (isInBetween $value 0 1) (add-atom $space (modulator $name $value)) (Error (value is incorrect))))


!(insert-modulators &modulator-space)
!(fetch-modulator &modulator-space securing-threshold)
!(fetch-modulator-val &modulator-space securing-threshold)

!(add-modulator &modulator-space (modulator custom 0.8))
!(get-atoms &modulator-space)
!(normalize-value 6.0)
;; !(normalize-value 9.0)
!(get-atoms &modulator-space)