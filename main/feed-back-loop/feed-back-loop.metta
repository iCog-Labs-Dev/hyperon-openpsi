
!(bind! &kb (new-space))

!(bind! &modulator-space (new-space))
!(bind! &demandspace (new-space))

;; This function removes values from a given atomspace
;;(:remove-atoms (-> Grounded))
(= (remove-atoms $space)
    (let $atoms (get-atoms $space)
        (remove-atom $space $atoms)
    )
 )
;; Remove The remove occurrences function removes values based on a given 
;;pattern for instance a perception updater value can be stored as 
;;(perception value time)
(: remove-occurrences (-> hyperon::space::DynSpace Expression Expression)) 
(= (remove-occurrences $space $pattern)
   	(collapse(let* (
            ($atoms (match $space $pattern $pattern))
            ($_ (println! (atoms-to-remove $atoms)))
           ) 
	  	(remove-atoms' $space $atoms))))


(= (add-atoms $space $values)
	(add-reduct $space (superpose $values)))


;;The below function is used to synchronize two atomspaces for having the same
;;Replicated value. The updater space belongs to the mind-agent while the atomspace to be synchronized is the 
;; knowledge base atomspace.
(: update-atoms (-> Expression Grounded Grounded Expression ))
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
(: update-all (-> Symbol Grounded Grounded Expression))
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
(= (query $space (demand $name $min $max $val)) (collapse (match $space (demand $name $min $max $val) (demand $name $min $max $val))))

(: queryAll (-> Grounded Symbol Expression))
(= (queryAll $space $type)
   (case $type(
	       (modulator (query $space (modulator $x $y)))
	       (perception (query $space (perception $x $y)))
	       (demand (query $space (demand $name $min $max $val)))
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
		  	(if (<= $currVal $maxVal)
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
;(: matchGoal (-> Grounded Expression Expression)) 
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
					   ($newDemValue (+ $demandValue (* (- 1 $demandValue) 0.5)))
                )
			  	    (setDemandValue &demandspace $demandName $newDemValue)
                )
				()
			)
		)))
; A non-deterministic implementation of demand selection refer 
;; OpenPsi: A Novel Computational Affective Model and its Application in Video Games by Goertzel,Ben et. al (2013)
(: selectDemand (-> Expression Expression))
(= (selectDemand $demands)
   (let* (
	  ($selectionVal (fetch-modulator-val &modulator-space selection-threshold))
	  ($_ (println! (This is the selection thresholdvalue $selectionVal)))
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
(: selectRuleByAction (-> Grounded Symbol Expression)) 
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


(: isGoalMet? (-> Expression Goal Bool))
(= (isGoalMet? $actions $goal)
	(let* (
	       ($length (size-atom $actions))
	       ($lastAction (index-atom $actions (- $length 1)))
	       ($rules' (findRulesWithAction &kb $lastAction))
           ;($_ (println! (rulesinGoal $rules')))
	)
		 (isGoalMet' $rules' $goal)
	)	
)



(:isGoalMet' (-> Expression Goal Bool))
(= (isGoalMet' $rules $goal)
   	(if (== $rules ())
		False
		(let* (
			(($rule $tail) (decons-atom $rules))
            ;($_ (println! (isGoalMetInnerRule $rule tail $tail)))
			($ruleGoal (extractGoalFromRule $rule))
            ;($_ (println! (this is the goal $ruleGoal)))
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

(= (get-goal-value (Goal $goal_name $goal_value $target_goal_value))
    $goal_value
)
(= (find-best-goal' $related_goals $max_value $best_goal)
    (if (== $related_goals ()) $best_goal 
        (let* (
            ($current-goal (car-atom $related_goals))
            ($next_goals (cdr-atom $related_goals))
            ($current_goal_value (get-goal-value $current-goal))
            ; (() println! (current-goal-value = $current_goal_value))
            ; (() (println! (currentgoal= $current-goal , current-goal-value= $current_goal_value , next-goals= $next_goals)))
        )
            (if (> $current_goal_value $max_value)
                (find-best-goal' $next_goals $current_goal_value $current-goal)
                (find-best-goal' $next_goals $max_value $best_goal)
            )
        )
    )
)

(= (find-best-goal $goals)
    (find-best-goal' $goals 0 ())
)
(= (goal-selector $space $demand)
    (let* (
        ($relatedGoals (collapse (get-type-space $space $demand)))
         ;(() (println! (related-goals= $relatedGoals)))
        ($selectedGoal (find-best-goal $relatedGoals))
    )
    $selectedGoal
)
)

(: psi-agent-loop (-> Symbol hyperon::space::DynSpace Expression)) 
(= (psi-agent-loop $state $kb)
	(let* (
	    ($demands (queryAll $kb demand))
        ($_ (println! (demands $demands)))
		($currDemand (fetchLeastSatisfiedDemand $kb))
        ($_ (println! (dmSelector $currDemand)))
		((demand $demandName $minVal $maxVal $demandValue) $currDemand)
        ($goalObj (goalSelector $demandName))
		((Goal $goal $goalVal1 $goalVal2) $goalObj) 
        ($_ (println! (goal-psi $goal)))
		($actions (planner &ruleSpace $state $goal))
        ($_ (println! (actions-psi-to-apply $actions goal $goal demand $currDemand)))
		($applyValue (applyActions $actions $goalObj $currDemand &ruleSpace &demandSpace)) 
        ($_ (println! (applyValue $applyValue)))
		($competenceDemand (getDemandByName &demandSpace competence)) 
		($affiliationDemand (getDemandByName &demandSpace affiliation))
		($energyDemand (getDemandByName &demandSpace energy))
    
        ($_ (println! (demandValues $competenceDemand $affiliationDemand $energyDemand)))
		($modUpdate (modulatorUpdaterAgent &modulator-space $competenceDemand $affiliationDemand $energyDemand))

        ($_ (println! (modUpdate $modUpdate modulatorValues (collapse (get-atoms &modulator-space))))) 
		($happinessValue (happinessFeelingUpdater &modulator-space))
        ($_ (println! (happinessVal $happinessValue)))
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


(= (isListEmpty $list)
	(if (== (size-atom $list) 0) True False)
)

;; The below function is going to be used to validate the result of the psi-main-loop output for emotion parameters.
;; The result should be in the mentioned format with a strict order.

(= (emotionChecker $emotion)
	(unify $emotion (happinessValue $happinessValue sadnessValue $sadnessValue angerValue $angerValue fearValue $fearValue gratitudeValue $gratitude) True False)
)
;;!(kb-initializer &kb)
; !(assertEqual (kb-initializer &kb) ())
; !(assertEqual (isListEmpty (queryAll &kb modulator)) False)
; !(assertEqual (isListEmpty (queryAll &kb rule)) False)
; !(assertEqual (isListEmpty (queryAll &kb demand)) False)
; !(assertEqual (isGoalMet? (report) (Goal mission_complete 1.0 1.0)) True)
; !(assertEqual (isGoalMet? (analyze upload) (Goal analyze_data 1 1)) False)
; !(assertEqual (emotionChecker (psi-agent-loop init &kb)) True)
; !(assertEqual (demandSelector ((demand Affiliation 3) (demand Concept 4) (demand Car 8))) (demand Car 8))
;; !(psi-agent-loop init &kb)


;; !(fearFeelingUpdater &modulator-space)
;; !(happinessFeelingUpdater &modulator-space)

;; !(get-atoms &modulator-space)
