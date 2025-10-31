(= (clear-space $space) (
	let $atoms  (get-atoms $space)
        (remove-atom $space $atoms)
))

;; Remove The remove occurrences function removes values based on a given 
;;pattern for instance a perception updater value can be stored as 
;;(perception value time)
(: remove-occurrences (-> hyperon::space::DynSpace Expression Expression)) 
(= (remove-occurrences $space $pattern)
   	(collapse(let* (
            ($atoms (match $space $pattern $pattern))
           ) 
	  	(remove-atom $space $atoms))
))

(= (add-atoms $space $values)
	(add-reduct $space (superpose $values)
))

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
(= (update-all $tag $updater $updated) (
	case $tag (
              (demand (update-atoms (demand $name $min $max $val) $updater $updated))
              (modulator (update-atoms (modulator $x $y) $updater $updated))
        )
))

(= (query $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $cumm-weight))
   	(collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $cumm-weight)
	       ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $cumm-weight))

))
(= (query $space (modulator $x $y)) (collapse (match $space (modulator $x $y) (modulator $x $y))))
(= (query $space (perception $x $y)) (collapse (match $space (perception $x $y) (perception $x $y))))
(= (query $space (demand $name $min $max $val)) (collapse (match $space (demand $name $min $max $val) (demand $name $min $max $val))))

(: queryAll (-> hyperon::space::DynSpace Symbol Expression))
(= (queryAll $space $type) (
	case $type (
	       (modulator (query $space (modulator $x $y)))
	       (perception (query $space (perception $x $y)))
	       (demand (query $space (demand $name $min $max $val)))
	       (rule (query $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $cumm-weight)))
	       ($_ (Error "This form doesn't exist in the atomspace"))
	    )
))

;; A one to one relationship between a demand and a goal.
;; This goal selector maps from the demand and applies the goal to it
;; This is an unfinished function
(= (goalSelector $demandName) (
	case $demandName (
		(affiliation (Goal mission_complete 1.0 1.0))
		(competence (Goal mission_complete 1.0 1.0))
        (energy (Goal mission_complete 1.0 1.0))
	)
))

;;(: applyActions (-> Expression Goal Expression Expression))
(= (applyActions $actions $goal $demand $ruleSpace) 
   (if (== $actions ())
     		()
		(let $isGoalMet? (isGoalMet? $actions $goal $ruleSpace)
		  	(if $isGoalMet?
                (let* (
                       ($_ (println! (goalMet $isGoalMet?)))
                       ((demand $demandName $minVal $maxVal $demandValue) $demand)
					   ($newDemValue (+ $demandValue (* (- 1 $demandValue) 0.5)))
                )
			  	    (updateDemandValue &demandspace $demandName $newDemValue)
                )
				()
			)
)))

(: selectRuleByAction (-> hyperon::space::DynSpace Symbol Expression)) 
(= (selectRuleByAction $ruleSpace $action)
   	(collapse (match $ruleSpace ((:$handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $val) ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $val))))

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
(: isGoalMet? (-> Expression Goal hyperon::space::DynSpace Bool))
(= (isGoalMet? $actions $goal $ruleSpace)
	(let* (
	       ($length (size-atom $actions))
	       ($lastAction (index-atom $actions (- $length 1)))
	       ($rules' (findRulesWithAction $ruleSpace $lastAction))
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

