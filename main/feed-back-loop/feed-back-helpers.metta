;;(: remove-atoms' (-> hyperon::space::DynSpace Expression Expression))
(= (remove-atoms' $space $expression)
    (if (== $expression ())
        ()
        (let* (
            (($head $tail) (decons-atom $expression))
            ($_  (remove-atom $space $head))
           ($rem (collapse (get-atoms $space)))
           ;;($_ (println! (remaining-atoms $rem)))
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
;;(: remove-occurrences (-> hyperon::space::DynSpace Expression Expression)) 
(= (remove-occurrences $space $pattern)
   	(let* (
            ($atoms (collapse (match $space $pattern $pattern)))
            ($_ (println! (atoms-to-remove $atoms)))
           ) 
	  	(remove-atoms' $space $atoms)))

;;The below function is used to synchronize two atomspaces for having the same
;;Replicated value. The updater space belongs to the mind-agent while the atomspace to be synchronized is the 
;; knowledge base atomspace.
(: update-atoms (-> Expression hyperon::space::DynSpace hyperon::space::DynSpace Expression ))
(= (update-atoms $pattern $updater $updated)
   	(let* (
	       ($updater-atoms (collapse (get-atoms $updater)))
	       ($rem-res (remove-occurrences $updated $pattern))
           ($atoms (collapse (get-atoms $updated)))
            ($res (collapse (add-atoms $updated $updater-atoms)))
    
	       )
	  	()	
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
;; This function can be replaced with a semantic network it relates goal to demand.

(= (goalSelector $demand)
   (case $demand(
		 ((demand affiliation $y) (Goal mission_complete 1.0 1.0))
		((demand competence $x) (Goal mission_complete 1.0 1.0))
        ((demand energy $x) (Goal mission_complete 1.0 1.0))
	)
)
)

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

;; This function implements the kb-initializer for the open-psi loop to work
(: kb-initializer (-> hyperon::space::DynSpace Expression))
(= (kb-initializer $kb)
   (let* (
	  	($rules (collapse (get-atoms &rule-space)))
		($modulators (collapse (get-atoms &modulator-space)))
		($demands (collapse (get-atoms &demandspace)))
		($partialKb (union-atom $rules $modulators))
		($kbExp (union-atom $partialKb $demands))
		($_ (collapse (add-atoms $kb $kbExp)))
	)
     		()
    
	)
)