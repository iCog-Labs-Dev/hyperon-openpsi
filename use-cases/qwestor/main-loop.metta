(= (qwestorLoop $contextState)
   (let* (
      ($demands (queryAll $kb demand))
		($currDemand (demandSelector $demands))
        ($goalObj (goalSelector $currDemand))
		((Goal $goal $goalVal1 $goalVal2) $goalObj) 
		($actions (planner &ruleSpace $contextState $goal))
		($applyValue (applyActions $actions $goalObj $currDemand)) 
		($competenceDemand (getDemandByName &demandspace competence)) 
		($affiliationDemand (getDemandByName &demandspace affiliation))
		($energyDemand (getDemandByName &demandspace energy))
    
		($modUpdate (modulatorUpdaterAgent &modulator-space $competenceDemand $affiliationDemand $energyDemand))


   )
    $actions
   ) 
)