
; fetches all modulator values from the modulator space
(= (all-modulators $space)

    (let* 
        (
            ($_ (add-modulator $space (modulator pleasure 0.5)))
            ($activation  (fetch-modulator-val $space arousal))
            ($resolution (fetch-modulator-val $space goal-directedness))
            ($securing-threshold (fetch-modulator-val $space securing-threshold))
            ($selection-threshold (fetch-modulator-val $space selection-threshold))
            ($pleasure (fetch-modulator-val $space positive-valence))
        )
            ($activation $resolution $securing-threshold $selection-threshold $pleasure)
    )
    
)

(= (sum $list)
    (foldl + 0 $list)
    (let * 
    ($acc (foldl-atom $list 0 $acc $x (+ $acc $x))) 
    ($acc)
    )
)

; Happy feeling updater 
(= (happy-feeling-updater $modulators)
    (let* (
            (($activation $resolution $securing-threshold $selection-threshold $pleasure) $modulators)
            ($act (fuzzy-logic-p $activation H))
            ($res (fuzzy-logic-p $resolution L))
            ($sec (fuzzy-logic-p $securing-threshold U))
            ($sel (fuzzy-logic-p $selection-threshold H))
            ($ple (fuzzy-logic-p $pleasure H))
            ($sum (sum($act $res $sec $sel $ple)))
            ($happiness  (/ $sum 5))
        
        )
      $happiness
    )

)

; Sad feeling updater 
(= (sad-feeling-updater $modulators)
    (let* (
            (($activation $resolution $securing-threshold $selection-threshold $pleasure) $modulators)
            ($act (fuzzy-logic-p $activation L))
            ($res (fuzzy-logic-p $resolution H))
            ($sec (fuzzy-logic-p $securing-threshold U))
            ($sel (fuzzy-logic-p $selection-threshold EL))
            ($ple (fuzzy-logic-p $pleasure EL))
            ($sum (sum($act $res $sec $sel $ple)))
            ($sadness  (/ $sum 5))
        
        )
      $sadness
    )

)

; Angry feeling updater 
(= (angry-feeling-updater $modulators)
    (let* (
            (($activation $resolution $securing-threshold $selection-threshold $pleasure) $modulators)
            ($act (fuzzy-logic-p $activation H))
            ($res (fuzzy-logic-p $resolution L))
            ($sec (fuzzy-logic-p $securing-threshold U))
            ($sel (fuzzy-logic-p $selection-threshold L))
            ($ple (fuzzy-logic-p $pleasure EL))
            ($sum (sum($act $res $sec $sel $ple)))
            ($anger  (/ $sum 5))
        
        )
      $anger
    )

)

; Fear feeling updater 
(= (fear-feeling-updater $modulators)
    (let* (
            (($activation $resolution $securing-threshold $selection-threshold $pleasure) $modulators)
            ($act (fuzzy-logic-p $activation EL))
            ($res (fuzzy-logic-p $resolution EH))
            ($sec (fuzzy-logic-p $securing-threshold L))
            ($sel (fuzzy-logic-p $selection-threshold U))
            ($ple (fuzzy-logic-p $pleasure EL))
            ($sum (sum($act $res $sec $sel $ple)))
            ($fear  (/ $sum 5))
        
        )
      $fear
    )

)
