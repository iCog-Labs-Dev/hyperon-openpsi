!(register-module! ../../../../../hyperon-openpsi)
!(register-module! ../../../../utilities-module)

!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v2)
!(bind! &ruleSpace (new-space))

;; Test
(= (addRulesToSpace $space)
    (add-reduct $space (superpose 
(
            
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

!(addRulesToSpace &ruleSpace)

;!(get-atoms &ruleSpace)
;!(assertEqual (hillClimbingPlanner init mission_complete (TestedActions) () &ruleSpace) (explore approach interact report))
;!(assertEqual (hillClimbingPlanner init task_done (TestedActions) () &ruleSpace) (explore approach interact))
