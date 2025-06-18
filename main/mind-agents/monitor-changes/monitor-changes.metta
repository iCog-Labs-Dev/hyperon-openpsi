!(bind! rand (py-atom numpy.random.rand))
!(bind! &newSpace (new-space))
!(bind! &sngSpace (new-space))

;A function that takes the latestTime and a list of times
;and finds the appropriate position to set previous time pointer.
;
;returns: a tuple of previous time and latest time.
(: setPreviousTime (-> Expression Number))
(= (setPreviousTime $times)
   (let* 
     (
      ($random-num (rand))
      ($interval (+ 5 (* 5 $random-num)))
      ($times' (sort $times dec))
      ($latestTime (car-atom $times'))
      ($prevTime (setPreviousTime' $times' $latestTime $interval)) 
      )
     ($prevTime $latestTime) 
     )
   )


(= (setPreviousTime' $times $latest $interval)
   (if (== $times ())
     (default-value)
     (let*
       (
        (($previous $tail) (decons-atom $times)) 
        ;(() (println! ($previous $latest $interval)))
        )
       (if (>= (- $latest $previous) $interval)
         $previous
         (setPreviousTime' $tail $latest $interval)
         )
      )
     )
   )

(: addPredicatesHelper (-> Grounded Expression))
(= (addPredicatesHelper $space) 
  (let* 
    (
      ($pred-change-with-tv (Predicate change-with-tv))
      ($pred-change-with-arg (Predicate change-with-arg))
      ($pred-has-dramatic-changes (Predicate has-dramatic-change))
      ($_ (collapse (let $x 
                        (superpose ($pred-change-with-tv $pred-change-with-arg $pred-has-dramatic-changes))
                        (addPredicate $x $space)
                  )
            )
          )
      )
    ($pred-change-with-tv $pred-change-with-arg $pred-has-dramatic-changes)
  )
)

;a function that removes previous changes with tv and with args from 
;a provided space

(: removePrevChanges (-> Grounded Expression (->)))
(= (removePrevChanges $space $atoms)
   (if (== $atoms ())
     ()
     (let* (
            (($h $t) (decons-atom $atoms))
            ($list-link (out $h ))
            ;(() (println! (remove' $list-link $h)))
            )
        (if (== $h ())
          ()
          (let $_ (let () (remove-atom $space $list-link) (remove-atom $space $h)) 
            (removePrevChanges $space $t)
            )
          )
       )
     )
   )

(= (addPredicate $pred $space)
   (if (== (collapse (match $space $pred $pred)) ())
     (let $_ (add-atom $space $pred) $pred)
     (empty)
     )
   )

(= (update-drmtc-chng-tv $pred $space $ntv)
   (let $r (collapse (match $space ($pred $old-tv) $old-tv)) 
     (if (== $r ())
          (let $_ (add-atom $space ($pred $ntv)) ())
          (let $tv (car-atom $r) (update-atom $space ($pred $tv) ($pred $ntv)))
      )
     )
   )

; Record the changes in the atomspace
(= (record-changes-tv $space $changes-tv)
  (if (== $changes-tv ())
    ()
    (let* 
      (
        (($head $tail) (decons-atom $changes-tv))
        ($_ (add-atom $space (LIST_LINK $head)))
        ($_ (add-atom $space (REFERENCE_LINK ((Predicate change-with-tv) (LIST_LINK $head)))))
      )
      (record-changes-tv $space $tail)
    )
  )
)

(= (record-changes-arg $space $changes-arg)
  (if (== () $changes-arg)()
    (let $_ (add-atom $space (LIST_LINK $changes-arg))
      (add-atom $space (REFERENCE_LINK ((Predicate change-with-arg) (LIST_LINK $changes-arg))))
    )
  )
)

(: NetDifference Type)
(: netDiff (-> Number Expression NetDifference))

!(get-type (netDiff 7 (a b c))) 

(: compareChanges (-> hyperon::space::DynSpace hyperon::space::DynSpace Expression))
(= (compareChanges $space1 $space2)
    (let* (
            ($space_val_1 (collapse (get-atoms $space1)))
            ($space_val_2 (collapse (get-atoms $space2)))
            ($net (subtraction-atom $space_val_1 $space_val_2))
          )
        ((size-atom $net) $net)
    )
)

(: compareSpaceToList (-> hyperon::space::DynSpace Expression Expression))
(= (compareSpaceToList $space $list)
	(let* (
          ($space_val (collapse (get-atoms $space)))
          ($net (subtraction-atom $space_val $list))
        )
        ((size-atom $net) $net)
    )
  )

(: detectChangesHelper (-> Grounded Expression Expression Number Expression Expression))
(= (detectChangesHelper $space $time $previous_times $delta $accum)
	(if (== $previous_times ())
      $accum
      (let ($head $tail) (decons-atom $previous_times)
        (if (== (getImplication $head $space) (getImplication $time $space))
          (let* (
                  ($timeTv (extractTvFromRule $time $space))
                  ($latestTv (extractTvFromRule $head $space))
                  ($prevTvMean (cogTvMean $timeTv))
                  ($latestTvMean (cogTvMean $latestTv))
                  ($diff (- $latestTvMean $prevTvMean))
                 )
            (if (<= (abs-math $diff) $delta)
              (let $accum' (union-atom $accum (($time $head)))
                (detectChangesHelper $space $time $tail $delta $accum')
                )	
              (detectChangesHelper $space  $time $tail $delta $accum)
            )
           )
          (detectChangesHelper $space $time $tail $delta $accum)
        )
      )
    )
)

;;The following function is written for checking 
;; the state of the atomspace. This is between two consecutive time cycles.
(: detectChanges (-> Grounded Expression Expression Number Expression Expression))
(= (detectChanges $space $prev_times $latest_times $delta $accum)
	(if (or (== $prev_times ()) (== $latest_times ()))
		$accum
		(let* (
          (($head $tail) (decons-atom $latest_times))
          ($accum' (detectChangesHelper $space $head $prev_times $delta $accum))
        )
        (detectChanges $space $prev_times $tail $delta $accum')
		)
	)
)

(: monitor-changes (-> Grounded (->)))
(= (monitor-changes $space) 
   (let $prev_times (get-previous-times $space)
     (if (== () $prev_times)
          ()
          (let* (
                ($prev_times' (get-timevals $prev_times))
                (($previous_time $latest_time) (setPreviousTime $prev_times'))
                
                ($at_times_latest (get-incoming-by-type $space $latest_time TimeValue)) 
                ($at_times_previous (get-incoming-by-type $space $previous_time TimeValue))
                ;(() (println! ($at_times_previous $at_times_latest)))

                ($delta (match $space (tv_delta $v) $v))
                ($changes-with-tv (detectChanges $space $at_times_previous $at_times_latest $delta ()))
                ;(() (println! $changes-with-tv))

                (($pred-change-with-tv $pred-change-with-arg 
                                      $pred-has-dramatic-changes) (addPredicatesHelper $space))

                ($old-changes-with-tv (get-incoming-by-type $space $pred-change-with-tv REFERENCE_LINK))

                ($_ (removePrevChanges $space $old-changes-with-tv))
                ($_ (update-drmtc-chng-tv $pred-has-dramatic-changes $space (STV 0.0 0.0)))

                ($at_times_latest' (get-incoming-by-type $space $latest_time TimeValue)) 
                ($at_times_previous' (get-incoming-by-type $space $previous_time TimeValue))
                ($_ (record-changes-tv $space $changes-with-tv))
                ($remainingChanges (detectChanges $space $at_times_previous' $at_times_latest' $delta ()))
              )
              (if (== $remainingChanges ())
                ()
                (update-drmtc-chng-tv $pred-has-dramatic-changes $space (STV 1.0 1.0))
              )
          )
       )
     )
)
