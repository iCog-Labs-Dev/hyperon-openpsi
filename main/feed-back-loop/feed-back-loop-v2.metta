
(: psi-loop-v2 (-> Symbol hyperon::space::DynSpace Expression)) 
(= (psi-loop-v2 $state $kb)
	(let* (
	    ($demands (queryAll $kb demand))
        ($_ (println! (Available Demands $demands)))

		($currDemand (fetchLeastSatisfiedDemand $kb))
        ($_ (println! (Selected Demand: $currDemand)))

		((demand $demandName $minVal $maxVal $demandValue) $currDemand)
        ($goalObj (goalSelector $demandName))
		((Goal $goal $goalVal1 $goalVal2) $goalObj) 
        ($_ (println! (Selected Goal: $goal)))

		($actions (hillClimbingPlanner $state $goal (Tested Actions) () &ruleSpace))
        ($_ (println! (Actions: $actions goal $goal demand $currDemand)))
		(() (updateDemandValue &demandSpace $demandName 1.77))
		($applyValue (applyActions $actions $goalObj $currDemand &ruleSpace &demandSpace)) 
        ($_ (println! (applyValue $applyValue)))

		($competenceDemand (getDemandByName &demandSpace competence)) 
		($affiliationDemand (getDemandByName &demandSpace affiliation))
		($energyDemand (getDemandByName &demandSpace energy))
        ($_ (println! (Demand Values: $competenceDemand $affiliationDemand $energyDemand)))
		
		($modUpdate (modulatorUpdaterAgent &modulator-space $competenceDemand $affiliationDemand $energyDemand))
        ($_ (println! (modUpdate $modUpdate modulatorValues (collapse (get-atoms &modulator-space))))) 
		
		($happinessValue (happinessFeelingUpdater &modulator-space))
		($sadnessValue (sadnessFeelingUpdater &modulator-space))
		($angerValue (angerFeelingUpdater &modulator-space))
		($fearValue (fearFeelingUpdater &modulator-space))
		($excitementValue (excitementFeelingUpdater &modulator-space))
		($loveValue (loveFeelingUpdater &modulator-space))
		($hateValue (hateFeelingUpdater &modulator-space))
		($gratitude (gratitudeFeelingUpdater &modulator-space))
	    
		($_ (update-all modulator &modulator-space $kb))
        ($_ (update-all demand &demandSpace $kb))
	)
	  (happinessValue $happinessValue sadnessValue $sadnessValue angerValue $angerValue fearValue $fearValue gratitudeValue $gratitude) 
	)	
)
