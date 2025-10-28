;; Demand Representation: (demand <$demand-name> <$min-value> <$max-value> <$current-value>)

(: Demand Type)
(: SkipDemand Type)
(: skip (-> Symbol SkipDemand))

(: addDemand (-> hyperon::space::DynSpace Symbol Number Number Number Demand))
(= (addDemand $space $name $minVal $maxVal $currentValue) (
    let* (
            ($demand (demand $name $minVal $maxVal $currentValue))
            (() (add-atom $space $demand))
        )
    ()
))

(: fetchDemand (-> hyperon::space::DynSpace Symbol Demand))
(= (fetchDemand $space $name) (
    match $space (demand $name $min $max $val) (demand $name $min $max $val)
))

(: fetchDemandVal (-> hyperon::space::DynSpace Symbol Number))
(= (fetchDemandVal $space $name) (
    let (demand $n $min $max $val) (fetchDemand $space $name) $val
))

(: fetchDemandMinVal (-> hyperon::space::DynSpace Symbol Number))
(= (fetchDemandMinVal $space $name) (
    let (demand $n $min $max $val) (fetchDemand $space $name) $min
))

(: fetchDemandMaxVal (-> hyperon::space::DynSpace Symbol Number))
(= (fetchDemandMaxVal $space $name) (
    let (demand $n $min $max $val) (fetchDemand $space $name) $max
))

(: getAllDemands (-> hyperon::space::DynSpace Expression))
(= (getAllDemands $space) (
    collapse (match $space (demand $name $min $max $val) (demand $name $min $max $val))
))

(: skipDemand (-> hyperon::space::DynSpace Symbol (->)))
(= (skipDemand $space $demandName) (
    let* (
        ($skip (collapse (match $space (skip $demandName) (skip $demandName))))
        ($isNotFound (== $skip ()))
    ) (if $isNotFound 
        (add-reduct $space (skip $demandName)) 
        ()
    )
))

(: getEnabledDemands (-> hyperon::space::DynSpace Expression))
(= (getEnabledDemands $space) (
    let* (
       ($skippedDemands (collapse (match $space (, (demand $x $min $max $v) (skip $x)) (demand $x $min $max $v)) ))
       ($allDemands (getAllDemands $space))
       ($enabledDemands (collapse (subtraction  (superpose $allDemands)  (superpose $skippedDemands))))
    ) 
    $enabledDemands
))

(: updateDemandValue (-> hyperon::space::DynSpace Symbol Number (->)))
(= (updateDemandValue $space $demandName $newValue) (
    let* (
        ((demand $demandName $min $max $oldValue) (match $space (demand $demandName $min $max $oldValue) (demand $demandName $min $max $oldValue)))
        (() (remove-atom $space (demand $demandName $min $max $oldValue)))
        (() (add-atom $space (demand $demandName $min $max $newValue)))
    )
    ()
))

(= (updateDemandMinValue $space $demandName $newMinValue) (
    let* (
        ((demand $demandName $oldMin $max $value) (match $space (demand $demandName $oldMin $max $value) (demand $demandName $oldMin $max $value)))
        (() (remove-atom $space (demand $demandName $oldMin $max $value)))
        (() (add-atom $space (demand $demandName $newMinValue $max $value)))
    )
    ()
))

(= (updateDemandMaxValue $space $demandName $newMaxValue) (
    let* (
        ((demand $demandName $min $oldMax $value) (match $space (demand $demandName $min $oldMax $value) (demand $demandName $min $oldMax $value)))
        (() (remove-atom $space (demand $demandName $min $oldMax $value)))
        (() (add-atom $space (demand $demandName $min $newMaxValue $value)))
    )
    ()
))

(: getDemandByName (-> hyperon::space::DynSpace Symbol Demand))
(= (getDemandByName $space $name) (match $space (demand $name $min $max $val) (demand $name $min $max $val)))


(: demandDecay (-> hyperon::space::DynSpace Expression Number (->)))
(= (demandDecay $space $demand $value)
    (let* (
        ($oldValue  (match $space (demand $demand $minVal $maxVal $oldValue) $oldValue))
        ($newValue (- $oldValue $value))
    )
    (if (>= $newValue 0)
        (updateDemandValue $space $demand $newValue)
        (let* (
            ($demandAtom (match $space (demand $demand $minVal $maxVal $oldValue) (demand $demand $minVal $maxVal $oldValue)))
            (() (remove-atom $space $demandAtom))
        ) (remove-atom $space (skip $demand))
        )
    )
))

; Apply decay only to skipped demands
(: decaySkippedDemands (-> hyperon::space::DynSpace Number (->)))
(= (decaySkippedDemands $space $decayValue)
    (let* (
        ($skippedDemandNames (collapse (match $space (skip $x) $x)))
        ($skippedDemands (collapse (match $space (demand $x $minVal $maxVal $value) (demand $x $minVal $maxVal $value))))
    )
    (if (== (size-atom $skippedDemands) 0)
        (There are no skipped demands) 
        (demandDecay $space (superpose $skippedDemandNames) $decayValue)
    ))
)

; Apply decay to all demands (both enabled and skipped)
(: decayAllDemands (-> hyperon::space::DynSpace Number (->)))
(= (decayAllDemands $space $decayValue)
    (let* (
        ($allDemands (getAllDemands $space))
        ($demandNames (collapse (match $space (demand $name $minVal $maxVal $val) $name)))
    )
    (if (== (size-atom $allDemands) 0)
        (No demands in the space)
        (demandDecay $space (superpose $demandNames) $decayValue)
    ))
)

; Apply different decay rates to enabled vs skipped demands
(: decayDemandsWithDifferentRates (-> hyperon::space::DynSpace Number Number (->)))
(= (decayDemandsWithDifferentRates $space $enabledDecayRate $skippedDecayRate)
    (let* (
        ($enabledDemandNames (getEnabledDemands $space))
        ($enabledDemands (collapse (unify $enabledDemandNames (demand $name $minVal $maxVal $val) $name ())))
        ($skippedDemandNames (collapse (match $space (skip $name) $name)))
        ($_ (decaySkippedDemands $space $skippedDecayRate))
    )
    (if (== (size-atom $enabledDemands) 0)
        (There is no skipped demand)
        (demandDecay $space (superpose $enabledDemands) $enabledDecayRate)
    ))
)

