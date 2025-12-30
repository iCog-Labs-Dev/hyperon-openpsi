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