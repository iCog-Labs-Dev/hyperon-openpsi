!(bind! &demandspace (new-space))
!(bind! &cacheSpace (new-space))

(: Demand Type)
(: SkipDemand Type)
; (: demand (-> Symbol Number Demand))
(: skip (-> Symbol SkipDemand))

; (: addDemand (-> hyperon::space::DynSpace Symbol Number Demand))
(= (addDemand $space $name $value)
    (let* (
        ($demand (demand $name $value))
        ; ($duplicateDemandList  (match $space (demand $name $v) (demand $name $v)))
      
       

        (() (add-atom $space $demand))
    )
     ()
    )
    )


(= (getAllDemands $space)
    (collapse (match $space (demand $x $_) (demand $x $_)))
)

!(add-reduct &demandspace (superpose (
        (demand energy 0.5)
        (demand affiliation 0.5)
        (demand competence 0.5)
        
    
)))

(= (skipDemand $space $demand ) 
    (let* (
        ($skip (collapse (match $space (skip $demand) (skip $demand))))
        ( $isNotFound (== $skip ()))
    )
    (if $isNotFound 
        (add-reduct $space (skip $demand)) 
        ()
    )
    )
)


; !(add-reduct &demandspace (superpose (
;         (skip competence 0.5)
; )))

(= (getEnabledDemands $space)
    (let* (
       ( $skippedDemands (collapse (match $space (, (demand $x $_) (skip $x)) (demand $x $_)) ))
    
       ( $allDemands (getAllDemands $space))
    
       ( $enabledDemands (collapse (subtraction  (superpose $allDemands)  (superpose $skippedDemands))))
     
    ) 
        $enabledDemands
    )
)

(= (setDemandValue $space $demandName $newValue)
    (let* (
        ((demand $demandName $oldValue ) (match $space (demand $demandName $oldValue) (demand $demandName $oldValue)))
        (() (remove-atom $space (demand $demandName $oldValue)))
        (() (add-atom $space (demand $demandName $newValue)))
    )
    ()
    )

)


!(skipDemand energy)
!(skipDemand affiliation)

!(setDemandValue energy 0.6)


!(getEnabledDemands)


!(get-atoms &demandspace)





