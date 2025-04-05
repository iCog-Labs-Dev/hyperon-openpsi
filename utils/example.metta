; modulators.metta

; Define Types explicitly for clarity and potential type checking
(: Modulator Type)
(: GroundedAtom Type) ; Assuming GroundedAtom is a recognized type
(: Symbol Type)
(: Number Type)
(: Bool Type)
(: Atom Type) ; Generic Atom type
(: Expression Type) ; Generic Expression type
(: Empty Type) ; Represents successful void operations
(: arrousal Type)

(: modulator (-> Symbol Number Modulator))

; The logger instance passed from Python
(: logger GroundedAtom)


!(bind! modulatorUpdatedEvent (py-atom logger.mofi))


!(test "this is a test")


; !(py-log "this is a test")
!(modulatorUpdatedEvent "arrousal" 0.5 0.448)

; Declare the space (could also be passed as argument if needed)
!(bind! &modulator-space (new-space))

; == Functions from original example ==

; (: insert-modulators (-> Atom Empty)) ; Using Atom for space type flexibility
; (= (insert-modulators $space)
;    (add-reduct $space (superpose (
;         (modulator arousal 0.5)
;         (modulator positive-valence 0.5)
;         (modulator negative-valence 0.5)
;         (modulator selection-threshold 0.5)
;         (modulator securing-threshold 0.5)
;         (modulator goal-directedness 0.5)
;    )))
; )

; (: fetch-modulator (-> Atom Symbol Expression)) ; Returns the full (modulator name val) expr or Empty
; (= (fetch-modulator $space $name)
;    (collapse (match $space (modulator $name $x) (modulator $name $x)))
; )

; (: fetch-modulator-val (-> Atom Symbol Atom)) ; Returns value or Error
; (= (fetch-modulator-val $space $name)
;    (let $mod (fetch-modulator $space $name)
;         (case $mod (
;              ((modulator $_ $val) $val)
;              ; Return Error if not found or structure mismatch
;              (($_) (Error (Modulator Not Found) $name))
;         ))
;    )
; )

; (: normalize-value (-> Number Number))
; (= (normalize-value $num)
;    (if (and (<= $num 7) (>= $num 1))
;        (/ $num 7.0)
;        (Error (Invalid Input for Normalization) $num)
;    )
; )

; (: isInBetween (-> Number Number Number Bool))
; (= (isInBetween $val $a $b)
;    (if (and (>= $val $a) (<= $val $b)) True False)
; )


; (: update-modulator! (->hyperon::space::DynSpace Symbol Number Atom))
; (= (update-modulator! $space $name $value)
;    (let* (
;    ((modulator $name $prev_val) (match $space (modulator $name $x) (modulator $name $x)))
;    (() (remove-atom $space (modulator $name $prev_val)))
;    (() (add-reduct $space (modulator $name $value)))
;    ))
; ;    (if (isInBetween $value 0 1)
; ;        (let* (
; ;            ($prev_mod (fetch-modulator $space $name))
; ;            (_ (case $prev_mod (
; ;                 (Empty (nop))
; ;                 ($mod (remove-atom $space $mod))
; ;            )))
; ;            (_ (add-atom $space (modulator $name $value)))
; ;            (_ (case $prev_mod (
; ;                 (Empty (modulatorUpdatedEvent "$name" 10 0))
; ;                 ((modulator $_ $prev_val) (modulatorUpdatedEvent "$name" 40 30))
; ;            )))
; ;        ) Empty)
; ;     ;    (let _ (py-log "(Update Failed: Invalid value for $name: $value. Must be [0, 1])")
; ;     ;        (Error (Invalid Modulator Value) (modulator $name $value))
; ;     ;    )
; ;     (this is a test)
; ;    )
; (this is a test)
; )

; ; Initialize modulators
; !(insert-modulators &modulator-space)
; ; Log that setup is done
; ; !(py-log "(Initial modulators inserted into &modulator-space)")

; ; Example updates that will trigger logs
; !(update-modulator! &modulator-space arousal 0.7)
; !(update-modulator! &modulator-space negative-valence 0.1)

; ; Example adding a new modulator
; !(update-modulator! &modulator-space vigilance 0.85)

; ; Example of an invalid update triggering an error log
; !(update-modulator! &modulator-space arousal 1.5)

; ; Check final state (optional, will just print MeTTa result)
; !(get-atoms &modulator-space)