!(register-module! ../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v1)

!(addRulesToSpace &ruleSpace)
!(assertEqual (getWeightFromRule ((: r1 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 2)) 2)
!(assertEqual (getWeightFromRule ((: r2 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 3)) 3)
!(assertEqual (selectSingleAction (()) 1.0) (() ()))
!(assertEqual (selectActionFromRule ((: r1 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 2)) explore)
!(assertEqual (selectSingleAction (collapse (get-atoms &ruleSpace)) 10) (((: r4 ((TTV 1 (STV 0.65 0.6)) (IMPLICATION_LINK (AND_LINK ((Goal task_done 1 1) report)) (Goal mission_complete 1 1)))) 10) report))
!(assertEqual (findRulesWithGoalAsContext &ruleSpace low_energy) ())
!(assertEqual (findRulesWithGoalAsContext &ruleSpace found_target) (((: r2 ((TTV 1 (STV 0.75 0.65)) (IMPLICATION_LINK (AND_LINK ((Goal found_target 1 1) approach)) (Goal near_target 1 1)))) 3)))
!(assertEqual (planner &ruleSpace init  mission_complete) (explore approach interact report))
        
