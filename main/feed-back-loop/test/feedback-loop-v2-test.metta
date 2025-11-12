!(register-module! ../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:modulator:modulator)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:modulator-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:tests:modulator-updater-test-helpers)

!(register-module! ../../../utilities-module)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:main:demand:demand)
!(import! &self hyperon-openpsi:main:feed-back-loop:feed-back-helpers)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v1)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v2)
!(import! &self hyperon-openpsi:main:mind-agents:feeling-updater:feeling-updaters)
!(import! &self hyperon-openpsi:psi-utilities:normalization)

!(bind! &kb (new-space))
!(bind! &modulator-space (new-space))
!(bind! &demandSpace (new-space))

(= (addRulesToTestSpace $space)
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

    ))
))
!(addRulesToTestSpace &ruleSpace)
!(insert-modulators &modulator-space)

!(addDemand &demandSpace energy -10 10 -15)
!(addDemand &demandSpace affiliation -10 10 5)
!(addDemand &demandSpace competence -10 10 0)

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
			(selectMaxRule $tail $maxRule)
			(selectMaxRule $tail $rule)
		)
)))


;; This function implements the kb-initializer for the open-psi loop to work
(: kb-initializer (-> hyperon::space::DynSpace Expression))
(= (kb-initializer $kb)
   (let* (
	  	 ($rules (collapse (get-atoms &ruleSpace)))
		($modulators (collapse (get-atoms &modulator-space)))
		($demands (collapse (get-atoms &demandSpace)))
		($partialKb (union-atom $rules $modulators))
		($kbExp (union-atom $partialKb $demands))
		($_ (collapse (add-atoms $kb $kbExp)))
	)
     		()
    
	)
)

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

(= (isListEmpty $list)
	(if (== (size-atom $list) 0) True False)
)

(= (emotionChecker $emotion)
	(unify $emotion (happinessValue $happinessValue sadnessValue $sadnessValue angerValue $angerValue fearValue $fearValue gratitudeValue $gratitude) True False)
)

(: random (-> Number Number Number))
(= (random $x $y) 0.2) ;; For deterministic testing only


!(assertEqual (kb-initializer &kb) ())
!(assertEqual (isListEmpty (queryAll &kb modulator)) False)
!(assertEqual (isListEmpty (queryAll &kb rule)) False)
!(assertEqual (isListEmpty (queryAll &kb demand)) False)
!(assertEqual (emotionChecker (psi-loop-v2 init &kb)) True)

;; Uncomment the following lines to run psi-agent-loop
;; !(kb-initializer &kb)
;; !(psi-agent-loop init &kb)
