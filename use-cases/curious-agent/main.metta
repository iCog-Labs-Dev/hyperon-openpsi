!(register-module! ../../../hyperon-openpsi)
!(import! &self utils) 
!(import! &self hyperon-openpsi:main:feed-back-loop:feed-back-loop)
!(import! &self hyperon-openpsi:main:modulator:modulator)
!(import! &self hyperon-openpsi:main:demand:demand)
!(import! &self hyperon-openpsi:main:mind-agents:feeling-updater:feeling-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:modulator-updater:modulator-updaters)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v1)
!(import! &self hyperon-openpsi:psi-utilities:psi_utils)
!(import! &self hyperon-openpsi:psi-utilities:normalization)
!(import! &self hyperon-openpsi:use-cases:curious-agent:setup-kb)

!(register-module! ../../utilities-module)
!(import! &self utilities-module:utils)

;; This function implements the kb-initializer for the open-psi loop to work
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

(= (loop $emotionVals) 
   (let* (
        ($userInput (pyModule getUserInput ()))
        ($response (pyModule generateResponse ($userInput $emotionVals)))
        ($summary (extractSummary $response))
        ;;($rules (collapse (get-atoms &ruleSpace)))
        ($rules (queryAll &kb rule))
        ($rule (pyModuleX correlation_matcher ($summary $rules $userInput)))
        (((: $handle ($tv (IMPLICATION_LINK (AND_LINK ((Goal $context $x $y) $action)) $goal))) $wght) $rule)
        ($emotion (psi-agent-loop $context &kb))
        ;(() (println! $emotion))
      )
      (
        if(== $userInput "exit")
          ()
          (loop $emotion)
      )
    )
   )

(= (extractSummary $response) 
   (let* (
          ($messages ((py-dot $response get) "messages" ""))
          ($summary ((py-dot $response get) "summary" ""))
        )
        $summary
     )
   )

!(addDemandGoalRels &kb)
!(populateRuleSpace &ruleSpace)
!(populateDemandSpace &demandspace)
!(insert-modulators &modulator-space)
!(kb-initializer &kb)

!(loop (happinessValue 0.5 sadnessValue 0.039 angerValue 0.2 fearValue 0.04 gratitudeValue 0.6))
