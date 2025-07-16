(: compareModulatorValues (-> Modulator Modulator Bool))
(=(compareModulatorValues (modulator $x $y) (modulator $x' $y'))
    (if (and (== $x $x') (== $y $y')) True False)
)
(= (not-eq $at-1 $at-2)
    (== (== $at-1 $at-2) False))

(: all (-> Expression Bool))
(= (all $expressions) (if (isMember False $expressions) False True))


;; Implementation of the dataset 
(: compareModulators (-> hyperon::space::DynSpace hyperon::space::DynSpace Bool))
(= (compareModulators $modulatorSpace $demandSpace)
    (let* (
        ($activation (fetch-modulator $modulatorSpace arousal))
        ($selectionThreshold (fetch-modulator $modulatorSpace selection-threshold))
        ($securingThreshold (fetch-modulator $modulatorSpace securing-threshold))
        ($competence-demand (getDemandByName $demandSpace competence))
        ($energy-demand (getDemandByName $demandSpace energy))
        ($affiliation-demand (getDemandByName $demandSpace affiliation))
        ($_ (modulatorUpdaterAgent $modulatorSpace $competence-demand $affiliation-demand $energy-demand))
        ($activation' (fetch-modulator $modulatorSpace arousal))
        ($selectionThreshold' (fetch-modulator $modulatorSpace selection-threshold))
        ($securingThreshold' (fetch-modulator $modulatorSpace securing-threshold))
        ($compAct (not-eq $activation $activation'))
        ($compSel (not-eq $selectionThreshold $selectionThreshold'))
        ($comSec (not-eq $securingThreshold $securingThreshold'))
    )
        (all ($compAct $compSel $comSec))
    )
)




