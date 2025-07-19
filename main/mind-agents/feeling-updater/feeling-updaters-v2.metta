
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
