!(register-module! ../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:modulator:modulator)
!(import! &self hyperon-openpsi:main:demand:demand)
!(import! &self hyperon-openpsi:main:mind-agents:feeling-updater:feeling-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:modulator-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v1)
!(import! &self hyperon-openpsi:main:feed-back-loop:feed-back-loop)

(: kb-initializer (-> Grounded Expression))
(= (kb-initializer $kb)
   (let* 
     (
      ($rules (collapse (get-atoms &ruleSpace)))
      ($modulators (collapse (get-atoms &modulator-space)))
      ($demands (collapse (get-atoms &demandspace)))
      ($partialKb (union-atom $rules $modulators))
      ($kbExp (union-atom $partialKb $demands))
      ($_ (collapse (add-atoms $kb $kbExp)))
    )
    ()
	)
)

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