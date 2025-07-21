!(register-module! ../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:modulator:modulator)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:modulator-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:tests:modulator-updater-test-helpers)
!(register-module! ../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:main:demand:demand)
;; !(import! &self hyperon-openpsi:main:feed-back-loop:feed-back-loop)
;; !(import! &self hyperon-openpsi:main:feed-back-loop:feed-back-helpers)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v1)
!(import! &self hyperon-openpsi:main:mind-agents:feeling-updater:feeling-updaters)
!(bind! &kb (new-space))
!(addRulesToSpace &ruleSpace)
!(insert-modulators &modulator-space)



(: remove-atoms' (-> hyperon::space::DynSpace Expression Expression))
(= (remove-atoms' $space $expression)
    (if (== $expression ())
        ()
        (let* (
            (($head $tail) (decons-atom $expression))
            ($_  (remove-atom $space $head))
           ($rem (collapse (get-atoms $space)))
           ($_ (println! (remaining-atoms $rem)))
        )
            (remove-atoms' $space $tail)
        )
    )
)
;; This function removes values from a given atomspace
;;(:remove-atoms (-> hyperon::space::DynSpace))
(= (remove-atoms $space)
    (let $atoms (collapse (get-atoms $space))
        (remove-atoms' $space $atoms)
    )
 )
;; Remove The remove occurrences function removes values based on a given 
;;pattern for instance a perception updater value can be stored as 
;;(perception value time)
(: remove-occurrences (-> hyperon::space::DynSpace Expression Expression)) 
(= (remove-occurrences $space $pattern)
   	(let* (
            ($atoms (collapse (match $space $pattern $pattern)))
            ($_ (println! (atoms-to-remove $atoms)))
           ) 
	  	(remove-atoms' $space $atoms)))


(= (add-atoms $space $values)
	(add-reduct $space (superpose $values)))


;;The below function is used to synchronize two atomspaces for having the same
;;Replicated value. The updater space belongs to the mind-agent while the atomspace to be synchronized is the 
;; knowledge base atomspace.
(: update-atoms (-> Expression hyperon::space::DynSpace hyperon::space::DynSpace Expression ))
(= (update-atoms $pattern $updater $updated)
   	(let* (
	       ($updater-atoms (collapse (get-atoms $updater)))
        ;;    ($_ (println! (pattern $pattern)))
	       ($rem-res (remove-occurrences $updated $pattern))
		;;    ($_ (println! (removed successfully $rem-res)))
        ;;    ($atoms (collapse (get-atoms $updated)))
        ;;    ($_ (println! (atomsKb $atoms)))
            ($res (collapse (add-atoms $updated $updater-atoms)))
            ;; ($_ (println! (result-after-added $res)))
            ;;($atoms' (collapse (get-atoms $updated)))
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
              )))



;; a querying mechanism of the knowledge base.
(= (query $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $cumm-weight))
   	(collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $cumm-weight)
	       ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $cumm-weight))

	))
(= (query $space (modulator $x $y)) (collapse (match $space (modulator $x $y) (modulator $x $y))))
(= (query $space (perception $x $y)) (collapse (match $space (perception $x $y) (perception $x $y))))
(= (query $space (demand $x $y)) (collapse (match $space (demand $x $y) (demand $x $y))))

(: queryAll (-> hyperon::space::DynSpace Symbol Expression))
(= (queryAll $space $type)
   (case $type(
	       (modulator (query $space (modulator $x $y)))
	       (perception (query $space (perception $x $y)))
	       (demand (query $space (demand $x $y)))
	       (rule (query $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $cumm-weight)))
	       ($_ (Error "This form doesn't exist in the atomspace"))
	       )))



(: demandSelector' (-> Expression Number Demand))
(= (demandSelector' $demands $maxDemand)
   	(if (== $demands ()) 
	  	$maxDemand
		(let* (
		       	((demand $maxName $maxVal) $maxDemand)
		       	(((demand $currName $currVal) $tail) (decons-atom $demands))
		       )
		  	(if (>= $currVal $maxVal)
			  	(demandSelector' $tail (demand $currName $currVal))
				(demandSelector' $tail $maxDemand)
			)
		)
	)
)

;; (: demandSelector (-> Expression Demand))
(= (demandSelector $demands)
   	(if (== $demands ())
	  	(Error "No Demands Available")
		(demandSelector' $demands (car-atom $demands))))
;
;; A one to one relationship between a demand and a goal.
;; This goal selector maps from the demand and applies the goal to it
;; This is an unfinished function
(= (goalSelector $demand)
   (case $demand(
		 ((demand affiliation $y) (Goal mission_complete 1.0 1.0))
		((demand competence $x) (Goal mission_complete 1.0 1.0))
        ((demand energy $x) (Goal mission_complete 1.0 1.0))
	)
)
)

;; A for the matched llm value
;(: matchGoal (-> hyperon::space::DynSpace Expression Expression)) 
;(= (matchGoal $ruleSpace $actions)
 ;  	(goal1 context1)
;)
;;(: applyActions (-> Expression Goal Expression Expression))
(= (applyActions $actions $goal $demand) 
   (if (== $actions ())
     		()
		(let $isGoalMet? (isGoalMet? $actions $goal)
		  	(if $isGoalMet?
                (let* (
                       ($_ (println! (goalMet $isGoalMet?)))
                       ((demand $demandName $demandValue) $demand)
                )
			  	    (setDemandValue &demandspace $demandName 1.0)
                )
				()
			)
		)))
; A non-deterministic implementation of demand selection refer 
;; OpenPsi: A Novel Computational Affective Model and its Application in Video Games by Goertzel,Ben et. al (2013)
(: selectDemand (-> Expression Expression))
(= (selectDemand $demands)
   (let* (
	  ($selectionVal (fetch-modulator-val (modulatorSpace) selection-threshold))
	  ($randomVal (random-float $rng 0 1))
	)
     	(if (>= $selectionVal $randomVal)
	  	(demandSelector $demands)
		(let* (
			($length (size-atom $demands))
			($randIndex (random-int &rng 0 (- $length 1)))
			($demand (index-atom $demands $randIndex))
		)
		  $demand))))
;;What happens when actions are applied?
;;How are we going to solve the problem?
;;(: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)))
;; we  can write a function that selects rules based on actions, then we can take the function that has the biggest heuristic
(: selectRuleByAction (-> hyperon::space::DynSpace Symbol Expression)) 
(= (selectRuleByAction $ruleSpace $action)
   	(collapse (match $ruleSpace ((:$handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $val) ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $val))))

;; A temporary selector of rules which are selected based on having the same actions. 
(: selectMaxRule (-> Expression Expression Expression))
(= (selectMaxRule $rules $maxRule)
   	(if (== $rules ())
	  $maxRule
	(let* (
	       ((($rule $weight) $tail) (decons-atom $rules))
		    (($maxRule' $maxWeight) $maxRule)
	       )
	  (if (>= $maxWeight $weight)
		  	;;()
			(selectMaxRule $tail $maxRule)
			(selectMaxRule $tail $rule)

		)
	  	
	)))





(:isGoalMet' (-> Expression Goal Bool))
(= (isGoalMet' $rules $goal)
   	(if (== $rules ())
		False
		(let* (
			(($rule $tail) (decons-atom $rules))
            ($_ (println! (isGoalMetInnerRule $rule tail $tail)))
			($ruleGoal (extractGoalFromRule $rule))
            ($_ (println! (this is the goal $ruleGoal)))
		)
		  (if (== $ruleGoal $goal)
		    	True
		    	(isGoalMet' $tail $goal)
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
	       ($rules' (findRulesWithAction &ruleSpace $lastAction))
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
(: kb-initializer (-> hyperon::space::DynSpace Expression))
(= (kb-initializer $kb)
   (let* (
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
		($actions (planner &ruleSpace $state $goal))
        ($_ (println! (actions-psi-to-apply $actions goal $goal demand $currDemand)))
		($applyValue (applyActions $actions $goalObj $currDemand)) 
        ($_ (println! (applyValue $applyValue)))
		($competenceDemand (getDemandByName &demandspace competence)) 
        ($_ (println! (competence-psi $competenceDemand)))
		($affiliationDemand (getDemandByName &demandspace affiliation))
		($energyDemand (getDemandByName &demandspace energy))
    
        ($_ (println! (demandValues $competenceDemand $affiliationDemand $energyDemand)))
		($modUpdate (modulatorUpdaterAgent &modulator-space $competenceDemand $affiliationDemand $energyDemand))

        ($_ (println! (modUpdate $modUpdate modulatorValues (collapse (get-atoms &modulator-space))))) 
		($happinessValue (happinessFeelingUpdater &modulator-space))
        ($_ (println! (happinessVal $happinessValue)))
		($sadnessValue (sadnessFeelingUpdater &modulator-space))
        ;; ($_ (println! (sadnessVal $sadnessValue)))
		($angerValue (angerFeelingUpdater &modulator-space))
        ;; ($_ (println! (angerVal $angerValue)))
		($fearValue (fearFeelingUpdater &modulator-space))
		($excitementValue (excitementFeelingUpdater &modulator-space))
		($loveValue (loveFeelingUpdater &modulator-space))
		($hateValue (hateFeelingUpdater &modulator-space))
		($gratitude (gratitudeFeelingUpdater &modulator-space))
        ;($_ (println! (happinessValue $happinessValue angerValue $angerValue sadnessValue $sadnessValue angerValue $angerValue fearValue $fearValue)))
 	    ($_ (update-all modulator &modulator-space $kb))
;; ;        
        ($_ (update-all demand &demandspace $kb))

	)
	;;   (hateValue $hateValue happinessValue $happinessValue sadnessValue $sadnessValue angerValue $angerValue)
	 (happinessValue $happinessValue sadnessValue $sadnessValue angerValue $angerValue fearValue $fearValue gratitudeValue $gratitude) 
	)	

)
(= (isListEmpty $list)
	(if (== (size-atom $list) 0) True False)
)

(= (emotionChecker $emotion)
	(unify $emotion (happinessValue $happinessValue sadnessValue $sadnessValue angerValue $angerValue fearValue $fearValue gratitudeValue $gratitude) True False)
)
;;!(kb-initializer &kb)
!(assertEqual (kb-initializer &kb) ())
!(assertEqual (isListEmpty (queryAll &kb modulator)) False)
!(assertEqual (isListEmpty (queryAll &kb rule)) False)
!(assertEqual (isListEmpty (queryAll &kb demand)) False)
!(assertEqual (isGoalMet? (report) (Goal mission_complete 1.0 1.0)) True)
!(assertEqual (isGoalMet? (analyze upload) (Goal analyze_data 1 1)) False)
!(assertEqual (emotionChecker (psi-agent-loop init &kb)) True)
;; !(psi-agent-loop init &kb)


;; !(fearFeelingUpdater &modulator-space)
;; !(happinessFeelingUpdater &modulator-space)

;; !(get-atoms &modulator-space)