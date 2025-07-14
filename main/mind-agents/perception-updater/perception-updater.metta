!(bind! &envSpace (new-space))
!(bind! &percepta (new-space))
!(bind! &cache (new-space))

;; inspired by rocca it is going to receive time-stamped observations.
;; in every cycle, the cache space is expected to be updated when the environment
;; is updated. Hence once the the perception updater agent perceives the cache
;; it is expected ft O(N^2) 
;; time complexity. Hence new dynamic enviroment is persisted in both
;; the envSpace and the cache. So using this rationale, we can say that
;; the cache holds new percepta which are about to be persisted in the 
;; percepta atomspace.
;; (: Perception Type)
;; (: perception (-> Number Expression Perception))

;; A custom function to remove atoms given an s-expression.
(= (remove-atoms' $space $expression)
    (if (== $expression ())
        ()
        (let* (
            (($head $tail) (decons-atom $expression))
            ($_ (remove-atom $space $head))
        )
            (remove-atoms' $space $tail)
        )
    )
)
(= (remove-atoms $space)
    (let $atoms (collapse (get-atoms $space))
        (remove-atoms' $space $atoms)
    )
)

;; adds perceptions in the percepta space after 
;; checking defensively if the perceptions are empty

(= (addPerceptions $space $perceptions)
    (if (== $perceptions ())
        ()
        (add-reduct $space (superpose $perceptions))
    )
)

(= (fetchMaxCycle' $expressions $min)
    (if (== $expressions ())
        $min
    
        (let* (
            ($_ (println! (It enters here)))
            (($head $tail) (decons-atom $expressions))
            ($_  (println! (head $head)))
            ((perception $timeCycle $observation) $head)
            ($_ (println! (timeCycle $timeCycle)))
            ($isHeadLarger (> $timeCycle $min))
        )
            (if $isHeadLarger (fetchMaxCycle' $tail $timeCycle) (fetchMaxCycle' $tail $min))
        )
    )

)
(= (fetchMaxCycle $space)
    (let $expressions (collapse (get-atoms $space))
        (fetchMaxCycle' $expressions 0) ;; the 0 here is below the lower bound for timecycles. Since
                                        ;; they are positive values.
    )
)

(= (changeToPercepta $data $timeStamp)
    (collapse (perception $timeStamp (superpose $data)))
)

;; This implementation updates the percepta atomspace with
;; The current cache by incrementing the logical time-stamp
;; It is also expected to remove the cacheSpace after reading from 
;; it. As the cacheSpace adds new environment data the above mentioned
;; sequence repeats it-self.
(= (perceptionUpdater $cacheSpace $percepta  $max-recur)
    (if (and (> $max-recur 0) (not (== (collapse (get-atoms $cacheSpace)) ())))
        (let* (
            ($newData (collapse (get-atoms $cacheSpace)))
            ($_ (remove-atoms $cacheSpace))
            ($maxCycle (fetchMaxCycle $percepta))
            ($newPercepta (if (== $newData ())
                                ()
                                (changeToPercepta $newData (+ $maxCycle 1))
                            )
            
            )
            ($_ (println! (newPercepta $newPercepta)))
            ($_ (addPerceptions $percepta $newPercepta))
            

        )
            (perceptionUpdater $cacheSpace $percepta (- $max-recur 1))

        )
        ()
    )


)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          tests for perception-updater ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; !(add-atom &envSpace (a b c d))
;; !(add-atom &envSpace (dat))
;; !(get-atoms &envSpace)
;; !(remove-atoms &envSpace)
;; !(get-atoms &envSpace)
;; !(fetchMaxCycle &percepta)
;; !(add-reduct &cache (superpose ((a b c) (d e f) (g h i))))
;; !(get-atoms &cache)
;; !(perceptionUpdater &cache &percepta 3)
;; !(get-atoms &percepta)



or its contents (atoms) to be deleted.
;; The cache space in this scenario is used for optimizing the code. 
;; since similarity checks for an s-expression or a list takes atleas