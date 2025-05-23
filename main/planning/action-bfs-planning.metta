 
;; so what are the things that are known in prior
;; 1. An agent knows the current context it is in.
;; 2. An agent knows the goal it shall achieve. Should involve in some kind of searching mechanism
;; 3. There is a rule space that contains all the necessary cognitive schema. This is expected 
;; to be mined by the pattern miner.
;; 4. Since the agent knows its initial state, it will start 
;; from there and search rules that begins with the initial state.
;; 5. Hence, the agent selects the rule with the best metric.
;; 6. Then it selects the action from the rule and adds it to an accumulator.
;; 7. Then it starts from the goal as a context from the rule that is selected.
!(bind! &ruleSpace (new-space))


(= (addRulesToSpace $space)
    (add-reduct $space (superpose (
            
((: r1 ((TTV 1 (STV 0.8 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.9 0.6) explore)) 
          (Goal found_target 1.0 1.0)))) 2)

;; r2: Approach after finding target
((: r2 ((TTV 1 (STV 0.75 0.65)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal found_target 1.0 1.0) approach)) 
          (Goal near_target 1.0 1.0)))) 3)

;; r3: Interact when near
((: r3 ((TTV 1 (STV 0.7 0.6)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal near_target 1.0 1.0) interact)) 
          (Goal task_done 1.0 1.0)))) 2)

;; r4: Report task done
((: r4 ((TTV 1 (STV 0.65 0.6)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal task_done 1.0 1.0) report)) 
          (Goal mission_complete 1.0 1.0)))) 10)

;; r5: Do nothing and become low energy
((: r5 ((TTV 1 (STV 0.5 0.5)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.8 0.5) idle)) 
          (Goal low_energy 1.0 1.0)))) 1)

;; r6: Analyze after mission complete
((: r6 ((TTV 1 (STV 0.75 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal mission_complete 0.9 0.7) analyze)) 
          (Goal analyze_data 1.0 1.0)))) 4)

;; r7: Upload results after analysis
((: r7 ((TTV 1 (STV 0.7 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal analyze_data 0.85 0.7) upload)) 
          (Goal upload_results 1.0 1.0)))) 2)

;; r8: Reboot after upload
((: r8 ((TTV 1 (STV 0.9 0.8)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal upload_results 0.95 0.75) reboot)) 
          (Goal reset_system 1.0 1.0)))) 1)

            )
        )
    )

)
;;gets weights from rule
(= (getWeightFromRule $rule)
    (let ($schema $weight) $rule $weight)
)
;; The below function extracts an action from a cognitive schema.
;; The input will be a scalar weighted rule and returns an action. 
(= (selectActionFromRule $rule)
    (let* (
        (($schema $weight) $rule)
        ($schema (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
    )
        $action
    )
)
;; select single action from available rules. 
(= (selectSingleActionHelper $rulesWithWeight $minValue $currAction $targetValue)
    (if (== $rulesWithWeight ())
        (let $handleWithAction (findRulesWithAction &ruleSpace $currAction) ;; a temporary solution
            ((car-atom $handleWithAction) $currAction)

        )
        (let* (
            ($currRule (car-atom $rulesWithWeight))
            ($tail (cdr-atom $rulesWithWeight))
            ($weight (getWeightFromRule $currRule))
            ($ruleAction (selectActionFromRule $currRule))
            ($range (- $targetValue $weight))
        )
            (if (< $range (- $targetValue $minValue))
                (selectSingleActionHelper $tail $weight $ruleAction $targetValue)
                (selectSingleActionHelper $tail $minValue $currAction $targetValue)
            )
        )

    )
    
)

;; This functions selects a single action from a list of rules
;; That are going to be implemented in relation to a target value.
(= (selectSingleAction $rulesWithWeight $targetValue)
    (if (or (== $rulesWithWeight ()) (== $rulesWithWeight (())))
        (() ())
        (let* (
            ($head (car-atom $rulesWithWeight))
            ($action (selectActionFromRule $head))
            ($weight (getWeightFromRule $head))
        )
            (selectSingleActionHelper $rulesWithWeight $weight $action $targetValue)
        )
    )
)

;; This function might require further modification later.
(= (findRulesWithContext $space $context)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $weight) 
    ))

)
;; finds rules with goals as contexts
(= (findRulesWithGoalAsContext $space $goal)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $goal $x $y) $action)) $nextGoal))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ((Goal $goal $x $y) $action)) $nextGoal))) $weight) 
    ))

)
;; finds rules with similar actions
(= (findRulesWithAction $space $action)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        
    ))

)
;; This function fetches rules for multiple goals given as an s-expression. 
(= (findRulesForMultipleGoals $space $goals $accum)
    (if (== $goals ())
        $accum
        (let* (
            (($head $tail) (decons-atom $goals))
            ($goalName (extractGoalName $head))
            ($rules (findRulesWithGoalAsContext $space $goalName))
            ($newAccum (union-atom $accum $rules))
        )  
            (findRulesForMultipleGoals $space $tail $newAccum)
        )
    )
)
;; filters rules with the same goal name.
(= (findRulesWithGoal $space $goal)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) (Goal $goal $x $y)))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) (Goal $goal $x $y)))) $weight)
        
    ))
)

(= (getDgv $goal)
    (let (Goal $name $x $y) $goal $y)
)

(= (extractGoalName $goal)
    (let (Goal $name $x $y) $goal $name)
)

(= (extractGoalFromRule $rule)
    (let ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight) $rule $goal)

)

(= (extractContextFromRule $rule)
    (let ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight) $rule $context)
)
;; an implementation inspired that greedily selects 
;; an action at each step.
(= (planner' $ruleSpace $initState $goal $target $accum)
    (if (== $initState $goal)
        $accum
        (let* (
            ($relatedRules (findRulesWithContext $ruleSpace $initState))
            ($_ (println! (relatedRules $relatedRules)))
            (($rule $currAction) (selectSingleAction $relatedRules $target))
            ($_ (println! (rule $rule action $currAction)))
            ($accum' (if (== $currAction ()) $accum (union-atom $accum ($currAction))))
            ($goals (collapse (extractGoalFromRule (superpose $relatedRules))))
            ($nextRules (findRulesForMultipleGoals $ruleSpace $goals ()))
            ($_ (println! (goals $goals nextRules $nextRules)))
            (($currRule $action) (selectSingleAction $nextRules $target))
            ($_ (println! (currRule $currRule action $action)))
            
        )
            (if (== $action ())
                $accum'
                (let* (
                    ($newAccum (union-atom $accum' ($action))) ;; accumulating actions in the action accumulator.
                    ($newState (extractGoalFromRule $currRule))
                    ($stateName (extractGoalName $newState))         
                )
                    (planner' $ruleSpace $stateName $goal $target $newAccum)
                )
            )

        )        
    )
)
(= (planner $ruleSpace $initState $goal)
    (let* (
        
        ($targetRules (findRulesWithGoal $ruleSpace $goal))
        ($_ (println! (targetRules $targetRules)))
        ($targetRule (car-atom $targetRules))
        ($target (getWeightFromRule $targetRule))
        ($_ (println! (targetRules $targetRules target $target)))
        
    )
        (planner' $ruleSpace $initState $goal $target ())

    )
)


 
