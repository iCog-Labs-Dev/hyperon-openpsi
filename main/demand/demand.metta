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
        ((demand $name $min $max $oldValue) $demand)
        ($newValue (- $oldValue $value))
    )
    (if (>= $newValue 0)
        (updateDemandValue $space $name $newValue)
        (let* (
            (() (remove-atom $space $demand))
            (() (remove-atom $space (skip $name)))
        ) ()
        )
    )
))

; Apply decay only to skipped demands
(: decaySkippedDemands (-> hyperon::space::DynSpace Number (->)))
(= (decaySkippedDemands $space $decayValue)
    (let* (
        ($skippedDemandNames (collapse (match $space (skip $x) $x)))
        ($skippedDemands (collapse (let $demandName (superpose $skippedDemandNames) (fetchDemand $space $demandName))))
    )
    (if (== (size-atom $skippedDemands) 0)
        (There are no skipped demands) 
        (demandDecay $space (superpose $skippedDemands) $decayValue)
    ))
)

; Apply decay to all demands (both enabled and skipped)
(: decayAllDemands (-> hyperon::space::DynSpace Number (->)))
(= (decayAllDemands $space $decayValue)
    (let* (
        ($allDemands (getAllDemands $space))
    )
    (if (== (size-atom $allDemands) 0)
        (No demands in the space)
        (let $demand (superpose $allDemands) (demandDecay $space $demand $decayValue))
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

;; alpha denotes how fast the fuzzy_equal output decreases when current deviates from minVal.
(: alpha (-> Number))
(= (alpha) 150)

;; Function to calculate demand satisfaction according to Ben's Paper
;; Requires random function which should be imported from utils
(: calculateDemandSatisfaction (-> hyperon::space::DynSpace Symbol Number))
(= (calculateDemandSatisfaction $space $demandName) (
    let* (
        ((demand $demandName $minVal $maxVal $currentValue) (fetchDemand $space $demandName))
        ($alpha (alpha))
    ) (if (and (>= $currentValue $minVal) (<= $currentValue $maxVal))
        (+ 0.8 (* 0.2 (random 0 1)))
        (if (< $currentValue $minVal)
            (fuzzy_equal $currentValue $minVal $alpha)
            (+ 0.9 (* 0.1 (random 0 1)))
        )
    )
))

;; Priority order for demand-arbitration tie-breaking.
;; Lower index = higher priority = wins on a tie.
(: demandPriorityOrder (-> Expression))
(= (demandPriorityOrder) (energy competence affiliation))

;; Looks up how important a demand is, by its position in the priority list.
;; A demand not in the list gets treated as lowest priority.
(: demandPriorityIndex' (-> Expression Symbol Number Number))
(= (demandPriorityIndex' $list $name $idx)
    (if (== $list ())
        999
        (let ($head $tail) (decons-atom $list)
            (if (== $head $name)
                $idx
                (demandPriorityIndex' $tail $name (+ $idx 1))
            )
        )
    )
)

(: demandPriorityIndex (-> Symbol Number))
(= (demandPriorityIndex $name)
    (let $order (demandPriorityOrder)
        (demandPriorityIndex' $order $name 0)
    )
)

(: fetchLeastSatisfiedDemand' (-> hyperon::space::DynSpace Expression Demand Demand))
(= (fetchLeastSatisfiedDemand' $space $demands $leastSatisfiedDemand)
    (if (== $demands ())
        $leastSatisfiedDemand
        (let* (
            (($currentDemand $restDemands) (decons-atom $demands))
            ((demand $currentName $currentMin $currentMax $currentValue) $currentDemand)
            ((demand $leastName $leastMin $leastMax $leastValue) $leastSatisfiedDemand)
            ($currentSatisfaction (calculateDemandSatisfaction $space $currentName))
            ($leastSatisfaction (calculateDemandSatisfaction $space $leastName))
        )
        (if (< $currentSatisfaction $leastSatisfaction)
            (fetchLeastSatisfiedDemand' $space $restDemands $currentDemand)
            (if (== $currentSatisfaction $leastSatisfaction)
                (if (< (demandPriorityIndex $currentName) (demandPriorityIndex $leastName))
                    (fetchLeastSatisfiedDemand' $space $restDemands $currentDemand)
                    (fetchLeastSatisfiedDemand' $space $restDemands $leastSatisfiedDemand)
                )
                (fetchLeastSatisfiedDemand' $space $restDemands $leastSatisfiedDemand)
            )
        )
    )
))
 
;; Function to fetch the least satisfied demand
(: fetchLeastSatisfiedDemand (-> hyperon::space::DynSpace Demand))
(= (fetchLeastSatisfiedDemand $space) (
    let* (
        ($activeDemands (getEnabledDemands $space))
    ) (if (== $activeDemands ())
        ("No active demands found")
        (fetchLeastSatisfiedDemand' $space $activeDemands (car-atom $activeDemands))
    )
))