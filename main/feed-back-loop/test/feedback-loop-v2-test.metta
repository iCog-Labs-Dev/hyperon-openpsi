!(register-module! ../../../../hyperon-openpsi)

!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:modulator-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:tests:modulator-updater-test-helpers)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v2)
!(import! &self hyperon-openpsi:main:mind-agents:feeling-updater:feeling-updaters)
!(import! &self hyperon-openpsi:main:modulator:modulator)
!(import! &self hyperon-openpsi:main:demand:demand)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:psi-utilities:normalization)

!(register-module! ../../../utilities-module)
!(import! &self utilities-module:utils)

;; Create the necessary spaces
!(bind! &kb (new-space))
!(bind! &ruleSpace (new-space))
!(bind! &modulator-space (new-space))
!(bind! &demandspace (new-space))

(= (addRulesToSpaceV2 $space) (
    add-reduct $space (superpose (
        (addGoal (found_target) 0.5 () $space)
        (addGoal (init) 0 1 $space)
        (addGoal (hold_item) 1 1 $space)
        (addRule $space r1 ((init)) (explore) (found_target) (TTV 0 (STV 1.0 1.0)))
        (addRule $space r2 ((found_target)) (pick_item) (hold_item) (TTV 0 (STV 1.0 1.0)))
    ))
))

;; Populate the spaces
!(insert-modulators &modulator-space)
!(addRulesToSpaceV2 &ruleSpace)
!(addDemand &demandspace energy 0.6)
!(addDemand &demandspace affiliation 0.5)
!(addDemand &demandspace competence 0.2)

(= (extractGoalFromRuleV2 $rule)
    (let (: $handle (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) $rule $goal)
)

(= (findRulesWithActionV2 $space $action)
    (collapse (match $space (: $handle (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))
        (: $handle (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))
    ))
)

(=(reverse $list $acc)  
    (if(== $list ()) $acc
    (let ($head $tail ) (decons-atom $list) (reverse $tail (cons-atom $head $acc) ))
    )
)

(= (remove-atoms' $space $expressions)
   (remove-atom $space $expressions)   
)


;; This function removes values from a given atomspace
;;(:remove-atoms (-> hyperon::space::DynSpace))
(= (remove-atoms $space)
    (let $atoms (get-atoms $space)
        (remove-atoms' $space $atoms)
    )
)

;; Remove The remove occurrences function removes values based on a given 
;; pattern for instance a perception updater value can be stored as 
;; (perception value time)
(: remove-occurrences (-> hyperon::space::DynSpace Expression Expression)) 
(= (remove-occurrences $space $pattern)
   	(collapse(let* (
            ($atoms (match $space $pattern $pattern))
            ($_ (println! (atoms-to-remove $atoms)))
           ) 
	  	(remove-atoms' $space $atoms))))

(= (add-atoms $space $values)
	(add-reduct $space (superpose $values))
)

;;The below function is used to synchronize two atomspaces for having the same
;;Replicated value. The updater space belongs to the mind-agent while the atomspace to be synchronized is the 
;; knowledge base atomspace.
(: update-atoms (-> Expression hyperon::space::DynSpace hyperon::space::DynSpace Expression ))
(= (update-atoms $pattern $updater $updated)
   	(let* (
	       ($updater-atoms (collapse (get-atoms $updater)))
	       ($rem-res (remove-occurrences $updated $pattern))
           ($res (collapse (add-atoms $updated $updater-atoms)))
	      )
	  	  ()	
	)
)

;;Tag based specification for atomspace updation
(: update-all (-> Symbol hyperon::space::DynSpace hyperon::space::DynSpace Expression))
(= (update-all $tag $updater $updated)
   (case $tag(
              (demand (update-atoms (demand $x $y) $updater $updated))
              (modulator (update-atoms (modulator $x $y) $updater $updated))
            )
	)
)

;; a querying mechanism of the knowledge base.
(= (query $space (modulator $x $y)) (collapse (match $space (modulator $x $y) (modulator $x $y))))
(= (query $space (perception $x $y)) (collapse (match $space (perception $x $y) (perception $x $y))))
(= (query $space (demand $x $y)) (collapse (match $space (demand $x $y) (demand $x $y))))
(= (query $space (goal $x $y)) (collapse (match $space (Goal $g $x $y) (Goal $g $x $y))))

(: queryAll (-> hyperon::space::DynSpace Symbol Expression))
(= (queryAll $space $type)
   (case $type (
			(modulator (query $space (modulator $x $y)))
			(perception (query $space (perception $x $y)))
			(demand (query $space (demand $x $y)))
			(rule (query $space (: $handle (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
			(goal (query $space (goal $x $y)))
			($_ (Error "This form doesn't exist in the atomspace"))
	       )
	)
)

;; The demands are represented based on their satifsaction, 
;; a lower satisfation will require urgent response.
(: demandSelector' (-> Expression Number Demand))
(= (demandSelector' $demands $maxDemand)
   	(if (== $demands ()) 
	  	$maxDemand
		(let* (
		       	((demand $maxName $maxVal) $maxDemand)
		       	(((demand $currName $currVal) $tail) (decons-atom $demands))
		       )
		  	(if (<= $currVal $maxVal)
			  	(demandSelector' $tail (demand $currName $currVal))
				(demandSelector' $tail $maxDemand)
			)
		)
	)
)

(= (demandSelector $demands)
   	(if (== $demands ())
	  	(Error "No Demands Available")
		(demandSelector' $demands (car-atom $demands))
	)
)

;; A one to one relationship between a demand and a goal.
;; This goal selector maps from the demand and applies the goal to it
;; This is an unfinished function
(= (goalSelector $demand)
   (case $demand(
		((demand affiliation $y) (Goal (hold_item) 0.5 1.0))
		((demand competence $x) (Goal (hold_item) 0.5 1.0))
        ((demand energy $x) (Goal (hold_item) 0.5 1.0))
		)
	)
)

(= (applyActionsV2 $actions $goal $demand) 
   (if (== $actions ())
     		()
		(let $isGoalMet? (isGoalMet? $actions $goal)
		  	(if $isGoalMet?
                (let* (
                       ((demand $demandName $demandValue) $demand)
					   ($newDemValue (+ $demandValue (* (- 1 $demandValue) 0.5)))
                )
			  	    (setDemandValue &demandspace $demandName $newDemValue)
                )
				(applyActionsButFalse)
			)
		))
)

;: A non-deterministic implementation of demand selection refer 
;; OpenPsi: A Novel Computational Affective Model and its Application in Video Games by Goertzel,Ben et. al (2013)
(: selectDemand (-> Expression Expression))
(= (selectDemand $demands)
   (let* (
			($selectionVal (fetch-modulator-val &modulator-space selection-threshold))
			($randomVal (random-float $rng 0 1))
		)
     	(if (>= $selectionVal $randomVal)
			(demandSelector $demands)
			(let* (
				($length (size-atom $demands))
				($randIndex (random-int &rng 0 (- $length 1)))
				($demand (index-atom $demands $randIndex))
			)
				$demand
			)
		)
	)
)
		



(:isGoalMet' (-> Expression Goal Bool))
(= (isGoalMet' $rules $goal)
   	(if (== $rules ())
		False
		(let* (
			(($rule $tail) (decons-atom $rules))
            ($_ (println! (isGoalMetInnerRule $rule tail $tail)))
			($ruleGoal (extractGoalFromRuleV2 $rule))
			((Goal $g $tv $sgv) $goal)
            ($_ (println! (this is the goal $ruleGoal = $g)))
		)
		  (if (== $ruleGoal $g)
		    	True
		    	(isGoalMet' $tail $g)
		  )
		)
	)
)


;; How would this function work? how can I check whether the goal is met?
;; This function is used for a follow-up after the action-selection mind agent
;; is applied.
(: isGoalMet? (-> Expression Goal Bool))
(= (isGoalMet? $actions $goal)
	(let* (
	       ($length (size-atom $actions))
	       ($lastAction (index-atom $actions (- $length 1)))
	       ($rules' (findRulesWithActionV2 &ruleSpace $lastAction))
           ($_ (println! (rulesinGoal $rules')))
	)
		 (isGoalMet' $rules' $goal)
	)	
)


;; This function updates the modulator values in the atomspace.
(:update-modulator (-> Symbol Number Expression))
(= (update-modulator $modulatorName $modulatorValue)
	(let* (
	       ($modulator (fetch-modulator &modulator-space $modulatorName))
	       ($_ (update-atom &modulator-space $modulator ($modulatorName $modulatorValue)))
	)
	  	()
	)
)




;; This function implements the kb-initializer for the open-psi loop to work
;; Extracts all the info from the corresponding spaces and add it to one knowledge base
(: kb-initializer (-> hyperon::space::DynSpace Expression))
(= (kb-initializer $kb)
   (let* (
	  	($rules (collapse (get-atoms &ruleSpace)))
		($modulators (collapse (get-atoms &modulator-space)))
		($demands (collapse (get-atoms &demandspace)))
    (() (println! $demands))
		($partialKb (union-atom $rules $modulators))
		($kbExp (union-atom $partialKb $demands))
		($_ (collapse (add-atoms $kb $kbExp)))
	)
     	()
	)
)


(: psi-agent-loop (-> Symbol hyperon::space::DynSpace Expression)) 
(= (psi-agent-loop $state $kb)
	(let* (
	    ($demands (queryAll $kb demand))
        ($_ (println! (demands $demands)))

		($currDemand (demandSelector $demands))
        ($_ (println! (dmSelector $currDemand)))

        ($goalObj (goalSelector $currDemand))
		((Goal $goal $goalVal1 $goalVal2) $goalObj) 
        ($_ (println! (goal-psi $goal)))

		($actions-reversed (hillClimbingPlanner $state $goal (TestedActions) () &ruleSpace)) ;; Hillclimber returns actions in reverse order.
		($actions (reverse $actions-reversed ()))
        ($_ (println! (actions-psi-to-apply $actions goal $goal demand $currDemand)))
		
		($applyValue (applyActionsV2 $actions $goalObj $currDemand)) 
        ($_ (println! (applyValue $applyValue)))

		($competenceDemand (getDemandByName &demandspace competence)) 
		($affiliationDemand (getDemandByName &demandspace affiliation))
		($energyDemand (getDemandByName &demandspace energy))
        ($_ (println! (demandValues $competenceDemand $affiliationDemand $energyDemand)))
		
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
        ($_ (update-all demand &demandspace $kb))
	)
	 (happinessValue $happinessValue sadnessValue $sadnessValue angerValue $angerValue fearValue $fearValue gratitudeValue $gratitude) 
	)	

)
(= (isListEmpty $list)
	(if (== (size-atom $list) 0) True False)
)

;; The below function is going to be used to validate the result of the psi-main-loop output for emotion parameters.
;; The result should be in the mentioned format with a strict order.
(= (emotionChecker $emotion)
	(unify $emotion (happinessValue $happinessValue sadnessValue $sadnessValue angerValue $angerValue fearValue $fearValue gratitudeValue $gratitude) True False)
)

;; Tests
;!(get-atoms &demandspace)
!(assertEqual (kb-initializer &kb) ())
!(assertEqual (isListEmpty (queryAll &kb modulator)) False)
!(assertEqual (isListEmpty (queryAll &kb rule)) False)
!(assertEqual (isListEmpty (queryAll &kb demand)) False)
!(assertEqual (isListEmpty (queryAll &kb goal)) False)
!(assertEqual (isGoalMet? ((explore)) (Goal (found_target) 1.0 1.0)) True)
!(assertEqual (isGoalMet? ((explore)) (Goal (get_full) 1 1)) False)
!(assertEqual (emotionChecker (psi-agent-loop (init) &kb)) True)
!(assertEqual (demandSelector ((demand Affiliation 3) (demand Concept 4) (demand Car 8))) (demand Affiliation 3))

;; Uncomment the following to run the loop
 ;!(kb-initializer &kb)
 ;!(psi-agent-loop (init) &kb)
