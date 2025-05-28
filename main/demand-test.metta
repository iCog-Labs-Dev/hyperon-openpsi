!(register-module!  ../../hyperon-openpsi)
!(register-module! ../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:utils:psi_utils)
!(import! &self hyperon-openpsi:main:demand)

!(bind! &demandSpace (new-space))


;TODO: move these to utilities-module
(= (existsIn $space $atom)
  (case (get-metatype $atom)
  (
    (Expression (let $matchedAtoms (collapse (match $space $atom $atom)) (
      if (== $matchedAtoms ()) False True
    )
    ))
    (Symbol  ( let $res (collapse (get-type-space $space $atom)) (not (== (%Undefined%) $res)) ))
  )
  )
)
!(addDemand &demandSpace energy 0.6)
!(addDemand &demandSpace affiliation 0.5)
!(addDemand &demandSpace competence 0.2)
!(skipDemand &demandSpace competence)

; !(assertEqual (existsIn &demandSpace (demand energy 1.4)) False)
; !(assertEqual (existsIn &demandSpace (demand competence 0.2)) True)
; !(assertEqual (getAllDemands &demandSpace )  ((demand energy 0.6) (demand affiliation 0.5) (demand competence 0.2)))
; !(assertEqual (existsIn &demandSpace (skip competence)) True)

; !(assertEqual (getEnabledDemands &demandSpace) ((demand affiliation 0.5) (demand energy 0.6)))
; !(setDemandValue &demandSpace energy 0.8)
; !(assertEqual (existsIn &demandSpace (demand energy 0.8)) True)
; ; !(getAllDemands &demandSpace)
; !(get-atoms &demandSpace)